//
//  HEMRoomConditionsPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMSensorService;
@class HEMIntroService;
@class HEMRoomConditionsPresenter;
@class HEMActivityIndicatorView;

@protocol HEMRoomConditionsDelegate <NSObject>

- (void)showController:(UIViewController*)controller
         fromPresenter:(HEMRoomConditionsPresenter*)presenter;

@end

@interface HEMRoomConditionsPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMRoomConditionsDelegate> delegate;

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                         introService:(HEMIntroService*)introService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator;

@end
