//
//  HEMWifiPickerViewController.h
//  Sense
//
//  Created by Jimmy Lu on 10/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMBaseController.h"
#import "HEMWiFiConfigurationDelegate.h"

@interface HEMWifiPickerViewController : HEMBaseController

@property (nonatomic, weak) id<HEMWiFiConfigurationDelegate> delegate;

@end
