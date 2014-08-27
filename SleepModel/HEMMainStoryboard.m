//
// HEMMainStoryboard.m
// File generated using Ovaltine

#import <UIKit/UIKit.h>
#import "HEMMainStoryboard.h"

static UIStoryboard *_storyboard = nil;
static NSString *const _HEMMain = @"Main";
static NSString *const _HEMalarmSoundTableViewController = @"alarmSoundTableViewController";
static NSString *const _HEMalarmViewController = @"alarmViewController";
static NSString *const _HEMcurrentConditionsCell = @"currentConditionsCell";
static NSString *const _HEMcurrentController = @"currentController";
static NSString *const _HEMcurrentNavController = @"currentNavController";
static NSString *const _HEMinsightCell = @"insightCell";
static NSString *const _HEMlastNightController = @"lastNightController";
static NSString *const _HEMlastNightNavController = @"lastNightNavController";
static NSString *const _HEMpickSoundSegue = @"pickSoundSegue";
static NSString *const _HEMsensorViewController = @"sensorViewController";
static NSString *const _HEMsettingsController = @"settingsController";
static NSString *const _HEMsettingsNavController = @"settingsNavController";
static NSString *const _HEMsleepHistoryController = @"sleepHistoryController";
static NSString *const _HEMsleepSoundCell = @"sleepSoundCell";
static NSString *const _HEMsleepSoundViewController = @"sleepSoundViewController";
static NSString *const _HEMtimeSliceCell = @"timeSliceCell";

@implementation HEMMainStoryboard

+(UIStoryboard *)storyboard { return _storyboard ?: (_storyboard = [UIStoryboard storyboardWithName:_HEMMain bundle:[NSBundle mainBundle]]); }

/** Cell Reuse Identifiers */
+(NSString *)sleepSoundCellReuseIdentifier { return _HEMsleepSoundCell; }
+(NSString *)currentConditionsCellReuseIdentifier { return _HEMcurrentConditionsCell; }
+(NSString *)timeSliceCellReuseIdentifier { return _HEMtimeSliceCell; }
+(NSString *)insightCellReuseIdentifier { return _HEMinsightCell; }

/** Segue Identifiers */
+(NSString *)pickSoundSegueSegueIdentifier { return _HEMpickSoundSegue; }

/** View Controllers */
+(UIViewController *)instantiateAlarmViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmViewController]; }
+(UIViewController *)instantiateSettingsController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsController]; }
+(UIViewController *)instantiateSensorViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsensorViewController]; }
+(UIViewController *)instantiateSleepSoundViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepSoundViewController]; }
+(UIViewController *)instantiateCurrentController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentController]; }
+(UIViewController *)instantiateAlarmSoundTableViewController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMalarmSoundTableViewController]; }
+(UIViewController *)instantiateLastNightController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMlastNightController]; }
+(UIViewController *)instantiateSleepHistoryController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsleepHistoryController]; }
+(UIViewController *)instantiateCurrentNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMcurrentNavController]; }
+(UIViewController *)instantiateSettingsNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMsettingsNavController]; }
+(UIViewController *)instantiateLastNightNavController { return [[self storyboard] instantiateViewControllerWithIdentifier:_HEMlastNightNavController]; }

@end