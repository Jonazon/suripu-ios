//
//  HEMVoiceSettingsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMVoiceService;
@class HEMDeviceService;
@class HEMActivityIndicatorView;

@interface HEMVoiceSettingsPresenter : HEMPresenter

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService
                       deviceService:(HEMDeviceService*)deviceService;

- (void)bindWithTableView:(UITableView*)tableView;

- (void)bindWithNavigationItem:(UINavigationItem*)navItem;

- (void)bindWithActivityContainer:(UIView*)activityContainer;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicatorView;

@end
