//
//  NSDate+HEMRelative.m
//  Sense
//
//  Created by Jimmy Lu on 12/17/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import "NSDate+HEMRelative.h"

@implementation NSDate (HEMRelative)

static NSString* const kISODateFormat = @"yyyy-MM-dd";

+ (NSDate *)timelineInitialDate {
    NSDate* startDate = [[NSDate date] previousDay];
    if ([startDate shouldCountAsPreviousDay])
        startDate = [startDate previousDay];
    return startDate;
}

- (NSInteger)daysElapsed {
    NSDate *now = [NSDate date];
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay
                                               fromDate:self
                                                 toDate:now
                                                options:NSCalendarMatchStrictly];
    return [components day];
}

+ (NSDate*)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSDateComponents* dateComponents = [NSDateComponents new];
    [dateComponents setYear:2016];
    [dateComponents setMonth:5];
    [dateComponents setDay:26];
    NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return [calendar dateFromComponents:dateComponents];
}

- (NSString*)elapsed {
    long days = [self daysElapsed];
    NSString* elapsed = nil;
    
    if (days < 1) {
        elapsed = NSLocalizedString(@"date.elapsed.today", nil);
    } else {
        NSString* format = nil;
        long value = days;
        
        if (days < 2) {
            elapsed = NSLocalizedString(@"date.elapsed.yesterday", nil);
        } else if (days < 7) {
            format = NSLocalizedString(@"date.elapsed.days.format", nil);
        } else if (days == 7) {
            format = NSLocalizedString(@"date.elapsed.week.format", nil);
            value = 1;
        } else if (days < 15) {
            format = NSLocalizedString(@"date.elapsed.weeks.format", nil);
            value = (long)ceilf(days/7.0f);
        } else if (days < 31) {
            format = NSLocalizedString(@"date.elapsed.month.format", nil);
            value = 1;
        } else if (days < 365) {
            format = NSLocalizedString(@"date.elapsed.months.format", nil);
            value = (long)ceilf(days/30.0f);
        } else if (days == 365) {
            format = NSLocalizedString(@"date.elapsed.year.format", nil);
            value = 1;
        } else {
            format = NSLocalizedString(@"date.elapsed.years.format", nil);
            value = (long)ceilf(days/365.0f);
        }
        
        if (!elapsed && format) {
            elapsed = [NSString stringWithFormat:format, value];
        }
    }
    
    return elapsed;
}

- (NSString*)timeAgo {
    // wrapping SORelativeDateTransformer in case we no longer use it in the future
    NSValueTransformer* xform = [SORelativeDateTransformer registeredTransformer];
    return [xform transformedValue:self];
}

- (NSDate*)dateAtMidnight
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    return [calendar dateFromComponents:[calendar components:preservedComponents fromDate:self]];
}

- (NSDate*)nextDay {
    return [self daysFromNow:1];
}

- (NSDate*)previousDay {
    return [self daysFromNow:-1];
}

- (NSDate*)previousMonth {
    return [self monthsFromNow:-1];
}

- (NSDate*)nextMonth {
    return [self monthsFromNow:1];
}

- (NSInteger)dayOfWeek {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return [calendar component:NSCalendarUnitWeekday fromDate:self];
}

- (BOOL)isCurrentMonth {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit flags = (NSCalendarUnitYear | NSCalendarUnitMonth);
    NSDateComponents *components = [calendar components:flags fromDate:self];
    NSDateComponents *otherComponents = [calendar components:flags fromDate:[NSDate date]];
    return ([components month] == [otherComponents month] && [components year] == [otherComponents year]);
}

- (NSDate*)monthsFromNow:(NSInteger)months {
    NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [NSDateComponents new];
    components.month = months;
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate*)daysFromNow:(NSInteger)days {
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [NSDateComponents new];
    components.day = days;
    return [calendar dateByAddingComponents:components
                                     toDate:self
                                    options:0];
}

- (NSUInteger)hoursElapsed {
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitHour
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:NSCalendarMatchStrictly];
    return [components hour];
}

- (BOOL)isOnSameDay:(NSDate*)otherDate
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSCalendarUnit flags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *components = [calendar components:flags fromDate:self];
    NSDateComponents *otherComponents = [calendar components:flags fromDate:otherDate];

    return ([components day] == [otherComponents day] && [components month] == [otherComponents month] && [components year] == [otherComponents year]);
}

- (BOOL)shouldCountAsPreviousDay {
    NSInteger const HEMSleepDateStartHour = 3;
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    if ([self isOnSameDay:[now previousDay]]) {
        NSInteger hour = [calendar component:(NSCalendarUnitHour) fromDate:now];
        return hour < HEMSleepDateStartHour;
    }
    return NO;
}

- (NSString*)isoDate {
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:kISODateFormat];
    return [formatter stringFromDate:self];
}

@end
