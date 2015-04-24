//
// HEMMainStoryboard.h
// Copyright (c) 2015 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMMainStoryboard : NSObject

+(UIStoryboard *)storyboard;

/** Cell Reuse Identifiers */
+(NSString *)alarmSwitchCellReuseIdentifier;
+(NSString *)alarmSoundCellReuseIdentifier;
+(NSString *)alarmRepeatCellReuseIdentifier;
+(NSString *)alarmDeleteCellReuseIdentifier;
+(NSString *)singleReuseIdentifier;
+(NSString *)multipleReuseIdentifier;
+(NSString *)preferenceReuseIdentifier;
+(NSString *)imageReuseIdentifier;
+(NSString *)textReuseIdentifier;
+(NSString *)optionReuseIdentifier;
+(NSString *)infoReuseIdentifier;
+(NSString *)explanationReuseIdentifier;
+(NSString *)signoutReuseIdentifier;
+(NSString *)unitCellReuseIdentifier;
+(NSString *)settingsCellReuseIdentifier;
+(NSString *)pairReuseIdentifier;
+(NSString *)deviceReuseIdentifier;
+(NSString *)warningReuseIdentifier;
+(NSString *)actionsReuseIdentifier;
+(NSString *)timezoneReuseIdentifier;
+(NSString *)choiceCellReuseIdentifier;
+(NSString *)alarmListCellReuseIdentifier;
+(NSString *)alarmListEmptyCellReuseIdentifier;
+(NSString *)alarmListStatusCellReuseIdentifier;
+(NSString *)alarmChoiceCellReuseIdentifier;
+(NSString *)sensorGraphCellReuseIdentifier;
+(NSString *)timeSliceCellReuseIdentifier;
+(NSString *)overTimeReuseIdentifier;
+(NSString *)trendGraphReuseIdentifier;
+(NSString *)questionReuseIdentifier;
+(NSString *)insightReuseIdentifier;

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier;
+(NSString *)alarmRepeatSegueIdentifier;
+(NSString *)choiceSegueIdentifier;
+(NSString *)devicesSettingsSegueIdentifier;
+(NSString *)notificationSettingsSegueIdentifier;
+(NSString *)pickSoundSegueIdentifier;
+(NSString *)pillSegueIdentifier;
+(NSString *)senseSegueIdentifier;
+(NSString *)timezoneSegueIdentifier;
+(NSString *)unitsSettingsSegueIdentifier;
+(NSString *)updateEmailSegueIdentifier;
+(NSString *)updateNameSegueIdentifier;
+(NSString *)updatePasswordSegueIdentifier;

/** View Controllers */
+(id)instantiateRootViewController;
+(id)instantiateActionSheetViewController;
+(id)instantiateAlarmListNavViewController;
+(id)instantiateAlarmListViewController;
+(id)instantiateAlarmNavController;
+(id)instantiateAlarmRepeatTableViewController;
+(id)instantiateAlarmViewController;
+(id)instantiateCurrentNavController;
+(id)instantiateInsightFeedViewController;
+(id)instantiateSensorViewController;
+(id)instantiateSettingsController;
+(id)instantiateSettingsNavController;
+(id)instantiateSleepGraphController;
+(id)instantiateSleepGraphNavController;
+(id)instantiateSleepHistoryController;
+(id)instantiateSleepInsightViewController;
+(id)instantiateSleepQuestionsViewController;
+(id)instantiateTimeZoneNavViewController;
+(id)instantiateTimeZoneViewController;
+(id)instantiateTimelineFeedbackViewController;
+(id)instantiateTrendsViewController;

@end
