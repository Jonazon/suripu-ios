//
//  HEMTrendsCalendarMonthView.m
//  Sense
//
//  TODO: this assumes Sunday is the start of the week.  Also, move some NSDate
//  Code over to utility category as they can be reused
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "NSDate+HEMRelative.h"
#import "Sense-Swift.h"
#import "HEMTrendsCalendarMonthView.h"
#import "HEMTrendsDisplayPoint.h"
#import "HEMMultiTitleView.h"
#import "HEMTrendsScoreLabel.h"

CGFloat const HEMTrendsCalMonthDaySpacing = 14.0f;
CGFloat const HEMTrendsCalMonthDaySpacingForQuarter = 10.0f;
NSInteger const HEMTrendsCalMonthDaysInWeek = 7;
static CGFloat const HEMTrendsCalMonthTitleHeight = 13.0f;
static CGFloat const HEMTrendsCalMonthTitleBotMargin = 12.0f;

@interface HEMTrendsCalendarMonthView()

@property (nonatomic, weak) HEMMultiTitleView* titleView;
@property (nonatomic, copy) NSArray<NSAttributedString*>* localizedTitles;
@property (nonatomic, strong) NSMutableArray* scoreLabels;
@property (nonatomic, strong) NSMutableArray* reuseLabels;

@end

@implementation HEMTrendsCalendarMonthView

+ (CGFloat)sizeForEachDayInMonthWithWidth:(CGFloat)width {
    return [self sizeForEachDayWithWidth:width spacing:HEMTrendsCalMonthDaySpacing];
}

+ (CGFloat)sizeForEachDayWithWidth:(CGFloat)width spacing:(CGFloat)spacing {
    CGFloat spacingNeeded = (HEMTrendsCalMonthDaysInWeek - 1) * spacing;
    return ceilCGFloat((width - spacingNeeded) / HEMTrendsCalMonthDaysInWeek);
}

+ (CGFloat)heightForMonthInQuarter:(NSDate*)month maxWidth:(CGFloat)maxWidth {
    NSCalendar* calendar = [self calendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth
                                   inUnit:NSCalendarUnitMonth
                                  forDate:month];
    NSInteger numberOfWeeks = range.length;
    CGFloat scoreSize = [self sizeForEachDayWithWidth:maxWidth spacing:HEMTrendsCalMonthDaySpacingForQuarter];
    CGFloat titleWithSpacing = HEMTrendsCalMonthTitleHeight + HEMTrendsCalMonthTitleBotMargin;
    CGFloat daySpacing = (numberOfWeeks - 1) * HEMTrendsCalMonthDaySpacingForQuarter;
    CGFloat calendarHeight = (numberOfWeeks * scoreSize) + daySpacing;
    return ceilCGFloat(calendarHeight + titleWithSpacing);
}

+ (CGFloat)heightForMonthWithRows:(NSInteger)rows maxWidth:(CGFloat)maxWidth {
    CGFloat size = [self sizeForEachDayInMonthWithWidth:maxWidth];
    CGFloat spacingNeeded = (rows - 1) * HEMTrendsCalMonthDaySpacing;
    CGFloat titleWithSpacing = HEMTrendsCalMonthTitleHeight + HEMTrendsCalMonthTitleBotMargin;
    return (size * rows) + spacingNeeded + titleWithSpacing;
}

+ (NSCalendar*)calendar {
    static NSCalendar* calendar = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return calendar;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scoreLabels = [NSMutableArray array];
        [self configureTitleView];
    }
    return self;
}

- (void)configureTitleView {
    CGRect titleFrame = CGRectZero;
    titleFrame.size.width = CGRectGetWidth([self bounds]);
    titleFrame.size.height = HEMTrendsCalMonthTitleHeight;
    
    HEMMultiTitleView* titleView = [[HEMMultiTitleView alloc] initWithFrame:titleFrame];
    [self setTitleView:titleView];
    [self addSubview:titleView];
}

- (void)updateTitles:(NSArray<NSAttributedString*>*)localizedTitles
         withSpacing:(CGFloat)spacing
               width:(CGFloat)width {
    
    if (!(localizedTitles && [[self localizedTitles] isEqualToArray:localizedTitles])) {
        [[self titleView] clear];
        [self setLocalizedTitles:localizedTitles];
        CGFloat x = 0.0f;
        for (NSAttributedString* title in localizedTitles) {
            CGFloat maxX = [[self titleView] addLabelWithText:title atX:x maxLabelWidth:width];
            x = maxX + spacing;
        }
    } else if (!localizedTitles) {
        [[self titleView] clear];
        [self setLocalizedTitles:nil];
    }
}

- (void)prepareForReuse {
    [[self scoreLabels] makeObjectsPerformSelector:@selector(reuse)];
    [self setReuseLabels:[[self scoreLabels] mutableCopy]];
    [[self scoreLabels] removeAllObjects];
}

- (void)removeAllDayLabels {
    [[self scoreLabels] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self scoreLabels] removeAllObjects];
}

// FIXME: fix this!  Server actually pads all 7 days with nulls, but our APIClient
// code automatically strips out Nulls as if they never existed when parsing the
// response data in to the corresponding data structure.  The fix should be to update
// the API client to provide a filter, if needed, when calling the API and Trends
// logic should be changed to work off of NSNulls AND REMOVE THIS UGLY CODE!
//
// The change here is to reduce the risk in a quick patch release.  Will re-work
// the logic in a bigger release
- (NSArray<NSArray*>*)padValuesIfNeeded:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)values {
    NSInteger numberOfRows = [values count];
    NSMutableArray* rows = [NSMutableArray arrayWithCapacity:numberOfRows];
    NSMutableArray* paddedColumns = nil;
    NSInteger currentRowIndex = 0;
    
    for (NSArray<HEMTrendsDisplayPoint*>* columns in values) {
        paddedColumns = [NSMutableArray arrayWithCapacity:[columns count]];
        if ([columns count] == HEMTrendsCalMonthDaysInWeek) {
            [paddedColumns addObjectsFromArray:columns];
        } else if (numberOfRows > 1 && currentRowIndex == numberOfRows - 1) { // last row
            // must add nulls to the end of the array
            if ([columns count] > 0) {
                [paddedColumns addObjectsFromArray:columns];
            }
            while ([paddedColumns count] < HEMTrendsCalMonthDaysInWeek) {
                [paddedColumns addObject:[NSNull new]];
            }
        } else if (numberOfRows == 1) { // only row
            // must add nulls in the front and end
            NSCalendar* calendar = [[self class] calendar];
            NSInteger weekday = [calendar component:NSCalendarUnitWeekday
                                           fromDate:[[NSDate date] previousDay]];
            
            NSInteger nullsNeededInBack = HEMTrendsCalMonthDaysInWeek - weekday;
            NSInteger nullsNeededInFront = HEMTrendsCalMonthDaysInWeek - nullsNeededInBack - [columns count];
            while (nullsNeededInFront > 0) {
                [paddedColumns addObject:[NSNull new]];
                nullsNeededInFront--;
            }
            
            if ([columns count] > 0) {
                [paddedColumns addObjectsFromArray:columns];
            }
            
            while (nullsNeededInBack > 0) {
                [paddedColumns addObject:[NSNull new]];
                nullsNeededInBack--;
            }
        } else {
            // must add nulls to the front of the array
            NSInteger nullsNeeded = HEMTrendsCalMonthDaysInWeek - [columns count];
            while (nullsNeeded > 0) {
                [paddedColumns addObject:[NSNull new]];
                nullsNeeded--;
            }
            if ([columns count] > 0) {
                [paddedColumns addObjectsFromArray:columns];
            }
        }
        [rows addObject:paddedColumns];
        currentRowIndex++;
    }
    
    return rows;
}

- (void)showCurrentMonthWithValues:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)values
                            titles:(NSArray<NSAttributedString*>*)localizedTitles {

    [self prepareForReuse];
    
    NSArray<NSArray*>* paddedValues = [self padValuesIfNeeded:values];
    
    CGFloat fullWidth = CGRectGetWidth([self bounds]);
    CGFloat scoreSize = [[self class] sizeForEachDayInMonthWithWidth:fullWidth];
    CGFloat scoreSizeWithSpacing = scoreSize + HEMTrendsCalMonthDaySpacing;
    CGFloat titleWithSpacing = HEMTrendsCalMonthTitleHeight + HEMTrendsCalMonthTitleBotMargin;
    
    [self updateTitles:localizedTitles withSpacing:HEMTrendsCalMonthDaySpacing width:scoreSize];
    
    NSInteger rows = [paddedValues count];
    
    CGRect labelFrame = CGRectZero;
    labelFrame.size = CGSizeMake(scoreSize, scoreSize);

    NSArray* column = nil;
    for (NSInteger rIndex = rows - 1; rIndex >= 0; rIndex--) {
        column = paddedValues[rIndex];
        
        labelFrame.origin.y = (rIndex * scoreSizeWithSpacing) + titleWithSpacing;
        
        NSInteger cIndex = 0;
        for (id point in column) {
            labelFrame.origin.x = cIndex * scoreSizeWithSpacing;
            
            HEMTrendsScoreLabel* scoreLabel = [self scoreLabelForDataPoint:point
                                                                 withFrame:labelFrame];
            if ([point isKindOfClass:[HEMTrendsDisplayPoint class]]) {
                HEMTrendsDisplayPoint* trendsDisplayPoint = point;
                [scoreLabel setTextAlignment:NSTextAlignmentCenter];
                [scoreLabel setTextColor:[UIColor whiteColor]];
                [scoreLabel setFont:[UIFont h7Bold]];
                NSInteger score = [[trendsDisplayPoint value] integerValue];
                if (score >= 0) {
                    [scoreLabel setText:[NSString stringWithFormat:@"%ld", (long)score]];
                } else {
                    [scoreLabel setText:NSLocalizedString(@"empty-data", nil)];
                }
            }
            [self addSubview:scoreLabel];
            labelFrame.origin.x -= scoreSizeWithSpacing;
            cIndex++;
        }
    }
    
    [self animateIn];
}

- (void)showMonthInQuarterWithValues:(NSArray<HEMTrendsDisplayPoint*>*)values
                              titles:(NSAttributedString*)localizedMonthText
                            forMonth:(NSDate*)month {
    [self removeAllDayLabels];
    
    NSArray<NSAttributedString*>* titles = nil;
    if (localizedMonthText) {
        titles = @[localizedMonthText];
    }
    [self updateTitles:titles withSpacing:HEMTrendsCalMonthDaySpacingForQuarter width:MAXFLOAT];

    NSCalendar* calendar = [[self class] calendar];
    
    CGFloat fullWidth = CGRectGetWidth([self bounds]);
    CGFloat titleWithSpacing = HEMTrendsCalMonthTitleHeight + HEMTrendsCalMonthTitleBotMargin;
    CGFloat scoreSize = [[self class] sizeForEachDayWithWidth:fullWidth
                                                      spacing:HEMTrendsCalMonthDaySpacingForQuarter];
    CGFloat scoreSizeWithSpacing = scoreSize + HEMTrendsCalMonthDaySpacingForQuarter;
    
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit:NSCalendarUnitMonth
                                  forDate:month];
    NSUInteger daysInMonth = range.length;
    
    NSCalendarUnit units = NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents* monthComponents = [calendar components:units fromDate:month];
    
    NSDate* firstDayOfMonth = [calendar dateFromComponents:monthComponents];
    NSInteger weekday = [calendar component:NSCalendarUnitWeekday
                                   fromDate:firstDayOfMonth];

    CGRect labelFrame = CGRectZero;
    labelFrame.size = CGSizeMake(scoreSize, scoreSize);
    labelFrame.origin.x = (weekday - 1) * scoreSizeWithSpacing;
    labelFrame.origin.y = titleWithSpacing;
    
    BOOL isCurrentMonth = [month isCurrentMonth];
    NSInteger dayToStartCounting = isCurrentMonth ? 1 : (daysInMonth - [values count] + 1);
    NSInteger valueIndex = 0;
    HEMTrendsDisplayPoint* point = nil;
    
    for (NSInteger day = 1; day <= daysInMonth; day++) {
        point = nil;
        if (day >= dayToStartCounting && valueIndex < [values count]) {
            point = values[valueIndex++];
        }
        
        [self addSubview:[self scoreLabelForDataPoint:point withFrame:labelFrame]];
        
        weekday++;
        
        if (weekday == HEMTrendsCalMonthDaysInWeek + 1) {
            weekday = 1;
            labelFrame.origin.y += scoreSizeWithSpacing;
            labelFrame.origin.x = (weekday - 1) * scoreSizeWithSpacing;
        } else {
            labelFrame.origin.x += scoreSizeWithSpacing;
        }
    }
    
    [self animateIn];
}

- (void)animateIn {
    [UIView animateWithDuration:0.33f animations:^{
        for (HEMTrendsScoreLabel* label in [self scoreLabels]) {
            [label setAlpha:1.0f];
        }
        for (HEMTrendsScoreLabel* reuseLabel in [self reuseLabels]) {
            [reuseLabel setAlpha:0.0f];
        }
    } completion:^(BOOL finished) {
        [[self reuseLabels] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setReuseLabels:nil];
    }];
}

- (HEMTrendsScoreLabel*)scoreLabelForDataPoint:(HEMTrendsDisplayPoint*)dataPoint
                                     withFrame:(CGRect)frame {

    HEMTrendsScoreLabel* scoreLabel = [[self reuseLabels] lastObject];
    if (!scoreLabel) {
        scoreLabel = [HEMTrendsScoreLabel new];
        [scoreLabel setAlpha:0.0f];
    } else {
        [[self reuseLabels] removeLastObject];
    }
    [[self scoreLabels] addObject:scoreLabel];
    
    [scoreLabel setFrame:frame];
    
    if ([dataPoint isKindOfClass:[HEMTrendsDisplayPoint class]]) {
        UIColor* color = [SenseStyle colorWithCondition:[dataPoint condition] defaultColor:nil];
        [scoreLabel setScoreColor:color];
        [scoreLabel setScoreBorderColor:color];
        [scoreLabel setHighlighted:[dataPoint highlighted]];
    }
    
    return scoreLabel;
}

- (void)applyFillStyle {
    [super applyFillStyle];
    [[self scoreLabels] makeObjectsPerformSelector:@selector(applyStyle)];
}

@end
