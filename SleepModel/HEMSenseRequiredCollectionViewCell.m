//
//  HEMSenseRequiredCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/5/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSenseRequiredCollectionViewCell.h"
#import "UIFont+HEMStyle.h"
#import "HEMScreenUtils.h"

@interface HEMSenseRequiredCollectionViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingDescriptionConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingDescriptionConstraint;

@end

@implementation HEMSenseRequiredCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self descriptionLabel] setFont:[UIFont emptyStateDescriptionFont]];
    
    if (HEMIsIPhone4Family() || HEMIsIPhone5Family()) {
        CGFloat const MARGIN = 20.0f;
        [[self trailingDescriptionConstraint] setConstant:MARGIN];
        [[self leadingDescriptionConstraint] setConstant:MARGIN];
    }
}

@end
