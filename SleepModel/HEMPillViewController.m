//
//  HEMPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENDevice.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMPillViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMCardFlowLayout.h"
#import "HEMDeviceActionCollectionViewCell.h"
#import "HEMActivityCoverView.h"
#import "HEMSupportUtil.h"
#import "HEMWarningCollectionViewCell.h"
#import "HEMAlertViewController.h"
#import "HEMDeviceDataSource.h"
#import "HEMActionButton.h"
#import "HEMActionSheetViewController.h"

static NSInteger const HEMPillActionsCellHeight = 124.0f;

@interface HEMPillViewController() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMActivityCoverView* activityView;

@end

@implementation HEMPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [SENAnalytics track:kHEMAnalyticsEventPill];
}

- (void)configureCollectionView {
    [[self collectionView] setDataSource:self];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (NSAttributedString*)redMessage:(NSString*)message {
    NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor redColor]};
    return [[NSAttributedString alloc] initWithString:message attributes:attributes];
}

- (NSAttributedString*)attributedLongLastSeenMessage {
    NSString* format = NSLocalizedString(@"settings.pill.warning.last-seen-format", nil);
    NSString* lastSeen = [[[[SENServiceDevice sharedService] pillInfo] lastSeen] timeAgo];
    NSArray* args = @[[self redMessage:lastSeen ?: NSLocalizedString(@"settings.device.warning.last-seen-generic", nil)]];
    
    NSMutableAttributedString* attrWarning =
        [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedLowBatteryMessage {
    NSString* format = NSLocalizedString(@"settings.pill.warning.low-battery-format", nil);
    NSString* batteryLow = NSLocalizedString(@"settings.pill.warning.battery-low", nil);
    NSArray* args = @[[self redMessage:batteryLow]];
    
    NSMutableAttributedString* attrWarning =
    [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    [attrWarning addAttributes:@{NSFontAttributeName : [UIFont deviceCellWarningMessageFont]}
                         range:NSMakeRange(0, [attrWarning length])];
    
    return attrWarning;
}

- (NSAttributedString*)attributedMessageForWarning:(HEMDeviceWarning)warning {
    NSAttributedString* message = nil;
    switch (warning) {
        case HEMDeviceWarningLongLastSeen:
            message = [self attributedLongLastSeenMessage];
            break;
        case HEMPillWarningHasLowBattery:
            message = [self attributedLowBatteryMessage];
            break;
        default:
            break;
    }
    return message;
}

- (NSDictionary*)dialogMessageAttributes:(BOOL)bold {
    return @{NSFontAttributeName : bold ? [UIFont dialogMessageBoldFont] : [UIFont dialogMessageFont],
             NSForegroundColorAttributeName : [UIColor blackColor]};
}

- (CGFloat)heightForWarning:(HEMDeviceWarning)warning withDefaultItemSize:(CGSize)size {
    NSAttributedString* message = [self attributedMessageForWarning:warning];
    CGRect bounds = [message boundingRectWithSize:CGSizeMake(size.width, MAXFLOAT)
                                          options:NSStringDrawingUsesFontLeading
                     |NSStringDrawingUsesLineFragmentOrigin
                                          context:nil];
    return CGRectGetHeight(bounds);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[self warnings] count] + 1; // actions always available
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* reuseId
        = [indexPath row] < [[self warnings] count]
        ? [HEMMainStoryboard warningReuseIdentifier]
        : [HEMMainStoryboard actionsReuseIdentifier];
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMDeviceActionCollectionViewCell class]]) {
        HEMDeviceActionCollectionViewCell* actionCell = (HEMDeviceActionCollectionViewCell*)cell;
        [[actionCell action1Button] addTarget:self
                                       action:@selector(replaceBattery:)
                             forControlEvents:UIControlEventTouchUpInside];
        [[actionCell action2Button] addTarget:self
                                       action:@selector(showAdvancedOptions:)
                             forControlEvents:UIControlEventTouchUpInside];
    } else if ([cell isKindOfClass:[HEMWarningCollectionViewCell class]]) {
        HEMDeviceWarning warning = (HEMDeviceWarning)[[self warnings][[indexPath row]] integerValue];
        HEMWarningCollectionViewCell* warningCell = (HEMWarningCollectionViewCell*)cell;
        [[warningCell warningMessageLabel] setAttributedText:[self attributedMessageForWarning:warning]];
        [[warningCell actionButton] setTitle:[NSLocalizedString(@"actions.troubleshoot", nil) uppercaseString]
                                    forState:UIControlStateNormal];
        [[warningCell actionButton] setTag:warning];
        [[warningCell actionButton] addTarget:self
                                       action:@selector(takeWarningAction:)
                             forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMCardFlowLayout* layout = (HEMCardFlowLayout*)collectionViewLayout;
    CGSize size = [layout itemSize];
    if ([indexPath row] < [[self warnings] count]) {
        HEMDeviceWarning warning = [[self warnings][[indexPath row]] integerValue];
        NSAttributedString* message = [self attributedMessageForWarning:warning];
        CGRect bounds = [message boundingRectWithSize:CGSizeMake(size.width, MAXFLOAT)
                                              options:NSStringDrawingUsesFontLeading
                                                     |NSStringDrawingUsesLineFragmentOrigin
                                              context:nil];
        size.height = CGRectGetHeight(bounds) + HEMWarningCellBaseHeight;
    } else if ([indexPath row] == [[self warnings] count]) {
        size.height = HEMPillActionsCellHeight;
    }
    return size;
}

#pragma mark - Actions

- (void)takeWarningAction:(UIButton*)sender {
    HEMDeviceWarning warning = [sender tag];
    switch (warning) {
        case HEMDeviceWarningLongLastSeen: {
            NSString* page = NSLocalizedString(@"help.url.slug.pill-not-seen", nil);
            [HEMSupportUtil openHelpToPage:page fromController:self];
            break;
        }
        case HEMPillWarningHasLowBattery: {
            [self replaceBattery:self];
            break;
        }
        default:
            break;
    }
}

- (void)showAdvancedOptions:(id)sender {
    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [sheet setTitle:NSLocalizedString(@"settings.pill.advanced.option.title", nil)];
    
    __weak typeof (self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"settings.pill.advanced.option.replace-pill", nil)
                   titleColor:nil
                  description:NSLocalizedString(@"settings.pill.advanced.option.replace-pill.desc", nil)
                       action:^{
                           [weakSelf replacePill];
                       }];
    
    UIViewController* root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [root presentViewController:sheet animated:YES completion:^{
        [sheet show];
    }];
}

- (void)replaceBattery:(id)sender {
    NSString* page = NSLocalizedString(@"help.url.slug.pill-battery", nil);
    [HEMSupportUtil openHelpToPage:page fromController:self];
}

#pragma mark - Unpairing the pill

- (void)replacePill {
    NSString* title = NSLocalizedString(@"settings.pill.dialog.unpair-title", nil);
    NSString* messageFormat = NSLocalizedString(@"settings.pill.dialog.unpair-message.format", nil);
    NSString* helpLink = NSLocalizedString(@"help.url.support", nil);
    
    NSArray* args = @[[[NSAttributedString alloc] initWithString:helpLink
                                                      attributes:[self dialogMessageAttributes:YES]]];
    
    NSAttributedString* confirmation =
    [[NSMutableAttributedString alloc] initWithFormat:messageFormat
                                                 args:args
                                            baseColor:[UIColor blackColor]
                                             baseFont:[UIFont dialogMessageFont]];
    
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setAttributedMessage:confirmation];
    [dialogVC setDefaultButtonTitle:NSLocalizedString(@"actions.no", nil)];
    [dialogVC setViewToShowThrough:self.view];
    [dialogVC addAction:NSLocalizedString(@"actions.yes", nil) primary:NO actionBlock:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [self unpair];
        }];
    }];
    [dialogVC onLinkTapOf:helpLink takeAction:^(NSURL *link) {
        [self dismissViewControllerAnimated:YES completion:^{
            [HEMSupportUtil openHelpFrom:self];
        }];
    }];
    [dialogVC showFrom:self onDefaultActionSelected:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)showUnpairMessageForError:(NSError*)error {
    NSString* message = nil;
    switch ([error code]) {
        case SENServiceDeviceErrorSenseUnavailable:
            message = NSLocalizedString(@"settings.pill.unpair-no-sense-found", nil);
            break;
        case SENServiceDeviceErrorSenseNotPaired:
            message = NSLocalizedString(@"settings.pill.dialog.no-paired-sense-message", nil);
            break;
        case SENServiceDeviceErrorUnpairPillFromSense:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unpair-from-sense", nil);
            break;
        case SENServiceDeviceErrorUnlinkPillFromAccount:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unlink-from-account", nil);
            break;
        default:
            message = NSLocalizedString(@"settings.pill.dialog.unable-to-unpair", nil);
            break;
    }

    NSString* title = NSLocalizedString(@"settings.pill.unpair-error-title", nil);
    [HEMAlertViewController showInfoDialogWithTitle:title message:message controller:self];
}

- (void)unpair {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    if ([[self delegate] respondsToSelector:@selector(willUnpairPillFrom:)]) {
        [[self delegate] willUnpairPillFrom:self];
    }
    
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceActionUnpairPill}];
    
    id<UIApplicationDelegate> delegate = (id)[UIApplication sharedApplication].delegate;
    UIViewController* root = (id)delegate.window.rootViewController;
    
    NSString* message = NSLocalizedString(@"settings.pill.unpairing-message", nil);
    [[self activityView] showInView:[root view] withText:message activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        [[SENServiceDevice sharedService] unpairSleepPill:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    [strongSelf showUnpairMessageForError:error];
                }];
            } else {
                if ([[strongSelf delegate] respondsToSelector:@selector(didUnpairPillFrom:)]) {
                    [[strongSelf delegate] didUnpairPillFrom:strongSelf];
                }
                NSString* success = NSLocalizedString(@"settings.pill.unpaired-message", nil);
                [[strongSelf activityView] dismissWithResultText:success showSuccessMark:YES remove:YES completion:nil];
            }
        }];
    }];

}

@end
