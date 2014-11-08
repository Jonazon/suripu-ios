//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <SenseKit/BLE.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMSensePairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMUserDataCache.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMActivityCoverView.h"

// I've tested the scanning process multiple times starting with a timeout of
// 15 to 20.  Out of say 5 tries, I've seen it return in time once.  30 secs
// seem to allow the response to return in time reliably.
static CGFloat const kHEMSensePairScanTimeout = 30.0f;

@interface HEMSensePairViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothLogo;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyButtonWidthConstraint;

@property (strong, nonatomic) SENSenseManager* manager;
@property (copy,   nonatomic) NSString* disconnectObserverId;
@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (assign, nonatomic, getter=isTimedOut) BOOL timedOut;

@end

@implementation HEMSensePairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDescription];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBPairSense];
}

- (void)setupDescription {
    NSString* desc = NSLocalizedString(@"sense-pair.description", nil);
    
    NSMutableAttributedString* attrDesc = [[NSMutableAttributedString alloc] initWithString:desc];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    
    [[self descLabel] setAttributedText:attrDesc];
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self logoVSpaceConstraint] withDiff:diff];
    [self updateConstraint:[self readyVSpaceConstraint] withDiff:diff];
}

- (void)stopActivityWithMessage:(NSString*)message completion:(void(^)(void))completion {
    [[self activityView] dismissWithResultText:message remove:YES completion:^{
        [[self noSenseButton] setEnabled:YES];
        if (completion) completion ();
    }];
}

- (void)cacheManager {
    [[HEMUserDataCache sharedUserDataCache] setSenseManager:[self manager]];
}

- (void)disconnectSense {
    if ([self manager] != nil) {
        if ([self disconnectObserverId] != nil) {
            [[self manager] removeUnexpectedDisconnectObserver:[self disconnectObserverId]];
            [self setDisconnectObserverId:nil];
        }
        [[self manager] disconnectFromSense];
    }
}

- (void)observeUnexpectedDisconnects {
    __weak typeof(self) weakSelf = self;
    self.disconnectObserverId =
        [[self manager] observeUnexpectedDisconnect:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf stopActivityWithMessage:nil completion:^{
                    NSString* message = NSLocalizedString(@"pairing.error.unexpected-disconnect", nil);
                    NSString* title = NSLocalizedString(@"pairing.failed.title", nil);
                    [strongSelf showMessageDialog:message title:title];
                }];
            }
        }];
}

#pragma mark - Actions

- (IBAction)enablePairing:(id)sender {
    [self scanForSense];
}

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
}

#pragma mark - Scanning

- (void)scanTimeout {
    DDLogVerbose(@"scanning for Sense timed out, oh no!");
    [self setTimedOut:YES];
    [SENSenseManager stopScan];
    [self stopActivityWithMessage:nil completion:^{
        NSString* msg = NSLocalizedString(@"pairing.error.timed-out", nil);
        [self showErrorMessage:msg];
    }];
    [SENAnalytics track:kHEMAnalyticsEventError
             properties:@{kHEMAnalyticsEventPropMessage : @"scanning timed out"}];
}

- (void)scanForSense {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    [self setTimedOut:NO];
    [[self noSenseButton] setEnabled:NO];
    
    NSString* activityMessage = NSLocalizedString(@"pairing.activity.scanning-sense", nil);
    UIView* viewToAttach = [[self navigationController] view];
    [[self activityView] showInView:viewToAttach withText:activityMessage activity:YES completion:^{
        [self startScan];
        [self performSelector:@selector(scanTimeout)
                   withObject:nil
                   afterDelay:kHEMSensePairScanTimeout];
    }];
    
}

- (void)startScan {
    // always rescan in case the user has moved or changed Sense globes or
    // whatever the reason is, that would cause a cache of the Sense object
    // or manager to cause issues.
    DDLogVerbose(@"scanning for sense");
    __weak typeof(self) weakSelf = self;
    if (![SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && ![strongSelf isTimedOut]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf
                                                     selector:@selector(scanTimeout)
                                                       object:nil];
            if ([senses count] > 0) {
                // per team consensus, it is expected that the app pairs with the
                // first sense with the highest average RSSI value that is found.
                // In our case, the first object matches that spec.
                [strongSelf pairWith:[senses firstObject]];
                DDLogVerbose(@"sense found, %@", [[strongSelf manager] sense]);
            } else {
                [SENAnalytics track:kHEMAnalyticsEventError
                         properties:@{kHEMAnalyticsEventPropMessage : @"no sense found"}];
                
                [strongSelf stopActivityWithMessage:nil completion:^{
                    NSString* msg = NSLocalizedString(@"pairing.error.sense-not-found", nil);
                    [strongSelf showErrorMessage:msg];
                }];
            }
        }
    }]) {
        [self performSelector:@selector(startScan)
                   withObject:nil
                   afterDelay:0.1f];
    }
}

#pragma mark - Pairing

- (void)pairWith:(SENSense*)sense {
    [self disconnectSense]; // in case one has been set
    [self setManager:[[SENSenseManager alloc] initWithSense:sense]];
    [self observeUnexpectedDisconnects];

    NSString* activityMessage = NSLocalizedString(@"pairing.activity.pairing-sense", nil);
    [[self activityView] updateText:activityMessage completion:nil];
    DDLogVerbose(@"pairing with sense %@", [sense name]);
    
    __weak typeof(self) weakSelf = self;
    [[self manager] pair:^(id response) {
        DDLogVerbose(@"paired!");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && ![strongSelf isTimedOut]) {
            [strongSelf cacheManager];

            if ([[HEMUserDataCache sharedUserDataCache] settingUpSecondPill]) {
                [strongSelf linkAccount];
            } else {
                [strongSelf finish];
            }

        }
    } failure:^(NSError *error) {
        DDLogVerbose(@"failed to pair %@", error);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && ![strongSelf isTimedOut]) {
            [strongSelf stopActivityWithMessage:nil completion:^{
                NSString* msg = NSLocalizedString(@"pairing.error.could-not-pair", nil);
                [strongSelf showErrorMessage:msg];
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            }];
        }
    }];
}

- (void)finish {
    NSString* msg = NSLocalizedString(@"pairing.done", nil);
    __weak typeof(self) weakSelf = self;
    [self stopActivityWithMessage:msg completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf next];
        }
    }];
}

#pragma mark - Link Account

- (void)linkAccount {
    NSString* accessToken = [SENAuthorizationService accessToken];
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    
    __weak typeof(self) weakSelf = self;
    [manager linkAccount:accessToken success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf finish];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf stopActivityWithMessage:nil completion:^{
                NSString* msg = NSLocalizedString(@"pairing.error.link-account-failed", nil);
                [strongSelf showErrorMessage:msg];
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            }];
        }
        
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }];
}

#pragma mark - Errors

- (void)showErrorMessage:(NSString*)message {
    [self showMessageDialog:message title:NSLocalizedString(@"pairing.failed.title", nil)];
}

#pragma mark - Navigation

- (void)next {
    NSString* segueId = nil;
    if ([[HEMUserDataCache sharedUserDataCache] settingUpSecondPill]) {
        segueId = [HEMOnboardingStoryboard senseToPillSegueIdentifier];
    } else {
        segueId = [HEMOnboardingStoryboard wifiSegueIdentifier];
    }
    
    [self performSegueWithIdentifier:segueId sender:self];
}

#pragma mark - Clean up

- (void)dealloc {
    [SENSenseManager stopScan];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
