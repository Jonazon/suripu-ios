//
// HEMMainStoryboard.m
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <UIKit/UIKit.h>
#import "HEMMainStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMmain = @"Main";
static NSString *const _HEMrootViewController = @"RootViewController";
static NSString *const _HEMabout = @"about";
static NSString *const _HEMaccountSettings = @"accountSettings";
static NSString *const _HEMaction = @"action";
static NSString *const _HEMactionSheetViewController = @"actionSheetViewController";
static NSString *const _HEMalarmDeleteCell = @"alarmDeleteCell";
static NSString *const _HEMalarmExpansionCell = @"alarmExpansionCell";
static NSString *const _HEMalarmListCell = @"alarmListCell";
static NSString *const _HEMalarmListEmptyCell = @"alarmListEmptyCell";
static NSString *const _HEMalarmListNavViewController = @"alarmListNavViewController";
static NSString *const _HEMalarmListStatusCell = @"alarmListStatusCell";
static NSString *const _HEMalarmListViewController = @"alarmListViewController";
static NSString *const _HEMalarmNavController = @"alarmNavController";
static NSString *const _HEMalarmRepeat = @"alarmRepeat";
static NSString *const _HEMalarmRepeatCell = @"alarmRepeatCell";
static NSString *const _HEMalarmSoundCell = @"alarmSoundCell";
static NSString *const _HEMalarmSounds = @"alarmSounds";
static NSString *const _HEMalarmSwitchCell = @"alarmSwitchCell";
static NSString *const _HEMalarmViewController = @"alarmViewController";
static NSString *const _HEMalarms = @"alarms";
static NSString *const _HEMbar = @"bar";
static NSString *const _HEMbreakdownController = @"breakdownController";
static NSString *const _HEMbreakdownLineCell = @"breakdownLineCell";
static NSString *const _HEMbubbles = @"bubbles";
static NSString *const _HEMcalendar = @"calendar";
static NSString *const _HEMchart = @"chart";
static NSString *const _HEMcommandGroup = @"commandGroup";
static NSString *const _HEMcommands = @"commands";
static NSString *const _HEMconfig = @"config";
static NSString *const _HEMconfiguration = @"configuration";
static NSString *const _HEMconnect = @"connect";
static NSString *const _HEMconnection = @"connection";
static NSString *const _HEMcurrentNavController = @"currentNavController";
static NSString *const _HEMcurrentValue = @"currentValue";
static NSString *const _HEMdetail = @"detail";
static NSString *const _HEMdevicesSettings = @"devicesSettings";
static NSString *const _HEMerror = @"error";
static NSString *const _HEMexamples = @"examples";
static NSString *const _HEMexpansion = @"expansion";
static NSString *const _HEMexpansionConfig = @"expansionConfig";
static NSString *const _HEMexpansions = @"expansions";
static NSString *const _HEMexplanation = @"explanation";
static NSString *const _HEMfeed = @"feed";
static NSString *const _HEMfield = @"field";
static NSString *const _HEMformViewController = @"formViewController";
static NSString *const _HEMgroup = @"group";
static NSString *const _HEMimage = @"image";
static NSString *const _HEMinfo = @"info";
static NSString *const _HEMinfoCell = @"infoCell";
static NSString *const _HEMinfoNavigationController = @"infoNavigationController";
static NSString *const _HEMinfoViewController = @"infoViewController";
static NSString *const _HEMinsight = @"insight";
static NSString *const _HEMinsightsFeed = @"insightsFeed";
static NSString *const _HEMlist = @"list";
static NSString *const _HEMlistItem = @"listItem";
static NSString *const _HEMloading = @"loading";
static NSString *const _HEMmessage = @"message";
static NSString *const _HEMmultiple = @"multiple";
static NSString *const _HEMnotificationSettings = @"notificationSettings";
static NSString *const _HEMoption = @"option";
static NSString *const _HEMpair = @"pair";
static NSString *const _HEMpill = @"pill";
static NSString *const _HEMpillDFU = @"pillDFU";
static NSString *const _HEMpillDFUNav = @"pillDFUNav";
static NSString *const _HEMpillFinder = @"pillFinder";
static NSString *const _HEMplain = @"plain";
static NSString *const _HEMpreference = @"preference";
static NSString *const _HEMquestion = @"question";
static NSString *const _HEMscale = @"scale";
static NSString *const _HEMscan = @"scan";
static NSString *const _HEMsense = @"sense";
static NSString *const _HEMsensor = @"sensor";
static NSString *const _HEMsettings = @"settings";
static NSString *const _HEMsettingsCell = @"settingsCell";
static NSString *const _HEMsettingsController = @"settingsController";
static NSString *const _HEMsettingsNavController = @"settingsNavController";
static NSString *const _HEMsettingsToSupport = @"settingsToSupport";
static NSString *const _HEMsignout = @"signout";
static NSString *const _HEMsingle = @"single";
static NSString *const _HEMsleepGraphController = @"sleepGraphController";
static NSString *const _HEMsleepHistoryController = @"sleepHistoryController";
static NSString *const _HEMsleepInsight = @"sleepInsight";
static NSString *const _HEMsleepQuestions = @"sleepQuestions";
static NSString *const _HEMsleepSound = @"sleepSound";
static NSString *const _HEMsleepSounds = @"sleepSounds";
static NSString *const _HEMsoundsContainer = @"soundsContainer";
static NSString *const _HEMsoundsNavigation = @"soundsNavigation";
static NSString *const _HEMsummary = @"summary";
static NSString *const _HEMsummaryViewCell = @"summaryViewCell";
static NSString *const _HEMsupportCell = @"supportCell";
static NSString *const _HEMsupportTopicsViewController = @"supportTopicsViewController";
static NSString *const _HEMswitch = @"switch";
static NSString *const _HEMtext = @"text";
static NSString *const _HEMtimeSliceCell = @"timeSliceCell";
static NSString *const _HEMtimeZoneNavViewController = @"timeZoneNavViewController";
static NSString *const _HEMtimeZoneViewController = @"timeZoneViewController";
static NSString *const _HEMtimelineContainerController = @"timelineContainerController";
static NSString *const _HEMtimelineFeedback = @"timelineFeedback";
static NSString *const _HEMtimezone = @"timezone";
static NSString *const _HEMtitle = @"title";
static NSString *const _HEMtoggle = @"toggle";
static NSString *const _HEMtopicCell = @"topicCell";
static NSString *const _HEMtopics = @"topics";
static NSString *const _HEMtrends = @"trends";
static NSString *const _HEMtutorialViewController = @"tutorialViewController";
static NSString *const _HEMunitCell = @"unitCell";
static NSString *const _HEMunitsSettings = @"unitsSettings";
static NSString *const _HEMupdateAccountInfo = @"updateAccountInfo";
static NSString *const _HEMvoice = @"voice";
static NSString *const _HEMvolume = @"volume";
static NSString *const _HEMwarning = @"warning";
static NSString *const _HEMwelcome = @"welcome";

@implementation HEMMainStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMmain bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)aboutReuseIdentifier { return _HEMabout; }
+(NSString *)actionReuseIdentifier { return _HEMaction; }
+(NSString *)alarmDeleteCellReuseIdentifier { return _HEMalarmDeleteCell; }
+(NSString *)alarmExpansionCellReuseIdentifier { return _HEMalarmExpansionCell; }
+(NSString *)alarmListCellReuseIdentifier { return _HEMalarmListCell; }
+(NSString *)alarmListEmptyCellReuseIdentifier { return _HEMalarmListEmptyCell; }
+(NSString *)alarmListStatusCellReuseIdentifier { return _HEMalarmListStatusCell; }
+(NSString *)alarmRepeatCellReuseIdentifier { return _HEMalarmRepeatCell; }
+(NSString *)alarmSoundCellReuseIdentifier { return _HEMalarmSoundCell; }
+(NSString *)alarmSwitchCellReuseIdentifier { return _HEMalarmSwitchCell; }
+(NSString *)barReuseIdentifier { return _HEMbar; }
+(NSString *)breakdownLineCellReuseIdentifier { return _HEMbreakdownLineCell; }
+(NSString *)bubblesReuseIdentifier { return _HEMbubbles; }
+(NSString *)calendarReuseIdentifier { return _HEMcalendar; }
+(NSString *)chartReuseIdentifier { return _HEMchart; }
+(NSString *)commandGroupReuseIdentifier { return _HEMcommandGroup; }
+(NSString *)commandsReuseIdentifier { return _HEMcommands; }
+(NSString *)configReuseIdentifier { return _HEMconfig; }
+(NSString *)configurationReuseIdentifier { return _HEMconfiguration; }
+(NSString *)connectionReuseIdentifier { return _HEMconnection; }
+(NSString *)currentValueReuseIdentifier { return _HEMcurrentValue; }
+(NSString *)detailReuseIdentifier { return _HEMdetail; }
+(NSString *)errorReuseIdentifier { return _HEMerror; }
+(NSString *)examplesReuseIdentifier { return _HEMexamples; }
+(NSString *)expansionReuseIdentifier { return _HEMexpansion; }
+(NSString *)explanationReuseIdentifier { return _HEMexplanation; }
+(NSString *)fieldReuseIdentifier { return _HEMfield; }
+(NSString *)groupReuseIdentifier { return _HEMgroup; }
+(NSString *)imageReuseIdentifier { return _HEMimage; }
+(NSString *)infoReuseIdentifier { return _HEMinfo; }
+(NSString *)infoCellReuseIdentifier { return _HEMinfoCell; }
+(NSString *)insightReuseIdentifier { return _HEMinsight; }
+(NSString *)listItemReuseIdentifier { return _HEMlistItem; }
+(NSString *)loadingReuseIdentifier { return _HEMloading; }
+(NSString *)messageReuseIdentifier { return _HEMmessage; }
+(NSString *)multipleReuseIdentifier { return _HEMmultiple; }
+(NSString *)optionReuseIdentifier { return _HEMoption; }
+(NSString *)pairReuseIdentifier { return _HEMpair; }
+(NSString *)pillReuseIdentifier { return _HEMpill; }
+(NSString *)plainReuseIdentifier { return _HEMplain; }
+(NSString *)preferenceReuseIdentifier { return _HEMpreference; }
+(NSString *)questionReuseIdentifier { return _HEMquestion; }
+(NSString *)scaleReuseIdentifier { return _HEMscale; }
+(NSString *)senseReuseIdentifier { return _HEMsense; }
+(NSString *)sensorReuseIdentifier { return _HEMsensor; }
+(NSString *)settingsReuseIdentifier { return _HEMsettings; }
+(NSString *)settingsCellReuseIdentifier { return _HEMsettingsCell; }
+(NSString *)signoutReuseIdentifier { return _HEMsignout; }
+(NSString *)singleReuseIdentifier { return _HEMsingle; }
+(NSString *)summaryReuseIdentifier { return _HEMsummary; }
+(NSString *)summaryViewCellReuseIdentifier { return _HEMsummaryViewCell; }
+(NSString *)supportCellReuseIdentifier { return _HEMsupportCell; }
+(NSString *)switchReuseIdentifier { return _HEMswitch; }
+(NSString *)textReuseIdentifier { return _HEMtext; }
+(NSString *)timeSliceCellReuseIdentifier { return _HEMtimeSliceCell; }
+(NSString *)timezoneReuseIdentifier { return _HEMtimezone; }
+(NSString *)titleReuseIdentifier { return _HEMtitle; }
+(NSString *)toggleReuseIdentifier { return _HEMtoggle; }
+(NSString *)topicCellReuseIdentifier { return _HEMtopicCell; }
+(NSString *)unitCellReuseIdentifier { return _HEMunitCell; }
+(NSString *)warningReuseIdentifier { return _HEMwarning; }
+(NSString *)welcomeReuseIdentifier { return _HEMwelcome; }

/** Segue Identifiers */
+(NSString *)accountSettingsSegueIdentifier { return _HEMaccountSettings; }
+(NSString *)alarmRepeatSegueIdentifier { return _HEMalarmRepeat; }
+(NSString *)alarmSoundsSegueIdentifier { return _HEMalarmSounds; }
+(NSString *)alarmsSegueIdentifier { return _HEMalarms; }
+(NSString *)connectSegueIdentifier { return _HEMconnect; }
+(NSString *)detailSegueIdentifier { return _HEMdetail; }
+(NSString *)devicesSettingsSegueIdentifier { return _HEMdevicesSettings; }
+(NSString *)expansionSegueIdentifier { return _HEMexpansion; }
+(NSString *)expansionConfigSegueIdentifier { return _HEMexpansionConfig; }
+(NSString *)expansionsSegueIdentifier { return _HEMexpansions; }
+(NSString *)listSegueIdentifier { return _HEMlist; }
+(NSString *)notificationSettingsSegueIdentifier { return _HEMnotificationSettings; }
+(NSString *)pillSegueIdentifier { return _HEMpill; }
+(NSString *)scanSegueIdentifier { return _HEMscan; }
+(NSString *)senseSegueIdentifier { return _HEMsense; }
+(NSString *)settingsToSupportSegueIdentifier { return _HEMsettingsToSupport; }
+(NSString *)sleepSoundsSegueIdentifier { return _HEMsleepSounds; }
+(NSString *)timezoneSegueIdentifier { return _HEMtimezone; }
+(NSString *)topicsSegueIdentifier { return _HEMtopics; }
+(NSString *)unitsSettingsSegueIdentifier { return _HEMunitsSettings; }
+(NSString *)updateAccountInfoSegueIdentifier { return _HEMupdateAccountInfo; }
+(NSString *)voiceSegueIdentifier { return _HEMvoice; }
+(NSString *)volumeSegueIdentifier { return _HEMvolume; }

/** View Controllers */
+(id)instantiateRootViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMrootViewController]; }
+(id)instantiateActionSheetViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMactionSheetViewController]; }
+(id)instantiateAlarmListNavViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmListNavViewController]; }
+(id)instantiateAlarmListViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmListViewController]; }
+(id)instantiateAlarmNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmNavController]; }
+(id)instantiateAlarmViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmViewController]; }
+(id)instantiateBreakdownController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMbreakdownController]; }
+(id)instantiateCurrentNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentNavController]; }
+(id)instantiateExpansionConfigViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMexpansionConfig]; }
+(id)instantiateFeedViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMfeed]; }
+(id)instantiateFormViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMformViewController]; }
+(id)instantiateInfoNavigationController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMinfoNavigationController]; }
+(id)instantiateInfoViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMinfoViewController]; }
+(id)instantiateInsightsFeedViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMinsightsFeed]; }
+(id)instantiateListItemViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMlistItem]; }
+(id)instantiatePillDFUViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillDFU]; }
+(id)instantiatePillDFUNavViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillDFUNav]; }
+(id)instantiatePillFinderViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMpillFinder]; }
+(id)instantiateSettingsController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsController]; }
+(id)instantiateSettingsNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsNavController]; }
+(id)instantiateSleepGraphController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepGraphController]; }
+(id)instantiateSleepHistoryController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepHistoryController]; }
+(id)instantiateSleepInsightViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepInsight]; }
+(id)instantiateSleepQuestionsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepQuestions]; }
+(id)instantiateSleepSoundViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepSound]; }
+(id)instantiateSoundsContainerViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsoundsContainer]; }
+(id)instantiateSoundsNavigationViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsoundsNavigation]; }
+(id)instantiateSupportTopicsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsupportTopicsViewController]; }
+(id)instantiateTimeZoneNavViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtimeZoneNavViewController]; }
+(id)instantiateTimeZoneViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtimeZoneViewController]; }
+(id)instantiateTimelineContainerController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtimelineContainerController]; }
+(id)instantiateTimelineFeedbackViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtimelineFeedback]; }
+(id)instantiateTrendsViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtrends]; }
+(id)instantiateTutorialViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMtutorialViewController]; }
+(id)instantiateVoiceViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMvoice]; }

@end
