//
//  HEMSleepSoundViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import "HEMSleepSoundViewController.h"
#import "HEMSleepSoundPlayerPresenter.h"
#import "HEMSleepSoundService.h"
#import "HEMAlertViewController.h"
#import "HEMListItemSelectionViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSleepSoundsPresenter.h"
#import "HEMSleepSoundDurationsPresenter.h"
#import "HEMSleepSoundVolumePresenter.h"
#import "HEMAudioService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMDeviceService.h"
#import "HEMSensePairViewController.h"
#import "HEMStyledNavigationViewController.h"

@interface HEMSleepSoundViewController () <
    HEMSleepSoundPlayerDelegate,
    HEMListDelegate,
    HEMPresenterPairDelegate,
    HEMSensePairingDelegate,
    Scrollable
>

@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, weak) IBOutlet UIButton* actionButton;
@property (nonatomic, weak) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) HEMSleepSoundService* sleepSoundService;
@property (nonatomic, strong) HEMAudioService* audioService;
@property (nonatomic, strong) HEMListPresenter* listPresenter;
@property (nonatomic, weak) HEMSleepSoundPlayerPresenter* playerPresenter;
@property (nonatomic, copy) NSString* listTitle;

@end

@implementation HEMSleepSoundViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        static NSString* iconKey = @"sense.sounds.icon";
        static NSString* iconHighlightedKey = @"sense.sounds.highlighted.icon";
        _tabIcon = [SenseStyle imageWithAClass:[UITabBar class] propertyName:iconKey];
        _tabIconHighlighted = [SenseStyle imageWithAClass:[UITabBar class] propertyName:iconHighlightedKey];
        _tabTitle = NSLocalizedString(@"sleep-sounds.title", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
}

- (void)configurePresenters {
    [self setSleepSoundService:[HEMSleepSoundService new]];
    
    if (![self deviceService]) {
        [self setDeviceService:[HEMDeviceService new]];
    }
    
    HEMSleepSoundPlayerPresenter* playerPresenter =
        [[HEMSleepSoundPlayerPresenter alloc] initWithSleepSoundService:[self sleepSoundService]
                                                          deviceService:[self deviceService]];
    [playerPresenter bindWithActionButton:[self actionButton]];
    [playerPresenter bindWithCollectionView:[self collectionView]];
    [playerPresenter bindWithActivityIndicator:[self activityIndicator]];
    [playerPresenter setDelegate:self];
    [playerPresenter setPairDelegate:self];
    [self addPresenter:playerPresenter];
    
    [self setPlayerPresenter:playerPresenter];
}

#pragma mark - Actions

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Scrollable

- (void)scrollToTop {
    [[self collectionView] setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Sleep Sound Player Delegate

- (void)presentErrorWithTitle:(NSString*)title message:(NSString*)message {
    [HEMAlertViewController showInfoDialogWithTitle:title
                                            message:message
                                         controller:[self rootViewController]];
}

- (void)showAvailableSounds:(NSArray *)sounds
          selectedSoundName:(NSString*)selectedName
                  withTitle:(NSString*)title
                   subTitle:(NSString*)subTitle
                       from:(HEMSleepSoundPlayerPresenter *)presenter {
    if (![self audioService]) {
        [self setAudioService:[HEMAudioService new]];
    }
    
    HEMSleepSoundsPresenter* soundsPresenter =
        [[HEMSleepSoundsPresenter alloc] initWithTitle:subTitle
                                                 items:sounds
                                      selectedItemName:selectedName
                                          audioService:[self audioService]];

    [self showListViewControllerWithPresenter:soundsPresenter title:title];
}

- (void)showAvailableDurations:(NSArray *)durations
          selectedDurationName:(NSString*)selectedName
                     withTitle:(NSString*)title
                      subTitle:(NSString*)subTitle
                          from:(HEMSleepSoundPlayerPresenter *)presenter {
    HEMSleepSoundDurationsPresenter* durationsPresenter
        = [[HEMSleepSoundDurationsPresenter alloc] initWithTitle:subTitle
                                                           items:durations
                                               selectedItemNames:@[selectedName]];
    [self showListViewControllerWithPresenter:durationsPresenter title:title];
}

- (void)showVolumeOptions:(NSArray *)volumeOptions
       selectedVolumeName:(NSString*)selectedName
                withTitle:(NSString*)title
                 subTitle:(NSString*)subTitle
                     from:(HEMSleepSoundPlayerPresenter *)presenter {
    HEMSleepSoundVolumePresenter* volumePresenter
        = [[HEMSleepSoundVolumePresenter alloc] initWithTitle:subTitle
                                                        items:volumeOptions
                                            selectedItemNames:@[selectedName]];
    [self showListViewControllerWithPresenter:volumePresenter title:title];
}

- (void)showListViewControllerWithPresenter:(HEMListPresenter*)presenter title:(NSString*)title {
    [self setListTitle:title];
    [self setListPresenter:presenter];
    [[self listPresenter] setDelegate:self];
    [self performSegueWithIdentifier:[HEMMainStoryboard listSegueIdentifier] sender:self];
}

#pragma mark - List Delegate

- (void)didSelectItem:(id)item atIndex:(NSInteger)index from:(HEMListPresenter *)presenter {
    BOOL dismiss = YES;
    
    if ([presenter isKindOfClass:[HEMSleepSoundsPresenter class]]) {
        [[self playerPresenter] setSelectedSound:item save:YES];
        dismiss = NO;
    } else if ([presenter isKindOfClass:[HEMSleepSoundDurationsPresenter class]]) {
        [[self playerPresenter] setSelectedDuration:item save:YES];
    } else if ([presenter isKindOfClass:[HEMSleepSoundVolumePresenter class]]) {
        [[self playerPresenter] setSelectedVolume:item save:YES];
    }
    
    if (dismiss) {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    
}

#pragma mark - HEMPresenterPairDelegate

- (void)pairSenseFrom:(HEMPresenter *)presenter {
    HEMSensePairViewController *pairVC = (id)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMSensePairingDelegate

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [[self playerPresenter] prepareForReload];
    [self dismissModalAfterDelay:senseManager != nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [[self playerPresenter] prepareForReload];
    [self dismissModalAfterDelay:senseManager != nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMListItemSelectionViewController class]]) {
        HEMListItemSelectionViewController* listVC = destVC;
        [listVC setListPresenter:[self listPresenter]];
        [listVC setTitle:[self listTitle]];
    }
}

@end
