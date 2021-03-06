//
//  HEMSystemAlertPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENSystemAlert.h>

#import "HEMSystemAlertPresenter.h"
#import "HEMNetworkAlertService.h"
#import "HEMDeviceAlertService.h"
#import "HEMTimeZoneAlertService.h"

#import "HEMAppUsage.h"
#import "HEMSupportUtil.h"
#import "HEMActionView.h"
#import "HEMWifiPickerViewController.h"
#import "HEMPillPairViewController.h"
#import "HEMDevicesViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSettingsStoryboard.h"
#import "HEMDeviceService.h"
#import "HEMSystemAlertService.h"
#import "HEMVoiceService.h"
#import "HEMPillDFUStoryboard.h"
#import "HEMActivityCoverView.h"

typedef NS_ENUM(NSInteger, HEMSystemAlertType) {
    HEMSystemAlertTypeNetwork = 0,
    HEMSystemAlertTypeDevice,
    HEMSystemAlertTypeTimeZone,
    HEMSystemAlertTypeSystem
};

static CGFloat const HEMSystemAlertNetworkCheckDelay = 0.5f;
static CGFloat const HEMSystemAlertRelayoutDuration = 0.2f;
static CGFloat const HEMSystemAlertActivitySuccessDelay = 1.5f;

@interface HEMSystemAlertPresenter() <HEMNetworkAlertDelegate, HEMSensePairingDelegate, HEMPillPairDelegate>

@property (nonatomic, weak) HEMSystemAlertService* sysAlertService;
@property (nonatomic, weak) HEMNetworkAlertService* networkAlertService;
@property (nonatomic, weak) HEMSystemAlertService* alertService;
@property (nonatomic, weak) HEMDeviceAlertService* deviceAlertService;
@property (nonatomic, weak) HEMTimeZoneAlertService* tzAlertService;
@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UIView* alertContainerView;
@property (nonatomic, weak) UIView* topView;
@property (nonatomic, weak) HEMActionView* currentActionView;
@property (nonatomic, weak) HEMActivityCoverView* activityView;

@end

@implementation HEMSystemAlertPresenter

- (instancetype)initWithNetworkAlertService:(HEMNetworkAlertService*)networkAlertService
                         deviceAlertService:(HEMDeviceAlertService*)deviceAlertService
                       timeZoneAlertService:(HEMTimeZoneAlertService*)tzAlertService
                              deviceService:(HEMDeviceService*)deviceService
                            sysAlertService:(HEMSystemAlertService*)alertService
                               voiceService:(HEMVoiceService*)voiceService {
    self = [super init];
    if (self) {
        _sysAlertService = alertService;
        _networkAlertService = networkAlertService;
        _voiceService = voiceService;
        [_networkAlertService setDelegate:self];
        
        __weak typeof(self) weakSelf = self;
        _deviceAlertService = deviceAlertService;
        [_deviceAlertService observeDeviceChanges:^(HEMDeviceChange change) {
            [weakSelf handleDeviceChange:change];
        }];
        
        _tzAlertService = tzAlertService;
        _deviceService = deviceService;
        
        _enable = YES;
    }
    return self;
}

- (void)bindWithContainerView:(UIView*)containerView below:(UIView*)topView {
    [self setAlertContainerView:containerView];
    [self setTopView:topView];
}

#pragma mark - Handler device changes 

- (void)handleDeviceChange:(HEMDeviceChange)change {
    // I don't see any reason why any device change should not dismiss an alert
    // since user is currently actively taking action and we should let the next
    // check to re-present the alert if it's still a problem
    [self dismissActionView:nil];
}

#pragma mark - Presenter events

- (void)willRelayout {
    [super willRelayout];
    [self relayoutAlertIfShowing];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self runChecks];
}

- (void)userDidSignOut {
    [super userDidSignOut];
    [self dismissActionView:nil];
    [self setEnable:NO];
}

#pragma mark - Action View

- (void)relayoutAlertIfShowing {
    if ([self currentActionView]) {
        [[self currentActionView] setNeedsLayout];
        [UIView animateWithDuration:HEMSystemAlertRelayoutDuration animations:^{
            [[self currentActionView] layoutIfNeeded];
        }];
    }
}

- (HEMActionView*)configureAlertViewWithTitle:(NSString*)title
                                      message:(NSString*)message
                            cancelButtonTitle:(NSString*)cancelTitle
                               fixButtonTitle:(NSString*)fixTitle {
    
    NSDictionary* messageAttributes = [HEMActionView messageAttributes];
    NSAttributedString* attrMessage = [[NSAttributedString alloc] initWithString:message
                                                                      attributes:messageAttributes];
    HEMActionView* alert = [[HEMActionView alloc] initWithTitle:title message:attrMessage];
    [[alert cancelButton] setTitle:[cancelTitle uppercaseString] forState:UIControlStateNormal];
    
    if (fixTitle) {
        [[alert okButton] setTitle:[fixTitle uppercaseString] forState:UIControlStateNormal];
    } else {
        [alert hideOkButton];
    }
    
    return alert;
}

- (void)cancelAlert:(id)sender {
    [self dismissActionView:nil];
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionLater}];
}

- (void)dismissActionViewAfterDelay:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    int64_t delayInSecs = (int64_t)(HEMSystemAlertActivitySuccessDelay * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf dismissActionView:completion];
    });
}

- (void)dismissActionView:(void(^)(void))completion {
    [[self currentActionView] dismiss:YES completion:^{
        [self setCurrentActionView:nil];
        if (completion) {
            completion ();
        }
    }];
}

- (BOOL)canShowAlert {
    return [self isEnable] && ![self currentActionView] && [self alertContainerView];
}

- (void)runChecks {
    __weak typeof(self) weakSelf = self;
    [self showNetworkAlertIfNeeded:^(BOOL shown) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showSystemAlertsIfNeeded:^(BOOL shown) {
            if (!shown) {
                [strongSelf checkDevicesForProblems:^(BOOL alertShown) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf checkTimeZoneProblems];
                }];
            }
        }];
    }];
}

- (void)senseId:(void(^)(NSString* senseId))completion {
    NSString* deviceId = [[[[self deviceService] devices] senseMetadata] uniqueId];
    if (!deviceId) {
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            completion ([[devices senseMetadata] uniqueId]);
        }];
    } else {
        completion (deviceId);
    }
}

#pragma mark - Activity indicator

/**
 * @discussion
 * Completion is not called if activity was not shown, which only happens if there
 * is no alert currently shown
 */
- (void)showActivityOverAlert:(void(^)(BOOL shown))completion {
    if (![self currentActionView]) {
        if (completion) {
            completion (NO);
        }
        return;
    }
    
    [[self activityView] removeFromSuperview]; // if one was showing for some reason
    
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [self setActivityView:activityView];
    [activityView showInView:[self currentActionView] activity:YES completion:^{
        if (completion) {
            completion (YES);
        }
    }];
}

- (void)dismissActivityIfShown:(BOOL)success completion:(void(^)(void))completion {
    NSString* result = success ? NSLocalizedString(@"status.success", nil) : nil;
    [[self activityView] dismissWithResultText:result
                               showSuccessMark:success
                                        remove:YES
                                    completion:completion];
}

#pragma mark - Error

- (void)showError:(NSString*)message {
    [[self errorDelegate] showErrorWithTitle:[[self currentActionView] title]
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

#pragma mark - System alerts

- (void)showSystemAlertsIfNeeded:(void(^)(BOOL shown))completion {
    if (![self canShowAlert]) {
        return completion (NO);
    }
    
    __weak typeof(self) weakSelf = self;
    [[self sysAlertService] getNextAvailableAlert:^(SENSystemAlert * alert, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        BOOL shown = NO;
        if (!error && alert) {
            // for now, we only support unactionable alerts.  once we get more categories
            // of alerts, we may customize actions based on the category
            NSString* okTitle = NSLocalizedString(@"actions.ok", nil);
            NSString* fixTitle = nil;
            if ([alert category] == SENAlertCategoryMuted) {
                fixTitle = NSLocalizedString(@"actions.unmute", nil);
            }
            
            HEMActionView* alertView = [strongSelf configureAlertViewWithTitle:[alert localizedTitle]
                                                                       message:[alert localizedBody]
                                                             cancelButtonTitle:okTitle
                                                                fixButtonTitle:fixTitle];
            
            [alertView setType:HEMSystemAlertTypeSystem];
            [[alertView cancelButton] addTarget:strongSelf
                                         action:@selector(cancelAlert:)
                               forControlEvents:UIControlEventTouchUpInside];
            
            [[alertView okButton] addTarget:strongSelf
                                     action:@selector(unmute)
                           forControlEvents:UIControlEventTouchUpInside];
            
            [alertView showInView:[strongSelf alertContainerView]
                            below:[self topView]
                         animated:YES
                       completion:nil];
            
            [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageSystemAlertShown];
            [strongSelf trackSystemAlertEventForAlert:alert];
            [strongSelf setCurrentActionView:alertView];
            shown = YES;
        }
        
        completion (shown);
    }];
}

- (void)trackSystemAlertEventForAlert:(SENSystemAlert*)alert {
    NSString* type = nil;
    switch ([alert category]) {
        case SENAlertCategoryExpansionUnreachable:
            type = HEMAnalyticsEventSysAlertPropExpUnreachable;
            break;
        case SENAlertCategoryMuted:
            type = HEMAnalyticsEventSysAlertPropMuted;
            break;
        default:
            type = HEMAnalyticsEventSysAlertPropUnknown;
            break;
    }
    [SENAnalytics track:HEMAnalyticsEventSystemAlert
             properties:@{kHEMAnalyticsEventPropType : type}];
}

#pragma mark - Unmute Sense

- (void)unmute {
    __weak typeof(self) weakSelf = self;
    [self showActivityOverAlert:^(BOOL shown) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (shown) {
            void(^update)(NSString* senseId) = ^(NSString* senseId) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                SENSenseVoiceSettings* muteSettings = [SENSenseVoiceSettings new];
                [muteSettings setMuted:@NO];
                
                [[strongSelf voiceService] updateVoiceSettings:muteSettings
                                                    forSenseId:senseId
                                                    completion:^(SENSenseVoiceSettings* updatedSettings) {
                                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                                        if ([updatedSettings isMuted]) {
                                                            DDLogVerbose(@"unable to unmute");
                                                            [strongSelf dismissActivityIfShown:NO completion:^{
                                                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                [strongSelf showError:NSLocalizedString(@"alerts.update.error.unmute-failed", nil)];
                                                            }];
                                                        } else {
                                                            [strongSelf dismissActivityIfShown:YES completion:nil];
                                                            [strongSelf dismissActionViewAfterDelay:nil];
                                                        }
                                                    }];
            };
            
            [strongSelf senseId:^(NSString *senseId) {
                if (!senseId) {
                    // show error
                    DDLogVerbose(@"no device id to unmute with");
                    [strongSelf dismissActivityIfShown:NO completion:^{
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf showError:NSLocalizedString(@"alerts.update.error.no-sense-id", nil)];
                    }];
                } else {
                    update (senseId);
                }
            }];
        }
    }];
    
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionUnmute}];
}

#pragma mark - Time Zone alerts

- (void)checkTimeZoneProblems {
    if (![self canShowAlert]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[self tzAlertService] checkTimeZoneSetting:^(BOOL needsTimeZone) {
        if (needsTimeZone) {
            [weakSelf showTimeZoneWarning];
        }
    }];
}

- (void)showTimeZoneWarning {
    NSString* title = NSLocalizedString(@"alerts.timezone.title", nil);
    NSString* message = NSLocalizedString(@"alerts.timezone.message", nil);
    NSString* cancelTitle = NSLocalizedString(@"actions.later", nil);
    NSString* fixTitle = NSLocalizedString(@"actions.fix-now", nil);
    
    HEMActionView* alert = [self configureAlertViewWithTitle:title
                                                     message:message
                                           cancelButtonTitle:cancelTitle
                                              fixButtonTitle:fixTitle];
    
    [alert setType:HEMSystemAlertTypeTimeZone];
    [[alert cancelButton] addTarget:self
                             action:@selector(cancelAlert:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [[alert okButton] addTarget:self
                         action:@selector(fixTimeZoneNow:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [alert showInView:[self alertContainerView]
                below:[self topView]
             animated:YES
           completion:nil];
    
    [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageSystemAlertShown];
    
    [SENAnalytics track:HEMAnalyticsEventSystemAlert
             properties:@{kHEMAnalyticsEventPropType : @"time zone"}];
    
    [self setCurrentActionView:alert];
}

- (void)fixTimeZoneNow:(id)sender {
    [self dismissActionView:^{
        UIViewController* tzVC = [HEMSettingsStoryboard instantiateTimeZoneNavViewController];
        [[self delegate] presentViewController:tzVC from:self];
    }];
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionNow}];
}

#pragma mark - Device alerts

- (NSString*)analyticsPropertyTypeValueForDeviceState:(HEMDeviceAlertState)state {
    switch (state) {
        case HEMDeviceAlertStatePillLowBattery:
            return @"pill has low battery";
        case HEMDeviceAlertStatePillNotPaired:
            return @"pill is not paired";
        case HEMDeviceAlertStatePillNotSeen:
            return @"pill has not been seen for awhile";
        case HEMDeviceAlertStateSenseNotSeen:
            return @"sense has not been seen for awhile";
        case HEMDeviceAlertStateSenseNotPaired:
            return @"sense is not paired";
        case HEMDeviceAlertStatePillFirmwareUpdate:
            return @"pill firmware update available";
        default:
            return @"unknown";
    }
}

- (void)checkDevicesForProblems:(void(^)(BOOL alertShown))completion {
    if (![self canShowAlert]) {
        completion (NO);
        return;
    }
    
    DDLogVerbose(@"checking for device problems");
    __weak typeof(self) weakSelf = self;
    [[self deviceAlertService] checkDeviceState:^(HEMDeviceAlertState state) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (state != HEMDeviceAlertStateNormal && state != HEMDeviceAlertStateUnknown) {
            if (state == HEMDeviceAlertStatePillFirmwareUpdate
                && [[strongSelf deviceService] shouldSuppressPillFirmwareUpdate]) {
                return completion (NO);
            }
            
            NSString* title, *message, *cancelTitle, *fixTitle = nil;
            [strongSelf deviceWarningTitle:&title
                                   message:&message
                         cancelButtonTitle:&cancelTitle
                            fixButtonTitle:&fixTitle
                                 alertType:state];
            
            if (message) {
                [strongSelf showDeviceWarningWithTitle:title
                                               message:message
                                     cancelButtonTitle:cancelTitle
                                        fixButtonTitle:fixTitle
                                               forType:state];
                
                NSString* analyticsType = [self analyticsPropertyTypeValueForDeviceState:state];
                
                [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageSystemAlertShown];
                
                [SENAnalytics track:HEMAnalyticsEventSystemAlert
                         properties:@{kHEMAnalyticsEventPropType : analyticsType}];
                
                completion (YES);
                
            } else {
                completion (NO);
            }
            
        } else {
            completion (NO);
        }

    }];
}

- (void)deviceWarningTitle:(NSString**)warningTitle
                   message:(NSString**)warningMessage
         cancelButtonTitle:(NSString**)cancelTitle
            fixButtonTitle:(NSString**)fixTitle
                 alertType:(HEMDeviceAlertState)deviceState {
    
    *cancelTitle = NSLocalizedString(@"actions.later", nil);
    *fixTitle = NSLocalizedString(@"actions.fix-now", nil);
    
    switch (deviceState) {
        case HEMDeviceAlertStateSenseNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-sense.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-sense.message", nil);
            break;
        case HEMDeviceAlertStateSenseNotSeen:
            *warningTitle = NSLocalizedString(@"alerts.device.sense-last-seen.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.sense-last-seen.message", nil);
            break;
        case HEMDeviceAlertStatePillNotPaired:
            *warningTitle = NSLocalizedString(@"alerts.device.no-pill.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.no-pill.message", nil);
            break;
        case HEMDeviceAlertStatePillNotSeen:
            *warningTitle = NSLocalizedString(@"alerts.device.pill-last-seen.title", nil);
            *warningMessage = NSLocalizedString(@"alerts.device.pill-last-seen.message", nil);
            break;
        case HEMDeviceAlertStatePillLowBattery:
            *warningMessage = NSLocalizedString(@"alerts.device.pill-low-battery.message", nil);
            *fixTitle = NSLocalizedString(@"actions.replace", nil);
            break;
        case HEMDeviceAlertStatePillFirmwareUpdate:
            *warningMessage = NSLocalizedString(@"alerts.device.pill-firmware-update", nil);
            *warningTitle = NSLocalizedString(@"alerts.device.pill-firmware-update.title", nil);
            *fixTitle = NSLocalizedString(@"actions.update-now", nil);
        default:
            break;
    }
    
}

- (void)showDeviceWarningWithTitle:(NSString*)title
                           message:(NSString*)message
                 cancelButtonTitle:(NSString*)cancelTitle
                    fixButtonTitle:(NSString*)fixTitle
                           forType:(HEMDeviceAlertState)type {
    
    if (![self canShowAlert]) {
        return;
    }
    
    HEMActionView* alert = [self configureAlertViewWithTitle:title
                                                     message:message
                                           cancelButtonTitle:cancelTitle
                                              fixButtonTitle:fixTitle];
    

    [alert setSubtype:type];
    [alert setType:HEMSystemAlertTypeDevice];
    
    [[alert cancelButton] addTarget:self
                             action:@selector(fixDeviceProblemLater:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [[alert okButton] addTarget:self
                         action:@selector(fixDeviceProblemNow:)
               forControlEvents:UIControlEventTouchUpInside];

    [alert showInView:[self alertContainerView]
                below:[self topView]
             animated:YES
           completion:nil];
    
    [self setCurrentActionView:alert];
}

#pragma mark Device Alert Actions

- (void)fixDeviceProblemLater:(id)sender {
    HEMDeviceAlertState state = [[self currentActionView] subtype];
    [[self deviceAlertService] updateLastAlertShownForState:state];
    
    [self dismissActionView:nil];
    
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionLater}];
}

- (void)fixDeviceProblemNow:(id)sender {
    HEMDeviceAlertState state = [[self currentActionView] subtype];
    [[self deviceAlertService] updateLastAlertShownForState:state];
    
    [self dismissActionView:^{
        [self launchHandlerForDeviceAlertType:state];
    }];
    
    [SENAnalytics track:HEMAnalyticsEventSystemAlertAction
             properties:@{kHEMAnalyticsEventPropAction : HEMAnalyticsEventSysAlertActionNow}];
}

- (void)launchHandlerForDeviceAlertType:(HEMDeviceAlertState)type {
    // supported warnings are handled below
    switch (type) {
        case HEMDeviceAlertStateSenseNotPaired:
            [self showSensePairController];
            break;
        case HEMDeviceAlertStateSenseNotSeen:
            [self showSenseHelp];
            break;
        case HEMDeviceAlertStatePillNotPaired:
            [self showPillPairController];
            break;
        case HEMDeviceAlertStatePillNotSeen:
            [self showPillHelp];
            break;
        case HEMDeviceAlertStatePillLowBattery:
            [self showHowToReplacePillBattery];
            break;
        case HEMDeviceAlertStatePillFirmwareUpdate:
            [self showPillDFUController];
            break;
        default:
            break;
    }
}

#pragma mark Sense Problems

- (void)showSensePairController {
    HEMSensePairViewController* pairVC = (id) [HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [[self delegate] presentViewController:nav from:self];
    
}

- (void)showSenseHelp {
    NSString* senseHelpSlug = NSLocalizedString(@"help.url.slug.sense-not-seen", nil);
    [[self delegate] presentSupportPageWithSlug:senseHelpSlug from:self];
}

#pragma mark HEMSensePairDelegate

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [[self delegate] dismissCurrentViewControllerFrom:self];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [[self delegate] dismissCurrentViewControllerFrom:self];
}

#pragma mark Pill Problems

- (void)showPillDFUController {
    UIViewController* viewController = [HEMPillDFUStoryboard instantiatePillDFUNavViewController];
    [[self delegate] presentViewController:viewController from:self];
}

- (void)showPillPairController {
    HEMPillPairViewController* pairVC = (id) [HEMOnboardingStoryboard instantiatePillPairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [[self delegate] presentViewController:nav from:self];
}

- (void)showPillHelp {
    NSString* pillHelpSlug = NSLocalizedString(@"help.url.slug.pill-not-seen", nil);
    [[self delegate] presentSupportPageWithSlug:pillHelpSlug from:self];
}

- (void)showHowToReplacePillBattery {
    NSString* page = NSLocalizedString(@"help.url.slug.pill-battery", nil);
    [[self delegate] presentSupportPageWithSlug:page from:self];
}

#pragma mark HEMPillPairDelegate

- (void)didPairWithPillFrom:(HEMPillPairViewController *)controller {
    [[self delegate] dismissCurrentViewControllerFrom:self];
}

- (void)didCancelPairing:(HEMPillPairViewController *)controller {
    [[self delegate] dismissCurrentViewControllerFrom:self];
}

#pragma mark - Network alerts

- (void)showNetworkAlertIfNeeded:(void(^)(BOOL shown))completion {
    __weak typeof(self) weakSelf = self;
    // a delay is needed because of the Reachability lib we are using will at
    // first consider the network not reachable and then shortly notify that
    // network is now reachable.
    int64_t delayInSeconds = HEMSystemAlertNetworkCheckDelay * NSEC_PER_SEC;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
        BOOL show = NO;
        if (![[weakSelf networkAlertService] isNetworkReachable]) {
            [weakSelf showNoInternetAlert];
            show = YES;
        } 
        completion (show);
    });
}

- (void)networkService:(HEMNetworkAlertService *)networkAlertService detectedNetworkChange:(BOOL)hasNetwork {
    if (hasNetwork) {
        if ([[self currentActionView] type] == HEMSystemAlertTypeNetwork) {
            [self dismissActionView:nil];
        }
    } else {
        [self showNoInternetAlert];
    }
}

- (void)showNoInternetAlert {
    if (![self canShowAlert]) {
        return;
    }
    
    NSString* title = NSLocalizedString(@"alerts.no-internet.title", nil);
    NSString* message = NSLocalizedString(@"alerts.no-internet.message", nil);
    NSString* cancelTitle = NSLocalizedString(@"actions.ok", nil);
    
    HEMActionView* alert = [self configureAlertViewWithTitle:title
                                                     message:message
                                           cancelButtonTitle:cancelTitle
                                              fixButtonTitle:nil];
    
    [alert setType:HEMSystemAlertTypeNetwork];
    
    [[alert cancelButton] addTarget:self
                             action:@selector(cancelAlert:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [alert showInView:[self alertContainerView] below:[self topView] animated:YES completion:nil];
    
    [SENAnalytics track:HEMAnalyticsEventSystemAlert
             properties:@{kHEMAnalyticsEventPropType : @"no internet"}];
    
    [self setCurrentActionView:alert];
}

@end
