//
//  HEMGradient.m
//  Sense
//
//  Created by Jimmy Lu on 12/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMGradient.h"

@interface HEMGradient()

@property (nonatomic, assign) CGGradientRef gradientRef;

@end

@implementation HEMGradient

+ (HEMGradient*)gradientForTimelineSleepSegment {
    UIColor* color1 = [UIColor colorWithWhite:1.0f alpha:0.12f];
    UIColor* color2 = [UIColor colorWithWhite:1.0f alpha:0.0f];
    CGFloat locations[] = {0, 1};
    return [[HEMGradient alloc] initWithColors:@[color1, color2] locations:locations];
}

+ (HEMGradient*)topGradientForTimePicker {
    UIColor* color1 = [UIColor colorWithWhite:1.0f alpha:0.8f];
    UIColor* color2 = [UIColor colorWithWhite:1.0f alpha:0.05f];
    CGFloat locations[] = {0, 1};
    return [[HEMGradient alloc] initWithColors:@[color1, color2] locations:locations];
}

+ (HEMGradient*)bottomGradientForTimePicker {
    UIColor* color1 = [UIColor colorWithWhite:1.0f alpha:0.05f];
    UIColor* color2 = [UIColor colorWithWhite:1.0f alpha:0.8f];
    CGFloat locations[] = {0, 1};
    return [[HEMGradient alloc] initWithColors:@[color1, color2] locations:locations];
}

+ (HEMGradient*)topVideoGradient {
    UIColor* color1 = [UIColor whiteColor];
    UIColor* color2 = [UIColor colorWithWhite:1.0f alpha:0.05f];
    CGFloat locations[] = {0, 1};
    return [[HEMGradient alloc] initWithColors:@[color1, color2] locations:locations];
}

+ (HEMGradient*)bottomVideoGradient {
    UIColor* color1 = [UIColor colorWithWhite:1.0f alpha:0.05f];
    UIColor* color2 = [UIColor whiteColor];
    CGFloat locations[] = {0, 1};
    return [[HEMGradient alloc] initWithColors:@[color1, color2] locations:locations];
}

- (instancetype)initWithColors:(NSArray*)colors locations:(const CGFloat*)locations {
    self = [super init];
    if (self) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSMutableArray* cgColors = [NSMutableArray array];
        for (UIColor* color in colors) {
            [cgColors addObject: (id)color.CGColor];
        }
        
        _colors = colors;
        _gradientRef = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)cgColors, locations);
        CGColorSpaceRelease(colorSpace);
    }
    return self;
}

- (NSArray*)colorRefs {
    NSMutableArray* refs = [NSMutableArray arrayWithCapacity:[[self colors] count]];
    for (UIColor* color in [self colors]) {
        [refs addObject:(id)[color CGColor]];
    }
    return refs;
}

- (void)dealloc {
    if (_gradientRef) {
        CGGradientRelease(_gradientRef);
    }
}

@end
