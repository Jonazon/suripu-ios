//
//  LineChartView+HEMSensor.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "LineChartView+HEMSensor.h"

@implementation LineChartView (HEMSensor)

- (instancetype)initForSensorWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame]) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleHeight];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setDrawGridBackgroundEnabled:NO];
        [self setDrawBordersEnabled:NO];
        [self setNoDataText:nil];
        [[self leftAxis] setEnabled:NO];
        [[self leftAxis] removeAllLimitLines];
        [[self rightAxis] removeAllLimitLines];
        [[self rightAxis] setEnabled:NO];
        [[self xAxis] setEnabled:YES];
        [[self xAxis] setDrawAxisLineEnabled:NO];
        [[self xAxis] setDrawGridLinesEnabled:NO];
        [[self xAxis] removeAllLimitLines];
        [[self xAxis] setDrawLabelsEnabled:NO];
        [self setDescriptionText:nil];
        [[self legend] setEnabled:NO];
        [[self layer] setBorderWidth:0.0f];
        [self setPinchZoomEnabled:NO];
        [self setDoubleTapToZoomEnabled:NO];
        [self setDragEnabled:NO];
        [self setScaleEnabled:NO];
        [self setHighlightPerTapEnabled:NO];
        [self setHighlightPerDragEnabled:NO];
        [self setViewPortOffsetsWithLeft:0.0f top:0.0f right:0.0f bottom:0.0f];
    }
    return self;
}

- (void)animateIn {
    CGFloat const duration = 1.0f;
    
    [self setAlpha:0.0f];
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self setAlpha:1.0f];
                     } completion:nil];
    
    [self animateWithXAxisDuration:duration
                      easingOption:ChartEasingOptionEaseInSine];
}

- (void)fadeIn {
    CGFloat const duration = 1.0f;
    
    [self setAlpha:0.0f];
    [UIView animateWithDuration:duration animations:^{
        [self setAlpha:1.0f];
    }];
}

@end
