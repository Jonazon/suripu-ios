//
//  HEMSleepSoundViewController.h
//  Sense
//
//  Created by Jimmy Lu on 3/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class SENSleepSounds;

@interface HEMSleepSoundViewController : HEMBaseController

@property (nonatomic, assign, getter=isCancellable) BOOL cancellable;
@property (nonatomic, strong) SENSleepSounds* sleepSounds;

@end