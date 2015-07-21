//
//  HEMOnboardingService.m
//  Sense
//
//  Created by Jimmy Lu on 7/16/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <AFNetworking/AFURLResponseSerialization.h>

#import <SenseKit/BLE.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMOnboardingService.h"

// notifications
NSString* const HEMOnboardingNotificationDidChangeSensePairing = @"HEMOnboardingNotificationDidChangeSensePairing";
NSString* const HEMOnboardingNotificationUserInfoSenseManager = @"HEMOnboardingNotificationUserInfoSenseManager";
NSString* const HEMOnboardingNotificationDidChangePillPairing = @"HEMOnboardingNotificationDidChangePillPairing";
NSString* const HEMOnboardingNotificationComplete = @"HEMOnboardingNotificationComplete";

static NSString* const HEMOnboardingErrorDomain = @"is.hello.app.onboarding";

// polling of data
static NSUInteger const HEMOnboardingMaxSensorPollAttempts = 10;
static NSUInteger const HEMOnboardingSensorPollIntervals = 5.0f;
// pre-scanning for senses
static NSInteger const HEMOnboardingMaxSenseScanAttempts = 10;
// settings / preferences
static NSString* const HEMOnboardingSettingCheckpoint = @"sense.checkpoint";
static NSString* const HEMOnboardingSettingSSID = @"sense.ssid";

@interface HEMOnboardingService()

@property (nonatomic, assign, getter=isPollingSensorData) BOOL pollingSensorData;
@property (nonatomic, assign) NSUInteger sensorPollingAttempts;
@property (nonatomic, copy)   NSArray* nearbySensesFound;
@property (nonatomic, assign) NSInteger senseScanAttempts;
@property (nonatomic, copy)   NSNumber* pairedAccountsToSense;
@property (nonatomic, strong) SENAccount* currentAccount;
@property (nonatomic, strong) SENSenseManager* currentSenseManager;
@property (nonatomic, assign, getter=shouldStopPreScanningForSenses) BOOL stopPreScanningForSenses;

@end

@implementation HEMOnboardingService

+ (instancetype)sharedService {
    static HEMOnboardingService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

- (void)clear {
    [self stopPreScanning];
    [SENSenseManager stopScan]; // if one is still scanning for some reason
    [self setNearbySensesFound:nil];
    [self setPairedAccountsToSense:nil];
    [self setPollingSensorData:NO];
    [self setSensorPollingAttempts:0];
    [self setSenseScanAttempts:0];
    // leave the current sense manager in place
}

- (NSError*)errorWithCode:(HEMOnboardingError)code reason:(NSString*)reason {
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey : reason ?: @""};
    return [NSError errorWithDomain:HEMOnboardingErrorDomain
                               code:code
                           userInfo:userInfo];
}

#pragma mark - Sense

/**
 * @return the currently used sense manager.  Because onboarding views / controllers
 *         can be reused within settings, we need to make sure that we check to
 *         make sure we're using the actual sense manager that is instantiated
 */
- (SENSenseManager*)currentSenseManager {
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    SENSenseManager* manager = nil;
    if ([deviceService senseManager]) {
        manager = [deviceService senseManager];
    } else {
        manager = _currentSenseManager;
    }
    return manager;
}

- (void)replaceCurrentSenseManagerWith:(SENSenseManager*)manager {
    [self setCurrentSenseManager:manager];
}

- (void)stopPreScanning {
    [self setStopPreScanningForSenses:YES];
}

- (void)preScanForSenses {
    __weak typeof(self) weakSelf = self;
    [SENSenseManager whenBleStateAvailable:^(BOOL on) {
        if (on) {
            [weakSelf scanForSenses];
        } else {
            DDLogVerbose(@"pre-scanning for nearby senses skipped, ble not on");
        }
    }];
}

- (void)scanForSenses {
    if ([self shouldStopPreScanningForSenses]) {
        [self setStopPreScanningForSenses:NO];
        DDLogVerbose(@"pre-scanning stopped");
        return;
    }
    
    if ([self senseScanAttempts] >= HEMOnboardingMaxSenseScanAttempts) {
        DDLogVerbose(@"pre-scanning for senses stopped, max attempts reached");
        return;
    }
    
    if ([SENSenseManager isScanning]) {
        DDLogVerbose(@"pre-scanning skipped, already scanning");
        return;
    }
    
    [SENSenseManager stopScan]; // stop a scan if one is in progress;
    DDLogVerbose(@"pre-scanning for nearby senses");
    
    float retryInterval = 0.2f;
    __weak typeof(self) weakSelf = self;
    if (![SENSenseManager scanForSense:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"found senses %@", senses);
        if ([senses count] == 0) {
            [strongSelf performSelector:@selector(scanForSenses)
                             withObject:nil
                             afterDelay:retryInterval];
        } else {
            [strongSelf setNearbySensesFound:senses];
        }
    }]) {
        [self performSelector:@selector(preScanForSenses)
                   withObject:nil
                   afterDelay:retryInterval];
    }
}

- (SENSense*)nearestSense {
    return [[self nearbySensesFound] firstObject];
}

- (BOOL)foundNearbySenses {
    return [[self nearbySensesFound] count] > 0;
}

- (void)disconnectCurrentSense {
    [[self currentSenseManager] disconnectFromSense];
}

- (void)clearNearbySensesCache {
    [self setNearbySensesFound:nil];
}

#pragma mark - Pairing Mode for next user

- (void)enablePairingMode:(void(^)(NSError* error))completion {
    SENSenseManager* manager = [self currentSenseManager];
    if (!manager) {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorSenseNotInitialized
                                     reason:@"cannot enable pairing mode without a sense"]);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [manager enablePairingMode:YES success:^(id response) {
        [weakSelf disconnectCurrentSense];
        if (completion) {
            completion (nil);
        }
    } failure:completion];
}

#pragma mark - Room conditions / sensor data

- (void)forceSensorDataUploadFromSense:(void(^)(NSError* error))completion {
    SENSenseManager* manager = [self currentSenseManager];
    if (manager) {
        __weak typeof(self) weakSelf = self;
        [manager forceDataUpload:^(id response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!error && ![strongSelf hasFinishedOnboarding]) {
                [strongSelf startPollingSensorData];
            }
            if (completion) {
                completion (error);
            }
        }];
    } else {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorSenseNotInitialized
                                     reason:@"cannot force sensor data upload without a sense"]);
        }
    }
}

- (void)startPollingSensorData {
    if (![self isPollingSensorData]
        && [self sensorPollingAttempts] < HEMOnboardingMaxSensorPollAttempts) {
        
        [self setSensorPollingAttempts:[self sensorPollingAttempts]+1];
        [self setPollingSensorData:YES];
        
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(sensorsDidUpdate:)
                       name:SENSensorsUpdatedNotification
                     object:nil];
        
        DDLogVerbose(@"polling for sensor data during onboarding");
        [SENSensor refreshCachedSensors];
    } else {
        DDLogVerbose(@"polling stopped, attempts %ld", (long)[self sensorPollingAttempts]);
    }
}

- (void)sensorsDidUpdate:(NSNotification*)note {
    if ([self isPollingSensorData]) {
        [self setPollingSensorData:NO];
        NSArray* sensors = [SENSensor sensors];
        NSInteger sensorCount = [sensors count];
        DDLogVerbose(@"sensors returned %ld", (long)sensorCount);
        if (sensorCount == 0
            || [((SENSensor*)sensors[0]) condition] == SENConditionUnknown) {
            
            __weak typeof (self) weakSelf = self;
            int64_t delayInSec = (int64_t)(HEMOnboardingSensorPollIntervals * NSEC_PER_SEC);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSec);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [weakSelf startPollingSensorData];
            });
            
        }
    }
    // always remove observer on update since it will add observer upon next attempt
    // or simply stop polling
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:SENSensorsUpdatedNotification object:nil];
}

#pragma mark - Accounts

- (BOOL)isAuthorizedUser {
    return [SENAuthorizationService isAuthorized];
}

- (void)checkNumberOfPairedAccounts {
    NSString* deviceId = [[[self currentSenseManager] sense] deviceId];
    if ([deviceId length] > 0) {
        __weak typeof(self) weakSelf = self;
        [SENAPIDevice getNumberOfAccountsForPairedSense:deviceId completion:^(NSNumber* pairedAccounts, NSError *error) {
            DDLogVerbose(@"sense %@ has %ld account paired to it", deviceId, [pairedAccounts longValue]);
            [weakSelf setPairedAccountsToSense:pairedAccounts];
        }];
    }
}

- (void)loadCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion {
    if (![self currentAccount]) {
        [self refreshCurrentAccount:completion];
    } else {
        if (completion) {
            completion ([self currentAccount], nil);
        }
    }
}

- (void)refreshCurrentAccount:(void(^)(SENAccount* account, NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount getAccount:^(SENAccount* account, NSError *error) {
        [weakSelf setCurrentAccount:account];
        if (completion) {
            completion (account, error);
        }
    }];
}

- (void)updateCurrentAccount:(void(^)(NSError* error))completion {
    if ([self currentAccount]) {
        [SENAPIAccount updateAccount:[self currentAccount] completionBlock:^(id data, NSError *error) {
            if (completion) {
                completion (error);
            }
        }];
    }
}

- (void)createAccountWithName:(NSString*)name
                        email:(NSString*)email
                         pass:(NSString*)password
            onAccountCreation:(void(^)(SENAccount* account))accountCreatedBlock
                   completion:(void(^)(SENAccount* account, NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount createAccountWithName:name
                            emailAddress:email
                                password:password
                              completion:^(SENAccount* account, NSError* error) {
                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                  
                                  if (!error) {
                                      if (account) {
                                          [strongSelf setCurrentAccount:account];
                                          
                                          if (accountCreatedBlock) {
                                              accountCreatedBlock(account);
                                          }
                                          
                                          [strongSelf authenticateUser:email
                                                                  pass:password
                                                                 retry:YES
                                                            completion:^(NSError *error) {
                                                                if (completion) {
                                                                    completion (account, error);
                                                                }
                                                            }];
                                          return;
                                      }
                                  }
                                  
                                  if (completion) {
                                      NSString* localizedMessage = [self localizedMessageFromAccountError:error];
                                      completion (nil, [strongSelf errorWithCode:HEMOnboardingErrorAccountCreationFailed
                                                                          reason:localizedMessage]);
                                  }
                              }];
}

- (void)authenticateUser:(NSString*)email
                    pass:(NSString*)password
                   retry:(BOOL)retry
              completion:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:email password:password callback:^(NSError *signInError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError* error = nil;
        if (signInError) {
            if (retry) {
                DDLogVerbose(@"authentication failed, retrying once");
                [strongSelf authenticateUser:email pass:password retry:NO completion:completion];
                return;
            }
            
            error = [strongSelf errorWithCode:HEMOnboardingErrorAuthenticationFailed
                                       reason:[self localizedMessageFromAccountError:signInError]];
        }
        
        if (completion) {
            completion (error);
        }
    }];
}

- (NSString*)localizedMessageFromAccountError:(NSError*)error {
    NSString* alertMessage = nil;
    SENAPIAccountError errorType = [SENAPIAccount errorForAPIResponseError:error];
    
    if (errorType == SENAPIAccountErrorUnknown) {
        NSHTTPURLResponse* response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        alertMessage = [self httpErrorMessageForStatusCode:[response statusCode]];
    } else {
        alertMessage = [self accountErrorMessageForType:errorType];
    }
    
    return alertMessage;
}

- (NSString*)httpErrorMessageForStatusCode:(NSInteger)statusCode {
    NSString* message = nil;
    // note that we will not attempt to create a message for every error code
    // that exists, but rather only for those that are commonly encountered.
    // We should never return the localizedDescription here as that provides
    // the user a unfriendly message that only iOS developers can actually understand
    switch (statusCode) {
        case 401:
            message = NSLocalizedString(@"authorization.sign-in.failed.message", nil);
            break;
        case 409:
            message = NSLocalizedString(@"sign-up.error.conflict", nil);
            break;
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"network.error.not-connected", nil);
            break;
        case NSURLErrorNetworkConnectionLost:
            message = NSLocalizedString(@"network.error.connection-lost", nil);
            break;
        case NSURLErrorCannotConnectToHost:
            message = NSLocalizedString(@"network.error.cannot-connect-to-host", nil);
            break;
        case NSURLErrorTimedOut:
            message = NSLocalizedString(@"network.error.timed-out", nil);
            break;
        default:
            message = NSLocalizedString(@"sign-up.error.generic", nil);
            break;
    }
    return message;
}

- (NSString*)accountErrorMessageForType:(SENAPIAccountError)errorType {
    NSString* message = nil;
    switch (errorType) {
        case SENAPIAccountErrorPasswordTooShort:
            message = NSLocalizedString(@"sign-up.error.password-too-short", nil);
            break;
        case SENAPIAccountErrorPasswordInsecure:
            message = NSLocalizedString(@"sign-up.error.password-insecure", nil);
            break;
        case SENAPIAccountErrorNameTooShort:
            message = NSLocalizedString(@"sign-up.error.name-too-short", nil);
            break;
        case SENAPIAccountErrorNameTooLong:
            message = NSLocalizedString(@"sign-up.error.password-too-long", nil);
            break;
        case SENAPIAccountErrorEmailInvalid:
            message = NSLocalizedString(@"sign-up.error.email-invalid", nil);
            break;
        default:
            message = NSLocalizedString(@"sign-up.error.generic", nil);
            break;
    }
    return message;
}

#pragma mark - WiFi

- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
   securityType:(SENWifiEndpointSecurityType)type
     completion:(void(^)(NSError* error))completion {
    
    SENSenseManager* manager = [self currentSenseManager];
    if (!manager) {
        if (completion) {
            completion ([self errorWithCode:HEMOnboardingErrorSenseNotInitialized
                                     reason:@"unable to set wifi without a sense manager initialized"]);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [manager setWiFi:ssid password:password securityType:type success:^(id response) {
        [weakSelf saveConfiguredSSID:ssid];
        if (completion) {
            completion (nil);
        }
    } failure:completion];
    
}

- (void)saveConfiguredSSID:(NSString*)ssid {
    if ([ssid length] == 0) return;
    
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:ssid forKey:HEMOnboardingSettingSSID];
}

- (NSString*)lastConfiguredSSID {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [preferences userPreferenceForKey:HEMOnboardingSettingSSID];
}

#pragma mark - Checkpoints

- (BOOL)hasFinishedOnboarding {
    HEMOnboardingCheckpoint checkpoint = [self onboardingCheckpoint];
    return [self isAuthorizedUser]
        && (checkpoint == HEMOnboardingCheckpointStart // start and authorized = signed in
        || checkpoint == HEMOnboardingCheckpointPillDone);
}

- (void)saveOnboardingCheckpoint:(HEMOnboardingCheckpoint)checkpoint {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setPersistentPreference:@(checkpoint) forKey:HEMOnboardingSettingCheckpoint];
}

- (HEMOnboardingCheckpoint)onboardingCheckpoint {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [[preferences persistentPreferenceForKey:HEMOnboardingSettingCheckpoint] integerValue];
}

- (void)resetOnboardingCheckpoint {
    [self saveOnboardingCheckpoint:HEMOnboardingCheckpointStart];
}

- (void)markOnboardingAsComplete {
    // if you call this method, you want to leave onboarding so make sure it's set
    [self saveOnboardingCheckpoint:HEMOnboardingCheckpointPillDone];
    [self clear];
    [self disconnectCurrentSense];
    [self setCurrentSenseManager:nil];
}

#pragma mark - Notifications

- (void)notify:(NSString*)notificationName {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notificationName object:nil];
}

- (void)notifyOfSensePairingChange {
    NSString* name = HEMOnboardingNotificationDidChangeSensePairing;
    NSDictionary* userInfo = nil;
    SENSenseManager* manager = [self currentSenseManager];
    if (manager) {
        userInfo = @{HEMOnboardingNotificationUserInfoSenseManager : manager};
    }
    NSNotification* notification = [NSNotification notificationWithName:name
                                                                 object:nil
                                                               userInfo:userInfo];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center postNotification:notification];
}

- (void)notifyOfPillPairingChange {
    [self notify:HEMOnboardingNotificationDidChangePillPairing];
}

- (void)notifyOfOnboardingCompletion {
    [self notify:HEMOnboardingNotificationComplete];
}

@end