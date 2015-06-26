//
//  HEMEventBubbleView.m
//  Sense
//
//  Created by Delisa Mason on 5/21/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMEventBubbleView.h"
#import "HelloStyleKit.h"
#import "NSAttributedString+HEMUtils.h"

@interface HEMEventBubbleView ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@implementation HEMEventBubbleView

CGFloat const HEMEventBubbleTextWidthOffset = 121.f;
CGFloat const HEMEventBubbleWidthOffset = 50.f;
CGFloat const HEMEventBubbleTextHeightOffset = 26.f;
CGFloat const HEMEventBubbleMinimumHeight = 48.f;
CGFloat const HEMEventTimeLabelWidth = 40.f;

+ (CGSize)sizeWithAttributedText:(NSAttributedString *)text timeText:(NSAttributedString *)time {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenSize);
    CGFloat textWidth = screenWidth - HEMEventBubbleTextWidthOffset - [time sizeWithWidth:HEMEventTimeLabelWidth].width;
    CGSize textSize = [text sizeWithWidth:textWidth];
    CGFloat width = screenWidth - HEMEventBubbleWidthOffset;
    CGFloat height = MAX(textSize.height + HEMEventBubbleTextHeightOffset, HEMEventBubbleMinimumHeight);
    return CGSizeMake(width, height);
}

- (void)awakeFromNib {
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 1.5f;
    self.layer.shadowColor = [HelloStyleKit tintColor].CGColor;
    self.layer.shadowOpacity = 0.2f;
    self.layer.cornerRadius = 3.f;
    self.backgroundColor = [UIColor whiteColor];
}

- (CGSize)intrinsicContentSize {
    return [[self class] sizeWithAttributedText:self.textLabel.attributedText timeText:self.timeLabel.attributedText];
}

- (void)setMessageText:(NSAttributedString *)message timeText:(NSAttributedString *)time {
    self.textLabel.attributedText = message;
    self.timeLabel.attributedText = time;
    [self invalidateIntrinsicContentSize];
}

@end
