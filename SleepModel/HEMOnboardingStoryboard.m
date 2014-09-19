//
// HEMOnboardingStoryboard.m
// File generated using Ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEMbluetoothViewController = @"bluetoothViewController";
static NSString *const _HEMdataIntro = @"dataIntro";
static NSString *const _HEMdataIntroViewController = @"dataIntroViewController";
static NSString *const _HEMdobViewController = @"dobViewController";
static NSString *const _HEMgender = @"gender";
static NSString *const _HEMheight = @"height";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMsetup = @"setup";
static NSString *const _HEMsignUpViewController = @"signUpViewController";
static NSString *const _HEMsignup = @"signup";
static NSString *const _HEMskip = @"skip";
static NSString *const _HEMsleepQuestionIntro = @"sleepQuestionIntro";
static NSString *const _HEMsleepQuestionIntroViewController = @"sleepQuestionIntroViewController";
static NSString *const _HEMweight = @"weight";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMlocation = @"location";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }



/** Segue Identifiers */
+(NSString *)signupSegueIdentifier { return _HEMsignup; }
+(NSString *)setupSegueIdentifier { return _HEMsetup; }
+(NSString *)genderSegueIdentifier { return _HEMgender; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)dataIntroSegueIdentifier { return _HEMdataIntro; }
+(NSString *)heightSegueIdentifier { return _HEMheight; }
+(NSString *)sleepQuestionIntroSegueIdentifier { return _HEMsleepQuestionIntro; }
+(NSString *)skipSegueIdentifier { return _HEMskip; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }
+(NSString *)weightSegueIdentifier { return _HEMweight; }
+(NSString *)locationSegueIdentifier { return _HEMlocation; }

/** View Controllers */
+(UIViewController *)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(UIViewController *)instantiateSignUpViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsignUpViewController]; }
+(UIViewController *)instantiateDataIntroViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdataIntroViewController]; }
+(UIViewController *)instantiateDobViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdobViewController]; }
+(UIViewController *)instantiateHeightViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMheight]; }
+(UIViewController *)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }
+(UIViewController *)instantiateGenderViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgender]; }
+(UIViewController *)instantiateWeightViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMweight]; }
+(UIViewController *)instantiateSleepQuestionIntroViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepQuestionIntroViewController]; }
+(UIViewController *)instantiateBluetoothViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbluetoothViewController]; }

@end
