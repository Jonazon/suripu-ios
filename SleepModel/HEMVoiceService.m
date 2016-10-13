//
//  HEMVoiceService.m
//  Sense
//
//  Created by Jimmy Lu on 7/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPISpeech.h>
#import <SenseKit/SENSpeechResult.h>
#import <SenseKit/SENService+Protected.h>
#import <SenseKit/SENLocalPreferences.h>

#import "HEMVoiceService.h"
#import "HEMVoiceCommand.h"

NSString* const HEMVoiceNotification = @"HEMVoiceNotificationResult";
NSString* const HEMVoiceNotificationInfoError = @"voice.error";
NSString* const HEMVoiceNotificationInfoResult = @"voice.result";

static CGFloat const HEMVoiceServiceWaitDelay = 1.0f;
static NSString* const HEMVoiceServiceHideIntroKey = @"HEMVoiceServiceIntroKey";

typedef void(^HEMVoiceCommandsHandler)(NSArray<SENSpeechResult*>* _Nullable results,
                                       NSError* _Nullable error);

@interface HEMVoiceService()

@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, assign, getter=isInProgress) BOOL inProgress;
@property (nonatomic, strong) NSDate* lastVoiceResultDate;
@property (nonatomic, strong) NSArray<HEMVoiceCommand*>* voiceCommands;

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

- (NSArray<HEMVoiceCommand*>*)availableVoiceCommands {
    if (![self voiceCommands]) {
        HEMVoiceCommand* soundsCommand = [HEMVoiceCommand new];
        [soundsCommand setCategoryName:NSLocalizedString(@"voice.command.sound.category.name", nil)];
        [soundsCommand setExample:NSLocalizedString(@"voice.command.sound.example", nil)];
        [soundsCommand setIconNameSmall:@"voiceSoundIconSmall"];
        
        HEMVoiceCommand* sleepCommand = [HEMVoiceCommand new];
        [sleepCommand setCategoryName:NSLocalizedString(@"voice.command.sleep.category.name", nil)];
        [sleepCommand setExample:NSLocalizedString(@"voice.command.sleep.example", nil)];
        [sleepCommand setIconNameSmall:@"voiceSleepIconSmall"];
        
        HEMVoiceCommand* rcCommand = [HEMVoiceCommand new];
        [rcCommand setCategoryName:NSLocalizedString(@"voice.command.room-conditions.category.name", nil)];
        [rcCommand setExample:NSLocalizedString(@"voice.command.room-conditions.example", nil)];
        [rcCommand setIconNameSmall:@"voiceConditionsIconSmall"];
        
        HEMVoiceCommand* expansionsCommand = [HEMVoiceCommand new];
        [expansionsCommand setCategoryName:NSLocalizedString(@"voice.command.expansions.category.name", nil)];
        [expansionsCommand setExample:NSLocalizedString(@"voice.command.expansions.example", nil)];
        [expansionsCommand setIconNameSmall:@"voiceExpansionsIconSmall"];
        
        [self setVoiceCommands:@[soundsCommand, sleepCommand, rcCommand, expansionsCommand]];
    }
    return [self voiceCommands];
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

@end
