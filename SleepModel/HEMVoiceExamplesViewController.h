//
//  HEMVoiceExamplesViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBaseController.h"

@class HEMVoiceCommandGroup;
@class SENVoiceCommandGroup;

@interface HEMVoiceExamplesViewController : HEMBaseController

@property (nonatomic, strong) SENVoiceCommandGroup* commandGroup;

@end
