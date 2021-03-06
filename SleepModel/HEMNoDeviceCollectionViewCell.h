//
//  HEMNoDeviceCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@class HEMActionButton;

@interface HEMNoDeviceCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *separator;

/**
 *  Set the title, message and styling for a missing sense device
 */
- (void)configureForSense;

/**
 *  Set the title, message and styling for a missing pill device
 */
- (void)configureForPill;

@end
