//
//  HEMFadingParallaxLayout.m
//  Sense
//
//  Created by Delisa Mason on 6/4/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMFadingParallaxLayout.h"
#import "HEMTimelineLayoutAttributes.h"

@implementation HEMFadingParallaxLayout

+ (Class)layoutAttributesClass {
    return [HEMTimelineLayoutAttributes class];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];
    for (HEMTimelineLayoutAttributes *attrs in layoutAttributesArray) {
        if (attrs.representedElementCategory == UICollectionElementCategoryCell) {
            [self updateAttributes:attrs];
        }
    }
    return layoutAttributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    HEMTimelineLayoutAttributes *attrs = (id)[super layoutAttributesForItemAtIndexPath:indexPath];
    [self updateAttributes:attrs];
    return attrs;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    CGRect rect = CGRectMake(proposedContentOffset.x, 0, CGRectGetWidth(self.collectionView.bounds),
                             CGRectGetHeight(self.collectionView.bounds));
    NSArray *array = [self layoutAttributesForElementsInRect:rect];
    for (HEMTimelineLayoutAttributes *attrs in array) {
        [self updateAttributes:attrs];
    }
    return proposedContentOffset;
}

- (void)updateAttributes:(HEMTimelineLayoutAttributes *)attrs {
    CGPoint offset = [self offsetFromCenterWithAttributes:attrs];
    attrs.ratioFromCenter = [self ratioFromCenterWithOffsetFromCenter:offset];
}

- (CGPoint)offsetFromCenterWithAttributes:(HEMTimelineLayoutAttributes *)attrs {
    CGFloat const layoutTopOffset = 15.f;
    CGRect bounds = self.collectionView.bounds;
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint cellPivot = attrs.frame.origin;
    cellPivot.y += layoutTopOffset;
    return CGPointMake(boundsCenter.x - cellPivot.x, boundsCenter.y - cellPivot.y);
}

- (CGFloat)ratioFromCenterWithOffsetFromCenter:(CGPoint)offsetFromCenter {
    CGRect bounds = self.collectionView.bounds;
    CGFloat halfHeight = CGRectGetHeight(bounds) / 2;
    CGFloat ratio = offsetFromCenter.y / halfHeight;
    return ratio;
}

@end
