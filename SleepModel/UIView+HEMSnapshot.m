//
//  UIView+HEMSnapshot.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIImage+HEMBlurTint.h"
#import "UIView+HEMSnapshot.h"

@implementation UIView (HEMSnapshot)

- (UIImage*)snapshot {
    UIGraphicsBeginImageContextWithOptions([self bounds].size, YES, 0);
    
    [self drawViewHierarchyInRect:[self bounds] afterScreenUpdates:NO];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

- (UIImage*)snapshotOfRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGRect enlargedRect = CGRectMake(-CGRectGetMinX(rect), -CGRectGetMinY(rect),
                                     CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self drawViewHierarchyInRect:enlargedRect afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)snapshotWithTint:(UIColor*)color {
    return [[self snapshot] imageWithTint:color];
}

- (UIImage*)blurredSnapshotWithTint:(UIColor*)color {
    return [[self snapshot] blurredImageWithTint:color];
}

@end
