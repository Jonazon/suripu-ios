//
//  HEMTimelineService.m
//  Sense
//
//  Created by Jimmy Lu on 1/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENAPITimeline.h>

#import "HEMTimelineService.h"
#import "HEMOnboardingService.h"
#import "NSDate+HEMRelative.h"

static CGFloat const HEMTimelineNextDayHour = 3; // hour of day (3am)
static NSString* const HEMTimelineSettingsAccountCreationDate = @"account.creation.date";
static NSString* const kHEMTimelineRangeDateFormat = @"MMMM d";
static NSString* const kHEMTimelineWeekDateFormat = @"EEEE";

NSString* const HEMTimelineNotificationTimelineAmended = @"notification.timeline.amended";

@interface HEMTimelineService()

@property (strong, nonatomic) NSDateFormatter *weekdayDateFormatter;
@property (strong, nonatomic) NSDateFormatter *rangeDateFormatter;
@property (strong, nonatomic) NSCalendar* calendar;

@end

@implementation HEMTimelineService

- (instancetype)init {
    if (self = [super init]) {
        NSDateFormatter* rangeFormatter = [NSDateFormatter new];
        [rangeFormatter setDateFormat:kHEMTimelineRangeDateFormat];
        _rangeDateFormatter = rangeFormatter;
        
        NSDateFormatter* weekFormatter = [NSDateFormatter new];
        [weekFormatter setDateFormat:kHEMTimelineWeekDateFormat];
        _weekdayDateFormatter = weekFormatter;
        
        _calendar = [NSCalendar autoupdatingCurrentCalendar];
    }
    return self;
}

- (NSDate*)accountCreationDateFrom:(SENAccount*)account {
    SENLocalPreferences* localPreferences = [SENLocalPreferences sharedPreferences];
    NSDate* creationDate = [localPreferences userPreferenceForKey:HEMTimelineSettingsAccountCreationDate];
    if (!creationDate) {
        creationDate = [account createdAt];
        if (creationDate) {
            [localPreferences setUserPreference:creationDate
                                         forKey:HEMTimelineSettingsAccountCreationDate];
        }
    }
    return creationDate;
}

- (BOOL)isWithinPreviousDayWindow:(NSDate*)date {
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitHour fromDate:date];
    return [components hour] < HEMTimelineNextDayHour;
}

- (BOOL)canViewTimelinesBefore:(NSDate*)date forAccount:(SENAccount*)account {
    if (!account) {
        // if account was not loaded / available, fallback to allowing user to
        // view older timelines
        return YES;
    }
    NSDate* creationDate = [self accountCreationDateFrom:account];
    NSDate* dateWithoutTime = [date dateAtMidnight];
    NSDate* createDateWithoutTime = [creationDate dateAtMidnight];
    BOOL creationWithinPreviousDayWindow = [self isWithinPreviousDayWindow:creationDate];
    NSComparisonResult dateComparison = [createDateWithoutTime compare:dateWithoutTime];
    // if the date is greater than the account creation date OR the dates are the
    // same, but the creation date lands within the previous day window AND days
    // elapsed has been more than 1 day
    return dateComparison == NSOrderedAscending
        || (creationWithinPreviousDayWindow
            && [dateWithoutTime daysElapsed] > 0
            && dateComparison == NSOrderedSame);
}

- (BOOL)isFirstNightOfSleep:(NSDate*)date forAccount:(SENAccount*)account {
    if (!account) {
        return NO;
    }
    NSDate* creationDate = [self accountCreationDateFrom:account];
    NSDate* dateWithoutTime = [date dateAtMidnight];
    NSDate* createDateWithoutTime = [creationDate dateAtMidnight];
    // if it's ascending or the same, it's the first night of sleep
    NSComparisonResult result = [dateWithoutTime compare:createDateWithoutTime];
    if (result == NSOrderedSame) {
        BOOL createdToday = [creationDate isOnSameDay:[NSDate date]];
        BOOL isLastNight = [self isDateLastNight:date];
        return createdToday && isLastNight;
    }
    return result != NSOrderedDescending;
}

- (void)notify:(NSString*)name {
    NSNotification* note = [NSNotification notificationWithName:name object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void)amendTimelineSegment:(SENTimelineSegment*)segment
              forDateOfSleep:(NSDate*)date
                    withHour:(NSNumber*)hour
                  andMinutes:(NSNumber*)minutes
                  completion:(HEMTimelineServiceUpdateHandler)completion {
    
    __weak typeof(self) weakSelf = self;
    [SENAPITimeline amendSleepEvent:segment
                     forDateOfSleep:date
                           withHour:hour
                         andMinutes:minutes
                         completion:^(id data, NSError *error) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             SENTimeline* updatedTimeline = SENObjectOfClass(data, [SENTimeline class]);
                             if (error) {
                                 [SENAnalytics trackError:error];
                             } else {
                                 [strongSelf notify:HEMTimelineNotificationTimelineAmended];
                             }
                             completion (updatedTimeline, error);
                         }];
    
}

- (NSString*)stringValueForTimelineDate:(NSDate*)date {
    NSString* title = nil;
    NSDate* previousDay = [[NSDate date] previousDay];
    NSDateComponents *diff = [[self calendar] components:NSCalendarUnitDay
                                                fromDate:date
                                                  toDate:previousDay
                                                 options:0];
    NSInteger daysAgo = [diff day];
    
    if (daysAgo == 0) {
        title =  NSLocalizedString(@"sleep-history.last-night", nil);
    } else if (daysAgo < 7) {
        title =  [[self weekdayDateFormatter] stringFromDate:date];
    } else {
        title = [[self rangeDateFormatter] stringFromDate:date];
    }
    
    return title;
}

- (BOOL)isDateLastNight:(NSDate*)date {
    NSDateComponents *diff = [[self calendar] components:NSCalendarUnitDay
                                                fromDate:date
                                                  toDate:[[NSDate date] previousDay]
                                                 options:0];
    return diff.day == 0;
}

@end
