//
// HEMMainStoryboard.h
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMMainStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)alarmSwitchCellReuseIdentifier;
+(NSString *)alarmSoundCellReuseIdentifier;
+(NSString *)alarmRepeatCellReuseIdentifier;
+(NSString *)alarmLightCellReuseIdentifier;
+(NSString *)alarmDeleteCellReuseIdentifier;
+(NSString *)singleReuseIdentifier;
+(NSString *)multipleReuseIdentifier;
+(NSString *)preferenceReuseIdentifier;
+(NSString *)imageReuseIdentifier;
+(NSString *)summaryReuseIdentifier;
+(NSString *)titleReuseIdentifier;
+(NSString *)loadingReuseIdentifier;
+(NSString *)detailReuseIdentifier;
+(NSString *)aboutReuseIdentifier;
+(NSString *)optionReuseIdentifier;
+(NSString *)infoCellReuseIdentifier;
+(NSString *)errorReuseIdentifier;
+(NSString *)expansionReuseIdentifier;
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
+(NSString *)currentValueReuseIdentifier;
+(NSString *)chartReuseIdentifier;
+(NSString *)scaleReuseIdentifier;
+(NSString *)alarmListCellReuseIdentifier;
+(NSString *)alarmListEmptyCellReuseIdentifier;
+(NSString *)alarmListStatusCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)sensorReuseIdentifier;
+(NSString *)groupReuseIdentifier;
+(NSString *)questionReuseIdentifier;
+(NSString *)insightReuseIdentifier;
+(NSString *)settingsReuseIdentifier;
+(NSString *)messageReuseIdentifier;
+(NSString *)calendarReuseIdentifier;
+(NSString *)barReuseIdentifier;
+(NSString *)bubblesReuseIdentifier;
+(NSString *)listItemReuseIdentifier;
+(NSString *)summaryViewCellReuseIdentifier;
+(NSString *)breakdownLineCellReuseIdentifier;
+(NSString *)fieldReuseIdentifier;

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier;
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)alarmSoundsSegueIdentifier;
+(NSString *)alarmsSegueIdentifier;
+(NSString *)connectSegueIdentifier;
+(NSString *)detailSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)expansionSegueIdentifier;
+(NSString *)expansionLightSegueIdentifier;
+(NSString *)expansionsSegueIdentifier;
+(NSString *)listSegueIdentifier;
+(NSString *)notificationSettingsSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)scanSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)settingsToSupportSegueIdentifier;
+(NSString *)sleepSoundsSegueIdentifier;
+(NSString *)timezoneSegueIdentifier;
+(NSString *)topicsSegueIdentifier;
+(NSString *)unitsSettingsSegueIdentifier;
+(NSString *)updateAccountInfoSegueIdentifier;

/** View Controllers */
+(id)instantiateRootViewController;
+(id)instantiateActionSheetViewController;
+(id)instantiateAlarmListNavViewController;
+(id)instantiateAlarmListViewController;
+(id)instantiateAlarmNavController;
+(id)instantiateAlarmViewController;
+(id)instantiateBreakdownController;
+(id)instantiateCurrentNavController;
+(id)instantiateExpansionConfigViewController;
+(id)instantiateFeedViewController;
+(id)instantiateFormViewController;
+(id)instantiateInfoNavigationController;
+(id)instantiateInfoViewController;
+(id)instantiateInsightsFeedViewController;
+(id)instantiateListItemViewController;
+(id)instantiatePillDFUViewController;
+(id)instantiatePillDFUNavViewController;
+(id)instantiatePillFinderViewController;
+(id)instantiateSettingsController;
+(id)instantiateSettingsNavController;
+(id)instantiateSleepGraphController;
+(id)instantiateSleepHistoryController;
+(id)instantiateSleepInsightViewController;
+(id)instantiateSleepQuestionsViewController;
+(id)instantiateSleepSoundViewController;
+(id)instantiateSoundsContainerViewController;
+(id)instantiateSoundsNavigationViewController;
+(id)instantiateSupportTopicsViewController;
+(id)instantiateTimeZoneNavViewController;
+(id)instantiateTimeZoneViewController;
+(id)instantiateTimelineContainerController;
+(id)instantiateTimelineFeedbackViewController;
+(id)instantiateTrendsViewController;
+(id)instantiateTutorialViewController;
+(id)instantiateVoiceViewController;

@end
