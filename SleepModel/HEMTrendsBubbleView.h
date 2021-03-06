//
//  HEMTrendsBubbleView.h
//  Sense
//
//  Created by Jimmy Lu on 2/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICountingLabel;

@interface HEMTrendsBubbleView : UIView

@property (weak, nonatomic) IBOutlet UICountingLabel* valueLabel;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;
@property (strong, nonatomic) UIColor* bubbleColor;

@end
