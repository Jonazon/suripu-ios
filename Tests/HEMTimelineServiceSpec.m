//
//  HEMTimelineServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 1/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import "HEMTimelineService.h"
#import "NSDate+HEMRelative.h"

SPEC_BEGIN(HEMTimelineServiceSpec)

describe(@"HEMTimelineService", ^{
    
    describe(@"-isFirstNightOfSleep:forAccount:", ^{
        
        __block HEMTimelineService* timelineService;
        __block SENAccount* fakeAccount;
        __block BOOL firstNight = NO;
        
        context(@"just created account today", ^{
            
            __block BOOL didSetUserPreference = NO;
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) withBlock:^id(NSArray *params) {
                    didSetUserPreference = YES;
                    return [KWValue valueWithBool:YES];
                }];
                
                firstNight = NO;
                NSDate* today = [NSDate date];
                
                timelineService = [HEMTimelineService new];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:today];
                
                firstNight = [timelineService isFirstNightOfSleep:[today previousDay] forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                firstNight = NO;
                didSetUserPreference = NO;
            });
            
            it(@"should return YES", ^{
                [[@(firstNight) should] beYes];
            });
            
            it(@"should have saved creation date", ^{
                [[@(didSetUserPreference) should] beYes];
            });
            
        });
        
        context(@"just created account today, but account is not loaded", ^{
            
            __block BOOL didSetUserPreference = NO;
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) withBlock:^id(NSArray *params) {
                    didSetUserPreference = YES;
                    return [KWValue valueWithBool:YES];
                }];
                
                firstNight = YES;
                timelineService = [HEMTimelineService new];
                firstNight = [timelineService isFirstNightOfSleep:[NSDate date] forAccount:nil];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                firstNight = YES;
                didSetUserPreference = NO;
            });
            
            it(@"should return NO if we cannot determine it", ^{
                [[@(firstNight) should] beNo];
            });
            
            it(@"should not have saved any user preference since no creation date", ^{
                [[@(didSetUserPreference) should] beNo];
            });
        });
        
        context(@"created an account yesterday", ^{
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) andReturn:[KWValue valueWithBool:YES]];
                
                firstNight = NO;
                NSDate* today = [NSDate date];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:[today previousDay]];
                
                timelineService = [HEMTimelineService new];
                
                firstNight = [timelineService isFirstNightOfSleep:today forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                firstNight = NO;
            });
            
            it(@"should return NO", ^{
                [[@(firstNight) should] beNo];
            });
            
        });
        
        context(@"onboarded 90 days ago", ^{
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) andReturn:[KWValue valueWithBool:YES]];
                
                firstNight = NO;
                NSDate* today = [NSDate date];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:[today daysFromNow:-90]];
                
                timelineService = [HEMTimelineService new];
                
                firstNight = [timelineService isFirstNightOfSleep:today forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                firstNight = NO;
            });
            
            it(@"should return NO", ^{
                [[@(firstNight) should] beNo];
            });
            
        });
        
        context(@"date passed in is before account creation date", ^{
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) andReturn:[KWValue valueWithBool:YES]];
                
                firstNight = NO;
                NSDate* today = [NSDate date];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:today];
                
                timelineService = [HEMTimelineService new];
                
                firstNight = [timelineService isFirstNightOfSleep:[today daysFromNow:-3]
                                                       forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                firstNight = NO;
            });
            
            it(@"should return YES", ^{
                [[@(firstNight) should] beYes];
            });
            
        });
        
    });
    
    describe(@"-canViewTimelinesBefore:forAccount:", ^{
        
        __block HEMTimelineService* timelineService;
        __block SENAccount* fakeAccount;
        __block BOOL canView = NO;
        
        context(@"just created account at midnight", ^{
            
            __block BOOL didSetUserPreference = NO;
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) withBlock:^id(NSArray *params) {
                    didSetUserPreference = YES;
                    return [KWValue valueWithBool:YES];
                }];
                
                canView = YES;
                
                NSDate* today = [[NSDate date] dateAtMidnight];

                timelineService = [HEMTimelineService new];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:today];
                
                canView = [timelineService canViewTimelinesBefore:[today previousDay]
                                                       forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                canView = YES;
                didSetUserPreference = NO;
            });
            
            it(@"should return NO", ^{
                [[@(canView) should] beNo];
            });
            
            it(@"should have saved creation date", ^{
                [[@(didSetUserPreference) should] beYes];
            });
            
        });
        
        context(@"just created account today, but account is not loaded", ^{
            
            __block BOOL didSetUserPreference = NO;
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) withBlock:^id(NSArray *params) {
                    didSetUserPreference = YES;
                    return [KWValue valueWithBool:YES];
                }];
                
                canView = NO;
                timelineService = [HEMTimelineService new];
                canView = [timelineService canViewTimelinesBefore:[[NSDate date] previousDay] forAccount:nil];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                canView = NO;
                didSetUserPreference = NO;
            });
            
            it(@"should return YES", ^{
                [[@(canView) should] beYes];
            });
            
            it(@"should not have saved any user preference since no creation date", ^{
                [[@(didSetUserPreference) should] beNo];
            });

        });
        
        context(@"created an account yesterday", ^{
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) andReturn:[KWValue valueWithBool:YES]];
                
                canView = NO;
                NSDate* today = [[NSDate date] dateAtMidnight];
                NSDate* yesterday = [today previousDay];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:yesterday];
                
                timelineService = [HEMTimelineService new];
                
                canView = [timelineService canViewTimelinesBefore:[yesterday previousDay]
                                                       forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                canView = NO;
            });
            
            it(@"should return NO", ^{
                [[@(canView) should] beNo];
            });
            
        });
        
        context(@"onboarded 90 days ago", ^{
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) andReturn:[KWValue valueWithBool:YES]];
                
                canView = NO;
                NSDate* today = [NSDate date];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:[today daysFromNow:-90]];
                
                timelineService = [HEMTimelineService new];
                
                canView = [timelineService canViewTimelinesBefore:[today previousDay] forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                canView = NO;
            });
            
            it(@"should return YES", ^{
                [[@(canView) should] beYes];
            });
            
        });
        
        context(@"date passed in is before account creation date", ^{
            
            beforeEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs stub:@selector(userPreferenceForKey:) andReturn:nil];
                [prefs stub:@selector(setUserPreference:forKey:) andReturn:[KWValue valueWithBool:YES]];
                
                canView = YES;
                NSDate* today = [NSDate date];
                
                fakeAccount = [SENAccount new];
                [fakeAccount setCreatedAt:today];
                
                timelineService = [HEMTimelineService new];
                
                canView = [timelineService canViewTimelinesBefore:[today daysFromNow:-3]
                                                       forAccount:fakeAccount];
            });
            
            afterEach(^{
                SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
                [prefs clearStubs];
                
                timelineService = nil;
                fakeAccount = nil;
                canView = YES;
            });
            
            it(@"should return NO", ^{
                [[@(canView) should] beNo];
            });
            
        });
        
    });
    
});

SPEC_END
