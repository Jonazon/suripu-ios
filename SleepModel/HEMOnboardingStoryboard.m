//
// HEMOnboardingStoryboard.m
// Copyright (c) 2017 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <UIKit/UIKit.h>
#import "HEMOnboardingStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMonboarding = @"Onboarding";
static NSString *const _HEMbeforeSleepToSmartAlarm = @"beforeSleepToSmartAlarm";
static NSString *const _HEMbeforeSleeptoRoomCheck = @"beforeSleeptoRoomCheck";
static NSString *const _HEMdfu = @"dfu";
static NSString *const _HEMdobViewController = @"dobViewController";
static NSString *const _HEMdone = @"done";
static NSString *const _HEMemail = @"email";
static NSString *const _HEMfinish = @"finish";
static NSString *const _HEMfirstAlarm = @"firstAlarm";
static NSString *const _HEMfirstName = @"firstName";
static NSString *const _HEMgender = @"gender";
static NSString *const _HEMgenderPicker = @"genderPicker";
static NSString *const _HEMhealthKitToLocation = @"healthKitToLocation";
static NSString *const _HEMheight = @"height";
static NSString *const _HEMheightPicker = @"heightPicker";
static NSString *const _HEMlastName = @"lastName";
static NSString *const _HEMlocationToPush = @"locationToPush";
static NSString *const _HEMmoreInfo = @"moreInfo";
static NSString *const _HEMnetwork = @"network";
static NSString *const _HEMnewSense = @"newSense";
static NSString *const _HEMnoBLE = @"noBLE";
static NSString *const _HEMnoBle = @"noBle";
static NSString *const _HEMnoBleToBirthday = @"noBleToBirthday";
static NSString *const _HEMnotificationToSense = @"notificationToSense";
static NSString *const _HEMonboardingComplete = @"onboardingComplete";
static NSString *const _HEMpair = @"pair";
static NSString *const _HEMpairPill = @"pairPill";
static NSString *const _HEMpassword = @"password";
static NSString *const _HEMphoto = @"photo";
static NSString *const _HEMpillDescription = @"pillDescription";
static NSString *const _HEMpillPair = @"pillPair";
static NSString *const _HEMpillSetup = @"pillSetup";
static NSString *const _HEMpillSetupTextCell = @"pillSetupTextCell";
static NSString *const _HEMpillSetupToColors = @"pillSetupToColors";
static NSString *const _HEMpillSetupVideoCell = @"pillSetupVideoCell";
static NSString *const _HEMregister = @"register";
static NSString *const _HEMreset = @"reset";
static NSString *const _HEMresetSense = @"resetSense";
static NSString *const _HEMroomCheck = @"roomCheck";
static NSString *const _HEMroomCheckToSmartAlarm = @"roomCheckToSmartAlarm";
static NSString *const _HEMsenseColors = @"senseColors";
static NSString *const _HEMsenseDFU = @"senseDFU";
static NSString *const _HEMsensePairToPill = @"sensePairToPill";
static NSString *const _HEMsensePairViewController = @"sensePairViewController";
static NSString *const _HEMsenseSetup = @"senseSetup";
static NSString *const _HEMsenseUpgraded = @"senseUpgraded";
static NSString *const _HEMsignupToNoBle = @"signupToNoBle";
static NSString *const _HEMskipPillPairSegue = @"skipPillPairSegue";
static NSString *const _HEMtitle = @"title";
static NSString *const _HEMupdateSense = @"updateSense";
static NSString *const _HEMupgradeDone = @"upgradeDone";
static NSString *const _HEMvoice = @"voice";
static NSString *const _HEMvoiceTutorial = @"voiceTutorial";
static NSString *const _HEMweight = @"weight";
static NSString *const _HEMweightPicker = @"weightPicker";
static NSString *const _HEMweightToHealthKit = @"weightToHealthKit";
static NSString *const _HEMweightToLocation = @"weightToLocation";
static NSString *const _HEMwelcome = @"welcome";
static NSString *const _HEMwifi = @"wifi";
static NSString *const _HEMwifiPassword = @"wifiPassword";
static NSString *const _HEMwifiPicker = @"wifiPicker";
static NSString *const _HEMwifiToPill = @"wifiToPill";
static NSString *const _HEMwifiViewController = @"wifiViewController";

@implementation HEMOnboardingStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMonboarding bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)emailReuseIdentifier { return _HEMemail; }
+(NSString *)firstNameReuseIdentifier { return _HEMfirstName; }
+(NSString *)genderReuseIdentifier { return _HEMgender; }
+(NSString *)lastNameReuseIdentifier { return _HEMlastName; }
+(NSString *)networkReuseIdentifier { return _HEMnetwork; }
+(NSString *)passwordReuseIdentifier { return _HEMpassword; }
+(NSString *)photoReuseIdentifier { return _HEMphoto; }
+(NSString *)pillSetupTextCellReuseIdentifier { return _HEMpillSetupTextCell; }
+(NSString *)pillSetupVideoCellReuseIdentifier { return _HEMpillSetupVideoCell; }
+(NSString *)titleReuseIdentifier { return _HEMtitle; }

/** Segue Identifiers */
+(NSString *)beforeSleepToSmartAlarmSegueIdentifier { return _HEMbeforeSleepToSmartAlarm; }
+(NSString *)beforeSleeptoRoomCheckSegueIdentifier { return _HEMbeforeSleeptoRoomCheck; }
+(NSString *)dfuSegueIdentifier { return _HEMdfu; }
+(NSString *)doneSegueIdentifier { return _HEMdone; }
+(NSString *)finishSegueIdentifier { return _HEMfinish; }
+(NSString *)genderSegueIdentifier { return _HEMgender; }
+(NSString *)healthKitToLocationSegueIdentifier { return _HEMhealthKitToLocation; }
+(NSString *)heightSegueIdentifier { return _HEMheight; }
+(NSString *)locationToPushSegueIdentifier { return _HEMlocationToPush; }
+(NSString *)moreInfoSegueIdentifier { return _HEMmoreInfo; }
+(NSString *)noBLESegueIdentifier { return _HEMnoBLE; }
+(NSString *)noBleToBirthdaySegueIdentifier { return _HEMnoBleToBirthday; }
+(NSString *)notificationToSenseSegueIdentifier { return _HEMnotificationToSense; }
+(NSString *)pairSegueIdentifier { return _HEMpair; }
+(NSString *)pairPillSegueIdentifier { return _HEMpairPill; }
+(NSString *)pillSetupToColorsSegueIdentifier { return _HEMpillSetupToColors; }
+(NSString *)registerSegueIdentifier { return _HEMregister; }
+(NSString *)resetSegueIdentifier { return _HEMreset; }
+(NSString *)roomCheckToSmartAlarmSegueIdentifier { return _HEMroomCheckToSmartAlarm; }
+(NSString *)sensePairToPillSegueIdentifier { return _HEMsensePairToPill; }
+(NSString *)signupToNoBleSegueIdentifier { return _HEMsignupToNoBle; }
+(NSString *)skipPillPairSegue { return _HEMskipPillPairSegue; }
+(NSString *)updateSenseSegueIdentifier { return _HEMupdateSense; }
+(NSString *)upgradeDoneSegueIdentifier { return _HEMupgradeDone; }
+(NSString *)voiceSegueIdentifier { return _HEMvoice; }
+(NSString *)voiceTutorialSegueIdentifier { return _HEMvoiceTutorial; }
+(NSString *)weightSegueIdentifier { return _HEMweight; }
+(NSString *)weightToHealthKitSegueIdentifier { return _HEMweightToHealthKit; }
+(NSString *)weightToLocationSegueIdentifier { return _HEMweightToLocation; }
+(NSString *)wifiSegueIdentifier { return _HEMwifi; }
+(NSString *)wifiPasswordSegueIdentifier { return _HEMwifiPassword; }
+(NSString *)wifiToPillSegueIdentifier { return _HEMwifiToPill; }

/** View Controllers */
+(id)instantiateDobViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMdobViewController]; }
+(id)instantiateFirstAlarmViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMfirstAlarm]; }
+(id)instantiateGenderPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMgenderPicker]; }
+(id)instantiateHeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMheightPicker]; }
+(id)instantiateNewSenseViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMnewSense]; }
+(id)instantiateNoBleViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMnoBle]; }
+(id)instantiateOnboardingCompleteViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMonboardingComplete]; }
+(id)instantiatePillDescriptionViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillDescription]; }
+(id)instantiatePillPairViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillPair]; }
+(id)instantiatePillSetupViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillSetup]; }
+(id)instantiateResetSenseViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMresetSense]; }
+(id)instantiateRoomCheckViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMroomCheck]; }
+(id)instantiateSenseColorsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseColors]; }
+(id)instantiateSenseDFUViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseDFU]; }
+(id)instantiateSensePairViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsensePairViewController]; }
+(id)instantiateSenseSetupViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseSetup]; }
+(id)instantiateSenseUpgradedViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsenseUpgraded]; }
+(id)instantiateVoiceTutorialViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMvoiceTutorial]; }
+(id)instantiateWeightPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMweightPicker]; }
+(id)instantiateWelcomeViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwelcome]; }
+(id)instantiateWifiPickerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiPicker]; }
+(id)instantiateWifiViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMwifiViewController]; }

@end
