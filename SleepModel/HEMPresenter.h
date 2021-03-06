//
//  HEMPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class Theme;
@class HEMNavigationShadowView;
@class HEMPresenter;
@class HEMAlertViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMPresenterErrorDelegate <NSObject>

- (void)showErrorWithTitle:(nullable NSString*)title
                andMessage:(NSString*)message
              withHelpPage:(nullable NSString*)helpPage
             fromPresenter:(HEMPresenter*)presenter;

@optional
- (void)showCustomerAlert:(HEMAlertViewController*)alert
            fromPresenter:(HEMPresenter*)presenter;

@end

@protocol HEMPresenterActivityDelegate <NSObject>

- (UIView*)activityContainerFromPresenter:(HEMPresenter*)presenter;

@end

@protocol HEMPresenterPairDelegate <NSObject>

- (void)pairSenseFrom:(HEMPresenter*)presenter;

@end

@interface HEMPresenter : NSObject

@property (nonatomic, assign, getter=isVisible, readonly) BOOL visible;
@property (nonatomic, weak, readonly) HEMNavigationShadowView* shadowView;
@property (nonatomic, weak) id<HEMPresenterErrorDelegate> errorDelegate;
@property (nonatomic, weak) id<HEMPresenterActivityDelegate> activityDelegate;
@property (nonatomic, weak) id<HEMPresenterPairDelegate> pairDelegate;

/*
 * @discussion
 *
 * Throughout the app, we want to show a shadow on the top most part of the view
 * when the content in the main view is scrolled "underneath".  To avoid code
 * duplication, use this method to bind with the shadow view, and call 
 * didScrollContentIn:
 */
- (void)bindWithShadowView:(nullable HEMNavigationShadowView*)shadowView;

/*
 * @discussion
 *
 * If the presenter manages a scrollview, call this method on scrollViewDidScroll:
 * and pass the scroll view in to it to allow the base presenter to handle any
 * changes needed based on the content changes
 */
- (void)didScrollContentIn:(UIScrollView*)scrollView;

/*
 * @discussion
 *
 * View controllers should call this method upon viewWillAppear to give the
 * presenter a chance to refresh data or anything else
 */
- (void)willAppear;

/*
 * @discussion
 *
 * View controllers should call this method upon viewDidAppear to give the
 * presenter a chance to refresh data or anything else when the attached view
 * is now visible.
 */
- (void)didAppear;

/*
 * @discussion
 *
 * View controllers should call this method upon viewWillDisappear to give the
 * presenter a chance to handle the view of the view controller disappearing
 */
- (void)willDisappear;

/*
 * @discussion
 *
 * View controllers should call this method upon viewWillDisappear to give the
 * presenter a chance to handle anything needed while the view controller is
 * not visible
 */
- (void)didDisappear;

/*
 * @discussion
 *
 * View controllers should call this method upon viewWillLayoutSubviews to let
 * the presenter know how to process changes before layout is complete
 */
- (void)willRelayout;

/*
 * @discussion
 *
 * View controllers should call this method upon viewDidLayoutSubviews to let
 * the presenter know how to process changes in layout
 */
- (void)didRelayout;

/*
 * @discussion
 *
 * View controllers should call this method upon entering the background when
 * notified through UIApplicationDidEnterBackgroundNotification
 */
- (void)didEnterBackground;

/*
 * @discussion
 *
 * View controllers should call this method when the app becomes active again
 * after changing state of the application
 */
- (void)didComeBackFromBackground;

/**
 * @discussion
 *
 * View controllers should call this method when the controller moved to a parent
 */
- (void)didMoveToParent;

/**
 * @discussion
 *
 * View controllers should call this method when the controller is moved off of
 * the parent view controller
 */
- (void)wasRemovedFromParent;

/*
 * @discussion
 *
 * Subclasses should override this to automaticaly be notified when network
 * has gained connectivity
 */
- (void)didGainConnectivity;

/*
 * @discussion
 *
 * Subclasses should override this to automatically be notified when the user
 * signed out of the application
 */
- (void)userDidSignOut;

/*
 * @discussion
 *
 * Subclasses should override this to react to lower memory warnings if neccessary
 */
- (void)lowMemory;

/**
 * @param view: view to check the visibility on
 * @return YES if view is fully visible in the viewport of the window.  No otherwise
 */
- (BOOL)isViewFullyVisible:(UIView*)view;

/**
 * @discussion
 * Called when the theme has changed.  Subclasses should call super on this method
 *
 * @param theme: the current Theme to display / update with
 * @param automatically: YES if not from a direct action of user.  NO otherwise
 */
- (void)didChangeTheme:(Theme*)theme auto:(BOOL)automatically;

@end

NS_ASSUME_NONNULL_END
