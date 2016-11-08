//
//  HEMSensorGroupMemberView.h
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SenseKit/SENSensor.h>

@interface HEMSensorGroupMemberView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (assign, nonatomic) SENSensorType type;
@property (weak, nonatomic, readonly) UITapGestureRecognizer* tap;

+ (instancetype)defaultInstance;

@end
