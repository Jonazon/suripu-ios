//
//  HEMGradient.h
//  Sense
//
//  Created by Jimmy Lu on 12/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMGradient : NSObject

@property (nonatomic, assign, readonly) CGGradientRef gradientRef;
@property (nonatomic, strong, readonly) NSArray* colors;

+ (HEMGradient*)gradientForTimelineSleepSegment;
+ (HEMGradient*)topGradientForTimePicker;
+ (HEMGradient*)bottomGradientForTimePicker;
+ (HEMGradient*)bottomVideoGradient;
+ (HEMGradient*)topVideoGradient;

- (instancetype)initWithColors:(NSArray*)colors
                     locations:(const CGFloat*)locations NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (NSArray*)colorRefs;

@end
           
NS_ASSUME_NONNULL_END
