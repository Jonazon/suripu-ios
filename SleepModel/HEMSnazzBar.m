//
//  HEMSnazzBar.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSnazzBar.h"
#import "HEMSnazzBarButton.h"
#import "HelloStyleKit.h"

CGFloat const HEMSnazzBarAnimationDuration = 0.25f;

@interface HEMSnazzBar ()

@property (nonatomic, strong) UIView* indicatorView;
@property (nonatomic, strong) UIView* bottomBorderView;
@property (nonatomic) NSUInteger selectionIndex;
@end

@implementation HEMSnazzBar

static CGFloat const HEMSnazzBarTopMargin = 20.f;
static CGFloat const HEMSnazzBarIndicatorHeight = 1.f;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.shadowOffset = CGSizeMake(0, 0.5);
        self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1f].CGColor;
        self.layer.shadowRadius = 0;
        self.layer.shadowOpacity = 0.85f;
        _bottomBorderView = [UIView new];
        _bottomBorderView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.f];
        [self addSubview:_bottomBorderView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutBarButtons];
    self.bottomBorderView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - HEMSnazzBarIndicatorHeight, CGRectGetWidth(self.bounds), HEMSnazzBarIndicatorHeight);
}

- (void)layoutBarButtons
{
    NSArray* buttons = [self buttons];
    if (buttons.count == 0)
        return;

    CGFloat width = ((CGRectGetWidth(self.bounds)) / buttons.count);
    CGSize buttonSize = CGSizeMake(width, CGRectGetHeight(self.bounds) - HEMSnazzBarTopMargin);
    for (int i = 0; i < buttons.count; i++) {
        UIButton* button = buttons[i];
        CGFloat x = i * buttonSize.width;
        button.frame = (CGRect){ .size = buttonSize, .origin = CGPointMake(x, HEMSnazzBarTopMargin)};
        if ([button isSelected])
            [self indicateButtonSelected:button];
    }
}

- (void)indicateButtonSelected:(UIButton*)button
{
    CGRect frame = CGRectMake(CGRectGetMinX(button.frame),
                              CGRectGetHeight(self.bounds) - HEMSnazzBarIndicatorHeight,
                              CGRectGetWidth(button.bounds),
                              HEMSnazzBarIndicatorHeight);
    if (self.indicatorView) {
        self.indicatorView.frame = frame;
    } else {
        self.indicatorView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.indicatorView];
    }
    self.indicatorView.backgroundColor = self.selectionColor;
}

- (void)setSelectionColor:(UIColor *)selectionColor
{
    self.indicatorView.backgroundColor = selectionColor;
    _selectionColor = selectionColor;
}

#pragma mark - Button management

- (NSArray*)buttons
{
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:self.subviews.count];
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[HEMSnazzBarButton class]])
            [buttons addObject:view];
    }
    return buttons;
}

- (void)buttonPressed:(UIButton*)button
{
    NSUInteger index = [self.buttons indexOfObjectIdenticalTo:button];
    if (index != NSNotFound)
        [self.delegate bar:self didReceiveTouchUpInsideAtIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    [self addButtonAtIndex:self.buttons.count withTitle:title image:image selectedImage:selectedImage];
}

- (void)addButtonAtIndex:(NSUInteger)index
               withTitle:(NSString *)title
                   image:(UIImage *)image
           selectedImage:(UIImage*)selectedImage
{
    HEMSnazzBarButton* button = [HEMSnazzBarButton buttonWithType:UIButtonTypeCustom];
    button.accessibilityLabel = title;
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self setNeedsLayout];
}

- (void)selectButtonAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSArray* buttons = [self buttons];
    if (index >= buttons.count)
        return;

    self.selectionIndex = index;
    for (int i = 0; i < buttons.count; i++) {
        UIButton* button = buttons[i];
        if ((button.selected = (i == index))) {
            void (^animations)() = ^{
                [self indicateButtonSelected:button];
                button.selected = YES;
            };
            if (animated)
                [UIView animateWithDuration:HEMSnazzBarAnimationDuration
                                      delay:0
                     usingSpringWithDamping:0.8
                      initialSpringVelocity:0
                                    options:(UIViewAnimationOptionCurveEaseInOut)
                                 animations:animations
                                 completion:NULL];
            else
                animations();
        } else {
            button.selected = NO;
        }
    }
}

- (void)removeAllButtons
{
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)removeButtonAtIndex:(NSUInteger)index
{
    NSArray* buttons = [self buttons];
    if (index >= buttons.count)
        return;

    UIButton* button = buttons[index];
    [button removeFromSuperview];
    [self setNeedsLayout];
}

@end
