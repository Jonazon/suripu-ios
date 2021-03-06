//
//  HEMWiFiDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 10/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSenseMessage.pb.h>
#import <SenseKit/SENServiceDevice.h>

#import "NSTimeZone+HEMMapping.h"

#import "HEMWiFiDataSource.h"
#import "HEMOnboardingService.h"

NSString* const kHEMWifiOtherCellId = @"other";
NSString* const kHEMWifiNetworkCellId = @"network";

static NSString* const kHEMWifiNetworkErrorDomain = @"is.hello.ble.wifi";

@interface HEMWiFiDataSource()

@property (nonatomic, strong) NSMutableArray* wifisDetected;
@property (nonatomic, assign) NSUInteger scanCount;

/**
 * @property uniqueSSIDs
 *
 * @discussion
 * This is needed to not add networks that are already shown as multiple scans
 * are needed, but that will return possibly wifis that are already detected.
 * It would be easy enough to just use a NSOrderedSet to hold networks, but
 * those objects' isEquals: method also checks RSSI values, which unfortunately
 * we don't care if it doesn't match, as it likely won't
 */
@property (nonatomic, strong) NSMutableSet* uniqueSSIDs;
@property (nonatomic, assign, getter=isScanning) BOOL scanning;
@property (nonatomic, assign) BOOL scanned;

@end

@implementation HEMWiFiDataSource

- (id)init {
    self = [super init];
    if (self) {
        [self setWifisDetected:[NSMutableArray array]];
        [self setUniqueSSIDs:[NSMutableSet set]];
    }
    return self;
}

- (void)addDetectedNetworksFromArray:(NSArray*)networks {
    if ([networks count] == 0) return;
    
    NSInteger insertionIndex = 0;
    for (SENWifiEndpoint* network in networks) {
        // seems like there is a possibility that the ssid is nil, in which case
        // we should ignore it to prevent a possible crash and also because we
        // can't use the network object anyways
        if (![network ssid]) {
            continue;
        }
        
        if (![[self uniqueSSIDs] containsObject:[network ssid]]) {
            insertionIndex =
                [[self wifisDetected] indexOfObject:network
                                      inSortedRange:NSMakeRange(0, [[self wifisDetected] count])
                                            options:NSBinarySearchingInsertionIndex
                                    usingComparator:^NSComparisonResult(SENWifiEndpoint* wifi1, SENWifiEndpoint* wifi2) {
                                        NSComparisonResult result = NSOrderedSame;
                                        if ([wifi1 rssi] < [wifi2 rssi]) {
                                            result = NSOrderedDescending;
                                        } else if ([wifi1 rssi] > [wifi2 rssi]) {
                                            result = NSOrderedAscending;
                                        }
                                        return result;
                                    }];
            [[self wifisDetected] insertObject:network atIndex:insertionIndex];
            [[self uniqueSSIDs] addObject:[network ssid]];
        }
    }
}

- (SENSenseManager*)manager {
    return [[HEMOnboardingService sharedService] currentSenseManager];
}

- (void)clearDetectedWifis {
    [self setScanned:NO];
    [[self wifisDetected] removeAllObjects];
    [[self uniqueSSIDs] removeAllObjects];
}

- (void)keepLEDOnIfRequiredThen:(void(^)(void))next {
    SENSenseLEDState led = [self keepSenseLEDOn] ? SENSenseLEDStatePair : SENSenseLEDStateOff;
    [[self manager] setLED:led completion:^(id ledResponse, NSError *error) {
        next();
    }];
}

- (void)scan:(void(^)(NSError* error))completion {
    SENSenseManager* manager = [self manager];
    if (manager) {
        [self setScanning:YES];
        
        __weak typeof(self) weakSelf = self;
        
        void(^finish)(NSError* error) = ^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setScanning:NO];
            [strongSelf setScanned:YES];
            completion (error);
        };

        [manager setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error != nil) {
                finish (error);
                return;
            }
            
            [strongSelf setScanCount:[strongSelf scanCount] + 1];
            
            NSString* countryCode = nil;
            if ([strongSelf scanCount] > 1) {
                countryCode = [NSTimeZone countryCodeForSense];
                DDLogVerbose(@"sending country code %@ to Sense", countryCode);
            }
            
            [[strongSelf manager] scanForWifiNetworksInCountry:countryCode success:^(id response) {

                [strongSelf keepLEDOnIfRequiredThen:^{
                    [strongSelf addDetectedNetworksFromArray:response];
                    finish (nil);
                }];
                
            } failure:^(NSError *error) {
                [strongSelf keepLEDOnIfRequiredThen:^{
                    finish (error);
                }];
            }];
            
        }];
    } else {
        completion ([NSError errorWithDomain:kHEMWifiNetworkErrorDomain
                                        code:HEMWiFiErrorCodeInvalidArgument
                                    userInfo:nil]);
    }
}

- (SENWifiEndpoint*)endpointAtIndexPath:(NSIndexPath*)indexPath {
    SENWifiEndpoint* endpoint = nil;
    
    NSInteger row = [indexPath row];
    if (row < [[self wifisDetected] count]) {
        endpoint = [self wifisDetected][row];
    }
    
    return endpoint;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 1 for Other (Manual), but only if not scanning
    return [self isScanning] || ![self scanned] ? 0 : 1 + [[self wifisDetected] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = nil;
    if ([self endpointAtIndexPath:indexPath] == nil) {
        cellId = kHEMWifiOtherCellId;
    } else {
        cellId = kHEMWifiNetworkCellId;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

@end
