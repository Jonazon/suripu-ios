//
//  HEMSensorDetailPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <Charts/Charts-Swift.h>
#import "LineChartView+HEMSensor.h"

#import <SenseKit/SENSensor.h>
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENSensorStatus.h>

#import "Sense-Swift.h"

#import "HEMSensorDetailPresenter.h"
#import "HEMSensorService.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"
#import "HEMSensorValueFormatter.h"
#import "HEMSensorChartContainer.h"
#import "HEMSubNavigationView.h"
#import "HEMScreenUtils.h"
#import "HEMHandHoldingService.h"
#import "HEMHandholdingView.h"

#import "HEMSensorValueCollectionViewCell.h"
#import "HEMSensorAboutCollectionViewCell.h"
#import "HEMSensorChartCollectionViewCell.h"
#import "HEMSensorScaleCollectionViewCell.h"

static CGFloat const kHEMSensorDetailCellChartHeightRatio = 0.45f;
static CGFloat const kHEMSensorDetailChartXLabelCount = 7;
static NSUInteger const kHEMSensorDetailXAxisOffset = 10;
static CGFloat const kHEMSensorDetailMaxChartHeight = 271.0f;
static CGFloat const kHEMSensorDetailChartTopSpaceOffset = 0.09f;
static CGFloat const kHEMSensorDetailChartHandHoldingPadding = 24.0f;

typedef NS_ENUM(NSUInteger, HEMSensorDetailContent) {
    HEMSensorDetailContentValue = 0,
    HEMSensorDetailContentChart,
    HEMSensorDetailContentScale,
    HEMSensorDetailContentAbout
};

@interface HEMSensorDetailPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    HEMSensorChartScrubberDelegate
>

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) HEMHandHoldingService* handHoldingService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* content;
@property (nonatomic, strong) SENSensor* sensor;
@property (nonatomic, strong) NSAttributedString* aboutDetail;
@property (nonatomic, strong) HEMSensorValueFormatter* formatter;
@property (nonatomic, strong) SENSensorStatus* status;
@property (nonatomic, strong) SENSensorDataCollection* sensorData;
@property (nonatomic, strong) NSError* pollError;
@property (nonatomic, strong) NSArray<ChartDataEntry*>* chartData;
@property (nonatomic, strong) NSArray<NSString*>* xLabelData;
@property (nonatomic, assign) HEMSensorServiceScope scopeSelected;
@property (nonatomic, strong) NSDateFormatter* xAxisLabelFormatter;
@property (nonatomic, assign) BOOL chartLoaded;
@property (nonatomic, assign, getter=isScrubbing) BOOL scrubbing;
@property (nonatomic, weak) LineChartView* chartView;
@property (nonatomic, strong) NSDateFormatter* exactTimeFormatter;
@property (nonatomic, weak) UILabel* currentValueLabel;
@property (nonatomic, weak) HEMSensorValueCollectionViewCell* valueCell;
@property (nonatomic, assign) SENSensorType type;
@property (nonatomic, weak) HEMHandholdingView* handHoldingView;

@property (nonatomic, assign) CGFloat chartMinValue;
@property (nonatomic, assign) CGFloat chartMaxValue;

@end

@implementation HEMSensorDetailPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                            forSensor:(SENSensor*)sensor
                andHandHoldingService:(HEMHandHoldingService*)handHoldingService {
    if (self = [super init]) {
        _sensorService = sensorService;
        _handHoldingService = handHoldingService;
        _sensor = sensor;
        _type = [sensor type];
        _chartMinValue = MAXFLOAT;
        _chartMaxValue = 0.0f;
        _xAxisLabelFormatter = [NSDateFormatter new];
        _exactTimeFormatter = [NSDateFormatter new];
        _formatter = [[HEMSensorValueFormatter alloc] initWithSensorUnit:[sensor unit]];
        [_formatter setIncludeUnitSymbol:YES];
        
        [self updateFormatters];
        [self determineContent];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNav {
    [self bindWithShadowView:[subNav shadowView]];
}

- (void)determineContent {
    NSString* sensorType = [[[self sensor] typeStringValue] lowercaseString];
    if ([[self sensor] type] == SENSensorTypeTemp) {
        if ([SENPreference useCentigrade]) {
            sensorType = [sensorType stringByAppendingString:@".celsius"];
        } else {
            sensorType = [sensorType stringByAppendingString:@".fahrenheit"];
        }
    }
    NSString* aboutKey = [NSString stringWithFormat:@"sensor.section.about.%@", sensorType];
    NSString* about = NSLocalizedString(aboutKey, nil);
    
    NSMutableArray* content = [NSMutableArray arrayWithCapacity:HEMSensorDetailContentAbout + 1];
    [content addObject:@(HEMSensorDetailContentValue)];
    [content addObject:@(HEMSensorDetailContentChart)];
    
    // check if sensor has scales to show
    if ([[[self sensor] scales] count] > 0) {
        [content addObject:@(HEMSensorDetailContentScale)];
    }
    
    // if string for content exists
    if (![about isEqualToString:aboutKey]) {
        NSDictionary* attributes = @{NSFontAttributeName : [UIFont body],
                                     NSForegroundColorAttributeName : [UIColor grey5],
                                     NSParagraphStyleAttributeName : DefaultBodyParagraphStyle()};
        [self setAboutDetail:[[NSAttributedString alloc] initWithString:about attributes:attributes]];
        [content addObject:@(HEMSensorDetailContentAbout)];
    }
    
    [self setContent:content];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    NSString* sensorType = [[self sensor] typeStringValue];
    NSDictionary* props = @{kHEMAnalyticsEventPropSensorName : sensorType ?: @""};
    [SENAnalytics track:kHEMAnalyticsEventSensor properties:props];
}

- (void)didGainConnectivity {
    [super didGainConnectivity];
    if ([self pollError]) {
        [self startPolling];
    }
}

#pragma mark - Poll data

- (void)startPolling {
    __weak typeof(self) weakSelf = self;
    HEMSensorService* service = [self sensorService];
    [service pollDataForSensorType:[self type]
                         withScope:[self scopeSelected]
                        completion:^(HEMSensorServiceScope scope,
                                     SENSensorStatus* status,
                                     SENSensorDataCollection* data,
                                     NSError* error) {
                        
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            
                            if ([strongSelf scopeSelected] != scope) {
                                return; // ignore
                            }
                        
                            [strongSelf setPollError:error];
                            if (!error) {
                                BOOL needsUIUpdate = ![strongSelf status]
                                    || ![status isEqual:[strongSelf status]];
                                [strongSelf setStatus:status];
                                [strongSelf updateSensorFromStatus];
                            
                                SENSensorDataCollection* sensorData = data;
                                if (sensorData && ![[strongSelf sensorData] isEqual:sensorData]) {
                                    [strongSelf setSensorData:data];
                                    needsUIUpdate = needsUIUpdate || YES;
                                }
                            
                                if (needsUIUpdate) {
                                    [strongSelf prepareChartDataAndReload];
                                }
                            
                            } else {
                                [strongSelf setSensor:nil];
                                [strongSelf clearData];
                                [strongSelf reloadUI];
                            }
                    }];
}

- (void)updateSensorFromStatus {
    for (SENSensor* sensor in [[self status] sensors]) {
        if ([sensor type] == [self type]) {
            [self setSensor:sensor];
            break;
        }
    }
}

- (void)reloadUI {
    if (![self isScrubbing]) {
        [[self collectionView] reloadData];
        [self showScrollTutorialIfNeeded];
    }
}

- (void)prepareChartDataAndReload {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray<NSNumber*>* values = [[strongSelf sensorData] filteredDataPointsWithType:[[strongSelf sensor] type]];
        NSArray<SENSensorTime*>* timestamps = [[strongSelf sensorData] timestamps];
        NSUInteger valueCount = [values count];
        
        if (valueCount <= [timestamps count]) { // # of timestamps cannot be less than # of values!
            NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:valueCount];
            NSMutableArray* labelData = [NSMutableArray arrayWithCapacity:kHEMSensorDetailChartXLabelCount];
            NSInteger indicesBetweenLabels = (valueCount - 1) / kHEMSensorDetailChartXLabelCount;
            NSUInteger index = 0;
            SENSensorTime* time = nil;
            for (NSNumber* value in values) {
                CGFloat entryValue = MAX(0.0f, [value doubleValue]);
                [chartData addObject:[[ChartDataEntry alloc] initWithX:index y:entryValue]];
                if (index == ([labelData count] + 1) * indicesBetweenLabels) {
                    NSInteger indexWithOffset = index - kHEMSensorDetailXAxisOffset;
                    time = [[strongSelf sensorData] timestamps][indexWithOffset];
                    [labelData addObject:[[strongSelf xAxisLabelFormatter]
                                          stringFromDate:[time date]]];
                }
                
                if ([value doubleValue] < [strongSelf chartMinValue]) {
                    [strongSelf setChartMinValue:entryValue];
                }
                
                if ([value doubleValue] > [strongSelf chartMaxValue]) {
                    [strongSelf setChartMaxValue:entryValue];
                }
                
                index++;
            }
            [strongSelf setChartData:chartData];
            [strongSelf setXLabelData:labelData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf reloadUI];
        });
    });
}

- (void)clearData {
    [self setChartData:nil];
    [self setSensorData:nil];
    [self setXLabelData:nil];
    [self setStatus:nil];
    [self setChartMaxValue:0.0f];
    [self setChartMinValue:MAXFLOAT];
}

- (void)setPollScope:(HEMSensorServiceScope)scope {
    [[self sensorService] stopPollingForData];
    [self setScopeSelected:scope];
    [self clearData];
    [self updateFormatters];
    [self reloadUI];
    [self startPolling];
}

- (void)updateFormatters {
    if ([self scopeSelected] == HEMSensorServiceScopeWeek) {
        [[self xAxisLabelFormatter] setDateFormat:@"EEE"];
        if ([SENPreference timeFormat] == SENTimeFormat24Hour) {
            [[self exactTimeFormatter] setDateFormat:@"EEEE - HH:mm"];
        } else {
            [[self exactTimeFormatter] setDateFormat:@"EEEE - h:mm a"];
        }
    } else {
        if ([SENPreference timeFormat] == SENTimeFormat24Hour) {
            [[self xAxisLabelFormatter] setDateFormat:@"HH:mm"];
            [[self exactTimeFormatter] setDateFormat:@"HH:mm"];
        } else {
            [[self xAxisLabelFormatter] setDateFormat:@"ha"];
            [[self exactTimeFormatter] setDateFormat:@"h:mm a"];
        }
    }
}

#pragma mark - Hand Holding

- (void)showScrubbingTutorialIfNeeded {
    if ([self chartLoaded]
        && [self chartView]
        && ![self handHoldingView]
        && [[self handHoldingService] shouldShow:HEMHandHoldingSensorScrubbing]) {
        CGRect frame = [[self chartView] convertRect:[[self chartView] bounds]
                                              toView:[[self collectionView] superview]];
        CGFloat midY = CGRectGetMidY(frame);
        CGFloat width = CGRectGetWidth(frame);
        CGFloat halfSize = HEMHandholdingGestureSize / 2.0f;
        CGFloat endX = width - halfSize - kHEMSensorDetailChartHandHoldingPadding;
        CGFloat startX = halfSize + kHEMSensorDetailChartHandHoldingPadding;
        CGPoint startPoint = CGPointMake(startX, midY);
        CGPoint endPoint = CGPointMake(endX, midY);
        
        HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
        [handholdingView setGestureStartCenter:startPoint];
        [handholdingView setGestureEndCenter:endPoint];
        [handholdingView setMessage:NSLocalizedString(@"handholding.message.sensor-scrubbing", nil)];
        [handholdingView setAnchor:HEMHHDialogAnchorBottom];
        
        __weak typeof(self) weakSelf = self;
        [handholdingView showInView:[[self collectionView] superview]
                    fromContentView:[self chartView]
                      dismissAction:^(BOOL shown) {
                          __strong typeof(weakSelf) strongSelf = self;
                          if (shown) {
                              [strongSelf completeScrubbingTutorial];
                          }
                      }];
        
        [self setHandHoldingView:handholdingView];
    }
}

- (void)completeScrubbingTutorial {
    [[self handHoldingService] completed:HEMHandHoldingSensorScrubbing];
    [self setHandHoldingView:nil];
}

- (void)showScrollTutorialIfNeeded {
    if ([[self collectionView] contentOffset].y == 0.0f
        && ![self handHoldingView]
        && [[self handHoldingService] shouldShow:HEMHandHoldingSensorScroll]) {
        
        HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
        [handholdingView setMessageStyle:HEMHHMessageStyleOval];
        [handholdingView setMessage:NSLocalizedString(@"handholding.message.sensor-scroll", nil)];
        [handholdingView setAnchor:HEMHHDialogAnchorBottom];
        [handholdingView showInView:[[self collectionView] superview]
                    fromContentView:[[self collectionView] superview]
                      dismissAction:nil];
        
        [self setHandHoldingView:handholdingView];
    }
}

- (void)completeScrollTutorial {
    [[self handHoldingService] completed:HEMHandHoldingSensorScroll];
    [self setHandHoldingView:nil];
}

#pragma mark - UICollectionViewDelegate / DataSource

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* flowLayout = (id)collectionViewLayout;
    CGFloat widthBounds = CGRectGetWidth([[collectionView superview] bounds]);
    CGFloat heightBounds = CGRectGetHeight([[collectionView superview] bounds]);
    CGFloat cellSpacing = [flowLayout minimumInteritemSpacing];
    CGFloat topSpacing = [flowLayout sectionInset].top;
    CGFloat height = 0.0f;
    // FIXME: hack this for now to ensure limit lines are touched by the chart
    // for as many devices as possible
    CGFloat chartHeight = kHEMSensorDetailMaxChartHeight;
    if (HEMIsIPhone4Family()) {
        chartHeight = heightBounds * kHEMSensorDetailCellChartHeightRatio;
    }
    
    NSNumber* contentType = [self content][[indexPath row]];
    switch ([contentType unsignedIntegerValue]) {
        default:
        case HEMSensorDetailContentValue:
            height = CGRectGetHeight([collectionView bounds])
                        - cellSpacing
                        - topSpacing
                        - chartHeight;
            break;
        case HEMSensorDetailContentChart:
            height = chartHeight;
            break;
        case HEMSensorDetailContentScale: {
            NSUInteger count = [[[self sensor] scales] count];
            height = [HEMSensorScaleCollectionViewCell heightWithNumberOfScales:count];
            break;
        }
        case HEMSensorDetailContentAbout: {
            NSString* title = NSLocalizedString(@"sensor.section.about.title", nil);
            height = [HEMSensorAboutCollectionViewCell heightWithTitle:title
                                                                 about:[self aboutDetail]
                                                              maxWidth:widthBounds];
            break;
        }
    }

    return CGSizeMake(widthBounds, height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self content] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    NSNumber* contentType = [self content][[indexPath row]];
    switch ([contentType unsignedIntegerValue]) {
        case HEMSensorDetailContentValue:
            reuseId = [HEMMainStoryboard currentValueReuseIdentifier];
            break;
        case HEMSensorDetailContentChart:
            reuseId = [HEMMainStoryboard chartReuseIdentifier];
            break;
        case HEMSensorDetailContentScale:
            reuseId = [HEMMainStoryboard scaleReuseIdentifier];
            break;
        case HEMSensorDetailContentAbout:
            reuseId = [HEMMainStoryboard aboutReuseIdentifier];
            break;
        default:
            break;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSensorValueCollectionViewCell class]]) {
        [self configureValueCell:(id) cell];
    } else if ([cell isKindOfClass:[HEMSensorChartCollectionViewCell class]]) {
        [self configureChartCell:(id) cell];
    } else if ([cell isKindOfClass:[HEMSensorScaleCollectionViewCell class]]) {
        [self configureScaleCell:(id) cell];
    } else if ([cell isKindOfClass:[HEMSensorAboutCollectionViewCell class]]) {
        [self configureAboutCell:(id) cell];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
    [self completeScrollTutorial];
}

#pragma mark - Cell appearance

- (LineChartView*)chartViewForSensor:(SENSensor*)sensor
                              inCell:(HEMSensorChartCollectionViewCell*)cell {
    SENCondition condition = [sensor condition];
    UIColor* sensorColor = [UIColor colorForCondition:condition];
    LineChartView* lineChartView = (id) [[cell chartContentView] chartView];
    
    if (!lineChartView) {
        CGRect chartFrame = [[cell chartContentView] bounds];
        lineChartView = [[LineChartView alloc] initForSensorWithFrame:chartFrame];
        
        ChartYAxis* yAxis = [lineChartView leftAxis];
        CGFloat chartHeight = CGRectGetHeight(chartFrame);
        CGFloat topLimitY = CGRectGetMaxY([[[cell chartContentView] topLimitLine] frame]);
        CGFloat xAxisHeight = CGRectGetHeight([[cell xAxisLabelContainer] bounds]);
        // round down
        CGFloat bottomSpace = floorCGFloat((xAxisHeight / chartHeight) * 100) / 100.0f;
        CGFloat topSpace = floorCGFloat((topLimitY/ chartHeight) * 100) / 100.0f;
        [yAxis setSpaceTop:kHEMSensorDetailChartTopSpaceOffset + topSpace];
        [yAxis setSpaceBottom:topSpace + bottomSpace];
    }
    
    LineChartDataSet* dataSet = [[LineChartDataSet alloc] initWithData:[[self chartData] copy]
                                                                  color:sensorColor];

    [lineChartView setData:[[LineChartData alloc] initWithDataSet:dataSet]];
    [lineChartView setGridBackgroundColor:sensorColor];
    [lineChartView setNeedsDisplay];
    
    return lineChartView;
}

- (void)updateValueCell:(HEMSensorValueCollectionViewCell*)valueCell
              withValue:(NSNumber*)value
              condition:(SENCondition)condition
                message:(NSString*)message {
    UIColor* conditionColor = [UIColor colorForCondition:condition];
    UIImage* valueReplacementImage = nil;
    
    if (condition == SENConditionCalibrating) {
        valueReplacementImage = [UIImage imageNamed:@"sensorCalibrating"];
    } else {
        if ([[self sensor] type] == SENSensorTypeTemp) {
            NSString* valueString = nil;
            if (value) {
                valueString = [[self formatter] stringFromSensorValue:value];
            } else {
                NSString* emtpyData = NSLocalizedString(@"empty-data", nil);
                NSString* symbol = [[self formatter] unitSymbol];
                valueString = [NSString stringWithFormat:@"%@%@", emtpyData, symbol];
            }
            [[valueCell valueLabel] setTextColor:conditionColor];
            [[valueCell valueLabel] setText:valueString];
            [[valueCell valueLabel] setFont:[UIFont h1]];
        } else {
            NSDictionary* valueAttributes = @{NSFontAttributeName : [UIFont h1],
                                              NSForegroundColorAttributeName : conditionColor};
            NSDictionary* unitAttributes = @{NSFontAttributeName : [UIFont h4],
                                             NSForegroundColorAttributeName : conditionColor,
                                             NSBaselineOffsetAttributeName : @(12.0f)};
            
            NSAttributedString* attrValue = [[self formatter] attributedValue:value
                                                           unitSymbolLocation:HEMSensorValueUnitLocSubscript
                                                              valueAttributes:valueAttributes
                                                               unitAttributes:unitAttributes];
            [[valueCell valueLabel] setAttributedText:attrValue];
        }
    }
    
    [valueCell replaceValueWithImage:valueReplacementImage];
    [[valueCell messageLabel] setText:message];
    [[valueCell messageLabel] setTextColor:[UIColor grey5]];
    [[valueCell messageLabel] setFont:[UIFont body]];
}

- (void)configureValueCell:(HEMSensorValueCollectionViewCell*)valueCell {
    NSNumber* value = nil;
    NSString* message = nil;
    SENCondition condition = SENConditionUnknown;
    if (![self pollError]) {
        message = [[self sensor] localizedMessage];
        value = [[self sensor] value];
        condition = [[self sensor] condition];
    }

    [self updateValueCell:valueCell withValue:value condition:condition message:message];
    [self setValueCell:valueCell];
}

- (void)configureChartCell:(HEMSensorChartCollectionViewCell*)chartCell {
    LineChartView* chartView = nil;
    HEMSensorChartContainer* chartContainer = [chartCell chartContentView];
    [chartContainer setScrubberColor:[UIColor colorForCondition:[[self sensor] condition]]];
    [chartContainer setDelegate:self];
    [chartCell setXAxisLabels:[self xLabelData]];
    
    if (![self sensorData]) {
        BOOL hasError = [self pollError] != nil;
        [chartContainer showLoadingActivity:!hasError];
        [[chartContainer noDataLabel] setText:NSLocalizedString(@"sensor.data.error", nil)];
        [[chartContainer noDataLabel] setHidden:!hasError];
        [chartContainer setChartView:nil];
        [[[chartCell chartContentView] topLimitLabel] setText:nil];
        [[[chartCell chartContentView] botLimitLabel] setText:nil];
    } else {
        chartView = [self chartViewForSensor:[self sensor] inCell:chartCell];
        [chartContainer showLoadingActivity:NO];
        [[chartContainer noDataLabel] setHidden:YES];
        
        // must check whether chart data is empty or not before using chartview
        // min / max values, otherwise chart will cause a crash
        if ([[self chartData] count] > 0) {
            
            HEMSensorLimit* limit = [chartView limitFromCalculatedMinY:@([self chartMinValue])
                                                        calculatedMaxY:@([self chartMaxValue])
                                                             formatter:[self formatter]];

            [chartContainer setChartView:chartView];
            [[chartContainer topLimitLabel] setText:[limit max]];
            [[chartContainer botLimitLabel] setText:[limit min]];
            
            if (![self chartLoaded]) {
                [chartView animateIn];
                [self setChartLoaded:YES];
            } else {
                [chartView fadeIn];
            }
        } else {
            [chartContainer setChartView:nil];
            [[[chartCell chartContentView] topLimitLabel] setText:nil];
            [[[chartCell chartContentView] botLimitLabel] setText:nil];
        }
    }
    
    [self setChartView:chartView];
    [self showScrubbingTutorialIfNeeded];
}

- (void)configureScaleCell:(HEMSensorScaleCollectionViewCell*)scaleCell {
    NSUInteger count = [[[self sensor] scales] count];
    NSString* measureFormat = NSLocalizedString(@"sensor.section.scale.measure.format", nil);
    NSString* unitString = [[self formatter] unitSymbol];
    
    if ([[self sensor] type] == SENSensorTypeTemp) {
        if ([SENPreference useCentigrade]) {
            unitString = [NSString stringWithFormat:@"C%@", unitString];
        } else {
            unitString = [NSString stringWithFormat:@"F%@", unitString];
        }
    }

    if ([unitString length] > 0) {
        NSString* measureString = [NSString stringWithFormat:measureFormat, unitString];
        [[scaleCell measurementLabel] setText:measureString];
    } else {
        [[scaleCell measurementLabel] setHidden:YES];
    }
    
    [scaleCell setNumberOfScales:count];
    [[scaleCell titleLabel] setFont:[UIFont h6Bold]];
    [[scaleCell titleLabel] setTextColor:[UIColor grey6]];
    [[scaleCell titleLabel] setText:NSLocalizedString(@"sensor.section.scale.title", nil)];
    
    NSString* rangeFormat = nil;
    NSString* rangeString = nil;
    
    for (SENSensorScale* scale in [[self sensor] scales]) {
        if ([scale min] && [scale max]) {
            rangeFormat = NSLocalizedString(@"sensor.section.scale.range.format", nil);
            rangeString = [NSString stringWithFormat:rangeFormat,
                           [[[self formatter] convertValue:[scale min]] doubleValue],
                           [[[self formatter] convertValue:[scale max]] doubleValue]];
        } else if (![scale min] && [scale max]) {
            rangeFormat = NSLocalizedString(@"sensor.section.scale.range.no-min.format", nil);
            rangeString = [NSString stringWithFormat:rangeFormat,
                           [[[self formatter] convertValue:[scale max]] doubleValue]];
        } else if (![scale max] && [scale min]) {
            rangeFormat = NSLocalizedString(@"sensor.section.scale.range.no-max.format", nil);
            rangeString = [NSString stringWithFormat:rangeFormat,
                           [[[self formatter] convertValue:[scale min]] doubleValue]];
        } else {
            rangeString = NSLocalizedString(@"empty-data", nil);
        }

        [scaleCell addScaleWithName:[scale localizedName]
                              range:rangeString
                     conditionColor:[UIColor colorForCondition:[scale condition]]];
    }
}

- (void)configureAboutCell:(HEMSensorAboutCollectionViewCell*)aboutCell {
    NSString* title = NSLocalizedString(@"sensor.section.about.title", nil);
    [[aboutCell titleLabel] setText:title];
    [[aboutCell titleLabel] setFont:[UIFont h6Bold]];
    [[aboutCell titleLabel] setTextColor:[UIColor grey6]];
    [[aboutCell aboutLabel] setAttributedText:[self aboutDetail]];
    [[aboutCell aboutLabel] setFont:[UIFont body]];
    [[aboutCell aboutLabel] setTextColor:[UIColor grey5]];
}

#pragma mark - HEMSensorChartScrubberDelegate

- (void)willBeginScrubbingIn:(HEMSensorChartContainer *)chartContainer {
    [[self collectionView] setScrollEnabled:NO];
    [self setScrubbing:YES];
    [self completeScrubbingTutorial];
}

- (void)didEndScrubbingIn:(HEMSensorChartContainer *)chartContainer {
    NSString* message = [[self sensor] localizedMessage];
    NSNumber* value = [[self sensor] value];
    SENCondition condition = [[self sensor] condition];
    [self updateValueCell:[self valueCell]
                withValue:value
                condition:condition
                  message:message];
    
    [[self collectionView] setScrollEnabled:YES];
    [self setScrubbing:NO];
}

- (void)didMoveScrubberTo:(CGPoint)pointInChartView within:(HEMSensorChartContainer *)chartContainer {
    NSArray<NSNumber*>* values = [[self sensorData] filteredDataPointsWithType:[[self sensor] type]];
    ChartDataEntry* entry = [[self chartView] getEntryByTouchPointWithPoint:pointInChartView];
    NSInteger index = [entry x];
    NSNumber* actualValue = index < [values count] ? values[index] : nil;
    if ([actualValue integerValue] == kHEMSensorSentinelValue) {
        actualValue = nil;
    }
    SENSensorTime* time = [[self sensorData] timestamps][index];
    NSString* timeString = [[self exactTimeFormatter] stringFromDate:[time date]];
    
    DDLogVerbose(@"moved scrubber to value %f, time %@", [actualValue doubleValue], timeString);
    
    [self updateValueCell:[self valueCell]
                withValue:actualValue
                condition:[[self sensor] condition]
                  message:timeString];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_sensorService) {
        [_sensorService stopPollingForData];
    }
}

@end
