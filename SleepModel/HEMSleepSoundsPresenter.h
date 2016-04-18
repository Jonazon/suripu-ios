//
//  HEMSleepSoundsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListPresenter.h"

@class HEMAudioService;

@interface HEMSleepSoundsPresenter : HEMListPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName NS_UNAVAILABLE;

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName
                 audioService:(HEMAudioService*)audioService NS_DESIGNATED_INITIALIZER;

@end
