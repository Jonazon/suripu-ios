
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENAuthorizationService.h>
#import <JBChartView/JBLineChartView.h>
#import <markdown_peg.h>

#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphViewController.h"
#import "HEMAggregateGraphCollectionViewCell.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMNoSleepEventCollectionViewCell.h"
#import "HEMSensorGraphDataSource.h"
#import "HelloStyleKit.h"
#import "HEMColorUtils.h"

NSString* const HEMSleepEventTypeWakeUp = @"WAKE_UP";
NSString* const HEMSleepEventTypeLight = @"LIGHT";
NSString* const HEMSleepEventTypeMotion = @"MOTION";
NSString* const HEMSleepEventTypeNoise = @"NOISE";
NSString* const HEMSleepEventTypeFallAsleep = @"SLEEP";

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSDateFormatter* timeDateFormatter;
@property (nonatomic, strong) NSDateFormatter* rangeDateFormatter;
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@property (nonatomic, strong) SENSleepResult* sleepResult;
@property (nonatomic, strong) NSArray* aggregateDataSources;
@end

@implementation HEMSleepGraphCollectionViewDataSource

static NSString* const sleepSegmentReuseIdentifier = @"sleepSegmentCell";
static NSString* const sleepSummaryReuseIdentifier = @"sleepSummaryCell";
static NSString* const sleepEventReuseIdentifier = @"sleepEventCell";
static NSString* const sensorTypeTemperature = @"temperature";
static NSString* const sensorTypeHumidity = @"humidity";
static NSString* const sensorTypeParticulates = @"particulates";

+ (NSDateFormatter*)sleepDateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM d, yyyy";
    });
    return formatter;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView sleepDate:(NSDate*)date
{
    if (self = [super init]) {
        _collectionView = collectionView;
        _dateForNightOfSleep = date;
        _timeDateFormatter = [NSDateFormatter new];
        _timeDateFormatter.dateFormat = ([SENSettings timeFormat] == SENTimeFormat12Hour) ? @"h:mm a" : @"H:mm";
        _rangeDateFormatter = [NSDateFormatter new];
        _rangeDateFormatter.dateFormat = @"MMM dd";
        [self configureCollectionView];
        [self reloadData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
    }
    return self;
}

- (void)reloadData
{
    self.sleepResult = [SENSleepResult sleepResultForDate:self.dateForNightOfSleep];
    [SENAPITimeline timelineForDate:self.dateForNightOfSleep completion:^(NSArray* timelines, NSError* error) {
        if (error) {
            NSLog(@"Failed to fetch timeline: %@", error.localizedDescription);
            return;
        }
        [self refreshWithTimelines:timelines];
    }];
}

- (void)refreshWithTimelines:(NSArray*)timelines
{
    NSDictionary* timeline = [timelines firstObject];
    [self.sleepResult updateWithDictionary:timeline];
    [self.sleepResult save];
    [self.collectionView reloadData];
}

- (void)configureCollectionView
{
    NSBundle* bundle = [NSBundle mainBundle];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMNoSleepEventCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepSegmentReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepSummaryCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepSummaryReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepEventCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepEventReuseIdentifier];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
}

- (NSUInteger)numberOfSleepSegments
{
    return self.sleepResult.segments.count;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return 1;
    case HEMSleepGraphCollectionViewSegmentSection:
        return self.sleepResult.segments.count;
    default:
        return 0;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection: {
        return [self collectionView:collectionView sleepSummaryCellForItemAtIndexPath:indexPath];
    } break;
    case HEMSleepGraphCollectionViewSegmentSection: {
        if ([self segmentForSleepExistsAtIndexPath:indexPath]) {
            return [self collectionView:collectionView sleepSegmentCellForItemAtIndexPath:indexPath];
        }
        else {
            return [self collectionView:collectionView sleepEventCellForItemAtIndexPath:indexPath];
        }
    }
    default:
        return nil;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepSummaryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMSleepSummaryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSummaryReuseIdentifier forIndexPath:indexPath];
    UIFont* emFont = [UIFont fontWithName:@"Calibre-Medium" size:cell.messageLabel.font.pointSize];
    [cell setSleepScore:[self.sleepResult.score integerValue] animated:YES];
    NSDictionary* attributes = @{
        @(STRONG) : @{
            NSFontAttributeName : emFont,
        }
    };
    cell.messageLabel.attributedText = markdown_to_attr_string(self.sleepResult.message, 0, attributes);
    NSString* dateText = [[[self class] sleepDateFormatter] stringFromDate:self.dateForNightOfSleep];
    NSString* lastNightDateText = [[[self class] sleepDateFormatter] stringFromDate:[NSDate dateWithTimeInterval:-60 * 60 * 24 sinceDate:[NSDate date]]];
    if ([dateText isEqualToString:lastNightDateText]) {
        cell.dateLabel.text = NSLocalizedString(@"sleep-history.last-night", nil);
    }
    else {
        cell.dateLabel.text = dateText;
    }
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepSegmentCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMNoSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSegmentReuseIdentifier forIndexPath:indexPath];
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep withColor:[HEMColorUtils colorForSleepDepth:sleepDepth]];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepEventCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepEventReuseIdentifier forIndexPath:indexPath];
    cell.eventTypeButton.layer.borderColor = [HEMColorUtils colorForSleepDepth:sleepDepth].CGColor;
    cell.eventTypeButton.layer.borderWidth = 2.f;
    cell.eventTypeButton.layer.cornerRadius = CGRectGetWidth(cell.eventTypeButton.bounds) / 2;
    if ([collectionView.delegate respondsToSelector:@selector(didTapEventButton:)]) {
        [cell.eventTypeButton addTarget:collectionView.delegate action:@selector(didTapEventButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.eventTypeButton setImage:[self imageForEventType:segment.eventType] forState:UIControlStateNormal];
    cell.eventTimeLabel.text = [self textForTimeInterval:[segment.date timeIntervalSince1970]];

    cell.eventTitleLabel.text = [self localizedNameForSleepEventType:segment.eventType];
    cell.firstSegment = [self.sleepResult.segments indexOfObject:segment] == 0;
    cell.lastSegment = [self.sleepResult.segments indexOfObject:segment] == self.sleepResult.segments.count - 1;
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep withColor:[HEMColorUtils colorForSleepDepth:sleepDepth]];
    return cell;
}

#pragma mark - Data Parsing

- (SENSleepResultSegment*)sleepSegmentForIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection ? self.sleepResult.segments[indexPath.row] : nil;
}

- (NSString*)localizedSleepDepth:(NSUInteger)sleepDepth
{
    switch (sleepDepth) {
    case 0:
        return NSLocalizedString(@"sleep-history.depth.awake", nil);
    case 1:
        return NSLocalizedString(@"sleep-history.depth.light", nil);
    case 2:
        return NSLocalizedString(@"sleep-history.depth.medium", nil);
    default:
        return NSLocalizedString(@"sleep-history.depth.deep", nil);
    }
}

- (NSString*)localizedNameForSleepEventType:(NSString*)eventType
{
    NSString* localizedFormat = [NSString stringWithFormat:@"sleep-event.type.%@.name", [eventType lowercaseString]];
    NSString* eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return [eventType capitalizedString];
    }
    return eventName;
}

- (UIImage*)imageForEventType:(NSString*)eventType
{
    if ([eventType isEqualToString:HEMSleepEventTypeWakeUp]) {
        return [UIImage imageNamed:@"wakeUpEventIcon"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeFallAsleep]) {
        return [UIImage imageNamed:@"fellAsleepEventIcon"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeLight]) {
        return [UIImage imageNamed:@"lightEventIcon"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeNoise]) {
        return [UIImage imageNamed:@"soundEventIcon"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeMotion]) {
        return [UIImage imageNamed:@"motionEventIcon"];
    }
    return nil;
}

- (NSString*)textForTimeInterval:(NSTimeInterval)timeInterval
{
    return [[self.timeDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]] lowercaseString];
}

- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    return !segment.eventType || [segment.eventType isEqual:[NSNull null]];
}

- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    return segment.eventType && ![segment.eventType isEqual:[NSNull null]];
}

@end
