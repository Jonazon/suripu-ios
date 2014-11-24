//
//  HEMScrollableView.m
//  Sense
//
//  Created by Jimmy Lu on 11/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMScrollableView.h"
#import "HEMOnboardingUtils.h"

typedef NS_ENUM(NSUInteger, HEMScrollableContentType) {
    HEMScrollableContentTypeEmpty = 0,
    HEMScrollableContentTypeTitle = 1,
    HEMScrollableContentTypeDesc = 2,
    HEMScrollableContentTypeImage = 3
};

static CGFloat const HEMScrollableTitleBotMargin = 27.0f;
static CGFloat const HEMScrollableDescBotMargin = 24.0f;
static CGFloat const HEMScrollableImageBotMargin = 18.0f;
static CGFloat const HEMScrollableTitleHeight = 34.0f;
static CGFloat const HEMScrollableBotPadding = 28.0f;

@interface HEMScrollableView()

@property (nonatomic, weak) UIScrollView* scrollView;
@property (nonatomic, assign) HEMScrollableContentType prevAddedContent;
@property (nonatomic, weak) UIView* lastContentView; // not the same as lastObject of scrollView subviews

@end

@implementation HEMScrollableView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setClipsToBounds:YES];
    [self addScrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self sizeLabelsToFitText];
    [self updateContentSize];
}

- (void)addScrollView {
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
    [scrollView setBackgroundColor:[self backgroundColor]];
    [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    
    [self addSubview:scrollView];
    [self setScrollView:scrollView];
}

- (CGFloat)nextY {
    CGFloat topMargin = 0.0f;
    switch ([self prevAddedContent]) {
        case HEMScrollableContentTypeTitle:
            topMargin = HEMScrollableTitleBotMargin;
            break;
        case HEMScrollableContentTypeDesc:
            topMargin = HEMScrollableDescBotMargin;
            break;
        case HEMScrollableContentTypeImage:
            topMargin = HEMScrollableImageBotMargin;
            break;
        default:
            break;
    }
    UIView* lastView = [[[self scrollView] subviews] lastObject];
    return CGRectGetMaxY([lastView frame]) + topMargin;
}

- (void)sizeLabelsToFitText {
    for (UIView* subview in [[self scrollView] subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            [label sizeToFit];
        }
    }
}

- (void)updateContentSize {
    CGSize contentSize = [[self scrollView] contentSize];
    contentSize.width = CGRectGetWidth([[self scrollView] bounds]);
    contentSize.height = CGRectGetMaxY([[self lastContentView] frame])+HEMScrollableBotPadding;
    [[self scrollView] setContentSize:contentSize];
}

- (void)addTitle:(NSString*)title {
    CGRect labelFrame = {
        0.0f,
        [self nextY],
        CGRectGetWidth([[self scrollView] bounds]),
        HEMScrollableTitleHeight
    };
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setTranslatesAutoresizingMaskIntoConstraints:YES];
    [label setBackgroundColor:[[self scrollView] backgroundColor]];
    [label setFont:[UIFont onboardingTitleFont]];
    [label setText:title];
    [label setNumberOfLines:2]; // max two lines
    [label setTextColor:[UIColor blackColor]];
    [[self scrollView] addSubview:label];
    
    [self updateContentSize];
    
    [self setPrevAddedContent:HEMScrollableContentTypeTitle];
    [self setLastContentView:label];
}

- (void)addImage:(UIImage*)image {
    CGRect imageFrame = {
        0.0f,
        [self nextY],
        CGRectGetWidth([[self scrollView] bounds]),
        image.size.height
    };
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [imageView setContentMode:UIViewContentModeCenter];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [imageView setImage:image];
    [imageView setBackgroundColor:[[self scrollView] backgroundColor]];
    
    [[self scrollView] addSubview:imageView];
    
    [self updateContentSize];
    
    [self setPrevAddedContent:HEMScrollableContentTypeImage];
    [self setLastContentView:imageView];
}

- (void)addDescription:(NSAttributedString*)attributedDes {
    UILabel* label = [[UILabel alloc] init];
    [label setAttributedText:attributedDes];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setTranslatesAutoresizingMaskIntoConstraints:YES];
    [label setBackgroundColor:[[self scrollView] backgroundColor]];
    [label setNumberOfLines:0];

    CGSize constraint = CGSizeZero;
    constraint.width = CGRectGetWidth([[self scrollView] bounds]);
    constraint.height = MAXFLOAT;
    
    CGSize textSize = [label sizeThatFits:constraint];
    CGRect labelFrame = {
        0.0f,
        [self nextY],
        CGRectGetWidth([[self scrollView] bounds]),
        textSize.height
    };
    
    [label setFrame:labelFrame];
    
    [[self scrollView] addSubview:label];
    
    [self updateContentSize];
    
    [self setPrevAddedContent:HEMScrollableContentTypeDesc];
    [self setLastContentView:label];
}

- (BOOL)scrollRequired {
    return [[self scrollView] contentSize].height > CGRectGetHeight([[self scrollView] bounds]);
}

@end
