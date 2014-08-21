//
//  HEMLocationCenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef enum {
    HEMLocationErrorCodeNotAuthorized = -10,
    HEMLocationErrorCodeNotEnabled = -11
} HEMLocationErrorCode;

typedef void(^HEMLocationSuccessBlock)(double lat, double lan, double accuracy);
typedef void(^HEMLocationFailureBlock)(NSError* error);

@interface HEMLocationCenter : NSObject <CLLocationManagerDelegate>

+ (id)sharedCenter;
- (NSString*)locate:(NSError**)locationError
            success:(HEMLocationSuccessBlock)success
            failure:(HEMLocationFailureBlock)failure;
- (void)stopLocatingFor:(NSString*)distinctId;

@end
