//
//  HEMAccountPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENAuthorizationService.h>

#import "Sense-Swift.h"

#import "SENRemoteImage+HEMDeviceSpecific.h"
#import "UIAlertController+HEMPhotoOptions.h"
#import "UIImagePickerController+HEMProfilePhoto.h"
#import "UIImage+HEMCompression.h"

#import "HEMAccountPresenter.h"
#import "HEMPresenter+HEMPhoto.h"
#import "HEMAccountService.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMSettingsStoryboard.h"
#import "HEMStyle.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBirthdatePickerViewController.h"
#import "HEMGenderPickerViewController.h"
#import "HEMHeightPickerViewController.h"
#import "HEMWeightPickerViewController.h"
#import "HEMFormViewController.h"
#import "HEMAccountUpdateDelegate.h"
#import "HEMNameChangePresenter.h"
#import "HEMEmailChangePresenter.h"
#import "HEMPasswordChangePresenter.h"
#import "HEMHealthKitService.h"
#import "HEMBasicTableViewCell.h"
#import "HEMPhotoHeaderView.h"
#import "HEMProfileImageView.h"
#import "HEMFacebookService.h"
#import "HEMPresenter+HEMBreadcrumb.h"
#import "HEMHandHoldingService.h"
#import "HEMHandholdingView.h"
#import "HEMAlertViewController.h"
#import "HEMUnitPreferenceViewController.h"
#import "HEMActivityCoverView.h"

typedef NS_ENUM(NSInteger, HEMAccountSection) {
    HEMAccountSectionAccount = 0,
    HEMAccountSectionDemographics,
    HEMAccountSectionUnits,
    HEMAccountSectionPreferences,
    HEMAccountSectionSignOut,
    HEMAccountSectionCount
};

typedef NS_ENUM(NSInteger, HEMAccountRow) {
    HEMAccountRowName = 0,
    HEMAccountRowEmail,
    HEMAccountRowPassword,
    HEMAccountRowCount
};

typedef NS_ENUM(NSInteger, HEMDemographicsRow) {
    HEMDemographicsRowBirthday = 0,
    HEMDemographicsRowGender,
    HEMDemographicsRowHeight,
    HEMDemographicsRowWeight,
    HEMDemographicsRowCount
};

typedef NS_ENUM (NSUInteger, HEMUnitsRow) {
    HEMUnitsRowUnitsAndTime = 0,
    HEMUnitsRowCount
};

typedef NS_ENUM(NSInteger, HEMPreferencesRow) {
    HEMPreferencesRowHealthKit = 0,
    HEMPreferencesRowEnhancedAudio,
    HEMPreferencesRowCount
};

typedef NS_ENUM(NSInteger, HEMSignOutRow) {
    HEMSignOutRowButton = 0,
    HEMSignOutRowCount
};

static CGFloat const HEMAccountTableCellBaseHeight = 56.0f;
static CGFloat const HEMAccountTableCellEnhancedAudioNoteHeight = 70.0f;
static CGFloat const HEMAccountAudioNoteVertMargin = 12.0f;
static CGFloat const HEMAccountAudioNoteHorzMargin = 24.0f;

@interface HEMAccountPresenter() <
    UITableViewDataSource,
    UITableViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>

@property (nonatomic, weak) HEMAccountService* accountService;
@property (nonatomic, weak) HEMFacebookService* facebookService;
@property (nonatomic, weak) HEMHealthKitService* healthKitService;
@property (nonatomic, weak) HEMHandHoldingService* handHoldingService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) NSAttributedString* enhancedAudioNote;
@property (nonatomic, weak) UISwitch* activatedSwitch;
@property (nonatomic, strong) UIAlertController* photoOptionController;
@property (nonatomic, weak) UIView* activityContainer;

@end

@implementation HEMAccountPresenter

- (instancetype)initWithAccountService:(HEMAccountService*)accountService
                       facebookService:(HEMFacebookService*)facebookService
                      healthKitService:(HEMHealthKitService*)healthKitService
                    handHoldingService:(HEMHandHoldingService*)hhService {
    self = [super init];
    if (self) {
        _accountService = accountService;
        _healthKitService = healthKitService;
        _facebookService = facebookService;
        _handHoldingService = hhService;
    }
    return self;
}

- (void)bindWithActivityContainerView:(UIView*)activityContainer {
    [self setActivityContainer:activityContainer];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    [navItem setTitle:NSLocalizedString(@"settings.account", nil)];
}

- (void)bindWithTableView:(UITableView*)tableView {
    UIView* footerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES
                                                                   bottomBorder:NO];
    [tableView setTableFooterView:footerView];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSectionFooterHeight:0.0f];
    
    [self setTableView:tableView];
    
    HEMPhotoHeaderView* photoView = [self photoHeaderView];
    [[photoView addButton] addTarget:self
                              action:@selector(showPhotoOptions)
                    forControlEvents:UIControlEventTouchUpInside];
    
    SENAccount* account = [[self accountService] account];
    NSString* url = [[account photo] uriForCurrentDevice];
    if (url) {
        [[photoView imageView] setImageWithURL:url];
    }
    
    [self refresh];
}

- (void)refresh {
    __weak typeof(self) weakSelf = self;
    [[self accountService] refreshWithPhoto:YES completion:^(SENAccount * account, NSDictionary<NSNumber *,SENPreference *> * preferences) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf tableView] reloadData];
        [[strongSelf tableView] flashScrollIndicators];
        
        NSString* url = [[account photo] uriForCurrentDevice];
        HEMProfileImageView* imageView = [[strongSelf photoHeaderView] imageView];
        if (url && ![[imageView currentImageURL] isEqualToString:url]) {
            [imageView setImageWithURL:url];
        }
    }];
}

- (void)showAccountUpdateError:(NSError*)error {
    NSString* title = NSLocalizedString(@"account.update.failed.title", nil);
    NSString* message = nil;
    if ([[error domain] isEqualToString:HEMAccountServiceDomain]) {
        switch ([error code]) {
            case HEMAccountServiceErrorInvalidArg:
                message = NSLocalizedString(@"settings.account.update.failure", nil);
                break;
            case HEMAccountServiceErrorAccountNotUpToDate:
                message = NSLocalizedString(@"settings.account.update.account-not-up-to-date", nil);
                break;
            case HEMAccountServiceErrorServerFailure:
            case HEMAccountServiceErrorUnknown:
            default:
                message = NSLocalizedString(@"account.update.error.generic", nil);
                break;
        }
    } else if ([[error domain] isEqualToString:NSURLErrorDomain]){
        message = [error localizedDescription];
    }

    [[self delegate] showErrorTitle:title message:message from:self];
}

- (void)didAppear {
    [super didAppear];
    [[self tableView] reloadData];
}

- (HEMPhotoHeaderView*)photoHeaderView {
    HEMPhotoHeaderView* photoView = nil;
    UIView* headerView = [[self tableView] tableHeaderView];
    if ([headerView isKindOfClass:[HEMPhotoHeaderView class]]) {
        photoView = (id) headerView;
    }
    return photoView;
}

#pragma mark - Photo

- (BOOL)hasPhotoToRemove {
    HEMPhotoHeaderView* photoView = [self photoHeaderView];
    return [[photoView imageView] showingProfilePhoto];
}

- (void)removePhoto {
    HEMPhotoHeaderView* photoView = [self photoHeaderView];
    [[photoView imageView] clearPhoto];
    [[self accountService] removeProfilePhoto:nil];
}

- (void)uploadPhoto:(UIImage*)image {
    __weak typeof(self) weakSelf = self;
    CGFloat compression = HEMAccountPhotoDefaultCompression;
    [image jpegDataWithCompression:compression completion:^(NSData * _Nullable data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (data) {
            [[strongSelf accountService] uploadProfileJpegPhoto:data progress:nil completion:nil];
        } else {
            // TODO: show error
        }
        
    }];
}

- (void)importFromFacebook {
    __weak typeof(self) weakSelf = self;
    UIViewController* mainController = [[self delegate] mainControllerFor:self];
    [[self facebookService] profileFrom:mainController completion:^(SENAccount* account, NSString* photoUrl, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSString* title = NSLocalizedString(@"account.error.import-photo-from-fb.title", nil);
            NSString* message = NSLocalizedString(@"account.error.import-photo-from-fb", nil);
            [[strongSelf delegate] showErrorTitle:title message:message from:strongSelf];
        } else if (photoUrl) {
            HEMPhotoHeaderView* photoView = [strongSelf photoHeaderView];
            [[photoView imageView] setImageWithURL:photoUrl completion:^(UIImage * image, NSString * url, NSError * error) {
                if (error) {
                    [SENAnalytics trackError:error];
                } else if ([url isEqualToString:photoUrl] && image) {
                    // upload it
                    [strongSelf uploadPhoto:image];
                }
            }];
        }
    }];
}

- (void)photoFromDevice:(BOOL)camera {
    __weak typeof(self) weakSelf = self;
    void(^show)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIImagePickerController* photoPicker = [UIImagePickerController photoPickerWithCamera:camera delegate:strongSelf];
        [[strongSelf delegate] presentViewController:photoPicker from:strongSelf];
    };
    
    void(^showSettingsPrompt)(void) =^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        HEMAlertViewController* alert = [strongSelf settingsPromptForCamera:camera];
        [[strongSelf delegate] presentViewController:alert from:strongSelf];
    };
    
    HEMProfilePhotoAccess currentAccess = [UIImagePickerController authorizationFor:camera];
    BOOL firstTimePrompt = currentAccess == HEMProfilePhotoAccessUnknown;
    
    [UIImagePickerController promptForAccessIfNeededFor:camera completion:^(HEMProfilePhotoAccess access) {
        if (access == HEMProfilePhotoAccessAuthorized) {
            show();
        } else if (access == HEMProfilePhotoAccessDenied && !firstTimePrompt) {
            showSettingsPrompt();
        }
    }];
}

- (void)showPhotoOptions {
    UIAlertController* alertVC = [UIAlertController photoOptionActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    if ([self hasPhotoToRemove]) {
        [alertVC addRemovePhotoAction:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf removePhoto];
            [SENAnalytics track:HEMAnalyticsEventDeletePhoto];
        }];
    }
    
    [alertVC addFacebookImportAction:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf importFromFacebook];
        [SENAnalytics trackPhotoAction:HEMAnalyticsEventPropSourceFacebook onboarding:NO];
    }];
    
    [alertVC addCameraActionIfSupported:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf photoFromDevice:YES];
        [SENAnalytics trackPhotoAction:HEMAnalyticsEventPropSourceCamera onboarding:NO];
    }];
    
    [alertVC addCameraRollAction:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf photoFromDevice:NO];
        [SENAnalytics trackPhotoAction:HEMAnalyticsEventPropSourcePhotoLibrary onboarding:NO];
    }];
    
    [self setPhotoOptionController:alertVC];
    [[self delegate] presentViewController:alertVC from:self];
}

#pragma mark Camera

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if ([UIImagePickerController originalIsPotentiallyAThumbnail:info]) {
        [[self delegate] dismissViewControllerFrom:self completion:^{
            NSString* title = NSLocalizedString(@"account.error.photo-selection.title", nil);
            NSString* message = NSLocalizedString(@"account.error.photo-selection.message", nil);
            
            [[self delegate] showErrorTitle:title message:message from:self];
        }];
    } else {
        UIImage* original = info[UIImagePickerControllerOriginalImage];
        UIImage* edited = info[UIImagePickerControllerEditedImage];
        UIImage* photoToUpload = edited ?: original;
        
        HEMPhotoHeaderView* photoView = [self photoHeaderView];
        [[photoView imageView] setImage:photoToUpload];
     
        [[self delegate] dismissViewControllerFrom:self completion:nil];
        [self uploadPhoto:photoToUpload];
    }

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[self delegate] dismissViewControllerFrom:self completion:nil];
}

#pragma mark - TableView Helpers

- (void)accountIcon:(UIImage**)icon title:(NSString**)title atRow:(NSInteger)row {
    SENAccount* account = [[self accountService] account];
    switch (row) {
        default:
        case HEMAccountRowName: {
            NSString* fullName = [account fullName];
            *title = [fullName length] > 0 ? fullName : NSLocalizedString(@"settings.account.name", nil);
            *icon = [UIImage imageNamed:@"settingsNameIcon"];
            break;
        }
        case HEMAccountRowEmail:
            *title = [account email] ?: NSLocalizedString(@"settings.account.email", nil);
            *icon = [UIImage imageNamed:@"settingsEmailIcon"];
            break;
        case HEMAccountRowPassword:
            *title = NSLocalizedString(@"settings.account.password", nil);
            *icon = [UIImage imageNamed:@"settingsPasswordIcon"];
            break;
    }
}

- (void)demographicsIcon:(UIImage**)icon title:(NSString**)title value:(NSString**)value atRow:(NSInteger)row {
    SENAccount* account = [[self accountService] account];
    
    switch (row) {
        default:
        case HEMDemographicsRowBirthday: {
            if ([account birthdate]) {
                *value = [account localizedBirthdateWithStyle:NSDateFormatterLongStyle];
            }
            *title = NSLocalizedString(@"settings.personal.info.birthday", nil);
            *icon = [UIImage imageNamed:@"settingsBirthdayIcon"];
            break;
        }
        case HEMDemographicsRowGender: {
            switch ([account gender]) {
                case SENAccountGenderFemale:
                    *value = NSLocalizedString(@"account.gender.female", nil);
                    break;
                case SENAccountGenderMale:
                    *value = NSLocalizedString(@"account.gender.male", nil);
                    break;
                default:
                    break;
            }
            *title = NSLocalizedString(@"settings.personal.info.gender", nil);
            *icon = [UIImage imageNamed:@"settingsGenderIcon"];
            break;
        }
        case HEMDemographicsRowHeight:
            *title = NSLocalizedString(@"settings.personal.info.height", nil);
            *icon = [UIImage imageNamed:@"settingsHeightIcon"];
            *value = [[self accountService] localizedHeightInPreferredUnit];
            break;
        case HEMDemographicsRowWeight:
            *title = NSLocalizedString(@"settings.personal.info.weight", nil);
            *icon = [UIImage imageNamed:@"settingsWeightIcon"];
            *value = [[self accountService] localizedWeightInPreferredUnit];
            break;
    }
    
    if (!*value) {
        *value = NSLocalizedString(@"empty-data", nil);
    }
}

- (void)unitsIcon:(UIImage**)icon title:(NSString**)title atRow:(NSInteger)row {
    switch (row) {
        default:
        case HEMUnitsRowUnitsAndTime:
            *icon = [UIImage imageNamed:@"settingsUnitsIcon"];
            *title = NSLocalizedString(@"settings.units", nil);
            break;
    }
}

- (void)preferencesIcon:(UIImage**)icon title:(NSString**)title enabled:(BOOL*)value atRow:(NSInteger)row {
    switch (row) {
        default:
        case HEMPreferencesRowHealthKit: {
            BOOL hkEnabled = [[self healthKitService] isHealthKitEnabled];
            BOOL canWrite = [[self healthKitService] canWriteSleepAnalysis];
            *value = hkEnabled && canWrite;
            *title = NSLocalizedString(@"settings.account.healthkit", nil);
            *icon = [UIImage imageNamed:@"settingsHealthIcon"];
            break;
        }
        case HEMPreferencesRowEnhancedAudio:
            *title = NSLocalizedString(@"settings.account.enhanced-audio", nil);
            *value = [[self accountService] isEnabled:SENPreferenceTypeEnhancedAudio];
            *icon = [UIImage imageNamed:@"settingsEnhancedAudioIcon"];
            break;
    }
}

- (NSAttributedString*)enhancedAudioNote {
    if (!_enhancedAudioNote) {
        NSString* note = NSLocalizedString(@"settings.enhanced-audio.desc", nil);
        NSDictionary* attributes = @{NSFontAttributeName : [UIFont settingsHelpFont],
                                     NSForegroundColorAttributeName : [UIColor grey4]};
        _enhancedAudioNote = [[NSAttributedString alloc] initWithString:note attributes:attributes];
    }
    return _enhancedAudioNote;
}

- (void)signOutIcon:(UIImage**)icon title:(NSString**)title {
    *title = NSLocalizedString(@"actions.sign-out", nil);
    *icon = [UIImage imageNamed:@"settingsSignOutIcon"];
}

- (UISwitch*)preferenceSwitch:(BOOL)enable forRow:(NSInteger)row {
    UISwitch *preferenceSwitch = [UISwitch new];
    [preferenceSwitch setOn:enable];
    [preferenceSwitch setTag:row];
    [preferenceSwitch setOnTintColor:[UIColor tintColor]];
    [preferenceSwitch addTarget:self
                         action:@selector(togglePreferenceSwitch:)
               forControlEvents:UIControlEventTouchUpInside];
    return preferenceSwitch;
}

#pragma mark - Preference Actions

- (void)togglePreferenceSwitch:(UISwitch*)control {
    [self setActivatedSwitch:control];
    
    switch ([control tag]) {
        case HEMPreferencesRowEnhancedAudio: {
            __weak typeof(self) weakSelf = self;
            [[self accountService] enablePreference:[control isOn]
                                            forType:SENPreferenceTypeEnhancedAudio
                                         completion:^(NSError * _Nonnull error) {
                                             if (error) {
                                                 // revert
                                                 [weakSelf showAccountUpdateError:error];
                                                 [control setOn:![control isOn]];
                                             }
                                         }];
            break;
        }
        case HEMPreferencesRowHealthKit:
            [self enableHealthKit:[control isOn]];
            break;
        default:
            break;
    }
}

- (void)enableHealthKit:(BOOL)enable {
    if (enable) {
        if (![[self healthKitService] isSupported]) {
            NSString* title = NSLocalizedString(@"settings.account.error.title.hk", nil);
            NSString* message = NSLocalizedString(@"settings.account.error.message.hk-not-supported", nil);
            [[self delegate] showErrorTitle:title message:message from:self];
            [[self activatedSwitch] setOn:NO animated:YES];
        } else {
            __weak typeof(self) weakSelf = self;
            [[self healthKitService] requestAuthorization:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!error) {
                    [[strongSelf healthKitService] setEnableHealthKit:enable];
                } else {
                    NSString* title = NSLocalizedString(@"settings.account.error.title.hk", nil);
                    NSString* message = NSLocalizedString(@"settings.account.error.message.hk-request-failed", nil);
                    [[strongSelf delegate] showErrorTitle:title message:message from:strongSelf];
                    [[strongSelf activatedSwitch] setOn:NO animated:YES];
                }
            }];
        }
    } else {
        [[self healthKitService] setEnableHealthKit:enable];
    }
}

#pragma mark - UITableViewDataSource / Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEMAccountTableCellBaseHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case HEMAccountSectionAccount:
            return 0.0f;
        default:
            return HEMSettingsHeaderFooterSectionHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == HEMAccountSectionPreferences ? HEMAccountTableCellEnhancedAudioNoteHeight : 0.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    HEMSettingsHeaderFooterView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    [footer setAttributedTitle:[self enhancedAudioNote]];
    [footer setTitleInsets:UIEdgeInsetsMake(HEMAccountAudioNoteVertMargin,
                                            HEMAccountAudioNoteHorzMargin,
                                            HEMAccountAudioNoteVertMargin,
                                            HEMAccountAudioNoteHorzMargin)];
    [footer setAdjustBasedOnTitle:YES];
    return footer;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL top = section != HEMAccountSectionSignOut;
    return [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:top bottomBorder:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return HEMAccountSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case HEMAccountSectionAccount:
            return HEMAccountRowCount;
        case HEMAccountSectionDemographics:
            return HEMDemographicsRowCount;
        case HEMAccountSectionUnits:
            return HEMUnitsRowCount;
        case HEMAccountSectionPreferences:
            return HEMPreferencesRowCount;
        case HEMAccountSectionSignOut:
            return HEMSignOutRowCount;
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* reuseId = nil;
    switch ([indexPath section]) {
        case HEMAccountSectionPreferences:
            reuseId = [HEMSettingsStoryboard preferenceReuseIdentifier];
            break;
        case HEMAccountSectionSignOut:
            reuseId = [HEMSettingsStoryboard signoutReuseIdentifier];
            break;
        default:
            reuseId = [HEMSettingsStoryboard infoReuseIdentifier];
            break;
    }
    
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor* textColor = [UIColor settingsTextColor];
    NSInteger row = [indexPath row];
    NSInteger rows = 1;
    UIImage* icon = nil;
    NSString* title = nil;
    NSString* value = nil;
    BOOL booleanValue = NO;
    BOOL showAccessory = NO;
    
    switch ([indexPath section]) {
        default:
        case HEMAccountSectionAccount: {
            [self accountIcon:&icon title:&title atRow:row];
            showAccessory = YES;
            rows = HEMAccountRowCount;
            break;
        }
        case HEMAccountSectionDemographics:
            [self demographicsIcon:&icon title:&title value:&value atRow:row];
            rows = HEMDemographicsRowCount;
            showAccessory = YES;
            break;
        case HEMAccountSectionUnits:
            [self unitsIcon:&icon title:&title atRow:row];
            rows = HEMUnitsRowCount;
            showAccessory = YES;
            break;
        case HEMAccountSectionPreferences: {
            [self preferencesIcon:&icon title:&title enabled:&booleanValue atRow:row];
            showAccessory = YES;
            UISwitch* control = [self preferenceSwitch:booleanValue forRow:row];
            [cell setAccessoryView:control];
            rows = HEMPreferencesRowCount;
            break;
        }
        case HEMAccountSectionSignOut:
            [self signOutIcon:&icon title:&title];
            textColor = [UIColor redColor];
            rows = HEMSignOutRowCount;
            break;
    }
    
    [cell showStyledAccessoryViewIfNone];
    [[cell textLabel] setFont:[UIFont settingsTableCellFont]];
    [[cell textLabel] setTextColor:textColor];
    [[cell detailTextLabel] setTextColor:[UIColor settingsDetailTextColor]];
    [[cell detailTextLabel] setFont:[UIFont settingsTableCellDetailFont]];
    [[cell detailTextLabel] setText:nil];
    [[cell accessoryView] setHidden:!showAccessory];
    [[cell textLabel] setText:title];
    [[cell imageView] setImage:icon];
    [[cell detailTextLabel] setText:value];
    
    if ([cell isKindOfClass:[HEMBasicTableViewCell class]]) {
        HEMBasicTableViewCell* basicCell = (id) cell;
        [basicCell showSeparator:row != rows - 1];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    // not all cells are "tappable"
    switch (section) {
        case HEMAccountSectionSignOut:
            [self handleSignOutRequest];
            break;
        case HEMAccountSectionAccount: {
            switch (row) {
                default:
                case HEMAccountRowName:
                    [self handleNameChangeRequest];
                    break;
                case HEMAccountRowEmail:
                    [self handleEmailChangeRequest];
                    break;
                case HEMAccountRowPassword:
                    [self handlePasswordChangeRequest];
                    break;
            }
            break;
        }
        case HEMAccountSectionDemographics:
            switch (row) {
                default:
                case HEMDemographicsRowBirthday:
                    [self handleBirthdateChangeRequest];
                    break;
                case HEMDemographicsRowGender:
                    [self handleGenderChangeRequest];
                    break;
                case HEMDemographicsRowHeight:
                    [self handleHeightChangeRequest];
                    break;
                case HEMDemographicsRowWeight:
                    [self handleWeightChangeRequest];
                    break;
            }
            break;
        case HEMAccountSectionUnits:
            [self handleUnitsChangeRequest];
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Actions

- (void)handleSignOutRequest {
    NSString* title = NSLocalizedString(@"actions.sign-out", nil);
    NSString* message = NSLocalizedString(@"settings.sign-out.confirmation", nil);

    __weak typeof(self) weakSelf = self;
    [[self delegate] showSignOutConfirmation:title messasge:message action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* signOutText = NSLocalizedString(@"account.signing-out", nil);
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        [activityView showInView:[strongSelf activityContainer] withText:signOutText activity:YES completion:^{
            [SENAuthorizationService deauthorize:^(NSError* error) {
                if (error) {
                    [SENAnalytics trackError:error];
                    [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        NSString* title = NSLocalizedString(@"account.error.sign-out.title", nil);
                        NSString* message = NSLocalizedString(@"account.error.sign-out.message", nil);
                        [[strongSelf delegate] showErrorTitle:title message:message from:strongSelf];
                    }];
                } else {
                    [SENAnalytics track:kHEMAnalyticsEventSignOut];
                }
            }];
        }];
    } from:self];
}

- (void)handleNameChangeRequest {
    HEMNameChangePresenter* presenter
        = [[HEMNameChangePresenter alloc] initWithAccountService:[self accountService]];
    HEMFormViewController* formVC = [HEMSettingsStoryboard instantiateFormViewController];
    [formVC setPresenter:presenter];
    [formVC setTitle:NSLocalizedString(@"settings.account.name.update.title", nil)];
    [[self delegate] presentViewController:formVC from:self];
}

- (void)handleEmailChangeRequest {
    HEMEmailChangePresenter* presenter
    = [[HEMEmailChangePresenter alloc] initWithAccountService:[self accountService]];
    HEMFormViewController* formVC = [HEMSettingsStoryboard instantiateFormViewController];
    [formVC setPresenter:presenter];
    [formVC setTitle:NSLocalizedString(@"settings.account.email.update.title", nil)];
    [[self delegate] presentViewController:formVC from:self];
}

- (void)handlePasswordChangeRequest {
    HEMPasswordChangePresenter* presenter
    = [[HEMPasswordChangePresenter alloc] initWithAccountService:[self accountService]];
    HEMFormViewController* formVC = [HEMSettingsStoryboard instantiateFormViewController];
    [formVC setPresenter:presenter];
    [formVC setTitle:NSLocalizedString(@"settings.account.password.update.title", nil)];
    [[self delegate] presentViewController:formVC from:self];
}

- (HEMAccountUpdateHandler)accountUpdateHandler {
    __weak typeof(self) weakSelf = self;
    return ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf showAccountUpdateError:error];
        } else {
            [[strongSelf tableView] reloadData];
        }
        [[strongSelf delegate] dismissViewControllerFrom:strongSelf completion:nil];
    };
}

#pragma mark Birthday

- (void)handleBirthdateChangeRequest {
    __weak typeof(self) weakSelf = self;
    HEMAccountUpdateDelegate* delegate = [HEMAccountUpdateDelegate new];
    [delegate setUpdateBlock:^(SENAccount * _Nonnull tempAccount) {
        [[weakSelf accountService] updateBirthdate:[tempAccount birthdate]
                                        completion:[weakSelf accountUpdateHandler]];
    } cancel:^{
        [[weakSelf delegate] dismissViewControllerFrom:weakSelf completion:nil];
    }];
     
    HEMBirthdatePickerViewController* vc = [HEMOnboardingStoryboard instantiateDobViewController];
    [vc setUpdateDelegate:delegate];
    
    NSDateComponents* components = [[[self accountService] account] birthdateComponents];
    if (components) {
        NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSInteger year = [[calendar components:NSCalendarUnitYear fromDate:[NSDate date]] year];
        [vc setInitialYear:year - [components year]];
        [vc setInitialMonth:[components month]];
        [vc setInitialDay:[components day]];
    }
    
    [[self delegate] presentViewController:vc from:self];
}

#pragma mark Gender

- (void)handleGenderChangeRequest {
    __weak typeof(self) weakSelf = self;
    HEMAccountUpdateDelegate* delegate = [HEMAccountUpdateDelegate new];
    [delegate setUpdateBlock:^(SENAccount * _Nonnull tempAccount) {
        [[weakSelf accountService] updateGender:[tempAccount gender]
                                     completion:[weakSelf accountUpdateHandler]];
    } cancel:^{
        [[weakSelf delegate] dismissViewControllerFrom:weakSelf completion:nil];
    }];
    
    SENAccount* account = [[self accountService] account];
    HEMGenderPickerViewController *genderPicker = (id)[HEMOnboardingStoryboard instantiateGenderPickerViewController];
    [genderPicker setDefaultGender:[account gender]];
    [genderPicker setDelegate:delegate];
    
    [[self delegate] presentViewController:genderPicker from:self];
}

#pragma mark Height

- (void)handleHeightChangeRequest {
    __weak typeof(self) weakSelf = self;
    HEMAccountUpdateDelegate* delegate = [HEMAccountUpdateDelegate new];
    [delegate setUpdateBlock:^(SENAccount * _Nonnull tempAccount) {
        [[weakSelf accountService] updateHeight:[tempAccount height]
                                     completion:[weakSelf accountUpdateHandler]];
    } cancel:^{
        [[weakSelf delegate] dismissViewControllerFrom:weakSelf completion:nil];
    }];
    
    SENAccount* account = [[self accountService] account];
    HEMHeightPickerViewController *heightPicker = (id)[HEMOnboardingStoryboard instantiateHeightPickerViewController];
    [heightPicker setHeightInCm:[account height]];
    [heightPicker setDelegate:delegate];
    
    [[self delegate] presentViewController:heightPicker from:self];
}

#pragma mark Weight

- (void)handleWeightChangeRequest {
    __weak typeof(self) weakSelf = self;
    HEMAccountUpdateDelegate* delegate = [HEMAccountUpdateDelegate new];
    [delegate setUpdateBlock:^(SENAccount * _Nonnull tempAccount) {
        [[weakSelf accountService] updateWeight:[tempAccount weight]
                                     completion:[weakSelf accountUpdateHandler]];
    } cancel:^{
        [[weakSelf delegate] dismissViewControllerFrom:weakSelf completion:nil];
    }];
    
    SENAccount* account = [[self accountService] account];
    HEMWeightPickerViewController *weightPicker = (id)[HEMOnboardingStoryboard instantiateWeightPickerViewController];
    [weightPicker setDefaultWeightInGrams:[account weight]];
    [weightPicker setDelegate:delegate];
    
    [[self delegate] presentViewController:weightPicker from:self];
}

#pragma mark - Units

- (void)handleUnitsChangeRequest {
    id prefVC = [HEMSettingsStoryboard instantiateUnitPreferenceViewController];
    [[self delegate] presentViewController:prefVC from:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
