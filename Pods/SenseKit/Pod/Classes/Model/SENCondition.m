//
//  SENCondition.m
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import <Foundation/Foundation.h>
#import "SENCondition.h"

NSString* const SENConditionRawUnavailable = @"UNAVAILABLE";
NSString* const SENConditionRawIncomplete = @"INCOMPLETE";
NSString* const SENConditionRawIdeal = @"IDEAL";
NSString* const SENConditionRawWarning = @"WARNING";
NSString* const SENConditionRawAlert = @"ALERT";
NSString* const SENConditionRawCalibrating = @"CALIBRATING";

SENCondition SENConditionFromString(NSString *condition) {
    if ([condition isKindOfClass:[NSString class]]) {
        if ([condition isEqualToString:SENConditionRawIdeal])
            return SENConditionIdeal;
        else if ([condition isEqualToString:SENConditionRawAlert])
            return SENConditionAlert;
        else if ([condition isEqualToString:SENConditionRawWarning])
            return SENConditionWarning;
        else if ([condition isEqualToString:SENConditionRawIncomplete])
            return SENConditionIncomplete;
        else if ([condition isEqualToString:SENConditionRawCalibrating])
            return SENConditionCalibrating;
    }
    return SENConditionUnknown;
}