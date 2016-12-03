//
// HEMSettingsStoryboard.h
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMSettingsStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)preferenceReuseIdentifier;
+(NSString *)errorReuseIdentifier;
+(NSString *)expansionReuseIdentifier;
+(NSString *)voiceSettingCellReuseIdentifier;
+(NSString *)switchReuseIdentifier;
+(NSString *)plainReuseIdentifier;
+(NSString *)configReuseIdentifier;
+(NSString *)textReuseIdentifier;
+(NSString *)toggleReuseIdentifier;
+(NSString *)infoReuseIdentifier;
+(NSString *)explanationReuseIdentifier;
+(NSString *)signoutReuseIdentifier;
+(NSString *)unitCellReuseIdentifier;
+(NSString *)settingsCellReuseIdentifier;
+(NSString *)senseReuseIdentifier;
+(NSString *)pillReuseIdentifier;
+(NSString *)pairReuseIdentifier;
+(NSString *)supportCellReuseIdentifier;
+(NSString *)topicCellReuseIdentifier;
+(NSString *)warningReuseIdentifier;
+(NSString *)actionReuseIdentifier;
+(NSString *)connectionReuseIdentifier;
+(NSString *)timezoneReuseIdentifier;
+(NSString *)fieldReuseIdentifier;

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier;
+(NSString *)connectSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)expansionSegueIdentifier;
+(NSString *)expansionsSegueIdentifier;
+(NSString *)notificationSettingsSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)settingsToSupportSegueIdentifier;
+(NSString *)timezoneSegueIdentifier;
+(NSString *)topicsSegueIdentifier;
+(NSString *)unitsSegueIdentifier;
+(NSString *)updateAccountInfoSegueIdentifier;
+(NSString *)voiceSegueIdentifier;
+(NSString *)volumeSegueIdentifier;

/** View Controllers */
+(id)instantiateExpansionController;
+(id)instantiateFormViewController;
+(id)instantiateSettingsController;
+(id)instantiateSettingsNavController;
+(id)instantiateSupportTopicsViewController;
+(id)instantiateTimeZoneNavViewController;
+(id)instantiateTimeZoneViewController;
+(id)instantiateUnitPreferenceViewController;

@end
