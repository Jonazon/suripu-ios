//
// HEMOnboardingStoryboard.h
// Copyright (c) 2014 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)networkReuseIdentifier;

/** Segue Identifiers */
+(NSString *)beforeSleepToAlarmSegueIdentifier;
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier;
+(NSString *)bluetoothOnSegueIdentifier;
+(NSString *)doneSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)getAppSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)locationToPushSegueIdentifier;
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)pushToNoBleSegueIdentifier;
+(NSString *)pushToSenseSetupSegueIdentifier;
+(NSString *)secondPillCheckSegueIdentifier;
+(NSString *)senseToPillSegueIdentifier;
+(NSString *)weightSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)wifiPasswordSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateBluetoothViewController;
+(UIViewController *)instantiateDobViewController;
+(UIViewController *)instantiateGenderPickerViewController;
+(UIViewController *)instantiateHeightPickerViewController;
+(UIViewController *)instantiatePillPairViewController;
+(UIViewController *)instantiateRoomCheckViewController;
+(UIViewController *)instantiateSenseSetupViewController;
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateWeightPickerViewController;
+(UIViewController *)instantiateWelcomeViewController;
+(UIViewController *)instantiateWifiPickerViewController;
+(UIViewController *)instantiateWifiViewController;

@end
