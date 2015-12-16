//
//  HEMNavigationShadowView.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMNavigationShadowView.h"

@implementation HEMNavigationShadowView

- (instancetype)initWithNavigationBar:(UIView*)navBar {
    UIImage* image = [UIImage imageNamed:@"topShadow"];
    CGFloat width = CGRectGetWidth([navBar bounds]);
    CGRect shadowFrame = CGRectZero;
    shadowFrame.size.width = width;
    shadowFrame.size.height = image.size.height;
    shadowFrame.origin.y = CGRectGetHeight([navBar bounds]);
    
    self = [super initWithFrame:shadowFrame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure {
    UIImage* image = [UIImage imageNamed:@"topShadow"];
    UIImageView* shadowView = [[UIImageView alloc] initWithImage:image];
    [shadowView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [shadowView setFrame:[self bounds]];
    [self addSubview:shadowView];
    [self setAlpha:0.0f];
}

- (void)updateVisibilityWithContentOffset:(CGFloat)contentOffset {
    CGFloat alpha = MAX(0.0f, MIN(1.0f, contentOffset / 10.0f));
    [self setAlpha:alpha];
    [[self superview] bringSubviewToFront:self];
}

@end