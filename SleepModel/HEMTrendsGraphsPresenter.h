//
//  HEMTrendsGraphsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMTrendsService;
@class HEMSubNavigationView;
@class HEMActivityIndicatorView;

NS_ASSUME_NONNULL_BEGIN

@interface HEMTrendsGraphsPresenter : HEMPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithSubNav:(HEMSubNavigationView*)subNav;
- (void)bindWithLoadingIndicator:(HEMActivityIndicatorView*)loadingIndicator;

@end

NS_ASSUME_NONNULL_END