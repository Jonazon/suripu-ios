//
//  HEMTrendsGraphsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENTrends.h>
#import <SenseKit/SENTrendsGraph.h>

#import "Sense-Swift.h"

#import "NSString+HEMUtils.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMTrendsGraphsPresenter.h"
#import "HEMTrendsCalendarViewCell.h"
#import "HEMTrendsBarGraphCell.h"
#import "HEMMultiTitleView.h"
#import "HEMTrendsSleepDepthCell.h"
#import "HEMSubNavigationView.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMTrendsService.h"
#import "HEMMainStoryboard.h"
#import "HEMActivityIndicatorView.h"
#import "HEMTimelineService.h"
#import "HEMCardFlowLayout.h"

static CGFloat const HEMTrendsGraphBarWeekBarSpacing = 5.0f;
static CGFloat const HEMTrendsGraphBarMonthBarSpacing = 2.0f;
static CGFloat const HEMTrendsGraphBarQuarterBarSpacing = 0.0f;
static NSInteger const HEMTrendsGraphAverageRequirement = 3;

@interface HEMTrendsGraphsPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) HEMTrendsService* trendService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) HEMActivityIndicatorView* loadingIndicator;
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign, getter=hasDataError) BOOL dataError;
@property (nonatomic, weak) HEMTrendsCalendarViewCell* sleepScoreCell;
@property (nonatomic, weak) HEMTrendsBarGraphCell* sleepDurationCell;
@property (nonatomic, weak) HEMTrendsSleepDepthCell* sleepDepthCell;
@property (nonatomic, assign) SENTrendsTimeScale scale;

@end

@implementation HEMTrendsGraphsPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendService
                            dataScale:(SENTrendsTimeScale)scale {
    self = [super init];
    if (self) {
        _trendService = trendService;
        _scale = scale == SENTrendsTimeScaleUnknown ? SENTrendsTimeScaleWeek : scale;
        [self listenForTimelineChanges];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView setHidden:NO];
    [collectionView applyStyle];
    [self setCollectionView:collectionView];
    [self refreshTrends];
}

- (void)bindWithLoadingIndicator:(HEMActivityIndicatorView*)loadingIndicator {
    [loadingIndicator stop];
    [loadingIndicator setHidden:YES];
    [loadingIndicator setUserInteractionEnabled:NO];
    [self setLoadingIndicator:loadingIndicator];
}

#pragma mark - Scale Titles

- (NSString*)scaleTitle {
    switch ([self scale]) {
        case SENTrendsTimeScaleMonth:
            return NSLocalizedString(@"trends.scope.month", nil);
        case SENTrendsTimeScaleQuarter:
            return NSLocalizedString(@"trends.scope.quarter", nil);
        case SENTrendsTimeScaleWeek:
        default:
            return NSLocalizedString(@"trends.scope.week", nil);
    }
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    [self refreshTrends];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self refreshTrends];
}

- (void)didChangeTheme:(Theme *)theme auto:(BOOL)automatically {
    [super didChangeTheme:theme auto:automatically];
    [[self collectionView] applyStyle];
    [[self collectionView] reloadData];
}

#pragma mark - Global loading indicator

- (void)showLoading:(BOOL)loading {
    SENTrends* trends = [self selectedTrends];

    if (loading && trends == nil) {
        [[self loadingIndicator] start];
        [[self loadingIndicator] setHidden:NO];
    } else if ([[self loadingIndicator] isAnimating]){
        [[self loadingIndicator] stop];
        [[self loadingIndicator] setHidden:YES];
    }
}

#pragma mark - Notifications

- (void)listenForTimelineChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(timelineChanged:)
                   name:HEMTimelineNotificationTimelineAmended
                 object:nil];
}

- (void)timelineChanged:(NSNotification*)note {
    [[self trendService] expireCache];
    [self refreshTrends];
}

#pragma mark - Data

- (void)refreshTrends {
    if ([self isRefreshing]) {
        return;
    }
    
    [self setRefreshing:YES];
    [self showLoading:YES];
    __weak typeof(self) weakSelf = self;
    [[self trendService] reloadTrends:[self scale] completion:^(SENTrends * trends, SENTrendsTimeScale scale, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setRefreshing:NO];
        [strongSelf showLoading:NO];
        [strongSelf setDataError:error != nil];
        [[strongSelf collectionView] reloadData];
    }];
}

- (BOOL)showTrendsMessage {
    return [[self trendService] isEmpty:[self selectedTrends]]
        || [[self trendService] isReturningUser:[self selectedTrends]]
        || [[self trendService] daysUntilMoreTrends:[self selectedTrends]] > 0;
}

- (SENTrends*)selectedTrends {
    return [[self trendService] cachedTrendsForTimeScale:[self scale]];
}

- (SENTrendsGraph*)selectedTrendsGraphAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger index = [indexPath row];
    if ([self showTrendsMessage]) {
        index--; // adjust to accommodate for trends message
    }
    SENTrends* trends = [self selectedTrends];
    return index >=0 && index < [[trends graphs] count] ? [trends graphs][index] : nil;
}

- (void)partialDataTitle:(NSAttributedString**)attributedTitle
                 message:(NSAttributedString**)attributedMessage
                   image:(UIImage**)partialDataImage
               forTrends:(SENTrends*)trends {
    
    NSString* title = nil, *message = nil;
    
    if ([[self trendService] isEmpty:trends]) {
        title = NSLocalizedString(@"trends.no-data.title", nil);
        message = NSLocalizedString(@"trends.no-data.message", nil);
        *attributedMessage = [self attributedPartialDataMessageWithText:message];
    } else if ([[self trendService] isReturningUser:trends]) {
        title = NSLocalizedString(@"trends.returning-user.title", nil);
        message = NSLocalizedString(@"trends.returning-user.message", nil);
        *attributedMessage = [self attributedPartialDataMessageWithText:message];
    } else {
        title = NSLocalizedString(@"trends.not-enough-data.title", nil);
        
        NSInteger daysToMore = [[self trendService] daysUntilMoreTrends:trends];
        NSString* messageFormat = NSLocalizedString(@"trends.not-enough-data.message.format", nil);
        *attributedMessage = [self attributedPartialDataMessageWithFormat:messageFormat
                                                              andDaysLeft:daysToMore];
    }
    
    *attributedTitle = [self attributedPartialDataTitleWithText:title];
    
    if (partialDataImage) {
        *partialDataImage = [UIImage imageNamed:@"partialTrends"];
    }
}

#pragma mark - Height Calculations

- (CGFloat)heightForCalendarViewForGraphData:(SENTrendsGraph*)graph itemWidth:(CGFloat)itemWidth {
    BOOL averages = [[graph annotations] count] == HEMTrendsGraphAverageRequirement;
    
    HEMTrendsCalendarType type = HEMTrendsCalendarTypeMonth;
    if ([graph timeScale] == SENTrendsTimeScaleQuarter) {
        type = HEMTrendsCalendarTypeQuarter;
    }
    
    return [HEMTrendsCalendarViewCell heightWithNumberOfSections:[[graph sections] count]
                                                         forType:type
                                                    withAverages:averages
                                                           width:itemWidth];
}

- (CGFloat)heightForBarGraphWithData:(SENTrendsGraph*)graph {
    return [HEMTrendsBarGraphCell heightWithAverages:[[graph annotations] count] > 0];
}

- (CGFloat)heightForBubbleGraphWithData:(SENTrendsGraph*)graph {
    return [HEMTrendsSleepDepthCell height];
}

- (CGFloat)heightForPartialDataCellWithTrends:(SENTrends*)trends itemWidth:(CGFloat)itemWidth {
    NSAttributedString* attributedTitle = nil, *attributedMessage = nil;
    [self partialDataTitle:&attributedTitle message:&attributedMessage image:NULL forTrends:trends];
    return [StatusMessageCell heightWithTitle:attributedTitle
                                      message:attributedMessage
                                    itemWidth:itemWidth];
}

- (CGFloat)heightForErrorMessageWithItemWidth:(CGFloat)itemWidth {
    NSString* message = NSLocalizedString(@"trends.loading.error.message", nil);
    UIFont* font = [UIFont body];
    CGFloat leftMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginLeft];
    CGFloat rightMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginRight];
    CGFloat topMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginTop];
    CGFloat botMargin = [SenseStyle floatWithGroup:GroupErrors property:ThemePropertyMarginBottom];
    CGFloat maxWidth = itemWidth - leftMargin - rightMargin;
    CGFloat textHeight = [message heightBoundedByWidth:maxWidth usingFont:font];
    return textHeight + topMargin + botMargin;
}

#pragma mark - Attributed Text

- (NSAttributedString*)attributedPartialDataTitleWithText:(NSString*)text {
    if (!text) {
        return nil;
    }
    NSDictionary* attributes = [StatusMessageCell titleAttributes];
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSDictionary*)attributesForPartialDataMessageWithColor:(UIColor*)color {
    NSMutableDictionary* attributes = [[StatusMessageCell messageAttributes] mutableCopy];
    [attributes setValue:color forKey:NSForegroundColorAttributeName];
    return attributes;
}

- (NSAttributedString*)attributedPartialDataMessageWithText:(NSString*)message{
    if (!message) {
        return nil;
    }
    NSDictionary* attributes = [StatusMessageCell messageAttributes];
    return [[NSAttributedString alloc] initWithString:message attributes:attributes];
}

- (NSAttributedString*)attributedPartialDataMessageWithFormat:(NSString*)format
                                                  andDaysLeft:(NSInteger)daysLeft {
    if (!format) {
        return nil;
    }
    
    NSDictionary* boldAttr = [StatusMessageCell boldMessageAttributes];
    NSDictionary* regAttr = [StatusMessageCell messageAttributes];
    NSParagraphStyle* para = regAttr[NSParagraphStyleAttributeName];
    
    NSString* dayNumberText = [NSString stringWithFormat:@"%ld", (long)daysLeft];
    NSAttributedString* boldNumber = [[NSAttributedString alloc] initWithString:dayNumberText
                                                                     attributes:boldAttr];
    
    NSString* daysText = nil;
    if (daysLeft == 1) {
        daysText = NSLocalizedString(@"trends.day", nil);
    } else {
        daysText = NSLocalizedString(@"trends.days", nil);
    }
    NSAttributedString* boldDays = [[NSAttributedString alloc] initWithString:daysText
                                                                   attributes:boldAttr];
    
    NSArray* args = @[boldNumber, boldDays];
    NSMutableAttributedString* message
        = [[NSMutableAttributedString alloc] initWithFormat:format
                                                       args:args
                                                  baseColor:regAttr[NSForegroundColorAttributeName]
                                                   baseFont:regAttr[NSFontAttributeName]];
    [message addAttribute:NSParagraphStyleAttributeName
                    value:para
                    range:NSMakeRange(0, [message length])];
    
    return message;
}

- (NSAttributedString*)attributedSubtitleTextFromString:(NSString*)string
                                            highlighted:(BOOL)highlighted {
    
    UIFont* textFont = [SenseStyle fontWithGroup:GroupTrendsTitles property:ThemePropertyTextFont];
    UIColor* textColor = [SenseStyle colorWithGroup:GroupTrendsTitles property:ThemePropertyTextColor];
    UIColor* boldColor = [SenseStyle colorWithGroup:GroupTrendsTitles property:ThemePropertyTextHighlightedColor];
    
    NSMutableParagraphStyle* paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    
    UIColor* color = highlighted ? boldColor : textColor;
    NSDictionary* attributes = @{NSFontAttributeName : textFont,
                                 NSForegroundColorAttributeName : color,
                                 NSKernAttributeName : @1,
                                 NSParagraphStyleAttributeName : paraStyle};
    
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSArray<NSAttributedString*>*)graphTitlesFrom:(SENTrendsGraph*)graph {
    NSMutableArray* titles = [NSMutableArray arrayWithCapacity:[[graph sections] count]];
    for (SENTrendsGraphSection* section in [graph sections]) {
        NSInteger titleIndex = 0;
        for (NSString* title in [section titles]) {
            BOOL highlighted = [[section highlightedTitleIndex] isEqualToNumber:@(titleIndex)];
            [titles addObject:[self attributedSubtitleTextFromString:title highlighted:highlighted]];
            titleIndex++;
        }
    }
    return titles;
}

- (NSAttributedString*)attributedTitleFromAnnotation:(SENTrendsAnnotation*)annotation {
    NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor lowImportanceTextColor],
                                 NSFontAttributeName : [UIFont h8]};
    NSString* title = [annotation title];
    if (!title) {
        title = NSLocalizedString(@"empty-data", nil);
    }
    return [[NSAttributedString alloc] initWithString:title
                                           attributes:attributes];
}

- (NSAttributedString*)attributedScoreFromAnnotation:(SENTrendsAnnotation*)annotation
                                             inGraph:(SENTrendsGraph*)graph{
    NSInteger averageValue = [[annotation value] integerValue];
    SENCondition condition = [[self trendService] conditionForValue:@(averageValue) inGraph:graph];
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont trendAverageValueFont],
                                 NSForegroundColorAttributeName : [UIColor colorForCondition:condition]};
    NSString* valueText = nil;
    if (averageValue >= 0) {
        valueText = [NSString stringWithFormat:@"%ld", (long)averageValue];
    } else {
        valueText = NSLocalizedString(@"empty-data", nil);
    }
    return [[NSAttributedString alloc] initWithString:valueText attributes:attributes];
}

- (NSAttributedString*)attributedSleepDurationFromAnnotation:(SENTrendsAnnotation*)annotation {
    UIColor* color = [SenseStyle colorWithSleepState:SENTimelineSegmentSleepStateSound];
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont trendAverageValueFont],
                                 NSForegroundColorAttributeName : color};
    CGFloat averageValue = [[annotation value] CGFloatValue];
    NSString* avgFormat = NSLocalizedString(@"trends.sleep-duration.average.format", nil);
    NSString* valueText = [NSString stringWithFormat:avgFormat, averageValue];
    NSMutableAttributedString* attrValue = [[NSMutableAttributedString alloc] initWithString:valueText
                                                                                  attributes:attributes];
    NSRange unitRange = NSMakeRange([valueText length] - 1, 1);
    [attrValue addAttribute:NSFontAttributeName value:[UIFont h5] range:unitRange];
    return attrValue;
}

- (void)averagesFromGraph:(SENTrendsGraph*)graph
                   titles:(NSArray<NSAttributedString*>**)titles
                   values:(NSArray<NSAttributedString*>**)values {
    
    NSMutableArray<NSAttributedString*>* averageTitles = nil;
    NSMutableArray<NSAttributedString*>* averageValues = nil;
    NSInteger annotationCount = [[graph annotations] count];
    if (annotationCount > 0) {
        averageTitles = [NSMutableArray arrayWithCapacity:annotationCount];
        averageValues = [NSMutableArray arrayWithCapacity:annotationCount];
        for (SENTrendsAnnotation* annotation in [graph annotations]) {
            [averageTitles addObject:[self attributedTitleFromAnnotation:annotation]];
            switch ([graph displayType]) {
                case SENTrendsDisplayTypeGrid:
                case SENTrendsDisplayTypeOverview:
                    [averageValues addObject:[self attributedScoreFromAnnotation:annotation inGraph:graph]];
                    break;
                case SENTrendsDisplayTypeBar:
                    [averageValues addObject:[self attributedSleepDurationFromAnnotation:annotation]];
                    break;
                default:
                    break;
            }
            
        }
    }
    *titles = averageTitles;
    *values = averageValues;
}

- (CGFloat)barSpacingForTimeScale:(SENTrendsTimeScale)timeScale {
    switch (timeScale) {
        case SENTrendsTimeScaleWeek:
            return HEMTrendsGraphBarWeekBarSpacing;
        case SENTrendsTimeScaleMonth:
            return HEMTrendsGraphBarMonthBarSpacing;
        case SENTrendsTimeScaleQuarter:
        case SENTrendsTimeScaleUnknown:
        default:
            return HEMTrendsGraphBarQuarterBarSpacing;
    }
}

#pragma mark - Configuring Cells

- (void)setAveragesIn:(HEMTrendsBaseCell*)cell fromGraph:(SENTrendsGraph*)graph {
    NSArray<NSAttributedString*>* averageTitles = nil;
    NSArray<NSAttributedString*>* averageValues = nil;
    [self averagesFromGraph:graph titles:&averageTitles values:&averageValues];
    [cell setAverageTitles:averageTitles values:averageValues];
}

- (void)configureCalendarCell:(HEMTrendsCalendarViewCell*)calendarCell forTrendsGraph:(SENTrendsGraph*)graph {
    [self setAveragesIn:calendarCell fromGraph:graph];
    
    HEMTrendsCalendarType type = HEMTrendsCalendarTypeMonth;
    if ([graph timeScale] == SENTrendsTimeScaleQuarter) {
        type = HEMTrendsCalendarTypeQuarter;
    }
    [calendarCell setType:type];
    [[calendarCell titleLabel] setText:[graph title]];
    
    // type must be set first!
    [calendarCell setSectionTitles:[self graphTitlesFrom:graph]
                            scores:[[self trendService] segmentedDataPointsFrom:graph]];
}

- (void)configureBarCell:(HEMTrendsBarGraphCell*)barCell forTrendsGraph:(SENTrendsGraph*)graph {
    [self setAveragesIn:barCell fromGraph:graph];
    
    NSArray<NSAttributedString*>* attributedTitles = [self graphTitlesFrom:graph];
    NSString* highlightFormat = NSLocalizedString(@"trends.sleep-duration.highlight.format", nil);
    UIColor* highlightLabelColor = [UIColor colorForSleepState:SENTimelineSegmentSleepStateSound];
    [[barCell titleLabel] setText:[graph title]];
    [barCell setHighlightLabelColor:highlightLabelColor];
    [barCell setMaxValue:[[graph maxValue] CGFloatValue]];
    [barCell setMinValue:[[graph minValue] CGFloatValue]];
    [barCell setDashLineColor:[UIColor separatorColor]];
    [barCell setHighlightLabelTextFormat:highlightFormat];
    [barCell setHighlightTextFont:[UIFont h7Bold]];
    [barCell updateGraphWithTitles:attributedTitles
                     displayPoints:[[self trendService] segmentedDataPointsFrom:graph]
                           spacing:[self barSpacingForTimeScale:[graph timeScale]]];
}

- (void)configureSleepDepthCell:(HEMTrendsSleepDepthCell*)sleepDepthCell
                 forTrendsGraph:(SENTrendsGraph*)graph {
    CGFloat light, medium, deep = 0.0f;
    [[self trendService] sleepDepthLightPercentage:&light mediumPercentage:&medium deepPercentage:&deep forGraph:graph];
    
    [[sleepDepthCell titleLabel] setText:[graph title]];
    [sleepDepthCell updateLightPercentage:light
                         mediumPercentage:medium
                           deepPercentage:deep];
}

- (void)configureMessageCell:(StatusMessageCell*)messageCell forTrends:(SENTrends*)trends {
    UIImage* partialDataImage = nil;
    NSAttributedString* attributedTitle = nil, *attributedMessage = nil;
    [self partialDataTitle:&attributedTitle message:&attributedMessage image:&partialDataImage forTrends:trends];
    [[messageCell imageView] setImage:partialDataImage];
    [[messageCell titleLabel] setAttributedText:attributedTitle];
    [[messageCell messageLabel] setAttributedText:attributedMessage];
}

- (void)configureErrorCell:(HEMTextCollectionViewCell*)textCell {
    [[textCell textLabel] setText:NSLocalizedString(@"trends.loading.error.message", nil)];
    [textCell setBackgroundColor:[UIColor whiteColor]];
    [textCell displayAsACard:YES];
    [textCell applyStyle];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    SENTrends* trends = [self selectedTrends];
    NSInteger items = 0;
    if ([[self trendService] dataHasBeenLoaded]) {
        items = [self showTrendsMessage] ? 1 : 0;
        items += [[trends graphs] count];
    }
    return items;
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize itemSize = [layout itemSize];
    
    SENTrendsGraph* graph  = [self selectedTrendsGraphAtIndexPath:indexPath];
    switch ([graph displayType]) {
        case SENTrendsDisplayTypeOverview:
        case SENTrendsDisplayTypeGrid:
            itemSize.height = [self heightForCalendarViewForGraphData:graph
                                                            itemWidth:itemSize.width];
            break;
        case SENTrendsDisplayTypeBubble: {
            itemSize.height = [self heightForBubbleGraphWithData:graph];
            break;
        }
        case SENTrendsDisplayTypeBar:
            itemSize.height = [self heightForBarGraphWithData:graph];
            break;
        case SENTrendsDisplayTypeUnknown:
        default: // no data or error
            if ([self hasDataError]) {
                itemSize.height = [self heightForErrorMessageWithItemWidth:itemSize.width];
            } else {
                itemSize.height = [self heightForPartialDataCellWithTrends:[self selectedTrends]
                                                                 itemWidth:itemSize.width];
            }
            break;
    }

    return itemSize;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* reuseId = nil;
    SENTrendsGraph* graph  = [self selectedTrendsGraphAtIndexPath:indexPath];
    
    switch ([graph displayType]) {
        case SENTrendsDisplayTypeBubble:
            reuseId = [HEMMainStoryboard bubblesReuseIdentifier];
            break;
        case SENTrendsDisplayTypeBar:
            reuseId = [HEMMainStoryboard barReuseIdentifier];
            break;
        case SENTrendsDisplayTypeOverview:
        case SENTrendsDisplayTypeGrid:
            reuseId = [HEMMainStoryboard calendarReuseIdentifier];
            break;
        case SENTrendsDisplayTypeUnknown:
        default: // no data
            if ([self hasDataError]) {
                reuseId = [HEMMainStoryboard errorReuseIdentifier];
            } else {
                reuseId = [HEMMainStoryboard messageReuseIdentifier];
            }
            break;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SENTrendsGraph* graph  = [self selectedTrendsGraphAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMTrendsBaseCell class]]) {
        HEMTrendsBaseCell* baseCell = (id)cell;
        [baseCell setLoading:[self isRefreshing]];
        
        if ([cell isKindOfClass:[HEMTrendsCalendarViewCell class]]) {
            [self setSleepScoreCell:(id)cell];
            [self configureCalendarCell:(id)cell forTrendsGraph:graph];
        } else if ([cell isKindOfClass:[HEMTrendsBarGraphCell class]]) {
            [self setSleepDurationCell:(id)cell];
            [self configureBarCell:(id)cell forTrendsGraph:graph];
        } else if ([cell isKindOfClass:[HEMTrendsSleepDepthCell class]]) {
            [self setSleepDepthCell:(id)cell];
            [self configureSleepDepthCell:(id)cell forTrendsGraph:graph];
        }
        
        [baseCell applyStyle];
    } else if ([cell isKindOfClass:[StatusMessageCell class]]) {
        [self configureMessageCell:(id)cell forTrends:[self selectedTrends]];
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) { // error
        [self configureErrorCell:(id)cell];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_collectionView) {
        [_collectionView setDataSource:nil];
        [_collectionView setDelegate:nil];
    }
}

@end
