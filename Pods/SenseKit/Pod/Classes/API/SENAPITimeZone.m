//
//  SENAPITimeZone.m
//  Pods
//
//  Created by Jimmy Lu on 10/29/14.
//
//

#import "SENAPITimeZone.h"

static NSString* const kSENAPITimeZoneErrorDomain = @"is.hello.api.timezone";
static NSString* const kSENAPITimeZoneResourceName = @"timezone";
static NSString* const kSENAPITimeZoneParamOffset = @"timezone_offset";
static NSString* const kSENAPITimeZoneParamId = @"timezone_id";

@implementation SENAPITimeZone

+ (void)setCurrentTimeZone:(SENAPIDataBlock)completion {
    [self setTimeZone:[NSTimeZone localTimeZone] completion:completion];
}

+ (void)setTimeZone:(NSTimeZone*)timeZone completion:(SENAPIDataBlock)completion {
    if (timeZone == nil) {
        if (completion) completion (nil, [NSError errorWithDomain:kSENAPITimeZoneErrorDomain
                                                        code:-1
                                                    userInfo:nil]);
        return;
    }
    
    NSNumber* timeZoneInMillis = @([timeZone secondsFromGMT] * 1000);
    NSString* timeZoneId = [timeZone name];
    
    [SENAPIClient POST:kSENAPITimeZoneResourceName
            parameters:@{kSENAPITimeZoneParamOffset : timeZoneInMillis,
                         kSENAPITimeZoneParamId : timeZoneId}
            completion:completion];
}

@end
