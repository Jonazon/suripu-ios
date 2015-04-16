//
//  HEMAnimationUtils.m
//  Sense
//
//  Created by Jimmy Lu on 9/29/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

static CGFloat const kHEMAnimationActivityLineWidth = 2.0f;
static CGFloat const kHEMAnimationActivityDuration = 3.0f;
static CGFloat const kHEMAnimationDefaultDuration = 0.2f;

#import "HEMAnimationUtils.h"

@implementation HEMAnimationUtils

+ (CALayer*)animateActivityAround:(UIView*)view {
    // show activity inside the view
    CGRect pathRect = [view bounds];
    pathRect.size.width -= kHEMAnimationActivityLineWidth;
    pathRect.size.height -= kHEMAnimationActivityLineWidth;
    pathRect.origin.x += (kHEMAnimationActivityLineWidth/2);
    pathRect.origin.y += (kHEMAnimationActivityLineWidth/2);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect
                                                    cornerRadius:[[view layer] cornerRadius]];
    
    CAShapeLayer* shapeLayer = [CAShapeLayer layer];
    [shapeLayer setPath:[path CGPath]];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[view layer] borderColor]];
    [shapeLayer setLineWidth:kHEMAnimationActivityLineWidth];
    [[view layer] addSublayer:shapeLayer];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setDuration:kHEMAnimationActivityDuration];
    [animation setRepeatCount:MAXFLOAT];
    [animation setFromValue:@(0.0f)];
    [animation setToValue:@(1.0f)];
    [shapeLayer addAnimation:animation forKey:@"borderAnimation"];
    
    return shapeLayer;
}

+ (void)transactAnimation:(void(^)(void))animation
               completion:(void(^)(void))completion
                   timing:(NSString*)timingFunctionName {
    
    CAMediaTimingFunction* function =
    [CAMediaTimingFunction functionWithName:timingFunctionName];
    
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:function];
    [CATransaction setCompletionBlock:^{
        if (completion) completion ();
    }];
    
    animation();
    
    [CATransaction commit];
    
}

+ (void)grow:(UIView*)view completion:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:kHEMAnimationDefaultDuration animations:^{
        [view setTransform:CGAffineTransformMakeScale(1.1f, 1.1f)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kHEMAnimationDefaultDuration/2 animations:^{
            [view setTransform:CGAffineTransformIdentity];
        } completion:completion];
    }];
}

+ (void)fade:(UIView*)view out:(void(^)(void))outBlock thenIn:(void(^)(void))inBlock {
    [UIView animateWithDuration:kHEMAnimationDefaultDuration animations:^{
        [view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if (outBlock) {
            outBlock();
        }
        [UIView animateWithDuration:kHEMAnimationActivityDuration animations:^{
            [view setAlpha:1.0f];
        } completion:^(BOOL finished) {
            if (inBlock) {
                inBlock();
            }
        }];
    }];
}

@end
