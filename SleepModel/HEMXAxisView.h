//
//  HEMXAxisView.h
//  Sense
//
//  Created by Jimmy Lu on 2/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMXAxisView : UIView

- (void)clear;

- (void)addLabelWithText:(NSAttributedString*)text
                     atX:(CGFloat)xOrigin
           maxLabelWidth:(CGFloat)maxLabelWidth;

@end
