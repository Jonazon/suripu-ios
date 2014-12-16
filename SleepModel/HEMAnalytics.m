//
//  HEMAnalytics.m
//  Sense
//
//  Created by Jimmy Lu on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAccount.h>

#import "HEMAnalytics.h"

// general
NSString* const kHEMAnalyticsEventError = @"Error";
NSString* const kHEMAnalyticsEventHelp = @"Help";
NSString* const kHEMAnalyticsEventVideo = @"Play Video";
NSString* const kHEMAnalyticsEventPropMessage = @"Message";
NSString* const kHEMAnalyticsEventPropAction = @"Action";
NSString* const kHEMAnalyticsEventPropPlatform = @"Platform";
NSString* const kHEMAnalyticsEventPlatform = @"iOS";
NSString* const kHEMAnalyticsEventPropName = @"Name";
NSString* const kHEMAnalyticsEventPropGender = @"Gender";
NSString* const kHEMAnalyticsEventPropAccount = @"Account Id";

// special mixpanel special properties
NSString* const kHEMAnalyticsEventMpPropName = @"$name";
NSString* const kHEMAnalyticsEventMpPropCreated = @"$created";

// permissions
NSString* const kHEMAnalyticsEventPermissionLoc = @"Permission Location";
NSString* const kHEManaltyicsEventPropStatus = @"Status";
NSString* const kHEManaltyicsEventStatusSkipped = @"skipped";
NSString* const kHEManaltyicsEventStatusEnabled = @"enabled";
NSString* const kHEManaltyicsEventStatusDisabled = @"disabled";
NSString* const kHEManaltyicsEventStatusDenied = @"denied";

// onboarding
NSString* const kHEMAnalyticsEventOnBStart = @"Onboarding Start";
NSString* const kHEMAnalyticsEventOnBBirthday = @"Onboarding Birthday";
NSString* const kHEMAnalyticsEventOnBGender = @"Onboarding Gender";
NSString* const kHEMAnalyticsEventOnBHeight = @"Onboarding Height";
NSString* const kHEMAnalyticsEventOnBWeight = @"Onboarding Weight";
NSString* const kHEMAnalyticsEventOnBLocation = @"Onboarding Location";
NSString* const kHEMAnalyticsEventOnBNotification = @"Onboarding Notifications";
NSString* const kHEMAnalyticsEventOnBSecondPillCheck = @"Onboarding Second Pill Check";
NSString* const kHEMAnalyticsEventOnBNoBle = @"Onboarding No BLE";
NSString* const kHEMAnalyticsEventOnBSenseSetup = @"Onboarding Sense Setup";
NSString* const kHEMAnalyticsEventOnBPairSense = @"Onboarding Pair Sense";
NSString* const kHEMAnalyticsEventOnBWiFi = @"Onboarding WiFi";
NSString* const kHEMAnalyticsEventOnBWiFiScan = @"Onboarding WiFi Scan";
NSString* const kHEMAnalyticsEventOnBWiFiPass = @"Onboarding WiFi Password";
NSString* const kHEMAnalyticsEventOnBPairPill = @"Onboarding Pair Pill";
NSString* const kHEMAnalyticsEventOnBPillPlacement = @"Onboarding Pill Placement";
NSString* const kHEMAnalyticsEventOnBAnotherPill = @"Onboarding Another Pill";
NSString* const kHEMAnalyticsEventOnBPairingOff = @"Onboarding Pairing Mode Off";
NSString* const kHEMAnalyticsEventOnBGetApp = @"Onboarding Get App";
NSString* const kHEMAnalyticsEventOnBSenseColors = @"Onboarding Sense Colors";
NSString* const kHEMAnalyticsEventOnBFirstAlarm = @"Onboarding First Alarm";
NSString* const kHEMAnalyticsEventOnBRoomCheck = @"Onboarding Room Check";
NSString* const kHEMAnalyticsEventOnBEnd = @"Onboarding End";

// main app
NSString* const kHEMAnalyticsEventAlarm = @"Alarm";
NSString* const kHEMAnalyticsEventTimeline = @"Timeline";

// authentication
NSString* const kHEMAnalyticsEventSignInStart = @"Sign In Start";
NSString* const kHEMAnalyticsEventSignIn = @"Signed In";
NSString* const kHEMAnalyticsEventSignOut = @"Signed Out";

// device management
NSString* const kHEMAnalyticsEventDeviceAction = @"Device Action";
NSString* const kHEMAnalyticsEventDeviceFactoryRestore = @"factory restore";
NSString* const kHEMAnalyticsEventDevicePairingMode = @"enable pairing mode";

@implementation HEMAnalytics

+ (void)trackSignUpWithName:(NSString*)userName {
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
    if ([accountId length] == 0) {
        // checking this case as it seemed to have happened before
        DDLogInfo(@"account id not found after sign up!");
        accountId = @"";
    }
    
    [SENAnalytics userWithId:[SENAuthorizationService accountIdOfAuthorizedUser]
     didSignUpWithProperties:@{kHEMAnalyticsEventMpPropName : userName ?: @"",
                               kHEMAnalyticsEventMpPropCreated : [NSDate date],
                               kHEMAnalyticsEventPropAccount : accountId,
                               kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform}];
    
    // these are properties that will be sent up for every event
    [SENAnalytics setGlobalEventProperties:@{kHEMAnalyticsEventPropName : userName,
                                             kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform}];
}

+ (void)trackUserSession {
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
    // need to additionally set the account id as a separate property so that it
    // is shown in as a user property when viewing People in Mixpanel.  If not using
    // mixpanel, we can probably just remove it
    [SENAnalytics setUserId:accountId
                 properties:@{kHEMAnalyticsEventPropPlatform : kHEMAnalyticsEventPlatform,
                              kHEMAnalyticsEventPropAccount : accountId ?: @""}];
}

+ (void)updateGender:(SENAccountGender)gender {
    NSString* genderString = nil;
    switch (gender) {
        case SENAccountGenderFemale:
            genderString = @"female";
            break;
        case SENAccountGenderMale:
            genderString = @"male";
            break;
        default:
            genderString = @"other";
            break;
    }
    [SENAnalytics setUserProperties:@{kHEMAnalyticsEventPropGender : genderString}];
}

@end
