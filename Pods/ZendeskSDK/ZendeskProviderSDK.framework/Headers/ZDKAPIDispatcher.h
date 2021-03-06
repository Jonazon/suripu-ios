/*
 *
 *  ZDKAPIDispatcher.h
 *  ZendeskSDK
 *
 *  Created by Zendesk on 22/04/2014.  
 *
 *  Copyright (c) 2014 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Terms
 *  of Service https://www.zendesk.com/company/terms and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/application-developer-and-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import <Foundation/Foundation.h>
#import "ZDKDeviceInfo.h"
#import "ZDKAccount.h"
#import "ZDKDispatcher.h"
#import "ZDKDispatcherDelegate.h"
#import "ZDKRequest.h"
#import "ZDKComment.h"

/**
 * ZDKAPI is the primary access point for API requests.
 *
 *  @since 0.9.3.1
 */
@interface ZDKAPIDispatcher : ZDKDispatcher <ZDKDispatcherDelegate>

/**
 *  Returns the singleton instance of the dispatcher.
 *
 *  @since 0.9.3.1
 *
 *  @return the dispatcher.
 */
+ (instancetype) instance;


+ (NSMutableDictionary *) getSharedHeaders;

@end

