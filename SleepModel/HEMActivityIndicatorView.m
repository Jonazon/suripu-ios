//
//  HEMActivityIndicatorView.m
//  Sense
//
//  Created by Jimmy Lu on 11/26/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMActivityIndicatorView.h"
#import "UIColor+HEMStyle.h"
#import "HEMMathUtil.h"

static NSString* const HEMActivityIndicatorRotateKey = @"rotate";
static CGFloat const HEMActivityIndicatorAnimDuration = 1.0f;

@interface HEMActivityIndicatorView()

@property (nonatomic, strong) CALayer* indicatorLayer;
@property (nonatomic, strong) UIImage* indicatorImage;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;

@end

@implementation HEMActivityIndicatorView

- (instancetype)initWithImage:(UIImage*)image andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _indicatorImage = image;
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithImage:[UIImage imageNamed:@"loading"] andFrame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _indicatorImage = [UIImage imageNamed:@"loading"];
        [self setup];
    }
    return self;
}

- (void)setup {
    if ([self indicatorLayer]) {
        [[self indicatorLayer] removeFromSuperlayer];
    }
    
    [self setUserInteractionEnabled:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImageView* indicator = [[UIImageView alloc] initWithImage:[self indicatorImage]];
    [indicator setContentMode:UIViewContentModeScaleAspectFill];
    [indicator setBackgroundColor:[UIColor clearColor]];
    [indicator setFrame:[self bounds]];
    [indicator setTintColor:[self tintColor]];

    CALayer* layer = [indicator layer];
    [self setIndicatorLayer:layer];
    [[self layer] addSublayer:layer];
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    if (![_indicatorImage isEqual:indicatorImage]) {
        _indicatorImage = indicatorImage;
        [self setup];
    }
}

- (void)start {
    [[self layer] addSublayer:[self indicatorLayer]];
    
    if ([[self indicatorLayer] animationForKey:HEMActivityIndicatorRotateKey] == nil) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = @(HEMDegreesToRadians(360.0f));
        animation.duration = HEMActivityIndicatorAnimDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [[self indicatorLayer] addAnimation:animation forKey:HEMActivityIndicatorRotateKey];
        [self setAnimating:YES];
    }
}

- (void)stop {
    [[self indicatorLayer] removeAnimationForKey:HEMActivityIndicatorRotateKey];
    [[self indicatorLayer] removeFromSuperlayer];
    [self setAnimating:NO];
}


@end
