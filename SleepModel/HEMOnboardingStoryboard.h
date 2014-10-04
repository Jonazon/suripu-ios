//
// HEMOnboardingStoryboard.h
// File generated using Ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;



/** Segue Identifiers */
+(NSString *)signupSegueIdentifier;
+(NSString *)setupSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)weightSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)dataIntroSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationSegueIdentifier;
+(NSString *)sleepQuestionIntroSegueIdentifier;
+(NSString *)skipSegueIdentifier;
+(NSString *)wifiSegueIdentifier;

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController;
+(UIViewController *)instantiateSignUpViewController;
+(UIViewController *)instantiateDataIntroViewController;
+(UIViewController *)instantiateDobViewController;
+(UIViewController *)instantiateHeightViewController;
+(UIViewController *)instantiateWifiViewController;
+(UIViewController *)instantiateGenderViewController;
+(UIViewController *)instantiateWeightViewController;
+(UIViewController *)instantiateSleepQuestionIntroViewController;
+(UIViewController *)instantiateBluetoothViewController;

@end
