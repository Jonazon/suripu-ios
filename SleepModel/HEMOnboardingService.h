//
//  HEMOnboardingService.h
//  Sense
//
//  Created by Jimmy Lu on 7/16/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "SENService.h"

extern NSString* const HEMOnboardingNotificationComplete;
extern NSString* const HEMOnboardingNotificationDidChangeSensePairing;
extern NSString* const HEMOnboardingNotificationUserInfoSenseManager;
extern NSString* const HEMOnboardingNotificationDidChangePillPairing;

typedef NS_ENUM(NSInteger, HEMOnboardingError) {
    HEMOnboardingErrorNoAccount = -1,
    HEMOnboardingErrorAccountCreationFailed = -2,
    HEMOnboardingErrorAuthenticationFailed = -3
};

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

@class SENSense;
@class SENAccount;
@class SENSenseManager;

@interface HEMOnboardingService : SENService

/**
 * @property pairedAccountsToSense
 *
 * @discussion
 * Set, after calling checkNumberOfPairedAccounts.  If it was set then, the method
 * is called again, it will override what was set before
 */
@property (nonatomic, copy, readonly) NSNumber* pairedAccountsToSense;
@property (nonatomic, copy, readonly) NSArray* nearbySensesFound;;
@property (nonatomic, strong, readonly) SENAccount* currentAccount;
@property (nonatomic, strong, readonly) SENSenseManager* currentSenseManager;

+ (instancetype)sharedService;

/**
 * Begin early caching of nearby Senses found, if any.  Will eventually stop if
 * not ask to stop if nothing was found
 */
- (void)preScanForSenses;
- (void)disconnectCurrentSense;
- (BOOL)foundNearyBySenses;
- (void)clearNearBySensesCache;
- (SENSense*)nearestSense;
- (void)replaceCurrentSenseManagerWith:(SENSenseManager*)manager;

/**
 * Stop the pre-scanning that may or may not have been started
 */
- (void)stopPreScanning;

/**
 *  Starts to poll sensor data until values are returned, at which point the
 *  polling will stop.  Clearing user data cache will also stop the polling.
 */
- (void)startPollingSensorData;

#pragma mark - Accounts

- (BOOL)isAuthorizedUser;
- (void)loadCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion;
- (void)refreshCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion;
- (void)updateCurrentAccount:(void(^)(NSError* error))completion;
- (void)createAccountWithName:(NSString*)name
                        email:(NSString*)email
                         pass:(NSString*)password
            onAccountCreation:(void(^)(SENAccount* account))accountCreatedBlock
                   completion:(void(^)(SENAccount* account, NSError* error))completion;
- (void)authenticateUser:(NSString*)email
                    pass:(NSString*)password
                   retry:(BOOL)retry
              completion:(void(^)(NSError* error))completion;
- (NSString*)localizedMessageFromAccountError:(NSError*)error;

/**
 * Check the number of paired accounts currently attached to the Sense that
 * has been set for the currently active sense manager, if any.  Upon completion,
 * the property pairedAccountsToSense will be set
 */
- (void)checkNumberOfPairedAccounts;

#pragma mark - WiFi

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
- (void)saveConfiguredSSID:(NSString*)ssid;

/**
 * @method lastConfiguredSSID
 *
 * @discussion
 * Retrieve the last known SSID saved, if any
 */
- (NSString*)lastConfiguredSSID;


#pragma mark - Checkpoints

/**
 * @return YES if onboarding has finished, NO otherwise
 */
- (BOOL)hasFinishedOnboarding;

/**
 * Save the onboarding checkpoint so that when user comes back, user can resume
 * from where user left off.
 *
 * @param checkpoint: the checkpoint from which the user has hit
 */
- (void)saveOnboardingCheckpoint:(HEMOnboardingCheckpoint)checkpoint;

/**
 * Determine the current checkpoint at which the user last left off in the onboarding
 * flow, based on when it was saved.
 *
 * @return last checkpoint saved
 */
- (HEMOnboardingCheckpoint)onboardingCheckpoint;

/**
 * Clear checkpoints by resetting it to the beginning
 */
- (void)resetOnboardingCheckpoint;

- (void)clear;

- (void)markOnboardingAsComplete;

/**
 * @method notifyOfSensePairingChange
 *
 * @discussion
 * Convenience method to post a notification about a Sense pairing change
 */
- (void)notifyOfSensePairingChange;

/**
 * @method notifyOfSensePairingChange
 *
 * @discussion
 * Convenience method to post a notification about a Sleep Pill pairing change
 */
- (void)notifyOfPillPairingChange;

- (void)notifyOfOnboardingCompletion;

@end
