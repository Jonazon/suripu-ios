
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepGraphViewController.h"

@interface NSDate (HEMEqualityChecker)

- (BOOL)isOnSameDay:(NSDate*)otherDate;
@end

@implementation HEMSleepSummaryPagingDataSource

static CGFloat const HEMSleepSummaryDayInterval = 60 * 60 * 24;

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)controllerAfter:(UIViewController*)viewController {
    HEMSleepGraphViewController* sleepVC =
        (HEMSleepGraphViewController*)viewController;
    NSDate* date = [sleepVC dateForNightOfSleep];
    NSDate* nextDay = [date dateByAddingTimeInterval:HEMSleepSummaryDayInterval];
    if ([nextDay isOnSameDay:[NSDate date]] || [nextDay compare:[NSDate date]] == NSOrderedDescending) {
        return nil; // no data to show in the future
    }
    return [self sleepSummaryControllerWithTimeIntervalOffset:HEMSleepSummaryDayInterval
                                            fromReferenceDate:date];
}

- (UIViewController*)controllerBefore:(UIViewController*)viewController {
        return [self sleepSummaryControllerWithTimeIntervalOffset:-60 * 60 * 24 fromReferenceDate:[(HEMSleepGraphViewController*)viewController dateForNightOfSleep]];
} 

#pragma mark - UIPageViewController

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController {
    return [self controllerAfter:viewController];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController {
    return [self controllerBefore:viewController];
}

- (UIViewController*)sleepSummaryControllerWithTimeIntervalOffset:(NSTimeInterval)offset fromReferenceDate:(NSDate*)date
{
    HEMSleepGraphViewController* controller = (HEMSleepGraphViewController*)[HEMMainStoryboard instantiateSleepGraphController];
    NSDate* nextViewControllerDate = [NSDate dateWithTimeInterval:offset sinceDate:date];
    [controller setDateForNightOfSleep:nextViewControllerDate];
    return controller;
}

@end

@implementation NSDate (HEMEqualityChecker)

+ (NSCalendar*)sharedCalendar
{
    static NSCalendar* calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar currentCalendar];
    });
    return calendar;
}

- (BOOL)isOnSameDay:(NSDate *)otherDate
{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSCalendarUnit flags = (NSMonthCalendarUnit| NSYearCalendarUnit | NSDayCalendarUnit);
    NSDateComponents *components = [calendar components:flags fromDate:self];
    NSDateComponents *otherComponents = [calendar components:flags fromDate:otherDate];

    return ([components day] == [otherComponents day] && [components month] == [otherComponents month] && [components year] == [otherComponents year]);
}

@end
