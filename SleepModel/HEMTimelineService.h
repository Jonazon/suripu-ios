//
//  HEMTimelineService.h
//  Sense
//
//  Created by Jimmy Lu on 1/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

@class SENAccount;

NS_ASSUME_NONNULL_BEGIN

@interface HEMTimelineService : SENService

- (BOOL)isFirstNightOfSleep:(NSDate*)date forAccount:(nullable SENAccount*)account;

@end

NS_ASSUME_NONNULL_END