//
//  HEMBarChartView.h
//  Sense
//
//  Created by Jimmy Lu on 2/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMTrendsDisplayPoint;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMBarChartAnimCompletion)(NSInteger minIndex, NSInteger maxIndex);

@interface HEMBarChartView : UIView

@property (nonatomic, assign) CGFloat barSpacing;
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;

- (void)updateBarChartWith:(NSArray<HEMTrendsDisplayPoint*>*)values
                completion:(HEMBarChartAnimCompletion)completion;
- (CGRect)frameOfBarAtIndex:(NSInteger)index relativeTo:(UIView*)view;

@end

@interface HEMBar : UIView

@property (nonatomic, strong) UIColor* barColor;

@end

NS_ASSUME_NONNULL_END
