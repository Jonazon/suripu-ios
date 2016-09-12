//
//  HEMRoomConditionsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Charts/Charts-Swift.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSensorStatus.h>

#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"

#import "HEMRoomConditionsPresenter.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMDescriptionHeaderView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSenseRequiredCollectionViewCell.h"
#import "HEMSensorCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMCardFlowLayout.h"
#import "HEMActionButton.h"
#import "HEMMainStoryboard.h"
#import "HEMSensorValueFormatter.h"
#import "HEMStyle.h"
#import "HEMSensorChartContainer.h"
#import "HEMSensorGroupCollectionViewCell.h"

static NSString* const kHEMRoomConditionsIntroReuseId = @"intro";
static CGFloat const kHEMRoomConditionsPairViewHeight = 352.0f;
static CGFloat const kHEMRoomConditionsChartAnimeDuration = 1.0f;

@interface HEMRoomConditionsPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    ChartViewDelegate
>

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) HEMIntroService* introService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, strong) NSAttributedString* attributedIntroTitle;
@property (nonatomic, strong) NSAttributedString* attributedIntroDesc;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) NSError* sensorError;
@property (nonatomic, assign) BOOL loadedIntro;
@property (nonatomic, strong) NSMutableDictionary* chartViewBySensor;
@property (nonatomic, strong) NSMutableDictionary* chartDataBySensor;
@property (nonatomic, strong) SENSensorStatus* sensorStatus;
@property (nonatomic, strong) NSArray* groupedSensors;
@property (nonatomic, strong) SENSensorDataCollection* sensorData;
@property (nonatomic, strong) HEMSensorValueFormatter* formatter;

@end

@implementation HEMRoomConditionsPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                         introService:(HEMIntroService*)introService {
    self = [super init];
    if (self) {
        _sensorService = sensorService;
        _introService = introService;
        _headerViewHeight = -1.0f;
        _chartViewBySensor = [NSMutableDictionary dictionaryWithCapacity:8];
        _chartDataBySensor = [NSMutableDictionary dictionaryWithCapacity:8];
        _formatter = [HEMSensorValueFormatter new];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setBackgroundColor:[UIColor grey2]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    [activityIndicator setHidden:YES];
    [activityIndicator stop];
    [self setActivityIndicator:activityIndicator];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [self startPolling];
}

- (void)didDisappear {
    [super didDisappear];
    [[self sensorService] stopPollingForData];
}

- (void)userDidSignOut {
    [super userDidSignOut];
    [[self sensorService] stopPollingForData];
}

- (void)didOpenDrawer {
    [super didOpenDrawer];
    if ([self isViewFullyVisible:[self collectionView]]) {
        [self startPolling];
    }
}

- (void)didCloseDrawer {
    [super didCloseDrawer];
    [[self sensorService] stopPollingForData];
}

#pragma mark - Data

- (void)startPolling {
    if (![self sensorStatus]) {
        [self setSensorError:nil];
        [[self collectionView] reloadData];
        [[self activityIndicator] setHidden:NO];
        [[self activityIndicator] start];
    }
    
    __weak typeof(self) weakSelf = self;
    HEMSensorService* service = [self sensorService];
    NSMutableSet<NSNumber*>* excludeSensorTypes = [NSMutableSet set];
    [excludeSensorTypes addObject:@(SENSensorTypeDust)];
    [excludeSensorTypes addObject:@(SENSensorTypeVOC)];
    [excludeSensorTypes addObject:@(SENSensorTypeCO2)];

    [service pollDataForSensorsExcept:excludeSensorTypes completion:^(SENSensorStatus* status, id data, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setSensorError:error];
        if (!error) {
            [strongSelf setSensorStatus:status];
            
            SENSensorDataCollection* sensorData = data;
            if (sensorData && ![[strongSelf sensorData] isEqual:sensorData]) {
                [strongSelf setGroupedSensors:[strongSelf groupedSensorsFrom:[status sensors]]];
                [strongSelf setSensorData:data];
                [strongSelf prepareChartDataAndReload];
            }
            
        } else {
            [[strongSelf activityIndicator] setHidden:YES];
            [[strongSelf activityIndicator] stop];
            [[strongSelf collectionView] reloadData];
        }
    }];
}

- (NSArray*)groupedSensorsFrom:(NSArray<SENSensor*>*)allSensors {
    if ([allSensors count] == 0) {
        return nil;
    }
    
    NSMutableArray* groupedSensors = [NSMutableArray arrayWithCapacity:[allSensors count]];
    NSMutableArray* airGroup = nil;
    for (SENSensor* sensor in allSensors) {
        if ([sensor type] == SENSensorTypeDust
            || [sensor type] == SENSensorTypeCO2
            || [sensor type] == SENSensorTypeVOC) {
            if (!airGroup) {
                airGroup = [NSMutableArray arrayWithCapacity:3];
                [groupedSensors addObject:airGroup];
            }
            [airGroup addObject:sensor];
        } else {
            [groupedSensors addObject:sensor];
        }
    }
    return groupedSensors;
}

#pragma mark - Charts

- (void)prepareChartDataAndReload {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray<SENSensor*>* sensors = [[strongSelf sensorStatus] sensors];
        for (SENSensor* sensor in sensors) {
            NSArray<NSNumber*>* values = [[strongSelf sensorData] dataPointsForSensorType:[sensor type]];
            NSArray<SENSensorTime*>* timestamps = [[strongSelf sensorData] timestamps];
            if ([values count] == [timestamps count]) {
                NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:[values count]];
                NSUInteger index = 0;
                for (NSNumber* value in values) {
                    [chartData addObject:[[ChartDataEntry alloc] initWithValue:[value doubleValue] xIndex:index++]];
                }
                [strongSelf chartDataBySensor][@([sensor type])] = chartData;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[strongSelf activityIndicator] setHidden:YES];
            [[strongSelf activityIndicator] stop];
            [[strongSelf collectionView] reloadData];
        });
    });
}

- (ChartViewBase*)chartViewForSensor:(SENSensor*)sensor
                              inCell:(HEMSensorCollectionViewCell*)cell {
    // TODO: for now, use the line chart for every sensor.
    LineChartView* lineChartView = [self chartViewBySensor][@([sensor type])];
    
    if (!lineChartView) {
        lineChartView = [[LineChartView alloc] initWithFrame:[[cell graphContainerView] bounds]];
        [lineChartView setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                         | UIViewAutoresizingFlexibleHeight];
        [lineChartView setBackgroundColor:[UIColor whiteColor]];
        [lineChartView setDrawGridBackgroundEnabled:NO];
        [lineChartView setDrawBordersEnabled:NO];
        [lineChartView setNoDataText:nil];
        [[lineChartView leftAxis] setEnabled:NO];
        [[lineChartView leftAxis] removeAllLimitLines];
        [[lineChartView rightAxis] removeAllLimitLines];
        [[lineChartView rightAxis] setEnabled:NO];
        [[lineChartView xAxis] setEnabled:NO];
        [[lineChartView xAxis] setDrawAxisLineEnabled:NO];
        [[lineChartView xAxis] setDrawGridLinesEnabled:NO];
        [[lineChartView xAxis] removeAllLimitLines];
        [lineChartView setDescriptionText:nil];
        [[lineChartView legend] setEnabled:NO];
        [[lineChartView layer] setBorderWidth:0.0f];
        [lineChartView setViewPortOffsetsWithLeft:0.0f top:0.0f right:0.0f bottom:-40.0f];
        [lineChartView setUserInteractionEnabled:NO];
        [self chartViewBySensor][@([sensor type])] = lineChartView;
    }
    
    SENCondition condition = [sensor condition];
    UIColor* sensorColor = [UIColor colorForCondition:condition];
    [lineChartView setGridBackgroundColor:sensorColor];
    
    NSArray* chartData = [self chartDataBySensor][@([sensor type])];
    LineChartDataSet* dataSet = [[LineChartDataSet alloc] initWithYVals:chartData];
    [dataSet setFill:[ChartFill fillWithColor:sensorColor]];
    [dataSet setColor:sensorColor];
    [dataSet setDrawFilledEnabled:YES];
    [dataSet setDrawCirclesEnabled:NO];
    [dataSet setFillColor:sensorColor];
    [dataSet setLabel:nil];
    
    
    NSArray<SENSensorTime*>* xVals = [[self sensorData] timestamps];
    [lineChartView setData:[[LineChartData alloc] initWithXVals:xVals dataSet:dataSet]];
    [lineChartView setNeedsDisplay];
    
    return lineChartView;
}

#pragma mark - Text

- (NSAttributedString*)attributedIntroTitle {
    if (!_attributedIntroTitle) {
        NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary* attrs = @{NSFontAttributeName : [UIFont h5],
                                NSForegroundColorAttributeName : [UIColor grey6],
                                NSParagraphStyleAttributeName : style};
        
        NSString* title = NSLocalizedString(@"room-conditions.intro.title", nil);
        
        _attributedIntroTitle = [[NSAttributedString alloc] initWithString:title attributes:attrs];
    }
    return _attributedIntroTitle;
}

- (NSAttributedString*)attributedIntroDesc {
    if (!_attributedIntroDesc) {
        NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary* attrs = @{NSFontAttributeName : [UIFont body],
                                NSForegroundColorAttributeName : [UIColor grey5],
                                NSParagraphStyleAttributeName : style};
        
        NSString* desc = NSLocalizedString(@"room-conditions.intro.desc", nil);
        
        _attributedIntroDesc = [[NSAttributedString alloc] initWithString:desc attributes:attrs];
    }
    return _attributedIntroDesc;
}

#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    HEMCardFlowLayout* cardLayout = (id)collectionViewLayout;
    CGSize itemSize = [cardLayout itemSize];
    
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk: {
            id sensorObj = [self groupedSensors][[indexPath row]];
            if ([sensorObj isKindOfClass:[NSArray class]]) {
                itemSize.height = [HEMSensorGroupCollectionViewCell heightWithNumberOfMembers:[sensorObj count]];
            } else {
                SENSensor* sensor = sensorObj;
                itemSize.height = [HEMSensorCollectionViewCell heightWithDescription:[sensor localizedMessage]
                                                                           cellWidth:itemSize.width];
            }
            return itemSize;
        }
        case SENSensorStateNoSense:
            itemSize.height = kHEMRoomConditionsPairViewHeight;
            return itemSize;
        default: {
            if ([self sensorError]) {
                NSString* text = NSLocalizedString(@"sensor.data-unavailable", nil);
                UIFont* font = [UIFont errorStateDescriptionFont];
                CGFloat maxWidth = itemSize.width - (HEMStyleCardErrorTextHorzMargin * 2);
                CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
                itemSize.height = textHeight + (HEMStyleCardErrorTextVertMargin * 2);
            }
            return itemSize;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self sensorStatus] ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk:
            return [[self groupedSensors] count];
        case SENSensorStateNoSense:
            return 1;
        default: {
            return [self sensorError] ? 1 : 0;
        }
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk: {
            id sensorObj = [self groupedSensors][[indexPath row]];
            if ([sensorObj isKindOfClass:[NSArray class]]) {
                reuseId = [HEMMainStoryboard groupReuseIdentifier];
            } else {
                reuseId = [HEMMainStoryboard sensorReuseIdentifier];
            }
            break;
        }
        case SENSensorStateNoSense:
            reuseId = [HEMMainStoryboard pairReuseIdentifier];
            break;
        default:
            reuseId = [self sensorError] ? [HEMMainStoryboard errorReuseIdentifier] : nil;
            break;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[HEMSensorCollectionViewCell class]]) {
        SENSensor* sensor = [self groupedSensors][[indexPath row]];
        [self configureSensorCell:(id)cell forSensor:sensor];
    } else if ([cell isKindOfClass:[HEMSenseRequiredCollectionViewCell class]]) {
        [self configurePairSenseCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) { // error
        [self configureErrorCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMSensorGroupCollectionViewCell class]]) {
        NSArray<SENSensor*>* sensors = [self groupedSensors][[indexPath row]];
        [self configureGroupSensorCell:(id)cell forSensors:sensors];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeZero;
    if ([[self introService] shouldIntroduceType:HEMIntroTypeRoomConditions]) {
        if ([self headerViewHeight] < 0.0f) {
            HEMCardFlowLayout* flowLayout = (id) collectionViewLayout;
            NSAttributedString* title = [self attributedIntroTitle];
            NSAttributedString* message = [self attributedIntroDesc];
            CGFloat itemWidth = [flowLayout itemSize].width;
            [self setHeaderViewHeight:[HEMDescriptionHeaderView heightWithTitle:title
                                                                     description:message
                                                                widthConstraint:itemWidth]];
        }
        headerSize.height = [self headerViewHeight];
    }
    return headerSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = kHEMRoomConditionsIntroReuseId;
    HEMDescriptionHeaderView* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                          withReuseIdentifier:reuseId
                                                                                 forIndexPath:indexPath];
    
    [[header titlLabel] setAttributedText:[self attributedIntroTitle]];
    [[header descriptionLabel] setAttributedText:[self attributedIntroDesc]];
    [[header descriptionLabel] sizeToFit];
    [[header imageView] setImage:[UIImage imageNamed:@"introRoomConditions"]];
    
    if (![self loadedIntro]) {
        [[self introService] incrementIntroViewsForType:HEMIntroTypeRoomConditions];
        [self setLoadedIntro:YES];
    }
    
    return header;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id sensorObj = [self groupedSensors][[indexPath row]];
    if ([sensorObj isKindOfClass:[SENSensor class]]) {
        [[self delegate] showSensor:sensorObj fromPresenter:self];
    }
}

#pragma mark - Cell configurations

- (void)configureGroupSensorCell:(HEMSensorGroupCollectionViewCell*)groupCell
                      forSensors:(NSArray<SENSensor*>*)sensors {
    NSString* groupTitle = NSLocalizedString(@"room-conditions.air-quality", nil);
    [[groupCell groupNameLabel] setText:[groupTitle uppercaseString]];
    
    SENCondition worstCondition = SENConditionIdeal;
    NSString* worstConditionString = nil;
    for (SENSensor* sensor in sensors) {
        if (!worstConditionString || [sensor condition] < worstCondition) {
            worstConditionString = [sensor localizedMessage];
            worstCondition = [sensor condition];
        }
        
        [[self formatter] setSensorUnit:[sensor unit]];
        [[self formatter] setIncludeUnitSymbol:YES];
        UIColor* conditionColor = [UIColor colorForCondition:[sensor condition]];
        NSString* valueText = [[self formatter] stringFromSensor:sensor];
        NSString* name = [sensor localizedName];
        [groupCell addSensorWithName:name value:valueText valueColor:conditionColor];
    }
    [[groupCell groupMessageLabel] setText:worstConditionString];
}

- (void)configureSensorCell:(HEMSensorCollectionViewCell*)sensorCell forSensor:(SENSensor*)sensor {
    [[self formatter] setSensorUnit:[sensor unit]];
    
    if ([sensor unit] == SENSensorUnitPercent
        || [sensor unit] == SENSensorUnitCelsius
        || [sensor unit] == SENSensorUnitFahrenheit) {
        [[self formatter] setIncludeUnitSymbol:YES];
        [[sensorCell unitLabel] setText:nil];
    } else {
        [[self formatter] setIncludeUnitSymbol:NO];
        [[sensorCell unitLabel] setText:[[self formatter] unitSymbol]];
    }
    
    SENCondition condition = [sensor condition];
    ChartViewBase* chartView = [self chartViewForSensor:sensor inCell:sensorCell];
    NSString* formattedValue = [[self formatter] stringFromSensorValue:[sensor value]];
    
    [[sensorCell descriptionLabel] setText:[sensor localizedMessage]];
    [[sensorCell nameLabel] setText:[[sensor localizedName] uppercaseString]];
    [[sensorCell valueLabel] setText:formattedValue];
    [[sensorCell valueLabel] setTextColor:[UIColor colorForCondition:condition]];
    [[sensorCell graphContainerView] setChartView:chartView];
    [[[sensorCell graphContainerView] topLimitLabel] setText:nil];
    [[[sensorCell graphContainerView] botLimitLabel] setText:nil];
    
    [chartView animateWithXAxisDuration:kHEMRoomConditionsChartAnimeDuration];
}

- (void)configureErrorCell:(HEMTextCollectionViewCell*)errorCell {
    [[errorCell textLabel] setText:NSLocalizedString(@"sensor.data-unavailable", nil)];
    [[errorCell textLabel] setFont:[UIFont errorStateDescriptionFont]];
    [errorCell displayAsACard:YES];
}

- (void)configurePairSenseCell:(HEMSenseRequiredCollectionViewCell*)pairSenseCell {
    NSString* buttonTitle = NSLocalizedString(@"room-conditions.pair-sense.button.title", nil);
    NSString* message = NSLocalizedString(@"room-conditions.pair-sense.message", nil);
    [[pairSenseCell descriptionLabel] setText:message];
    [[pairSenseCell pairSenseButton] addTarget:self
                                        action:@selector(pairSense)
                              forControlEvents:UIControlEventTouchUpInside];
    [[pairSenseCell pairSenseButton] setTitle:[buttonTitle uppercaseString]
                                     forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)pairSense {
    [[self pairDelegate] pairSenseFrom:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
