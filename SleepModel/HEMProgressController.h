//
//  HEMProgressController.h
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMProgressController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong, readonly) UIViewController* rootViewController;
@property (nonatomic, strong) UIColor* tintColor;

- (id)initWithRootViewController:(UIViewController*)controller
            backgroundImageNames:(NSArray*)imageNames;
- (void)pushViewController:(UIViewController*)controller
                  progress:(float)progress
                  animated:(BOOL)animated
                completion:(void(^)(void))completion;

@end
