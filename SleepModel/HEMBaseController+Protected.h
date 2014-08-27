//
//  HEMBaseController+Protected.h
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"

@interface HEMBaseController (Protected)

- (void)adjustConstraintsForIPhone4;
- (void)updateConstraint:(NSLayoutConstraint*)constraint withDiff:(CGFloat)diff;

@end