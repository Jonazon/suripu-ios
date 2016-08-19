//
// HEMOnboardingStoryboard.h
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMOnboardingStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)titleReuseIdentifier;
+(NSString *)emailReuseIdentifier;
+(NSString *)passwordReuseIdentifier;
+(NSString *)photoReuseIdentifier;
+(NSString *)firstNameReuseIdentifier;
+(NSString *)lastNameReuseIdentifier;
+(NSString *)networkReuseIdentifier;
+(NSString *)pillSetupTextCellReuseIdentifier;
+(NSString *)pillSetupVideoCellReuseIdentifier;

/** Segue Identifiers */
+(NSString *)audioToSetupSegueIdentifier;
+(NSString *)beforeSleepToSmartAlarmSegueIdentifier;
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier;
+(NSString *)dfuSegueIdentifier;
+(NSString *)doneSegueIdentifier;
+(NSString *)finishSegueIdentifier;
+(NSString *)genderSegueIdentifier;
+(NSString *)healthKitToLocationSegueIdentifier;
+(NSString *)heightSegueIdentifier;
+(NSString *)locationToPushSegueIdentifier;
+(NSString *)moreInfoSegueIdentifier;
+(NSString *)noBLESegueIdentifier;
+(NSString *)noBleToBirthdaySegueIdentifier;
+(NSString *)notificationToAudioSegueIdentifier;
+(NSString *)pairSegueIdentifier;
+(NSString *)pairPillSegueIdentifier;
+(NSString *)pillSetupToColorsSegueIdentifier;
+(NSString *)registerSegueIdentifier;
+(NSString *)resetSegueIdentifier;
+(NSString *)roomCheckToSmartAlarmSegueIdentifier;
+(NSString *)sensePairToPillSegueIdentifier;
+(NSString *)signupToNoBleSegueIdentifier;
+(NSString *)skipPillPairSegue;
+(NSString *)updateSenseSegueIdentifier;
+(NSString *)upgradeDoneSegueIdentifier;
+(NSString *)voiceSegueIdentifier;
+(NSString *)voiceTutorialSegueIdentifier;
+(NSString *)weightSegueIdentifier;
+(NSString *)weightToHealthKitSegueIdentifier;
+(NSString *)weightToLocationSegueIdentifier;
+(NSString *)wifiSegueIdentifier;
+(NSString *)wifiPasswordSegueIdentifier;
+(NSString *)wifiToPillSegueIdentifier;

/** View Controllers */
+(id)instantiateDobViewController;
+(id)instantiateGenderPickerViewController;
+(id)instantiateHeightPickerViewController;
+(id)instantiateNewSenseViewController;
+(id)instantiateNoBleViewController;
+(id)instantiateOnboardingCompleteViewController;
+(id)instantiatePillDescriptionViewController;
+(id)instantiatePillPairViewController;
+(id)instantiateResetDoneViewController;
+(id)instantiateResetSenseViewController;
+(id)instantiateRoomCheckViewController;
+(id)instantiateSenseAudioViewController;
+(id)instantiateSenseColorsViewController;
+(id)instantiateSenseDFUViewController;
+(id)instantiateSensePairViewController;
+(id)instantiateSenseSetupViewController;
+(id)instantiateSenseUpgradedViewController;
+(id)instantiateVoiceTutorialViewController;
+(id)instantiateWeightPickerViewController;
+(id)instantiateWelcomeViewController;
+(id)instantiateWifiPickerViewController;
+(id)instantiateWifiViewController;

@end
