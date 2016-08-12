//
//  HEMUpgradeFlow.m
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMUpgradeFlow.h"
#import "HEMHaveSenseViewController.h"
#import "HEMNoBLEViewController.h"
#import "HEMSensePairViewController.h"
#import "HEMUpgradePairSensePresenter.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBluetoothUtils.h"

@implementation HEMUpgradeFlow

- (instancetype)init {
    self = [super init];
    if (self) {
        // we need to do this to warm up the radio to check later
        BOOL on = [HEMBluetoothUtils isBluetoothOn];
        DDLogVerbose(@"is bluetooth on %@", on ? @"y" : @"n");
    }
    return self;
}

- (HEMPresenter*)presenterForNextViewController:(UIViewController*)controller
                      fromCurrentViewController:(UIViewController*)currentViewController {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    return [[HEMUpgradePairSensePresenter alloc] initWithOnboardingService:service];
}

- (NSString*)nextSegueIdentifierAfterViewController:(UIViewController*)currentViewController {
    NSString* nextSegueId = nil;
    if ([currentViewController isKindOfClass:[HEMHaveSenseViewController class]]) {
        if (![HEMBluetoothUtils isBluetoothOn]) {
            nextSegueId = [HEMOnboardingStoryboard noBLESegueIdentifier];
        } else {
            nextSegueId = [HEMOnboardingStoryboard pairSegueIdentifier];
        }
    } else if ([currentViewController isKindOfClass:[HEMNoBLEViewController class]]) {
        nextSegueId = [HEMOnboardingStoryboard pairSegueIdentifier];
    }
    return nextSegueId;
}

- (BOOL)enableBackButtonFor:(UIViewController*)currentViewController
     withPreviousController:(UIViewController*)previousController {
    BOOL enable = YES;
    if ([previousController isKindOfClass:[HEMNoBLEViewController class]]
        && [currentViewController isKindOfClass:[HEMSensePairViewController class]]) {
        enable = NO;
    }
    return enable;
}

@end
