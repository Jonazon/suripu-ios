//
//  HEMRoomConditionsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSensor.h>

#import "Sense-Swift.h"

#import "HEMRoomConditionsViewController.h"
#import "HEMRoomConditionsPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMSensorDetailViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSettingsStoryboard.h"
#import "HEMSettingsPresenter.h"

@interface HEMRoomConditionsViewController () <
    HEMPresenterPairDelegate,
    HEMSensePairingDelegate,
    HEMRoomConditionsDelegate,
    RoomConditionsNavDelegate,
    Scrollable,
    ShortcutHandler
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) HEMSensorService* sensorService;
@property (strong, nonatomic) HEMIntroService* introService;
@property (strong, nonatomic) SENSensor* sensorSelected;
@property (weak, nonatomic) HEMRoomConditionsPresenter* presenter;

@end

@implementation HEMRoomConditionsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        static NSString* iconKey = @"sense.conditions.icon";
        static NSString* iconHighlightedKey = @"sense.conditions.highlighted.icon";
        NSString* title = NSLocalizedString(@"current-conditions.title", nil);
        TabPresenter* tabPresenter = [[TabPresenter alloc] initWithStyleKey:iconKey
                                                        styleHighlightedKey:iconHighlightedKey
                                                                      title:title];
        [tabPresenter bindWithTabItem:[self tabBarItem]];
        [self addPresenter:tabPresenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    HEMSensorService* sensorService = [HEMSensorService new];
    HEMIntroService* introService = [HEMIntroService new];
    
    HEMRoomConditionsPresenter* presenter =
        [[HEMRoomConditionsPresenter alloc] initWithSensorService:sensorService
                                                     introService:introService];
    
    [presenter bindWithCollectionView:[self collectionView]];
    [presenter bindWithActivityIndicator:[self activityIndicator]];
    [presenter setPairDelegate:self];
    [presenter setDelegate:self];
    
    RoomConditionsNavPresenter* navPresenter = [RoomConditionsNavPresenter new];
    [navPresenter bindWithNavItem:[self navigationItem]];
    [navPresenter setNavDelegate:self];

    [self setPresenter:presenter];
    [self setSensorService:sensorService];
    [self setIntroService:introService];
    [self addPresenter:presenter];
    [self addPresenter:navPresenter];
}

#pragma mark - Scrollable

- (void)scrollToTop {
    [[self collectionView] setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Shortcut from extension

- (BOOL)canHandleActionWithAction:(HEMShortcutAction)action {
    return action == HEMShortcutActionRoomConditionsShow
        || action == HEMShortcutActionShowDeviceSettings;
}

- (void)takeActionWithAction:(HEMShortcutAction)action data:(id _Nullable)data {
    if ([[self navigationController] topViewController] != self) {
        [[self navigationController] popToRootViewControllerAnimated:NO];
    }
    switch (action) {
        case HEMShortcutActionRoomConditionsShow:
            [SENAnalytics track:kHEMAnalyticsEventLaunchedFromExt];
            break;
        case HEMShortcutActionShowDeviceSettings:
            [self showSettingsAnimated:NO category:HEMSettingsCategoryDevices];
            break;
        default:
            break;
    }
    
}

#pragma mark - RoomConditionsNavDelegate

- (void)showSettingsAnimated:(BOOL)animated category:(HEMSettingsCategory)category {
    HEMSettingsTableViewController* settingsVC = [HEMSettingsStoryboard instantiateSettingsController];
    [settingsVC setCategoryToShow:category];
    [[self navigationController] pushViewController:settingsVC animated:animated];
}

- (void)showSettingsFromPresenter:(__unused RoomConditionsNavPresenter *)presenter {
    [self showSettingsAnimated:YES category:HEMSettingsCategoryMain];
}

#pragma mark - HEMRoomConditionsDelegate

- (void)showSensor:(SENSensor *)sensor fromPresenter:(HEMRoomConditionsPresenter *)presenter {
    [self setSensorSelected:sensor];
    [self performSegueWithIdentifier:[HEMMainStoryboard detailSegueIdentifier] sender:self];
}

#pragma mark - HEMPresenterPairDelegate

- (void)pairSenseFrom:(HEMPresenter *)presenter {
    HEMSensePairViewController *pairVC = (id)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMSensePairingDelegate

- (void)notifyPresenterAndDismiss:(BOOL)paired {
    if (paired) {
        [[self presenter] startPolling];
    }
    [self dismissModalAfterDelay:paired];
}

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self notifyPresenterAndDismiss:senseManager != nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self notifyPresenterAndDismiss:senseManager != nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMSensorDetailViewController class]]) {
        HEMSensorDetailViewController* detailVC = destVC;
        [detailVC setSensor:[self sensorSelected]];
        [detailVC setTitle:[[self sensorSelected] localizedName]];
    }
}

@end
