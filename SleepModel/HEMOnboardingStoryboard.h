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
+(NSString *)doneSegueIdentifier;
+(NSString *)firstPillSenseSetupSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)needBluetoothSegueIdentifier;
+(NSString *)noBleToSetupSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)pillNeedBluetoothSegueIdentifier;
+(NSString *)secondPillNeedBleSegueIdentifier;
+(NSString *)secondPillToSenseSegueIdentifier;
+(NSString *)senseSetupSegueIdentifier;
+(NSString *)senseToPillSegueIdentifier;
+(NSString *)weightSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)wifiPasswordSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateBluetoothViewController;
+(UIViewController *)instantiateDobViewController;
+(UIViewController *)instantiateGenderPickerViewController;
+(UIViewController *)instantiateGetSetupViewController;
+(UIViewController *)instantiateHeightPickerViewController;
+(UIViewController *)instantiatePillIntroViewController;
+(UIViewController *)instantiatePillPairViewController;
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateWeightPickerViewController;
+(UIViewController *)instantiateWelcomeViewController;
+(UIViewController *)instantiateWifiViewController;

@end
