//
//  HEMNavigationShadowView.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMNavigationShadowView.h"

static CGFloat const HEMNavigationShadowViewBorderHeight = 1.0f;
static NSString* const kHEMNavigationShadowImageKey = @"sense.shadow.image";

@interface HEMNavigationShadowView()

@property (nonatomic, weak) UIImageView* shadowImageView;
@property (nonatomic, strong) UIView* separatorView;

@end

@implementation HEMNavigationShadowView

- (instancetype)initWithNavigationBar:(UIView*)navBar {
    UIImage* image = [SenseStyle imageWithAClass:[self class]
                                    propertyName:kHEMNavigationShadowImageKey];
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
    UIImage* image = [SenseStyle imageWithAClass:[self class]
                                    propertyName:kHEMNavigationShadowImageKey];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIImageView* shadowView = [[UIImageView alloc] initWithImage:image];
    [shadowView setContentMode:UIViewContentModeScaleAspectFill];
    [shadowView setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleTopMargin];
    [shadowView setFrame:[self bounds]];
    [shadowView setAlpha:0.0f];
    
    CGFloat topMargin = [SenseStyle floatWithGroup:GroupMargins property:ThemePropertyMarginTop];
    [self addSubview:shadowView];
    [self setTopOffset:topMargin];
    [self setShadowImageView:shadowView];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (void)addSeparator {
    CGRect separatorFrame = CGRectZero;
    separatorFrame.origin.y = 0.0f;
    separatorFrame.size.width = CGRectGetWidth([self bounds]);
    separatorFrame.size.height = HEMNavigationShadowViewBorderHeight;
    
    UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
    [separator setAutoresizingMask:UIViewAutoresizingFlexibleWidth
     | UIViewAutoresizingFlexibleTopMargin];
    [separator applySeparatorStyle];
    
    [self addSubview:separator];
    [self setSeparatorView:separator];
}

- (void)showSeparator:(BOOL)show {
    if (show && ![self separatorView]) {
        [self addSeparator];
    }
    [[self separatorView] setAlpha:show ? 1.0f : 0.0f];
}

- (void)reset {
    [[self shadowImageView] setAlpha:0.0f];
    [[self superview] bringSubviewToFront:self];
}

- (void)updateVisibilityWithContentOffset:(CGFloat)contentOffset {
    CGFloat diff = MAX(0.0f, contentOffset - [self topOffset]);
    CGFloat alpha = MAX(0.0f, MIN(1.0f, diff / 10.0f));
    [[self shadowImageView] setAlpha:alpha];
    [[self superview] bringSubviewToFront:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat myWidth = CGRectGetWidth([self bounds]);
    CGRect shadowFrame = [[self shadowImageView] frame];
    shadowFrame.size.width = myWidth;
    shadowFrame.origin.x = 0.0f;
    [[self shadowImageView] setFrame:shadowFrame];
    
    CGRect separatorFrame = [[self separatorView] frame];
    separatorFrame.size.width = myWidth;
    separatorFrame.origin.x = 0.0f;
    [[self separatorView] setFrame:separatorFrame];
}

- (void)applyStyle {
    UIImage* image = [SenseStyle imageWithAClass:[self class] propertyName:kHEMNavigationShadowImageKey];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[self shadowImageView] setImage:image];
}

@end
