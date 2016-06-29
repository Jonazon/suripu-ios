//
//  HEMInsightSummaryView.m
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMInsightCollectionViewCell.h"
#import "HEMURLImageView.h"
#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"
#import "HEMMarkdown.h"
#import "HEMStyle.h"

CGFloat const HEMInsightCellMessagePadding = 20.0f;

static CGFloat const HEMInsightCellBaseHeight = 235.0f;
static CGFloat const HEMInsightCellShareButtonHeight = 46.0f;

@interface HEMInsightCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonHeightConstraint;

@end

@implementation HEMInsightCollectionViewCell

+ (CGFloat)contentHeightWithMessage:(NSAttributedString*)message
                            inWidth:(CGFloat)contentWidth
                          shareable:(BOOL)shareable {
    CGFloat maxWidth = contentWidth - (HEMInsightCellMessagePadding * 2);
    CGFloat textHeight = [message sizeWithWidth:maxWidth].height;
    CGFloat totalHeight = textHeight + HEMInsightCellBaseHeight;
    if (!shareable) {
        totalHeight -= HEMInsightCellShareButtonHeight;
    }
    return totalHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self dateLabel] setTextColor:[UIColor lowImportanceTextColor]];
    [[self dateLabel] setFont:[UIFont h7]];
    [[self categoryLabel] setTextColor:[UIColor grey6]];
    [[self categoryLabel] setFont:[UIFont h7Bold]];
    [[self messageLabel] setTextColor:[UIColor detailTextColor]];
    [[self separator] setBackgroundColor:[UIColor separatorColor]];
    [[self imageContainer] setBackgroundColor:[UIColor backgroundColor]];
    [[[self shareButton] titleLabel] setFont:[UIFont button]];
    [[self shareButton] setTitleColor:[UIColor grey3]
                             forState:UIControlStateNormal];
    [[self shareButton] setTitleColor:[UIColor grey6]
                             forState:UIControlStateHighlighted];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self messageLabel] setAttributedText:nil];
    [[self messageLabel] setText:nil];
    [[self dateLabel] setAttributedText:nil];
    [[self dateLabel] setText:nil];
    [[self categoryLabel] setAttributedText:nil];
    [[self dateLabel] setText:nil];
}

- (void)enableShare:(BOOL)enable {
    [[self shareButton] setHidden:!enable];
    [[self separator] setHidden:!enable];
    
    CGFloat height = enable ? HEMInsightCellShareButtonHeight : 0.0f;
    [[self shareButtonHeightConstraint] setConstant:height];
    [self layoutIfNeeded];
}

@end
