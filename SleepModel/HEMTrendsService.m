//
//  HEMTrendsService.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPITrends.h>
#import <SenseKit/SENTrends.h>
#import <SenseKit/SENConditionRange.h>
#import <SenseKit/SENService+Protected.h>

#import "HEMTrendsService.h"
#import "HEMTrendsDisplayPoint.h"

static CGFloat const HEMTrendsServiceCacheExpirationInSecs = 300.0f;
static CGFloat const HEMTrendsServiceDaysUntilMoreTrends = 7;
static CGFloat const HEMTrendsServiceHighlightMinBarValue = 0.05f;

NSString* const HEMTrendsServiceNotificationWillRefresh = @"willRefresh";;
NSString* const HEMTrendsServiceNotificationDidRefresh = @"didRefresh";
NSString* const HEMTrendsServiceNotificationHitCache = @"cacheHit";
NSString* const HEMTrendsServiceNotificationInfoError = @"error";

@interface HEMTrendsService()

// caches required to prevent too uneccesary requests from being fired when data
// is rarely changed.  Expiration time interval can probably be higher.  Not using
// NSCache because it's volatile and will cause data to be evicted in situations
// other than memory warnings
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, SENTrends*>* cachedTrendsByScale;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSDate*>* cachedLastPullByScale;
@property (nonatomic, assign, getter=dataHasBeenLoaded) BOOL loaded;
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;

@end

@implementation HEMTrendsService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setCachedTrendsByScale:[NSMutableDictionary dictionary]];
        [self setCachedLastPullByScale:[NSMutableDictionary dictionary]];
    }
    return self;
}

- (void)notify:(NSString*)name error:(NSError*)error {
    NSDictionary* info = nil;
    if (error) {
        info = @{HEMTrendsServiceNotificationInfoError : error};
    }
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    NSNotification* notification = [NSNotification notificationWithName:name
                                                                 object:self
                                                               userInfo:info];
    [center postNotification:notification];
}

- (SENTrends*)cachedTrendsForTimeScale:(SENTrendsTimeScale)timeScale {
    if (timeScale == SENTrendsTimeScaleUnknown) {
        if ([[self cachedTrendsByScale] count] == 1) { // return what we got
            return [[[self cachedTrendsByScale] allValues] firstObject];
        }
        return nil;
    }
    NSNumber* timeScaleKey = @(timeScale);
    return [[self cachedTrendsByScale] objectForKey:timeScaleKey];
}

- (BOOL)isCachedTrendsExpiredFor:(SENTrendsTimeScale)timeScale {
    NSNumber* timeScaleKey = @(timeScale);
    NSDate* lastPulled = [[self cachedLastPullByScale] objectForKey:timeScaleKey];
    return !lastPulled || fabs([lastPulled timeIntervalSinceNow]) > HEMTrendsServiceCacheExpirationInSecs;
}

- (void)expireCache {
    [[self cachedLastPullByScale] removeAllObjects];
}

- (void)trendsFor:(SENTrendsTimeScale)timeScale completion:(HEMTrendsServiceDataHandler)completion {
    SENTrends* cachedTrends = [self cachedTrendsForTimeScale:timeScale];
    if (![self isCachedTrendsExpiredFor:timeScale] && cachedTrends) {
        [self notify:HEMTrendsServiceNotificationHitCache error:nil];
        if (completion) {
            completion (cachedTrends, timeScale, nil);
        }
        return;
    }
    
    [self reloadTrends:timeScale completion:completion];
}

- (void)reloadTrends:(SENTrendsTimeScale)timeScale completion:(HEMTrendsServiceDataHandler)completion {
    [self notify:HEMTrendsServiceNotificationWillRefresh error:nil];
    [self setRefreshing:YES];
    
    __weak typeof(self) weakSelf = self;
    [SENAPITrends trendsForTimeScale:timeScale completion:^(SENTrends* data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoaded:YES];
        
        SENTrends* trends = nil;
        NSNumber* timeScaleKey = @(timeScale);
        BOOL isAvailable = [[data availableTimeScales] containsObject:timeScaleKey];
        
        if (error) {
            [SENAnalytics trackError:error];
            [[strongSelf cachedLastPullByScale] removeAllObjects];
            [[strongSelf cachedTrendsByScale] removeAllObjects];
        } else if (isAvailable && [data isKindOfClass:[SENTrends class]]) {
            [[strongSelf cachedTrendsByScale] setObject:data forKey:timeScaleKey];
            [[strongSelf cachedLastPullByScale] setObject:[NSDate date] forKey:timeScaleKey];
            trends = data;
        }
        
        [strongSelf setRefreshing:NO];
        [strongSelf notify:HEMTrendsServiceNotificationDidRefresh error:error];
        
        if (completion) {
            completion (trends, timeScale, error);
        }
        
    }];
}

- (void)sleepDepthLightPercentage:(CGFloat*)lightPercentage
                 mediumPercentage:(CGFloat*)mediumPercentage
                   deepPercentage:(CGFloat*)deepPercentage
                         forGraph:(SENTrendsGraph*)graph {
    if ([graph dataType] == SENTrendsDataTypePercent) {
        SENTrendsGraphSection* section = [[graph sections] firstObject];
        if ([[section values] count] == 3) {
            *lightPercentage = [[[section values] firstObject] CGFloatValue];
            *mediumPercentage = [[section values][1] CGFloatValue];
            *deepPercentage = [[[section values] lastObject] CGFloatValue];
        }
    }
}

- (SENCondition)conditionForValue:(NSNumber*)value inGraph:(SENTrendsGraph*)graph {
    NSArray<SENConditionRange*>* ranges = [graph conditionRanges];
    SENCondition condition = SENConditionUnknown;
    if (value) {
        for (SENConditionRange* range in ranges) {
            NSComparisonResult minResult = [value compare:[range minValue]];
            NSComparisonResult maxResult = [value compare:[range maxValue]];
            if ((minResult == NSOrderedDescending || minResult == NSOrderedSame)
                && (maxResult == NSOrderedAscending || maxResult == NSOrderedSame)) {
                condition = [range condition];
                break;
            }
        }
    }
    return condition;
}

- (BOOL)shouldHighlight:(SENTrendsGraphSection*)section
                inGraph:(SENTrendsGraph*)graph
                atIndex:(NSInteger)index
                forData:(NSNumber*)data {
    BOOL highlighted = [[section highlightedValues] containsObject:@(index)];
    switch ([graph displayType]) {
        case SENTrendsDisplayTypeBar: {
            if (highlighted
                && [data CGFloatValue] < HEMTrendsServiceHighlightMinBarValue) {
                highlighted = NO;
            }
            break;
        }
        case SENTrendsDisplayTypeGrid: { // FIXME: fix me!
            if (!highlighted
                && [[section values] count] - 1 == index
                && [[graph sections] count] == 1
                && [graph timeScale] == SENTrendsTimeScaleWeek) {
                highlighted = YES;
            }
            break;
        }
        default:
            break;
    }
    return highlighted;
}

- (NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)segmentedDataPointsFrom:(SENTrendsGraph*)graph {
    NSInteger sections = [[graph sections] count];
    NSMutableArray* displayPoints = [NSMutableArray arrayWithCapacity:sections];
    NSMutableArray* sectionOfPoints = nil;
    // FIXME: find a better way or possibly move this on the a bg thread
    for (SENTrendsGraphSection* section in [graph sections]) {
        sectionOfPoints = [NSMutableArray arrayWithCapacity:[[section values] count]];
        NSInteger index = 0;
        for (NSNumber* dataPoint in [section values]) {
            BOOL highlighted = [self shouldHighlight:section
                                             inGraph:graph
                                             atIndex:index
                                             forData:dataPoint];
            HEMTrendsDisplayPoint* point =
                [[HEMTrendsDisplayPoint alloc] initWithValue:dataPoint
                                                 highlighted:highlighted];
            [point setCondition:[self conditionForValue:dataPoint inGraph:graph]];
            [sectionOfPoints addObject:point];
            index++;
        }
        [displayPoints addObject:sectionOfPoints];
    }
    return displayPoints;
}

- (NSInteger)daysUntilMoreTrends:(SENTrends*)currentTrends {
    NSInteger daysLeft = 0;
    if ([[currentTrends availableTimeScales] count] < 2
        && [[currentTrends graphs] count] == 1) {
        
        SENTrendsGraph* firstGraph = [[currentTrends graphs] firstObject];
        NSInteger daysOfUse = 0;
        for (SENTrendsGraphSection* section in [firstGraph sections]) {
            daysOfUse += [[section values] count];
        }
        daysLeft = MAX(0, HEMTrendsServiceDaysUntilMoreTrends - daysOfUse);
        
    }
    return daysLeft;
}

- (BOOL)isReturningUser:(SENTrends*)currentTrends {
    return ![self isRefreshing]
        && [[currentTrends availableTimeScales] count] > 0
        && [[currentTrends graphs] count] == 0;
}

- (BOOL)isEmpty:(SENTrends*)trends {
    return ![self isRefreshing]
        && [[trends availableTimeScales] count] == 0
        && [[trends graphs] count] == 0;
}

@end
