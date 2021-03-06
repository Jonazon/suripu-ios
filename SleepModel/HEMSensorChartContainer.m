//
//  HEMSensorChartContainer
//  Sense
//
//  Created by Jimmy Lu on 9/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMSensorChartContainer.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const kHEMSensorChartWidth = 1.0f;
static CGFloat const kHEMSensorChartScrubStartDelay = 0.15f;
static CGFloat const kHEMSensorChartScrubberFadeDuration = 0.5f;
static CGFloat const kHEMSensorChartScrubberCircleSize = 8.0f;
static CGFloat const kHEMSensorChartScrubberInnerCircleSize = 4.0f;

@interface HEMSensorChartContainer() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* scrubber;
@property (nonatomic, strong) UIView* scrubberCircle;
@property (nonatomic, weak) ChartViewBase* chartView;
@property (nonatomic, weak) UILongPressGestureRecognizer* scrubberGesture;
@property (nonatomic, weak) IBOutlet HEMActivityIndicatorView* activityView;

@end

@implementation HEMSensorChartContainer

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self noDataLabel] setUserInteractionEnabled:NO];
    [[self noDataLabel] setHidden:YES];
    
    [[self activityView] setHidden:YES];
    [[self activityView] stop];
    
    UILongPressGestureRecognizer* gesture = [UILongPressGestureRecognizer new];
    [gesture addTarget:self action:@selector(startScrubbing:)];
    [gesture setMinimumPressDuration:kHEMSensorChartScrubStartDelay];
    [gesture setDelegate:self];
    [self addGestureRecognizer:gesture];
    [self setScrubberGesture:gesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self activityView]) {
        [[self activityView] setCenter:[self center]];
    }
}

- (UIView*)scrubberCircle {
    if (!_scrubberCircle) {
        CGRect circleFrame = CGRectZero;
        circleFrame.size.height = kHEMSensorChartScrubberCircleSize;
        circleFrame.size.width = kHEMSensorChartScrubberCircleSize;
        
        CGFloat outerRingBorder = kHEMSensorChartScrubberCircleSize - kHEMSensorChartScrubberInnerCircleSize;
        CGRect innerFrame = CGRectZero;
        innerFrame.size.height = kHEMSensorChartScrubberInnerCircleSize;
        innerFrame.size.width = kHEMSensorChartScrubberInnerCircleSize;
        innerFrame.origin.x = outerRingBorder / 2;
        innerFrame.origin.y = outerRingBorder / 2;
        
        UIView* innerCircle = [[UIView alloc] initWithFrame:innerFrame];
        [innerCircle setBackgroundColor:[UIColor grey3]];
        [[innerCircle layer] setCornerRadius:kHEMSensorChartScrubberInnerCircleSize/2];
        
        _scrubberCircle = [[UIView alloc] initWithFrame:circleFrame];
        [[_scrubberCircle layer] setCornerRadius:kHEMSensorChartScrubberCircleSize/2];
        [_scrubberCircle setBackgroundColor:[UIColor whiteColor]];
        [_scrubberCircle addSubview:innerCircle];
    }
    return _scrubberCircle;
}

- (void)setScrubberEnable:(BOOL)scrubberEnable {
    _scrubberEnable = scrubberEnable;
    [[self scrubberGesture] setEnabled:scrubberEnable];
}

- (void)showLoadingActivity:(BOOL)loading {
    if (loading && ![self activityView]) {
        UIImage* loaderImage = [UIImage imageNamed:@"sensorLoaderGray"];
        CGRect loaderFrame = CGRectZero;
        loaderFrame.size = loaderImage.size;
        HEMActivityIndicatorView* indicatorView
            = [[HEMActivityIndicatorView alloc] initWithImage:loaderImage
                                                     andFrame:loaderFrame];
        [self setActivityView:indicatorView];
        [self addSubview:indicatorView];
    }
    
    [[self activityView]  setHidden:!loading];
    if (loading) {
        [[self activityView] start];
    } else {
        [[self activityView] stop];
    }
}

- (UIView*)scrubber {
    if (!_scrubber) {
        CGRect scrubberFrame = CGRectZero;
        scrubberFrame.origin.y = CGRectGetMaxY([[self topLimitLine] bounds]);
        scrubberFrame.size.height = CGRectGetMinY([[self botLimitLine] bounds]);
        scrubberFrame.size.width = kHEMSensorChartWidth;
        _scrubber = [[UIView alloc] initWithFrame:scrubberFrame];
        [_scrubber setBackgroundColor:[UIColor grey3]];
        [_scrubber setAlpha:0.0f];
    }
    return _scrubber;
}

- (void)setScrubberColor:(UIColor*)color {
    [[self scrubber] setBackgroundColor:color];
    [[[[self scrubberCircle] subviews] lastObject] setBackgroundColor:color];
}

- (void)setChartView:(ChartViewBase*)chartView {
    if (!chartView) {
        if (_chartView) {
            [_chartView removeFromSuperview];
            _chartView = chartView;
        }
        [self setUserInteractionEnabled:NO];
        return;
    }
    
    BOOL hasChartData = ![chartView isEmpty];
    [[self topLimitLabel] setHidden:!hasChartData];
    [[self botLimitLabel] setHidden:!hasChartData];
   
    [self insertSubview:chartView atIndex:0];
    [self setUserInteractionEnabled:hasChartData];
    
    _chartView = chartView;
}

- (void)setDelegate:(id<HEMSensorChartScrubberDelegate>)delegate {
    _delegate = delegate;
    [[self scrubberGesture] setEnabled:delegate != nil];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture {
    CGPoint pointInView = [gesture locationInView:[gesture view]];
    LineChartView* lineView = (id)[self chartView];
    ChartDataEntry* entry = [lineView getEntryByTouchPointWithPoint:pointInView];
    return entry != nil;
}

- (void)startScrubbing:(UILongPressGestureRecognizer*)gesture {
    CGPoint pointInView = [gesture locationInView:[gesture view]];
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan: {
            [[self delegate] willBeginScrubbingIn:self];
            
            CGFloat minY = CGRectGetMaxY([[self topLimitLine] frame]);
            CGRect scrubberFrame = [[self scrubber] frame];
            scrubberFrame.origin.x = pointInView.x;
            scrubberFrame.origin.y = minY;
            scrubberFrame.size.height = CGRectGetMinY([[self botLimitLine] frame]) - minY;
            [[self scrubber] setFrame:scrubberFrame];
            [[self scrubber] setAlpha:1.0f];
            [[self scrubberCircle] setAlpha:0.0f];
            [self addSubview:[self scrubber]];
            [self addSubview:[self scrubberCircle]];
            [self moveScrubberToPoint:pointInView];
            [[self delegate] didMoveScrubberTo:pointInView within:self];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self moveScrubberToPoint:pointInView];
            [[self delegate] didMoveScrubberTo:pointInView within:self];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            [self fadeOutScrubber];
            [[self delegate] didEndScrubbingIn:self];
            break;
        default:
            break;
    }
}

- (void)moveScrubberToPoint:(CGPoint)pointOnChart {
    ChartDataEntry* entry = nil;
    
    if ([[self chartView] isKindOfClass:[LineChartView class]]) {
        LineChartView* lineView = (id)[self chartView];
        entry = [lineView getEntryByTouchPointWithPoint:pointOnChart];
        CGPoint chartPoint = [lineView pixelForValuesWithX:[entry x]
                                                         y:[entry y]
                                                      axis:AxisDependencyLeft];
        [[self scrubberCircle] setCenter:chartPoint];
        [[self scrubberCircle] setAlpha:1.0f];
    }
    
    CGRect scrubberFrame = [[self scrubber] frame];
    scrubberFrame.origin.x = pointOnChart.x;
    [[self scrubber] setFrame:scrubberFrame];
}

- (void)fadeOutScrubber {
    [UIView animateWithDuration:kHEMSensorChartScrubberFadeDuration
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self scrubber] setAlpha:0.0f];
                         [[self scrubberCircle] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [[self scrubber] removeFromSuperview];
                         [[self scrubberCircle] removeFromSuperview];
                     }];
}

@end
