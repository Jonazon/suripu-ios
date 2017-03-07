//
//  HEMConfig.h
//  Sense
//
//  Created by Jimmy Lu on 2/23/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HEMConf) {
    HEMConfAPIURL,
    HEMConfClientId,
    HEMConfAnalyticsToken,
    HEMConfAllowDebugOptions,
    HEMConfZendeskToken,
    HEMConfZendeskURL,
    HEMConfZendeskClientId,
    HEMConfAppReviewURL,
    HEMConfPassResetURL,
    HEMConfEnvironmentName,
    HEMConfCrashReportToken,
    HEMConfPillFirmwareURL,
    HEMConfExtAppScheme
};

@interface HEMConfig : NSObject

+ (NSString*)stringForConfig:(HEMConf)config;
+ (BOOL)booleanForConfig:(HEMConf)config;

@end
