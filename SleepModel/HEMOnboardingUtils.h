//
//  HEMOnboardingUtils.h
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Checkpoints to be saved when progressing through the onboarding flow so that
 * user can resume from where user left off.  It is important that '...Start'
 * start at 0 as it is the default value returned when grabbing it from storage
 * if a checkpoint has not yet been saved
 */
typedef NS_ENUM(NSUInteger, HEMOnboardingCheckpoint) {
    HEMOnboardingCheckpointStart = 0,
    HEMOnboardingCheckpointAccountCreated = 1,
    HEMOnboardingCheckpointAccountDone = 2,
    HEMOnboardingCheckpointSenseDone = 3,
    HEMOnboardingCheckpointPillDone = 4
};

@interface HEMOnboardingUtils : NSObject

/**
 * @method
 * Apply common 'description' attributed string attributes to the existing string.
 * If the supplied attrText has already added attributes that this method applies,
 * it will remain as is and this method will not override them.
 *
 * @param attrText: the attributed text to apply common attributes to
 */
+ (void)applyCommonDescriptionAttributesTo:(NSMutableAttributedString*)attrText;

/**
 * @method
 * Convenience method to turn the text in to the properly bolded attributed text
 * by constructing an attributed string with the proper "bold" font attribute.  The
 * size of the font used is the same as the common description attributes
 *
 * @param text: the text to bold
 * @return bolded attributed text
 */
+ (NSAttributedString*)boldAttributedText:(NSString*)text;

/**
 * @method
 * Convenience method to turn the specified text in an attributed string with the
 * text 'bolded' with the color given
 *
 * @param text: the text to bold and color
 * @return bolded and colored attributed text
 */
+ (NSAttributedString*)boldAttributedText:(NSString *)text withColor:(UIColor*)color;

/**
 * Save the onboarding checkpoint so that when user comes back, user can resume
 * from where user left off.
 *
 * @param checkpoint: the checkpoint from which the user has hit
 */
+ (void)saveOnboardingCheckpoint:(HEMOnboardingCheckpoint)checkpoint;

/**
 * Determine the current checkpoint at which the user last left off in the onboarding
 * flow, based on when it was saved.
 *
 * @return last checkpoint saved
 */
+ (HEMOnboardingCheckpoint)onboardingCheckpoint;

/**
 * @param checkpoint: the onboarding checkpoint
 * @param authorized: YES if user is authorized, NO otherwise
 * @return the controller to show for the specified checkpoint
 */
+ (UIViewController*)onboardingControllerForCheckpoint:(HEMOnboardingCheckpoint)checkpoint authorized:(BOOL)authorized;

/**
 * Clear checkpoints by resetting it to the beginning
 */
+ (void)resetOnboardingCheckpoint;

/**
 * Show an alert for the error encountered during any http requests made while
 * in the onboarding flow, which will interpret any NSURLError codes as well
 * as HTTP Status Codes from the API that are relevant to us.
 *
 * @param error:      the error object encountered
 * @param errorTitle: the title of the alert when it's shown
 * @param controller: the controller that is presenting the alert
 */
+ (void)showAlertForHTTPError:(NSError*)error
                    withTitle:(NSString*)errorTitle
                         from:(UIViewController*)controller;

/**
 * Finish onboarding flow from the specified last controller in the flow and display
 * a message before it completes
 */
+ (void)finisOnboardinghWithMessageFrom:(UIViewController*)controller;

/**
 * Apply a shadow to the buton container on various onboarding screens to signal
 * to user that content exists behind it
 * @param buttonContainer: view that holds the buttons
 */
+ (void)applyShadowToButtonContainer:(UIView*)buttonContainer;

/**
 * @method saveConfiguredSSID:
 *
 * @discussion
 * TEMPORARY solution to handle cases of displaying the user's SSID.  This should
 * probably be stored and saved on the server as this is duplicated logic and can
 * be very error prone
 *
 * In the mean time, we will store the ssid and allow caller to retrieve it
 */
+ (void)saveConfiguredSSID:(NSString*)ssid;

/**
 * @method lastConfiguredSSID
 *
 * @discussion
 * Retrieve the last known SSID saved, if any
 */
+ (NSString*)lastConfiguredSSID;

/**
 * @method moreve the configured SSID, if 1 was saved
 */
+ (void)removeLastConfiguredSSID;

@end
