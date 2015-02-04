
#import "SENSleepResult.h"
#import "SENKeyedArchiver.h"

static NSDate* SENSleepResultDateFromTimestamp(NSNumber* timestampMillis)
{
    return [NSDate dateWithTimeIntervalSince1970:[timestampMillis doubleValue] / 1000];
}

static NSString* const SENSleepResultSegmentSensorName = @"name";

@interface SENSleepResult ()

/**
 *  Storage key for sleep result on a given date
 *
 *  @param date date for night of sleep of the data
 *
 *  @return unique key for a given date
 */
+ (NSString*)retrievalKeyForDate:(NSDate*)date;

/**
 *  Storage key
 *
 *  @return unique key
 */
- (NSString*)retrievalKey;
@end

@implementation SENSleepResult

static NSString* const SENSleepResultDate = @"date";
static NSString* const SENSleepResultScore = @"score";
static NSString* const SENSleepResultMessage = @"message";
static NSString* const SENSleepResultSegments = @"segments";
static NSString* const SENSleepResultSensorInsights = @"insights";
static NSString* const SENSleepResultStatistics = @"statistics";
static NSString* const SENSleepResultRetrievalKeyFormat = @"SleepResult-%ld-%ld-%ld";
static NSString* const SENSleepResultDateFormat = @"yyyy-MM-dd";

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = SENSleepResultDateFormat;
    });
    return formatter;
}

+ (NSString*)retrievalKeyForDate:(NSDate*)date
{
    if (!date)
        return nil;

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit)
                                               fromDate:date];
    return [NSString stringWithFormat:SENSleepResultRetrievalKeyFormat, (long)components.day, (long)components.month, (long)components.year];
}

+ (instancetype)sleepResultForDate:(NSDate*)date
{
    if (!date)
        return nil;

    SENSleepResult* result = [SENKeyedArchiver objectsForKey:[self retrievalKeyForDate:date]
                                                inCollection:NSStringFromClass([self class])];
    if (!result) {
        result = [[SENSleepResult alloc] init];
        result.date = date;
    }
    return result;
}

- (instancetype)initWithDictionary:(NSDictionary*)sleepData
{
    if (self = [super init]) {
        _date = SENSleepResultDateFromTimestamp(sleepData[SENSleepResultDate]);
        _score = sleepData[SENSleepResultScore];
        _message = sleepData[SENSleepResultMessage];
        _segments = [self parseSegmentsFromArray:sleepData[SENSleepResultSegments]];
        _sensorInsights = [self parseSensorInsightsFromArray:sleepData[SENSleepResultSensorInsights]];
        _statistics = [self parseStatisticsFromDictionary:sleepData[SENSleepResultStatistics]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:SENSleepResultDate];
        _score = [aDecoder decodeObjectForKey:SENSleepResultScore];
        _message = [aDecoder decodeObjectForKey:SENSleepResultMessage];
        _segments = [aDecoder decodeObjectForKey:SENSleepResultSegments];
        _sensorInsights = [aDecoder decodeObjectForKey:SENSleepResultSensorInsights];
        _statistics = [aDecoder decodeObjectForKey:SENSleepResultStatistics];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_date forKey:SENSleepResultDate];
    [aCoder encodeObject:_score forKey:SENSleepResultScore];
    [aCoder encodeObject:_message forKey:SENSleepResultMessage];
    [aCoder encodeObject:_segments forKey:SENSleepResultSegments];
    [aCoder encodeObject:_sensorInsights forKey:SENSleepResultSensorInsights];
    [aCoder encodeObject:_statistics forKey:SENSleepResultStatistics];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultDate])
        self.date = [[[self class] dateFormatter] dateFromString:data[SENSleepResultDate]];
    if (data[SENSleepResultMessage])
        self.message = data[SENSleepResultMessage];
    if (data[SENSleepResultScore])
        self.score = data[SENSleepResultScore];
    if (data[SENSleepResultSegments])
        self.segments = [self parseSegmentsFromArray:data[SENSleepResultSegments]];
    if (data[SENSleepResultSensorInsights])
        self.sensorInsights = [self parseSensorInsightsFromArray:data[SENSleepResultSensorInsights]];
    if (data[SENSleepResultStatistics])
        self.statistics = [self parseStatisticsFromDictionary:data[SENSleepResultStatistics]];
}

- (NSString*)retrievalKey
{
    return [[self class] retrievalKeyForDate:self.date];
}

- (NSArray*)parseStatisticsFromDictionary:(NSDictionary*)statisticData
{
    if (![statisticData isKindOfClass:[NSDictionary class]])
        return nil;
    __block NSMutableArray* stats = [[NSMutableArray alloc] initWithCapacity:statisticData.count];
    [statisticData enumerateKeysAndObjectsUsingBlock:^(NSString* name, NSNumber* value, BOOL *stop) {
        if ([name isKindOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
            SENSleepResultStatistic* stat = [[SENSleepResultStatistic alloc] initWithName:name value:value];
            if (stat)
                [stats addObject:stat];
        }
    }];
    return stats;
}

- (NSArray*)parseSegmentsFromArray:(NSArray*)segmentsData
{
    NSMutableArray* segments = [[NSMutableArray alloc] initWithCapacity:[segmentsData count]];
    for (NSDictionary* segmentData in segmentsData) {
        SENSleepResultSegment* segment = [[SENSleepResultSegment alloc] initWithDictionary:segmentData];
        if (segment)
            [segments addObject:segment];
    }
    return segments;
}

- (NSArray*)parseSensorInsightsFromArray:(NSArray*)insightData
{
    __block NSMutableArray* insights = [[NSMutableArray alloc] initWithCapacity:insightData.count];
    for (NSDictionary* data in insightData) {
        SENSleepResultSensorInsight* insight = [[SENSleepResultSensorInsight alloc] initWithDictionary:data];
        if (insight)
            [insights addObject:insight];
    }
    return insights;
}

- (void)save
{
    [SENKeyedArchiver setObject:self forKey:[self retrievalKey] inCollection:NSStringFromClass([SENSleepResult class])];
}

@end

@implementation SENSleepResultSound

static NSString* const SENSleepResultSoundURL = @"url";
static NSString* const SENSleepResultSoundDuration = @"duration_millis";

- (instancetype)initWithDictionary:(NSDictionary *)data
{
    if (!data) return nil;
    if (self = [super init]) {
        _URLPath = data[SENSleepResultSoundURL];
        _durationMillis = [data[SENSleepResultSoundDuration] longValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _URLPath = [aDecoder decodeObjectForKey:SENSleepResultSoundURL];
        _durationMillis = [[aDecoder decodeObjectForKey:SENSleepResultSoundDuration] longValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.URLPath forKey:SENSleepResultSoundURL];
    [aCoder encodeObject:@(self.durationMillis) forKey:SENSleepResultSoundDuration];
}

- (void)updateWithDictionary:(NSDictionary *)data
{
    if (data[SENSleepResultSoundURL])
        self.URLPath = data[SENSleepResultSoundURL];
    if (data[SENSleepResultSoundDuration])
        self.durationMillis = [data[SENSleepResultSoundDuration] longValue];
}

@end

@implementation SENSleepResultSegment

NSString* const SENSleepResultSegmentEventTypeWakeUp = @"WAKE_UP";
NSString* const SENSleepResultSegmentEventTypeSleep = @"SLEEP";

static NSString* const SENSleepResultSegmentServerID = @"id";
static NSString* const SENSleepResultSegmentTimestamp = @"timestamp";
static NSString* const SENSleepResultSegmentDuration = @"duration";
static NSString* const SENSleepResultSegmentEventType = @"event_type";
static NSString* const SENSleepResultSegmentMessage = @"message";
static NSString* const SENSleepResultSegmentSleepDepth = @"sleep_depth";
static NSString* const SENSleepResultSegmentTimezoneOffset = @"offset_millis";
static NSString* const SENSleepResultSegmentSound = @"sound";

- (instancetype)initWithDictionary:(NSDictionary*)segmentData
{
    if (self = [super init]) {
        _serverID = segmentData[SENSleepResultSegmentServerID];
        _date = SENSleepResultDateFromTimestamp(segmentData[SENSleepResultSegmentTimestamp]);
        _duration = segmentData[SENSleepResultSegmentDuration];
        _message = segmentData[SENSleepResultSegmentMessage];
        _eventType = segmentData[SENSleepResultSegmentEventType];
        _sleepDepth = [segmentData[SENSleepResultSegmentSleepDepth] integerValue];
        _sound = [[SENSleepResultSound alloc] initWithDictionary:segmentData[SENSleepResultSegmentSound]];
        _timezone = [NSTimeZone timeZoneForSecondsFromGMT:[segmentData[SENSleepResultSegmentTimezoneOffset] doubleValue] / 1000];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _serverID = [aDecoder decodeObjectForKey:SENSleepResultSegmentServerID];
        _date = [aDecoder decodeObjectForKey:SENSleepResultSegmentTimestamp];
        _duration = [aDecoder decodeObjectForKey:SENSleepResultSegmentDuration];
        _message = [aDecoder decodeObjectForKey:SENSleepResultSegmentMessage];
        _eventType = [aDecoder decodeObjectForKey:SENSleepResultSegmentEventType];
        _sleepDepth = [[aDecoder decodeObjectForKey:SENSleepResultSegmentSleepDepth] integerValue];
        _sound = [aDecoder decodeObjectForKey:SENSleepResultSegmentSound];
        _timezone = [aDecoder decodeObjectForKey:SENSleepResultSegmentTimezoneOffset];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.serverID forKey:SENSleepResultSegmentServerID];
    [aCoder encodeObject:self.date forKey:SENSleepResultSegmentTimestamp];
    [aCoder encodeObject:self.duration forKey:SENSleepResultSegmentDuration];
    [aCoder encodeObject:self.message forKey:SENSleepResultSegmentMessage];
    [aCoder encodeObject:self.eventType forKey:SENSleepResultSegmentEventType];
    [aCoder encodeObject:@(self.sleepDepth) forKey:SENSleepResultSegmentSleepDepth];
    [aCoder encodeObject:self.sound forKey:SENSleepResultSegmentSound];
    [aCoder encodeObject:self.timezone forKey:SENSleepResultSegmentTimezoneOffset];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultSegmentServerID])
        self.serverID = data[SENSleepResultSegmentServerID];
    if (data[SENSleepResultSegmentTimestamp])
        self.date = SENSleepResultDateFromTimestamp(data[SENSleepResultSegmentTimestamp]);
    if (data[SENSleepResultSegmentDuration])
        self.duration = data[SENSleepResultSegmentDuration];
    if (data[SENSleepResultSegmentMessage])
        self.message = data[SENSleepResultSegmentMessage];
    if (data[SENSleepResultSegmentEventType])
        self.eventType = data[SENSleepResultSegmentEventType];
    if (data[SENSleepResultSegmentSleepDepth])
        self.sleepDepth = [data[SENSleepResultSegmentSleepDepth] integerValue];
    if (data[SENSleepResultSegmentTimezoneOffset])
        self.timezone = [NSTimeZone timeZoneForSecondsFromGMT:[data[SENSleepResultSegmentTimezoneOffset] doubleValue] / 1000];
    if (data[SENSleepResultSegmentSound]) {
        if (self.sound)
            [self.sound updateWithDictionary:data[SENSleepResultSegmentSound]];
        else
            self.sound = [[SENSleepResultSound alloc] initWithDictionary:data[SENSleepResultSegmentSound]];
    }
}

@end

@implementation SENSleepResultStatistic

static NSString* const SENSleepResultStatisticNameKey = @"name";
static NSString* const SENSleepResultStatisticValueKey = @"value";
static NSString* const SENSleepResultStatisticTypeKey = @"type";

static NSString* const SENSleepResultStatisticNameSoundSleep = @"sound_sleep";
static NSString* const SENSleepResultStatisticNameTotalSleep = @"total_sleep";
static NSString* const SENSleepResultStatisticNameTimesAwake = @"times_awake";
static NSString* const SENSleepResultStatisticNameTimeToSleep = @"time_to_sleep";

+ (SENSleepResultStatisticType)typeFromName:(NSString*)name
{
    if ([name isKindOfClass:[NSString class]]) {
        if ([name isEqualToString:SENSleepResultStatisticNameSoundSleep])
            return SENSleepResultStatisticTypeSoundDuration;
        if ([name isEqualToString:SENSleepResultStatisticNameTotalSleep])
            return SENSleepResultStatisticTypeTotalDuration;
        if ([name isEqualToString:SENSleepResultStatisticNameTimesAwake])
            return SENSleepResultStatisticTypeTimesAwake;
        if ([name isEqualToString:SENSleepResultStatisticNameTimeToSleep])
            return SENSleepResultStatisticTypeTimeToSleep;
    }

    return SENSleepResultStatisticTypeUnknown;
}

- (instancetype)initWithName:(NSString *)name value:(NSNumber*)value
{
    if (self = [super init]) {
        if ([name isKindOfClass:[NSString class]])
            _name = name;
        if ([value isKindOfClass:[NSNumber class]])
            _value = value;
        _type = [SENSleepResultStatistic typeFromName:name];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:SENSleepResultStatisticNameKey];
        _value = [aDecoder decodeObjectForKey:SENSleepResultStatisticValueKey];
        _type = [aDecoder decodeIntegerForKey:SENSleepResultStatisticTypeKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:SENSleepResultStatisticNameKey];
    [aCoder encodeObject:self.value forKey:SENSleepResultStatisticValueKey];
    [aCoder encodeInteger:self.type forKey:SENSleepResultStatisticTypeKey];
}

@end

@implementation SENSleepResultSensorInsight

static NSString* const SENSleepResultSensorInsightName = @"sensor";
static NSString* const SENSleepResultSensorInsightMessage = @"message";
static NSString* const SENSleepResultSensorInsightCondition = @"condition";

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    if (self = [super init]) {
        _name = data[SENSleepResultSensorInsightName];
        _message = data[SENSleepResultSensorInsightMessage];
        _condition = [SENSensor conditionFromValue:data[SENSleepResultSensorInsightCondition]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)decoder
{
    if (self = [super init]) {
        _name = [decoder decodeObjectForKey:SENSleepResultSensorInsightName];
        _message = [decoder decodeObjectForKey:SENSleepResultSensorInsightMessage];
        _condition = [[decoder decodeObjectForKey:SENSleepResultSensorInsightCondition] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.name forKey:SENSleepResultSensorInsightName];
    [aCoder encodeObject:self.message forKey:SENSleepResultSensorInsightMessage];
    [aCoder encodeObject:@(self.condition) forKey:SENSleepResultSensorInsightCondition];
}

- (void)updateWithDictionary:(NSDictionary*)data
{
    if (data[SENSleepResultSensorInsightName])
        self.name = data[SENSleepResultSensorInsightName];
    if (data[SENSleepResultSensorInsightMessage])
        self.message = data[SENSleepResultSensorInsightMessage];
    if (data[SENSleepResultSensorInsightCondition])
        self.condition = [SENSensor conditionFromValue:data[SENSleepResultSensorInsightCondition]];
}

@end
