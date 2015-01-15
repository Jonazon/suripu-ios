//
//  HEMSensorGraphCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>
#import <AttributedMarkdown/markdown_peg.h>
#import <SenseKit/SENSensor.h>
#import "HEMSensorGraphCollectionViewCell.h"
#import "HEMLineGraphDataSource.h"
#import "NSAttributedString+HEMUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "HEMMarkdown.h"

@interface HEMSensorGraphCollectionViewCell ()<BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) HEMLineGraphDataSource* graphDataSource;
@property (nonatomic) CGFloat maxGraphValue;
@property (nonatomic) CGFloat minGraphValue;
@end

@implementation HEMSensorGraphCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureGraphView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.graphView.dataSource = nil;
    self.graphDataSource = nil;
}

- (void)configureGraphView
{
    self.graphView.userInteractionEnabled = NO;
    self.graphView.enableBezierCurve = NO;
    self.graphView.enableReferenceXAxisLines = NO;
    self.graphView.enableReferenceYAxisLines = NO;
    self.graphView.enableXAxisLabel = NO;
    self.graphView.enableYAxisLabel = NO;
    self.graphView.animationGraphStyle = BEMLineAnimationNone;
    self.graphView.animationGraphEntranceTime = 0;
    self.graphView.sizePoint = 1.f;
    self.graphView.colorTop = [UIColor whiteColor];
    self.graphView.colorBottom = [UIColor whiteColor];
    self.graphView.delegate = self;
}

- (void)setMessageText:(NSString *)markupMessageText
{
    NSAttributedString* text = markdown_to_attr_string(markupMessageText, 0, [HEMMarkdown attributesForBackViewText]);
    self.sensorMessageLabel.attributedText = [text trim];
}

- (void)setGraphData:(NSArray *)graphData sensor:(SENSensor *)sensor
{
    [self setGraphValueBoundsWithData:graphData forSensor:sensor];
    [UIView animateWithDuration:0.15 animations:^{
        self.graphView.alpha = 0;
    }];
    if (!graphData) {
        self.graphDataSource = nil;
        self.graphView.dataSource = nil;
        [self.graphView reloadGraph];
        return;
    }
    self.graphDataSource = [[HEMLineGraphDataSource alloc] initWithDataSeries:graphData unit:sensor.unit];
    self.graphView.dataSource = self.graphDataSource;
    UIColor* conditionColor = [UIColor colorForSensorWithCondition:sensor.condition];
    self.graphView.colorLine = conditionColor;
    self.graphView.gradientBottom = [self gradientForColor:conditionColor];
    [self.graphView reloadGraph];
}

- (void)setGraphValueBoundsWithData:(NSArray*)dataSeries forSensor:(SENSensor*)sensor {
    NSArray* values = [[dataSeries valueForKey:NSStringFromSelector(@selector(value))]
                       sortedArrayUsingSelector:@selector(compare:)];
    NSNumber* maxValue = [values lastObject];
    NSNumber* minValue = @1;
    if ([maxValue floatValue] == 0)
        self.maxGraphValue = 0;
    else
        self.maxGraphValue = [[SENSensor value:maxValue inPreferredUnit:sensor.unit] floatValue];
    for (NSNumber* value in values) {
        CGFloat number = [value floatValue];
        if (number  > 0) {
            minValue = value;
            break;
        }
    }
    self.minGraphValue = [[SENSensor value:minValue inPreferredUnit:sensor.unit] floatValue];
}

- (CGGradientRef)gradientForColor:(UIColor*)color
{
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        red, green, blue, 0.35,
        red, green, blue, 0.15
    };
    return CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
}

#pragma mark - BEMSimpleLineGraphDelegate

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.maxGraphValue;
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.minGraphValue;
}

- (BOOL)noDataLabelEnableForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return NO;
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph
{
    [UIView animateWithDuration:0.25 animations:^{
        graph.alpha = 1;
    }];
}

@end