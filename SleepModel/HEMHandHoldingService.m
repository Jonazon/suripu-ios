//
//  HEMHandHoldingService.m
//  Sense
//
//  Created by Jimmy Lu on 1/22/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>

#import "NSDate+HEMRelative.h"

#import "HEMHandHoldingService.h"
#import "HEMAppUsage.h"

static NSString* const HEMHandHoldingServicePrefName = @"tutorials";

// NOTE: names are set for historical reasons.  Changing them obviously might
// cause tutorials to show again for existing users

// insights
static NSString* const HEMHandHoldingServiceInsightTap = @"HandholdingInsightTap";
static NSInteger const HEMHandHoldingInsightTapMinDaysChecked = 1;

// sensors
static NSString* const HEMHandHoldingServiceSensorScrubbing = @"HandholdingSensorScrubbing";
static NSString* const HEMHandHoldingServiceSensorScroll = @"HandholdingSensorScroll";

// timeline
static NSString* const HEMHandHoldingServiceTimelineSwipe = @"HandholdingTimelineDaySwitch";
static NSInteger const HEMHandHoldingTimelineSwipeMinDaysChecked = 2;
static NSString* const HEMHandHoldingServiceTimelineOpen = @"HEMHandHoldingServiceTimelineOpen";

@interface HEMHandHoldingService()

@property (nonatomic, strong) NSMutableDictionary* tutorialRecordKeeper;

@end

@implementation HEMHandHoldingService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadRecordKeeper];
    }
    return self;
}

- (void)loadRecordKeeper {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    NSMutableDictionary* recordKeeper = [[prefs persistentPreferenceForKey:HEMHandHoldingServicePrefName] mutableCopy];
    if (!recordKeeper) {
        // migrate over the previously saved data
        recordKeeper = [NSMutableDictionary new];
        [recordKeeper setValue:[self oldTutorialRecord:HEMHandHoldingServiceInsightTap]
                        forKey:HEMHandHoldingServiceInsightTap];
        [recordKeeper setValue:[self oldTutorialRecord:HEMHandHoldingServiceSensorScrubbing]
                        forKey:HEMHandHoldingServiceSensorScrubbing];
        [recordKeeper setValue:[self oldTutorialRecord:HEMHandHoldingServiceTimelineSwipe]
                        forKey:HEMHandHoldingServiceTimelineSwipe];
        [prefs setPersistentPreference:recordKeeper forKey:HEMHandHoldingServicePrefName];
    }
    [self setTutorialRecordKeeper:recordKeeper];
    [self listenForHandHoldingResetAndCompletions];
}

#pragma mark - Preference Changes

- (void)listenForHandHoldingResetAndCompletions {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reloadRecords)
                   name:SENLocalPrefDidChangeNotification
                 object:HEMHandHoldingServicePrefName];
}

- (void)reloadRecords {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [self setTutorialRecordKeeper:[[prefs persistentPreferenceForKey:HEMHandHoldingServicePrefName] mutableCopy]];
}

#pragma mark -

- (BOOL)isComplete:(HEMHandHolding)tutorial {
    NSString* tutorialRecordKey = [self stringValueFor:tutorial];
    return tutorialRecordKey ? [[self tutorialRecordKeeper][tutorialRecordKey] boolValue] : NO;
}

- (NSString*)stringValueFor:(HEMHandHolding)tutorial {
    switch (tutorial) {
        default:
        case HEMHandHoldingInsightTap:
            return HEMHandHoldingServiceInsightTap;
        case HEMHandHoldingSensorScrubbing:
            return HEMHandHoldingServiceSensorScrubbing;
        case HEMHandHoldingTimelineSwipe:
            return HEMHandHoldingServiceTimelineSwipe;
        case HEMHandHoldingSensorScroll:
            return HEMHandHoldingServiceSensorScroll;
    }
}

- (void)completed:(HEMHandHolding)tutorial {
    if (![self isComplete:tutorial]) {
        NSString* tutorialName = [self stringValueFor:tutorial];
        
        if (tutorialName) {
            [self tutorialRecordKeeper][tutorialName] = @YES;
            
            SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
            [prefs setPersistentPreference:[self tutorialRecordKeeper]
                                    forKey:HEMHandHoldingServicePrefName];
            
            DDLogVerbose(@"completed %@", tutorialName);
        }
    }
}

- (void)reset {
    [[self tutorialRecordKeeper] removeAllObjects];
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setPersistentPreference:[self tutorialRecordKeeper]
                            forKey:HEMHandHoldingServicePrefName];
}

#pragma mark - Deprecated storage

- (NSNumber*)oldTutorialRecord:(NSString*)tutorialName {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    NSNumber* currentValue = [preferences persistentPreferenceForKey:tutorialName];
    if (!currentValue) {
        currentValue = [preferences sessionPreferenceForKey:tutorialName];
    }
    return currentValue;
}

#pragma mark - Show or not show logic

- (BOOL)isFirstAppUsage:(NSString*)usageName atLeast:(NSInteger)days {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:usageName];
    NSDate* lastUsageDate = [appUsage created];
    NSInteger daysSinceLastUsage = [lastUsageDate daysElapsed];
    return daysSinceLastUsage >= days;
}

- (BOOL)shouldShowInsightTap {
    return [self isFirstAppUsage:HEMAppUsageInsightsShownWithData
                         atLeast:HEMHandHoldingInsightTapMinDaysChecked];
}

- (BOOL)shouldShowTimelineSwipe {
    return [self isFirstAppUsage:HEMAppUsageTimelineShownWithData
                         atLeast:HEMHandHoldingTimelineSwipeMinDaysChecked];
}

- (BOOL)shouldShow:(HEMHandHolding)tutorial {
    if ([self isComplete:tutorial]) {
        return NO;
    }
    
    switch (tutorial) {
        case HEMHandHoldingInsightTap:
            return [self shouldShowInsightTap];
        case HEMHandHoldingTimelineSwipe:
            return [self shouldShowTimelineSwipe];
        case HEMHandHoldingSensorScroll:
            return [self isComplete:HEMHandHoldingSensorScrubbing]; // scrub first, then scroll
        case HEMHandHoldingSensorScrubbing:
        default:
            return YES;
    }
}

- (BOOL)shouldShow:(HEMHandHolding)tutorial forAccount:(SENAccount*)account {
    return [self shouldShow:tutorial];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
