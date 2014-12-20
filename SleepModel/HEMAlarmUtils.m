
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import "HEMAlarmUtils.h"
#import "HEMAlertController.h"

@implementation HEMAlarmUtils

+ (NSString*)repeatTextForUnitFlags:(NSUInteger)alarmRepeatFlags
{
    switch (alarmRepeatFlags) {
    case 0:
        return NSLocalizedString(@"alarm.repeat.days.none", nil);
    case (SENAlarmRepeatSaturday | SENAlarmRepeatSunday):
        return NSLocalizedString(@"alarm.repeat.days.weekends", nil);
    case (SENAlarmRepeatMonday | SENAlarmRepeatTuesday | SENAlarmRepeatWednesday | SENAlarmRepeatThursday | SENAlarmRepeatFriday):
        return NSLocalizedString(@"alarm.repeat.days.weekdays", nil);
    case (SENAlarmRepeatSunday | SENAlarmRepeatMonday | SENAlarmRepeatTuesday | SENAlarmRepeatWednesday | SENAlarmRepeatThursday | SENAlarmRepeatFriday | SENAlarmRepeatSaturday):
        return NSLocalizedString(@"alarm.repeat.days.all", nil);
    default: {
        NSMutableArray* days = [[NSMutableArray alloc] initWithCapacity:6];
        if ((alarmRepeatFlags & SENAlarmRepeatSunday) == SENAlarmRepeatSunday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.sunday.short", nil)];
        if ((alarmRepeatFlags & SENAlarmRepeatMonday) == SENAlarmRepeatMonday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.monday.short", nil)];
        if ((alarmRepeatFlags & SENAlarmRepeatTuesday) == SENAlarmRepeatTuesday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.tuesday.short", nil)];
        if ((alarmRepeatFlags & SENAlarmRepeatWednesday) == SENAlarmRepeatWednesday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.wednesday.short", nil)];
        if ((alarmRepeatFlags & SENAlarmRepeatThursday) == SENAlarmRepeatThursday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.thursday.short", nil)];
        if ((alarmRepeatFlags & SENAlarmRepeatFriday) == SENAlarmRepeatFriday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.friday.short", nil)];
        if ((alarmRepeatFlags & SENAlarmRepeatSaturday) == SENAlarmRepeatSaturday)
            [days addObject:NSLocalizedString(@"alarm.repeat.days.saturday.short", nil)];
        return [days componentsJoinedByString:@" "];
    }
    }
}

+ (void)refreshAlarmsFromPresentingController:(UIViewController*)controller completion:(void (^)())completion
{
    UIBarButtonItem* rightButton = controller.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem* loadItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    controller.navigationItem.rightBarButtonItem = loadItem;
    [indicatorView startAnimating];
    [SENAPIAlarms alarmsWithCompletion:^(NSArray* alarms, NSError* error) {
        if (error) {
            [self showError:error
                  withTitle:NSLocalizedString(@"alarm.load-error.title", nil)
               onController:controller];
        } else {
            [SENAlarm clearSavedAlarms];
            for (SENAlarm* alarm in alarms) {
                [alarm save];
            }
        }
        [indicatorView stopAnimating];
        controller.navigationItem.rightBarButtonItem = rightButton;
        if (completion)
            completion();
    }];
}

+ (void)updateAlarmsFromPresentingController:(UIViewController*)controller completion:(void (^)(BOOL))completion
{
    UIBarButtonItem* rightButton = controller.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem* loadItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    controller.navigationItem.rightBarButtonItem = loadItem;
    [indicatorView startAnimating];
    [SENAPIAlarms updateAlarms:[SENAlarm savedAlarms] completion:^(id data, NSError* error) {
        [indicatorView stopAnimating];
        controller.navigationItem.rightBarButtonItem = rightButton;
        if (error) {
            [self showError:error
                  withTitle:NSLocalizedString(@"alarm.save-error.title", nil)
               onController:controller];
        }
        if (controller && completion)
            completion(!error);
    }];
}

+ (void)showError:(NSError*)error withTitle:(NSString*)title onController:(UIViewController*)controller
{
    [HEMAlertController presentInfoAlertWithTitle:title
                                          message:error.localizedDescription
                             presentingController:controller];
}

@end
