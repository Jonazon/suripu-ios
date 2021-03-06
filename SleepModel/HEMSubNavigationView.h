//
//  HEMSubNavigationView.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMNavigationShadowView;

NS_ASSUME_NONNULL_BEGIN

@interface HEMSubNavigationView : UIView

@property (nonatomic, assign) NSInteger selectedControlTag;
@property (nonatomic, assign) NSInteger previousControlTag;
@property (nonatomic, weak, readonly) HEMNavigationShadowView* shadowView;

- (void)addControl:(UIControl*)control;
- (void)selectControlWithTag:(NSInteger)tag;
- (BOOL)hasControls;
- (void)reset;
- (void)applyStyle;

@end

NS_ASSUME_NONNULL_END
