//
//  HEMVoiceService.m
//  Sense
//
//  Created by Jimmy Lu on 7/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import <SenseKit/SENAPISpeech.h>
#import <SenseKit/SENSpeechResult.h>
#import <SenseKit/SENService+Protected.h>
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENSenseVoiceSettings.h>
#import <SenseKit/SENVoiceCommandGroup.h>

#import "HEMVoiceService.h"

NSString* const HEMVoiceNotificationSettingsUpdated = @"HEMVoiceNotificationSettingsUpdated";
NSString* const HEMVoiceNotificationInfoSettings = @"voice.settings";
NSString* const HEMVoiceNotification = @"HEMVoiceNotificationResult";
NSString* const HEMVoiceNotificationInfoError = @"voice.error";
NSString* const HEMVoiceNotificationInfoResult = @"voice.result";
NSInteger const HEMVoiceServiceMaxVolumeLevel = 11;

static CGFloat const HEMVoiceServiceUpdateVolumeTolerance = 2;
static CGFloat const HEMVoiceServiceWaitDelay = 1.0f;
static NSInteger const HEMVoiceServiceMaxCheckAttempts = 15;
static NSString* const HEMVoiceServiceHideIntroKey = @"HEMVoiceServiceIntroKey";

typedef void(^HEMVoiceCommandsHandler)(NSArray<SENSpeechResult*>* _Nullable results,
                                       NSError* _Nullable error);

@interface HEMVoiceService()

@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, assign, getter=isInProgress) BOOL inProgress;
@property (nonatomic, strong) NSDate* lastVoiceResultDate;
@property (nonatomic, strong) NSArray<SENVoiceCommandGroup*>* voiceCommands;

@end

@implementation HEMVoiceService

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastVoiceResultDate = [NSDate date];
    }
    return self;
}

#pragma mark - Speech responses

- (void)mostRecentVoiceCommands:(HEMVoiceCommandsHandler)completion {
    [SENAPISpeech getRecentVoiceCommands:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion(data, error);
    }];
}

- (void)startListeningForVoiceResult {
    if (![self isStarted]) {
        [self setStarted:YES];
        [self waitForVoiceCommandResult];
    }
}

- (void)waitForVoiceCommandResult {
    if ([self isInProgress]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self setInProgress:YES];
    [self mostRecentVoiceCommands:^(NSArray<SENSpeechResult *> * results, NSError * error) {
        __strong typeof(weakSelf) strongself = weakSelf;
        NSDictionary* info = nil;
        
        if (error) {
            info = @{HEMVoiceNotificationInfoError : error};
        } else if ([results count] > 0) {
            SENSpeechResult* result = [results lastObject];
            NSDate* resultDate = [result date];
            if (![self lastVoiceResultDate]
                || [[self lastVoiceResultDate] compare:resultDate] == NSOrderedAscending) {
                [self setLastVoiceResultDate:resultDate];
                info = @{HEMVoiceNotificationInfoResult : [results lastObject]};
            }
        }
        
        if (info) {
            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:HEMVoiceNotification
                                  object:strongself
                                userInfo:info];
        }
        
        int64_t delay = (int64_t)(HEMVoiceServiceWaitDelay * NSEC_PER_SEC);
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [strongself setInProgress:NO];
            if ([strongself isStarted]) {
                [strongself waitForVoiceCommandResult];
            }
        });
        
    }];
}

- (void)stopListeningForVoiceResult {
    [self setStarted:NO];
}

#pragma mark - Service overrides

- (void)serviceReceivedMemoryWarning {
    [super serviceReceivedMemoryWarning];
    [self setVoiceCommands:nil];
}

#pragma mark - Commands

- (void)availableVoiceCommands:(HEMVoiceAvailableCommandsHandler)completion {
    BOOL needsCallback = YES;
    if ([[self voiceCommands] count] > 0) {
        completion ([self voiceCommands]);
        needsCallback = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPISpeech getSupportedVoiceCommands:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [strongSelf setVoiceCommands:data];
        }
        if (needsCallback) {
            completion (data);
        }
    }];
}

- (BOOL)showVoiceIntro {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    return ![[localPrefs userPreferenceForKey:HEMVoiceServiceHideIntroKey] boolValue];
}

- (void)hideVoiceIntro {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setUserPreference:@YES forKey:HEMVoiceServiceHideIntroKey];
}

- (void)resetVoiceIntro {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setUserPreference:@NO forKey:HEMVoiceServiceHideIntroKey];
}

#pragma mark - Voice controls

- (void)updateVoiceSettings:(SENSenseVoiceSettings*)voiceSettings
                 forSenseId:(NSString*)senseId
                 completion:(HEVoiceSettingsUpdateHandler)completion {

    __weak typeof(self) weakSelf = self;
    [SENAPIDevice updateVoiceSettings:voiceSettings
                           forSenseId:senseId
                           completion:^(id data, NSError *error) {
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               if (error) {
                                   [SENAnalytics trackError:error];
                                   completion (nil);
                               } else {
                                   [strongSelf verifyUpdateFor:voiceSettings
                                                   withSenseId:senseId
                                                       attempt:1
                                                    completion:completion];
                               }
                           }];
}

- (BOOL)is:(SENSenseVoiceSettings*)settings updatedFrom:(SENSenseVoiceSettings*)response {
    NSNumber* updatedMute = [settings muted];
    NSNumber* updatedVolume = [settings volume];
    NSNumber* updatedPrimary = [settings primaryUser];
    return ((updatedMute && [settings isMuted] == [response isMuted]) || !updatedMute)
        && ((updatedVolume
             && [[settings volume] integerValue] >= [[response volume] integerValue] - HEMVoiceServiceUpdateVolumeTolerance
             && [[settings volume] integerValue] <= [[response volume] integerValue] + HEMVoiceServiceUpdateVolumeTolerance )
            || !updatedVolume)
        && ((updatedPrimary && [settings isPrimaryUser] == [response isPrimaryUser]) || !updatedPrimary);
}

- (void)verifyUpdateFor:(SENSenseVoiceSettings*)voiceSettings
            withSenseId:(NSString*)senseId
                attempt:(NSInteger)attempt
             completion:(HEVoiceSettingsUpdateHandler)completion {
    
    if (attempt <= HEMVoiceServiceMaxCheckAttempts) {
        __weak typeof(self) weakSelf = self;
        [self getVoiceSettingsForSenseId:senseId completion:^(id response, NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                completion (nil);
            } else {
                if ([strongSelf is:voiceSettings updatedFrom:response]) {
                    NSDictionary* info = nil;
                    if ([response isKindOfClass:[SENSenseVoiceSettings class]]) {
                        info = @{HEMVoiceNotificationInfoSettings : response};
                    }
                    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:HEMVoiceNotificationSettingsUpdated
                                          object:strongSelf
                                        userInfo:info];
                    
                    completion (response);
                } else if (attempt > HEMVoiceServiceMaxCheckAttempts) {
                    completion (nil);
                } else {
                    int64_t delay = (int64_t)(HEMVoiceServiceWaitDelay * NSEC_PER_SEC);
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay);
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf verifyUpdateFor:voiceSettings
                                        withSenseId:senseId
                                            attempt:attempt + 1
                                         completion:completion];
                    });
                }
            }
        }];
    } else {
        completion (nil);
    }
}

- (void)getVoiceSettingsForSenseId:(NSString*)senseId completion:(HEMVoiceSettingsHandler)completion {
    [SENAPIDevice getVoiceSettingsForSenseId:senseId completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (NSInteger)volumeLevelFrom:(SENSenseVoiceSettings*)voiceSettings {
    CGFloat volumePercentage = [[voiceSettings volume] integerValue] / 100.0f;
    return MAX(1, ceilCGFloat(HEMVoiceServiceMaxVolumeLevel * volumePercentage));
}

- (NSInteger)volumePercentageFromLevel:(NSInteger)volumeLevel {
    CGFloat levelFloat = HEMVoiceServiceMaxVolumeLevel;
    CGFloat percentageFraction = volumeLevel / levelFloat;
    return roundCGFloat(percentageFraction * 100);
}

- (BOOL)isFirmwareUpdateRequiredFromError:(NSError*)error {
    if (!error) {
        return NO;
    }
    
    NSDictionary* info = [error userInfo];
    id response = [info objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
    BOOL requireUpdate = NO;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* urlResponse = response;
        requireUpdate = [urlResponse statusCode] == 400 || [urlResponse statusCode] == 412;
    }
    return requireUpdate;
}

@end
