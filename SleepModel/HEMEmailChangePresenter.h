//
//  HEMEmailChangePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/22/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMFormPresenter.h"

@class HEMAccountService;

NS_ASSUME_NONNULL_BEGIN

@interface HEMEmailChangePresenter : HEMFormPresenter

- (instancetype)initWithAccountService:(HEMAccountService*)accountService;

@end

NS_ASSUME_NONNULL_END