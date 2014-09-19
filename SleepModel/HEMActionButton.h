
#import <UIKit/UIKit.h>

@interface HEMActionButton : UIButton

/**
 * Changes the button's shape to show an activity indicator
 * while disabling the button
 */
- (void)showActivity;

/**
 * Changes the button's shape to show an activity indicator
 * while disabling the button
 * @param constraint: the width constraint the button is using
 */
- (void)showActivityWithWidthConstraint:(NSLayoutConstraint*)constraint;

/**
 * If the button has been morphed and showing activity, this
 * will return it back to normal
 */
- (void)stopActivity;

/**
 * Determine if activity is currently showing for this button
 */
- (BOOL)isShowingActivity;

@end
