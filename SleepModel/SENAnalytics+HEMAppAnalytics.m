//
//  SENAnalytics+HEMAppAnalytics.m
//  Sense
//
//  Created by Jimmy Lu on 7/23/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENSense.h>
#import <SenseKit/SENAnalyticsLogger.h>

#import "Sense-Swift.h"

#import "SENAnalytics+HEMAppAnalytics.h"

#import "HEMConfig.h"
#import "HEMSegmentProvider.h"

// general
NSString* const kHEMAnalyticsEventWarning = @"Warning";
NSString* const kHEMAnalyticsEventHelp = @"Help";
NSString* const kHEMAnalyticsEventVideo = @"Play Video";
NSString* const kHEMAnalyticsEventPropMessage = @"message";
NSString* const kHEMAnalyticsEventPropAction = @"Action";
NSString* const kHEMAnalyticsEventPropDate = @"Date";
NSString* const kHEMAnalyticsEventPropType = @"Type";
NSString* const kHEMAnalyticsEventPropPlatform = @"Platform";
NSString* const kHEMAnalyticsEventPlatform = @"iOS";
NSString* const kHEMAnalyticsEventPropGender = @"Gender";
NSString* const kHEMAnalyticsEventPropAccount = @"Account Id";
NSString* const kHEMAnalyticsEventPropSenseId = @"Sense Id";
NSString* const kHEMAnalyticsEventPropHwVersion = @"Sense Version";
NSString* const kHEMAnalyticsEventPropValSenseV = @"Sense with Voice";
NSString* const kHEMAnalyticsEventPropValSense1 = @"Sense";
NSString* const kHEMAnalyticsEventPropPillId = @"Pill Id";
NSString* const kHEMAnalyticsEventPropHealthKit = @"HealthKit";
NSString* const kHEMAnalyticsEventPropSSID = @"SSID";
NSString* const kHEMAnalyticsEventPropPassLength = @"Password length";

static NSString* const HEMAnalyticsEventPropName = @"Name";

// special mixpanel - segment mapping special properties
static NSString* const HEMAnalyticsEventReservedPropEmail = @"email";
static NSString* const HEMAnalyticsEventReservedPropName = @"name";
static NSString* const HEMAnalyticsEventReservedPropCreated = @"createdAt";

// permissions
NSString* const kHEMAnalyticsEventPermissionLoc = @"Permission Location";
NSString* const kHEManaltyicsEventPropStatus = @"Status";
NSString* const kHEManaltyicsEventStatusSkipped = @"skipped";
NSString* const kHEManaltyicsEventStatusEnabled = @"enabled";
NSString* const kHEManaltyicsEventStatusDisabled = @"disabled";
NSString* const kHEManaltyicsEventStatusDenied = @"denied";
NSString* const kHEManaltyicsEventStatusNotSupported = @"not supported";

// onboarding
//
// welcome
//
NSString* const HEMAnalyticsEventWelcomeIntroSwipe = @"Onboarding intro swiped";
NSString* const HEMAnalyticsEventPropScreen = @"screen";
//
// Some events fire outside of onboarding b/c the controllers are reused.
// If the event is fired during onboarding, make sure HEMAnalyticsEventOnboardingPrefix
// is added to the event name.
NSString* const HEMAnalyticsEventOnboardingPrefix = @"Onboarding";
NSString* const kHEMAnalyticsEventOnBNoSense = @"I don't have a Sense";
NSString* const kHEMAnalyticsEventOnBHelp = @"Onboarding Help";
NSString* const kHEMAnalyticsEventPropStep = @"onboarding_step";
NSString* const kHEMAnalyticsEventPropBluetooth = @"bluetooth";
NSString* const kHEMAnalyticsEventPropAudio = @"enhanced_audio";
NSString* const kHEMAnalyticsEventPropSensePairingMode = @"sense_pairing_mode";
NSString* const kHEMAnalyticsEventPropSensePairing = @"sense_pairing";
NSString* const kHEMAnalyticsEventPropResetSense = @"reset_sense";
NSString* const kHEMAnalyticsEventPropSenseSetup = @"setup_sense";
NSString* const kHEMAnalyticsEventPropWiFiScan = @"wifi_scan";
NSString* const kHEMAnalyticsEventPropWiFiPass = @"sign_into_wifi";
NSString* const kHEMAnalyticsEventPropPillPairing = @"pill_pairing";
NSString* const kHEMAnalyticsEventPropPillPlacement = @"pill_placement";
NSString* const kHEMAnalyticsEventPropSenseDFU = @"sense_ota";

NSString* const HEMAnalyticsEventOnbStart = @"Onboarding Start";
NSString* const HEMAnalyticsEventAccount = @"Account";
NSString* const HEMAnalyticsEventHealth = @"Health";
NSString* const HEMAnalyticsEventLocation = @"Location";
NSString* const HEMAnalyticsEventNotification = @"Notifications";
NSString* const HEMAnalyticsEventNoBle = @"No BLE";
NSString* const HEMAnalyticsEventAudio = @"Sense Audio";
NSString* const HEMAnalyticsEventSleepPill = @"Sleep Pill";
NSString* const HEMAnalyticsEventPillPlacement = @"Pill Placement";
NSString* const HEMAnalyticsEventSenseColors = @"Onboarding Sense Colors";
NSString* const HEMAnalyticsEventFirstAlarm = @"Onboarding First Alarm";
NSString* const HEMAnalyticsEventRoomCheck = @"Onboarding Room Check";
NSString* const HEMAnalyticsEventOnbEnd = @"Onboarding End";
NSString* const HEMAnalyticsEventSkip = @"Skip";
NSString* const HEMAnalyticsEventBirthday = @"Birthday";
NSString* const HEMAnalyticsEventGender = @"Gender";
NSString* const HEMAnalyticsEventHeight = @"Height";
NSString* const HEMAnalyticsEventWeight = @"Weight";
NSString* const HEMAnalyticsEventSenseSetup = @"Sense Setup";
NSString* const HEMAnalyticsEventPairSense = @"Pair Sense";
NSString* const HEMAnalyticsEventSensePaired = @"Sense Paired";
NSString* const HEMAnalyticsEventWiFi = @"WiFi";
NSString* const HEMAnalyticsEventWiFiConnectionUpdate = @"Sense WiFi Update";
NSString* const HEMAnalyticsEventPropWiFiStatus = @"status";
NSString* const HEMAnalyticsEventPropHttpCode = @"http_response_code";
NSString* const HEMAnalyticsEventPropSocketCode = @"socket_error_code";
NSString* const HEMAnalyticsEventWiFiScan = @"WiFi Scan"; // fires when app auto starts a scan
NSString* const HEMAnalyticsEventWiFiRescan = @"WiFi Rescan"; // fires when user triggers a scan
NSString* const HEMAnalyticsEventWiFiPass = @"WiFi Password";
NSString* const HEMAnalyticsEventWiFiSubmit = @"WiFi Credentials Submitted";
NSString* const kHEMAnalyticsEventPropSecurityType = @"Security Type";
NSString* const kHEMAnalyticsEventPropWiFiOther = @"Is Other";
NSString* const kHEMAnalyticsEventPropWiFiRSSI = @"RSSI";
NSString* const HEMAnalyticsEventPairPill = @"Pair Pill";
NSString* const HEMAnalyticsEventPillPaired = @"Pill Paired";
NSString* const HEMAnalyticsEventPairPillRetry = @"Pair Pill Retry";
NSString* const kHEMAnalyticsEventPropOnBScreen = @"Screen";
NSString* const kHEMAnalyticsEventPropScreenPillPairing = @"pill_pairing";

// main app
NSString* const kHEMAnalyticsEventLaunchedFromExt = @"App Launched From Extension";
NSString* const kHEMAnalyticsEventPropExtUrl = @"extension url";
NSString* const kHEMAnalyticsEventAppLaunched = @"App Launched";
NSString* const kHEMAnalyticsEventAppClosed = @"App Closed";
NSString* const kHEMAnalyticsEventPropEvent = @"event";
NSString* const kHEMAnalyticsEventCurrentConditions = @"Current Conditions";
NSString* const kHEMAnalyticsEventFeed = @"Insights";
NSString* const kHEMAnalyticsEventQuestion = @"Question";
NSString* const kHEMAnalyticsEventInsight = @"Insight Detail";
NSString* const kHEMAnalyticsEventDevices = @"Devices";
NSString* const kHEMAnalyticsEventSensor = @"Sensor History";
NSString* const kHEMAnalyticsEventPropSensorName = @"sensor_name";
NSString* const HEMAnalyticsEventHealthSync = @"Health app sync";
NSString* const kHEMAnalyticsEventSettings = @"Settings";
NSString* const kHEMAnalyticsEventSense = @"Sense Detail";
NSString* const kHEMAnalyticsEventPill = @"Pill Detail";
NSString* const kHEMAnalyticsEventUnitsNTime = @"Units/Time";
NSString* const kHEMAnalyticsEventAccount = @"Account";

// trends
NSString* const HEMAnalyticsEventTrends = @"Trends";
NSString* const HEMAnalyticsEventTrendsChangeTimescale = @"Change trends timescale";
NSString* const HEMAnalyticsEventTrendsPropTimescale = @"timescale";
NSString* const HEMAnalyticsEventTrendsPropTimescaleWeek = @"week";
NSString* const HEMAnalyticsEventTrendsPropTimescaleMonth = @"month";
NSString* const HEMAnalyticsEventTrendsPropTimescaleQuarter = @"quarter";

// tell a friend
NSString* const HEMAnalyticsEventTellAFriendTapped = @"Tell a friend tapped";
NSString* const HEMAnalyticsEventTellAFriendCompleted = @"Tell a friend completed";
NSString* const HEMAnalyticsEventTellAFriendCompletedPropType = @"type";

// back view
NSString* const HEMAnalyticsEventBackViewSwipe = @"Top view tab swiped"; // name required to match Android
NSString* const HEMAnalyticsEventBackViewTapped = @"Top view tab tapped"; // name required to match Android

// support
NSString* const HEMAnalyticsEventSupport = @"Support";
NSString* const HEMAnalyticsEventSupportContactUs = @"Contact us";
NSString* const HEMAnalyticsEventSupportTickets = @"My tickets";
NSString* const HEMAnalyticsEventSupportUserGuide = @"User guide";
NSString* const HEMAnalyticsEventSupportTicketSubmitted = @"Submit ticket";

// authentication
NSString* const kHEMAnalyticsEventSignInStart = @"Sign In Start";
NSString* const kHEMAnalyticsEventSignIn = @"Signed In";
NSString* const kHEMAnalyticsEventSignOut = @"Signed Out";

// time zone
NSString* const HEMAnalyticsEventTimeZone = @"Time Zone";
NSString* const HEMAnalyticsEventTimeZoneChanged = @"Time Zone Changed";
NSString* const HEMAnalyticsEventPropTZ = @"tz";
NSString* const HEMAnalyticsEventMissingTZMapping = @"Time Zone Mapping Missing";

// device management
NSString* const kHEMAnalyticsEventDeviceAction = @"Device Action";
NSString* const kHEMAnalyticsEventDeviceActionFactoryRestore = @"factory restore";
NSString* const kHEMAnalyticsEventDeviceActionPairingMode = @"enable pairing mode";
NSString* const kHEMAnalyticsEventDeviceActionUnpairSense = @"unpair Sense";
NSString* const kHEMAnalyticsEventDeviceActionUnpairPill = @"unpair Sleep Pill";

// timeline
NSString* const HEMAnalyticsEventTimelineBarLongPress = @"Long press sleep duration bar";
NSString* const kHEMAnalyticsEventTimeline = @"Timeline";
NSString* const kHEMAnalyticsEventTimelineChanged = @"Timeline swipe"; // case sensitive, to be same as android
NSString* const kHEMAnalyticsEventTimelineAction = @"Timeline Event tapped";
NSString* const kHEMAnalyticsEventTimelineOpen = @"Timeline opened";
NSString* const kHEMAnalyticsEventTimelineClose = @"Timeline closed";
NSString* const HEMAnalyticsEventSleepScoreBreakdown = @"Sleep Score breakdown";
NSString* const HEMAnalyticsEventTimelineZoomOut = @"Timeline zoomed out";
NSString* const HEMAnalyticsEventTimelineZoomIn = @"Timeline zoomed in";
NSString* const HEMAnalyticsEventTimelineAdjustTime = @"Timeline adjust time tapped";
NSString* const HEMAnalyticsEventTimelineAdjustTimeFailed = @"Timeline adjust time failed";
NSString* const HEMAnalyticsEventTimelineEventCorrect = @"Timeline event correct";
NSString* const kHEMAnalyticsEventTimelineAdjustTimeSaved = @"Timeline event time adjust";
NSString* const HEMAnalyticsEventTimelineEventIncorrect = @"Timeline event incorrect";
NSString* const HEMAnalyticsEventTimelineDataRequest = @"Timeline data request";
NSString* const HEMAnalyticsEventTimelineAlarmShortcut = @"Timeline alarm shorcut";

// alarms
NSString* const kHEMAnalyticsEventAlarms = @"Alarms";
NSString* const HEMAnalyticsEventCreateNewAlarm = @"Create new alarm";
NSString* const HEMAnalyticsEventSwitchSmartAlarm = @"Flip smart alarm switch";
NSString* const HEMAnalyticsEventSwitchSmartAlarmOn = @"on";
NSString* const HEMAnalyticsEventSaveAlarm = @"Alarm Saved";
NSString* const HEMAnalyticsEventDeleteAlarm = @"Alarm Deleted";
NSString* const HEMAnalyticsEventAlarmOnOff = @"Alarm On/Off";
NSString* const HEMAnalyticsEventPropDaysRepeated = @"days_repeated";
NSString* const HEMAnalyticsEventPropEnabled = @"enabled";
NSString* const HEMAnalyticsEventPropIsSmart = @"smart_alarm";
NSString* const HEMAnalyticsEventPropHour = @"hour";
NSString* const HEMAnalyticsEventPropMinute = @"minute";

// system alerts
NSString* const HEMAnalyticsEventSystemAlert = @"System Alert";
NSString* const HEMAnalyticsEventSystemAlertAction = @"System Alert Action";
NSString* const HEMAnalyticsEventSysAlertActionLater = @"later";
NSString* const HEMAnalyticsEventSysAlertActionNow = @"now";
NSString* const HEMAnalyticsEventSysAlertPropUnknown = @"unknown";
NSString* const HEMAnalyticsEventSysAlertActionUnmute = @"unmute";
NSString* const HEMAnalyticsEventSysAlertPropMuted = @"sense muted";
NSString* const HEMAnalyticsEventSysAlertPropExpUnreachable = @"expansion unreachable";

// app review
NSString* const HEMAnalyticsEventAppReviewShown = @"App review shown";
NSString* const HEMAnalyticsEventAppReviewStart = @"App review start";
NSString* const HEMAnalyticsEventAppReviewEnjoySense = @"Enjoy Sense";
NSString* const HEMAnalyticsEventAppReviewDoNotEnjoySense = @"Do not enjoy Sense";
NSString* const HEMAnalyticsEventAppReviewHelp = @"Help from app review";
NSString* const HEMAnalyticsEventAppReviewRate = @"Rate app";
NSString* const HEMAnalyticsEventAppReviewRateOnAmazon = @"Rate on Amazon";
NSString* const HEMAnalyticsEventAppReviewRateNoAsk = @"Do not ask to rate app again";
NSString* const HEMAnalyticsEventAppReviewFeedback = @"Feedback from app review";
NSString* const HEMAnalyticsEventAppReviewDone = @"App review completed with no action";
NSString* const HEMAnalyticsEventAppReviewSkip = @"App review skip";

// force touch events
NSString* const HEMAnalyticsEventShortcutAlarmNew = @"3D Touch new alarm";
NSString* const HEMAnalyticsEventShortcutAlarmEdit = @"3D Touch edit alarm";

// sleep sound events
NSString* const HEMAnalyticsEventSleepSoundView = @"Sleep sounds";
NSString* const HEMAnalyticsEventSSActionPlay = @"Play sleep sound";
NSString* const HEMAnalyticsEventSSActionStop = @"Stop sleep sound";
NSString* const HEMAnalyticsEventSSPropSoundId = @"sound id";
NSString* const HEMAnalyticsEventSSPropDurationId = @"duration id";
NSString* const HEMAnalyticsEventSSPropVolume = @"volume";

// settings
NSString* const HEMAnalyticsEventChangeName = @"Change Name";
NSString* const HEMAnalyticsEventChangeEmail = @"Change Email";
NSString* const HEMAnalyticsEventChangePass = @"Change Password";
NSString* const HEMAnalyticsEventUpdatePhoto = @"Change Profile Photo";
NSString* const HEMAnalyticsEventPropSource = @"source";
NSString* const HEMAnalyticsEventPropSourceFacebook = @"facebook";
NSString* const HEMAnalyticsEventPropSourceCamera = @"camera";
NSString* const HEMAnalyticsEventPropSourcePhotoLibrary = @"photo library";
NSString* const HEMAnalyticsEventDeletePhoto = @"Delete Photo";

// share
NSString* const HEMAnalyticsEventShare = @"Share";
NSString* const HEMAnalyticsEventShareComplete = @"Share completed";
NSString* const HEMAnalyticsPropCategory = @"category";
NSString* const HEMAnalyticsPropService = @"service";

// dfu
NSString* const HEMAnalyticsEventPillDfuStart = @"Pill Update Start";
NSString* const HEMAnalyticsEventPillDfuOTAStart = @"Pill Update OTA Start";
NSString* const HEMAnalyticsEventPillDfuDone = @"Pill Update Complete";

// sense forced ota dfu
NSString* const HEMAnalyticsEventSenseDFU = @"Sense DFU";
NSString* const HEMAnalyticsEventSenseDFUBegin = @"Sense DFU begin";
NSString* const HEMAnalyticsEventSenseDFUEnd = @"Sense DFU end";

// voice
NSString* const HEMAnalyticsEventVoiceTutorial = @"Voice Tutorial";
NSString* const HEMAnalyticsEventVoiceResponse = @"Voice Command";
NSString* const HEMAnalyticsEventVoiceTutorialSkip = @"Voice Tutorial Skip";
NSString* const HEMAnalyticsEventVoiceTab = @"Voice";
NSString* const HEMAnalyticsEventVoiceExamples = @"Voice Examples";

// upgrade path
NSString* const HEMAnalyticsEventUpgradePrefix = @"Upgrade";
NSString* const HEMAnalyticsEventUpgradeSense = @"Upgrade Sense";
NSString* const HEMAnalyticsEventPurchaseVoice = @"Purchase Sense Voice";
NSString* const HEMAnalyticsEventUpgradeSenseStart = @"Upgrade Sense Start";
NSString* const HEMAnalyticsEventUpgradeSwapRequest = @"Upgrade Swap Accounts Request";
NSString* const HEMAnalyticsEventUpgradeSwapped = @"Upgrade Account Swapped";
NSString* const HEMAnalyticsEventUpgradeReset = @"Upgrade Factory Reset";

// night mode
static NSString* const kHEMAnalyticsEventNightModeChanged = @"Changed Night Mode";
static NSString* const kHEMAnalyticsEventPropSetting = @"setting";
static NSString* const kHEMAnalyticsTraitNightMode = @"Night Mode";
NSString* const kHEMAnalyticsPropNightModeValueOn = @"on";
NSString* const kHEMAnalyticsPropNightModeValueOff = @"off";
NSString* const kHEMAnalyticsPropNightModeValueAuto = @"auto";

// push notifications
static NSString* const kHEMAnalyticsEventOpenFromPushNotification = @"Open Notification";
static NSString* const kHEMAnalyticsEventNotificationType = @"type";
static NSString* const kHEMAnalyticsEventNotificationDetail = @"detail";

// internal use only
static NSString* const kHEMAnalyticsEventError = @"Error";
static NSString* const HEMAnalyticsEventAccountCreated = @"Onboarding Account Created";

// used only to ensure nothing is wrong when upgrading version with Segment
static NSString* const HEMAnalyticsSettingsSegment = @"is.hello.analytics.segment";

@implementation SENAnalytics (HEMAppAnalytics)

+ (void)enableAnalytics {
    // whatever 3rd party vendor we use for analytics, configure it here
    NSString* analyticsToken = [HEMConfig stringForConfig:HEMConfAnalyticsToken];
    if ([analyticsToken length] > 0) {
        [self addProvider:[[HEMSegmentProvider alloc] initWithWriteKey:analyticsToken]];
    }
    // logging for our own perhaps to replicate analytic events on console
    [self addProvider:[SENAnalyticsLogger new]];
}

+ (NSDictionary*)propertiesFromAccount:(nonnull SENAccount*)account {
    NSString* name = [account fullName];
    NSString* email = [account email] ?: @"";
    NSString* accountId = [account accountId] ?: [SENAuthorizationService accountIdOfAuthorizedUser];
    NSDate* createDate = [account createdAt] ?: [NSDate date];
    return @{kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform,
             HEMAnalyticsEventReservedPropCreated : createDate,
             HEMAnalyticsEventReservedPropName : name,
             HEMAnalyticsEventReservedPropEmail : email,
             kHEMAnalyticsEventPropAccount : accountId};
}

+ (void)trackSignUpOfNewAccount:(SENAccount*)account {
    NSDictionary* properties = [self propertiesFromAccount:account];
    [self userWithId:properties[kHEMAnalyticsEventPropAccount] didSignUpWithProperties:properties];
    // track required? for segment after alias and identify
    [self track:HEMAnalyticsEventAccountCreated];
    [self setGlobalEventProperties:@{kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform,
                                     HEMAnalyticsEventPropName : [account fullName] ?: @""}];
}

+ (void)trackUserSession:(nullable SENAccount*)account {
    [self trackUserSession:account properties:nil];
}

+ (void)trackUserSession:(nullable SENAccount *)account
              properties:(nullable NSDictionary<NSString*, NSString*>*)properties {
    
    if (account) {
        NSMutableDictionary* accountProperties = [[self propertiesFromAccount:account] mutableCopy];
        if ([properties count] > 0) {
            [accountProperties addEntriesFromDictionary:properties];
        }
        [self setUserId:[account accountId] properties:accountProperties];
    } else {
        NSMutableDictionary* platformProperties = [NSMutableDictionary new];
        [platformProperties setValue:kHEMAnalyticsEventPlatform forKey:kHEMAnalyticsEventPropPlatform];
        if ([properties count] > 0) {
            [platformProperties addEntriesFromDictionary:properties];
        }
        [self setUserId:[SENAuthorizationService accountIdOfAuthorizedUser] properties:platformProperties];
    }
    
    [self setGlobalEventProperties:@{kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform,
                                     HEMAnalyticsEventPropName : [account fullName] ?: @""}];
}

+ (void)trackUserProperty:(NSString*)name value:(NSString*)value {
    if ([[SENAuthorizationService accountIdOfAuthorizedUser] length] > 0
        && [name length] > 0
        && [value length] > 0) {
        
        NSDictionary* properties = @{name : value};
        [self setUserId:[SENAuthorizationService accountIdOfAuthorizedUser] properties:properties];
        [self setGlobalEventProperties:properties];
    }
}

+ (void)trackNightModeChangeWithSetting:(NSString*)settingValue {
    [self trackUserProperty:kHEMAnalyticsTraitNightMode value:settingValue];
    [self track:kHEMAnalyticsEventNightModeChanged properties:@{kHEMAnalyticsEventPropSetting : settingValue ?: @"unknown"}];
}

+ (void)trackErrorWithMessage:(NSString*)message {
    NSDictionary* props = @{kHEMAnalyticsEventPropMessage : message};
    [self track:kHEMAnalyticsEventError properties:props];
}

+ (void)trackWarningWithMessage:(NSString*)message {
    NSDictionary* props = @{kHEMAnalyticsEventPropMessage : message};
    [self track:kHEMAnalyticsEventWarning properties:props];
}

+ (void)trackError:(NSError*)error {
    NSString* eventName = kHEMAnalyticsEventError;
    if ([[error domain] isEqualToString:NSURLErrorDomain]) {
        switch ([error code]) {
            case NSURLErrorTimedOut:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorNotConnectedToInternet:
                eventName = kHEMAnalyticsEventWarning;
                break;
            default:
                break;
        }
    }
    [self trackError:error withEventName:eventName];
}

+ (void)updateEmail:(NSString*)email {
    [SENAnalytics setUserProperties:@{HEMAnalyticsEventReservedPropEmail : email}];
}

+ (NSString*)trueFalsePropertyValue:(BOOL)isTrue {
    return isTrue ? @"true" : @"false";
}

+ (void)appendValue:(NSString*)value toCommaSeparatedString:(NSMutableString*)csString{
    
    if ([csString length] > 0) {
        [csString appendFormat:@", %@", value];
    } else {
        [csString appendString:value];
    }

}

#pragma mark - Special Alarm Analytics

+ (NSString*)alarmRepeatedDaysPropertyValue:(SENAlarm*)alarm {
    NSMutableString* repeatedDays = [NSMutableString new];
    NSUInteger flags = [alarm repeatFlags];
    
    if (flags & SENAlarmRepeatSunday) {
        [self appendValue:@"0" toCommaSeparatedString:repeatedDays];
    }
    
    if (flags & SENAlarmRepeatMonday) {
        [self appendValue:@"1" toCommaSeparatedString:repeatedDays];
    }
    
    if (flags & SENAlarmRepeatTuesday) {
        [self appendValue:@"2" toCommaSeparatedString:repeatedDays];
    }
    
    if (flags & SENAlarmRepeatWednesday) {
        [self appendValue:@"3" toCommaSeparatedString:repeatedDays];
    }
    
    if (flags & SENAlarmRepeatThursday) {
        [self appendValue:@"4" toCommaSeparatedString:repeatedDays];
    }
    
    if (flags & SENAlarmRepeatFriday) {
        [self appendValue:@"5" toCommaSeparatedString:repeatedDays];
    }
    
    if (flags & SENAlarmRepeatSaturday) {
        [self appendValue:@"6" toCommaSeparatedString:repeatedDays];
    }
    
    return repeatedDays;
}

+ (NSDictionary*)alarmPropertiesFor:(SENAlarm*)alarm {
    return @{HEMAnalyticsEventPropHour : @([alarm hour]),
             HEMAnalyticsEventPropMinute : @([alarm minute]),
             HEMAnalyticsEventPropEnabled : [self trueFalsePropertyValue:[alarm isOn]],
             HEMAnalyticsEventPropIsSmart : [self trueFalsePropertyValue:[alarm isSmartAlarm]],
             HEMAnalyticsEventPropDaysRepeated : [self alarmRepeatedDaysPropertyValue:alarm]};
}

+ (void)trackAlarmSave:(SENAlarm*)alarm {
    NSDictionary* props = [self alarmPropertiesFor:alarm];
    [self track:HEMAnalyticsEventSaveAlarm properties:props];
}

+ (void)trackAlarmToggle:(SENAlarm*)alarm {
    NSDictionary* props = [self alarmPropertiesFor:alarm];
    [self track:HEMAnalyticsEventAlarmOnOff properties:props];
}

+ (void)trackTrendsTimescaleChange:(SENTrendsTimeScale)timescale {
    NSString* value = nil;
    switch (timescale) {
        case SENTrendsTimeScaleWeek:
            value = HEMAnalyticsEventTrendsPropTimescaleWeek;
            break;
        case SENTrendsTimeScaleMonth:
            value = HEMAnalyticsEventTrendsPropTimescaleMonth;
            break;
        case SENTrendsTimeScaleQuarter:
            value = HEMAnalyticsEventTrendsPropTimescaleQuarter;
            break;
        default:
            value = @"unspecified";
            break;
    }
    NSDictionary* props = @{HEMAnalyticsEventTrendsPropTimescale : value};
    [self track:HEMAnalyticsEventTrendsChangeTimescale properties:props];
}

#pragma mark - Photos

+ (void)trackPhotoAction:(NSString*)source onboarding:(BOOL)onboarding {
    NSDictionary* props = @{HEMAnalyticsEventPropSource : source ?: @"unknown"};
    [self track:HEMAnalyticsEventUpdatePhoto properties:props onboarding:onboarding];
}

#pragma mark - Onboarding convenience

+ (void)track:(NSString*)event properties:(NSDictionary*)props onboarding:(BOOL)onboarding {
    NSString* name = event;
    if (onboarding) {
        name = [HEMAnalyticsEventOnboardingPrefix stringByAppendingFormat:@" %@", name];
    }
    [self track:name properties:props];
}

#pragma mark - Sense Forced OTA DFU

+ (void)trackSenseUpdate:(SENDFUStatus*)status {
    [self track:@"Sense DFU status" properties:@{@"status" : @([status currentState])}];
}

#pragma mark - Track Sense

+ (void)trackSense:(SENSense*)sense {
    NSString* deviceId = [sense deviceId];
    if (deviceId) {
        NSString* userId = [SENAuthorizationService accountIdOfAuthorizedUser];
        NSString* hardwareVersion = [sense version] == SENSenseAdvertisedVersionVoice
            ? kHEMAnalyticsEventPropValSenseV
            : kHEMAnalyticsEventPropValSense1;
        [self setUserId:userId
             properties:@{kHEMAnalyticsEventPropSenseId : deviceId,
                          kHEMAnalyticsEventPropHwVersion : hardwareVersion}];
    }
}

#pragma mark - Track Push Notification

+ (void)trackPushNotification:(PushNotification*)notification {
    id detailObj = [notification detail];
    NSString* detail = nil;
    if ([detailObj isKindOfClass:[NSDate class]]) {
        detail = [detailObj isoDate];
    } else if ([detailObj respondsToSelector:@selector(stringValue)]) {
        detail = [detailObj stringValue];
    } else if ([notification type] == PushTypeSystem) {
        detail = [notification systemTypeStringValue];
    }
    
    NSDictionary* props = @{kHEMAnalyticsEventNotificationType : [notification typeStringValue],
                            kHEMAnalyticsEventNotificationDetail : detail ?: @"n/a"};
    [self track:kHEMAnalyticsEventOpenFromPushNotification properties:props];
}

#pragma mark - Convenience methods

+ (NSString*)addPrefixIfNeeded:(NSString*)prefix toEvent:(NSString*)event {
    NSString* prefixedEvent = event;
    if (![prefixedEvent hasPrefix:prefix]) {
        prefixedEvent = [NSString stringWithFormat:@"%@ %@", prefix, event];
    }
    return prefixedEvent;
}

@end
