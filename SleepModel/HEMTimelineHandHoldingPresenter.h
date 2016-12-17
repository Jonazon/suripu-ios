//
//  HEMTimelineHandHoldingPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMHandHoldingService;
@class HEMTimelineHandHoldingPresenter;
@class HEMTimelineTopBarCollectionReusableView;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMTimelineHandHoldingDelegate <NSObject>

- (UIView*)timelineContainerViewForPresenter:(HEMTimelineHandHoldingPresenter*)presenter;

@end

@interface HEMTimelineHandHoldingPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMTimelineHandHoldingDelegate> delegate;

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)handHoldingService;
- (void)bindWithContentView:(UIView*)contentView;
- (void)showIfNeeded;
- (void)didZoomOutOnTimeline;

@end

NS_ASSUME_NONNULL_END
