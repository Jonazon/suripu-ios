//
// HEMPillDFUStoryboard.h
// Copyright (c) 2016 Hello Inc. All rights reserved.
// Generated by Ovaltine - http://github.com/kattrali/ovaltine

#import <Foundation/Foundation.h>

@interface HEMPillDFUStoryboard : NSObject

+(UIStoryboard *)storyboard;



/** Segue Identifiers */
+(NSString *)scanSegueIdentifier;

/** View Controllers */
+(id)instantiatePillDFUViewController;
+(id)instantiatePillDFUNavViewController;
+(id)instantiatePillFinderViewController;

@end
