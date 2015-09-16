//
//  SENAnalyticsHEMAppAnalyticsSpec.m
//  Sense
//
//  Created by Jimmy Lu on 9/14/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENAnalytics+HEMAppAnalytics.h"

SPEC_BEGIN(SENAnalyticsHEMAppAnalyticsSpec)

describe(@"SENAnalytics+HEMAppAnalytics", ^{
    
    describe(@"+trackSignUpOfNewAccount:", ^{
        
        context(@"account is provided", ^{
            
            __block SENAccount* account = nil;
            __block NSString* accountIdCreated = nil;
            __block NSDictionary* propertiesOnCreation = nil;
            
            beforeAll(^{
                [SENAnalytics stub:@selector(userWithId:didSignUpWithProperties:) withBlock:^id(NSArray *params) {
                    accountIdCreated = [params firstObject];
                    propertiesOnCreation = [params lastObject];
                    return nil;
                }];
                
                account = [[SENAccount alloc] initWithDictionary:@{@"name" : @"tester",
                                                                   @"id" : @"1"}];
                [SENAnalytics trackSignUpOfNewAccount:account];
            });
            
            afterAll(^{
                account = nil;
                accountIdCreated = nil;
                propertiesOnCreation = nil;
                [SENAnalytics clearStubs];
            });
            
            it(@"should track with properties", ^{
                [[propertiesOnCreation should] beNonNil];
            });
            
            it(@"should track with account name", ^{
                NSString* name = propertiesOnCreation[@"$name"];
                [[name should] equal:[account name]];
            });
            
            it(@"should track with the account id", ^{
                [[accountIdCreated should] equal:[account accountId]];
                NSString* accountIdProp = propertiesOnCreation[@"Account Id"];
                [[accountIdProp should] equal:[account accountId]];
            });
            
            it(@"should add Platform as a property", ^{
                NSString* platform = propertiesOnCreation[@"Platform"];
                [[platform should] equal:@"iOS"];
            });
            
            it(@"should add created date property", ^{
                id date = propertiesOnCreation[@"$created"];
                [[date should] beKindOfClass:[NSDate class]];
            });
            
        });
        
        it(@"should not call userWithId:didSignUpWithProperties: if account not provided", ^{
            [[SENAnalytics shouldNot] receive:@selector(userWithId:didSignUpWithProperties:)];
            [SENAnalytics trackSignUpOfNewAccount:nil];
        });
        
    });
    
});

SPEC_END
