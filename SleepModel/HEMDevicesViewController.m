//
//  HEMDevicesViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/23/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENDevice.h>

#import "UIFont+HEMStyle.h"
#import "NSDate+HEMRelative.h"

#import "HEMDevicesViewController.h"
#import "HEMPillViewController.h"
#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMCardFlowLayout.h"
#import "HEMDeviceCollectionViewCell.h"
#import "HEMNoDeviceCollectionViewCell.h"
#import "HEMActionButton.h"
#import "HEMPillPairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMDeviceDataSource.h"
#import "HEMSensePairViewController.h"
#import "HEMSensePairDelegate.h"

static CGFloat const HEMDeviceInfoHeight = 190.0f;
static CGFloat const HEMNoDeviceHeight = 205.0f;

@interface HEMDevicesViewController() <UICollectionViewDelegate, HEMPillPairDelegate, HEMSenseControllerDelegate, HEMSensePairingDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMDeviceDataSource* dataSource;
@property (assign, nonatomic) BOOL loaded;
@property (strong, nonatomic) SENDevice* selectedDevice;

@end

@implementation HEMDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
}

- (void)configureCollectionView {
    HEMDeviceDataSource* dataSource = [[HEMDeviceDataSource alloc] init];
    [self setDataSource:dataSource];
    
    [[self collectionView] setDelegate:self];
    [[self collectionView] setDataSource:dataSource];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setSelectedDevice:nil];
    
    // only load devices again on appearance if user is coming back, not when
    // coming to, and only if devices are not configured so that we can check
    // if it has happened.
    if ([self loaded] && ![[self dataSource] isMissingADevice]) {
        [self reloadData];
    } else {
        __weak typeof(self) weakSelf = self;
        [[self dataSource] loadDeviceInfo:^(NSError *error) {
            [weakSelf reloadData];
        }];
        
        [self setLoaded:YES];
    }
    
}

- (void)reloadData {
    HEMCardFlowLayout* layout
        = (HEMCardFlowLayout*)[[self collectionView] collectionViewLayout];
    [layout clearCache];
    [[self collectionView] reloadData];
}

- (void)refreshDataSource {
    __weak typeof(self) weakSelf = self;
    [[self dataSource] refresh:^(NSError *error) {
        [weakSelf reloadData];
    }];
    [self reloadData]; // clear current display state to show activity
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMCardFlowLayout* layout = (HEMCardFlowLayout*)collectionViewLayout;
    SENDevice* device = [[self dataSource] deviceAtIndexPath:indexPath];
    CGSize size = [layout itemSize];
    size.height = device != nil ? HEMDeviceInfoHeight : HEMNoDeviceHeight;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [[self dataSource] updateCell:cell atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self dataSource] isObtainingData]) {
        return;
    }

    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    SENDeviceType type = [[self dataSource] deviceTypeAtIndexPath:indexPath];
    
    switch (type) {
        case SENDeviceTypeSense:
            if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
                [self showSensePairingController];
            } else {
                [self setSelectedDevice:[[self dataSource] deviceAtIndexPath:indexPath]];
                [self performSegueWithIdentifier:[HEMMainStoryboard senseSegueIdentifier]
                                          sender:self];
            }
            break;
        case SENDeviceTypePill:
            if ([cell isKindOfClass:[HEMNoDeviceCollectionViewCell class]]) {
                [self showPillPairingController];
            } else {
                [self setSelectedDevice:[[self dataSource] deviceAtIndexPath:indexPath]];
                [self performSegueWithIdentifier:[HEMMainStoryboard pillSegueIdentifier]
                                          sender:self];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Pair Pill

- (void)showPillPairingController {
    HEMPillPairViewController* pairVC =
        (HEMPillPairViewController*) [HEMOnboardingStoryboard instantiatePillPairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Pair Sense

- (void)showSensePairingController {
    HEMSensePairViewController* pairVC =
        (HEMSensePairViewController*) [HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark HEMPillPairDelegate

- (void)didPairWithPillFrom:(HEMPillPairViewController *)controller {
    [self reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPairing:(HEMPillPairViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMSenseControllerDelegate

- (void)didUpdateWiFiFrom:(HEMSenseViewController *)viewController {
    
    [self refreshDataSource];
}

#pragma mark - HEMSensePairDelegate

- (void)didPairSense:(BOOL)pair from:(UIViewController *)controller {
    if (pair) {
        [self refreshDataSource];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(BOOL)setup from:(UIViewController *)controller {
    [self refreshDataSource];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[HEMSenseViewController class]]) {
        HEMSenseViewController* senseVC = [segue destinationViewController];
        [senseVC setWarnings:[[self dataSource] deviceWarningsFor:[self selectedDevice]]];
        [senseVC setDelegate:self];
    } else if ([[segue destinationViewController] isKindOfClass:[HEMPillViewController class]]) {
        HEMPillViewController* pillVC = [segue destinationViewController];
        [pillVC setWarnings:[[self dataSource] deviceWarningsFor:[self selectedDevice]]];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end
