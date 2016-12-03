//
//  HEMVoiceSettingsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENSenseVoiceSettings.h>

#import "NSString+HEMUtils.h"

#import "HEMVoiceSettingsPresenter.h"
#import "HEMVoiceService.h"
#import "HEMDeviceService.h"
#import "HEMSettingsStoryboard.h"
#import "HEMStyle.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMActivityCoverView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAlertViewController.h"
#import "HEMBasicTableViewCell.h"
#import "HEMVolumeControlPresenter.h"

typedef NS_ENUM(NSUInteger, HEMVoiceSettingsRow){
    HEMVoiceSettingsRowVolume = 0,
    HEMVoiceSettingsRowMute,
    HEMVoiceSettingsRowPrimaryUser,
    HEMVoiceSettingsRowCount
};

static CGFloat const kHEMVoiceSettingsCellHeight = 56.0f;
static CGFloat const kHEMVoiceSettingsCellTextMargin = 24.0f;
static CGFloat const kHEMVoiceFootNoteHorzMargins = 24.0f;
static CGFloat const kHEMVoiceFootNoteVertMargins = 12.0f;

@interface HEMVoiceSettingsPresenter() <
    UITableViewDelegate,
    UITableViewDataSource,
    HEMVolumeControlUpdateDelegate
>

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) NSError* dataError;
@property (nonatomic, strong) SENSenseVoiceSettings* voiceSettings;

@end

@implementation HEMVoiceSettingsPresenter

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService
                       deviceService:(HEMDeviceService*)deviceService {
    if (self = [super init]) {
        _voiceService = voiceService;
        _deviceService = deviceService;
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    [tableView setSeparatorColor:[UIColor separatorColor]];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    HEMSettingsHeaderFooterView* headerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    HEMSettingsHeaderFooterView* footerView = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
    NSString* footNote = NSLocalizedString(@"voice.settings.primary-user.foot.note", nil);
    NSDictionary* attrs = @{NSFontAttributeName : [UIFont h7Bold],
                            NSForegroundColorAttributeName : [UIColor grey3]};
    NSAttributedString* attributedFootNote = [[NSAttributedString alloc] initWithString:footNote attributes:attrs];
    [footerView setAttributedTitle:attributedFootNote];
    [footerView setTitleInsets:UIEdgeInsetsMake(kHEMVoiceFootNoteVertMargins,
                                                kHEMVoiceFootNoteHorzMargins,
                                                kHEMVoiceFootNoteVertMargins,
                                                kHEMVoiceFootNoteHorzMargins)];
    [footerView setAdjustBasedOnTitle:YES];
    
    [tableView setTableHeaderView:headerView];
    [tableView setTableFooterView:footerView];
    [tableView setHidden:YES];
    [self setTableView:tableView];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    [navItem setTitle:NSLocalizedString(@"settings.voice", nil)];
}

- (void)bindWithActivityContainer:(UIView*)activityContainer {
    [self setActivityContainerView:activityContainer];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicatorView {
    [activityIndicatorView start];
    [activityIndicatorView setHidden:NO];
    [self setActivityIndicatorView:activityIndicatorView];
}

#pragma mark - Presenter events

- (void)didRelayout {
    [super didRelayout];
    
    UIView* footer = [[self tableView] tableFooterView];
    [footer sizeToFit];
    [[self tableView] setTableFooterView:footer];
}

- (void)didAppear {
    [super didAppear];
    [self updateUI];
}

#pragma mark - Data

- (void)updateUI {
    __weak typeof(self) weakSelf = self;
    void(^reload)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setDataError:error];
        [[[strongSelf tableView] tableFooterView] setHidden:error != nil];
        [[strongSelf tableView] setHidden:NO];
        [[strongSelf tableView] reloadData];
        [[strongSelf activityIndicatorView] stop];
        [[strongSelf activityIndicatorView] setHidden:YES];
    };
    
    void(^loadVoiceSettings)(SENSenseMetadata* senseMetadata) = ^(SENSenseMetadata* senseMetadata) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* senseId = [senseMetadata uniqueId];
        [[strongSelf voiceService] getVoiceSettingsForSenseId:senseId completion:^(id response, NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setVoiceSettings:response];
            reload(error);
        }];
    };
    
    if ([[[self deviceService] devices] senseMetadata]) {
        loadVoiceSettings([[[self deviceService] devices] senseMetadata]);
    } else {
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            if (error) {
                reload(error);
            } else {
                loadVoiceSettings([devices senseMetadata]);
            }
        }];
    }
}

- (NSString*)dataErrorMessage {
    NSString* errorMessage = [[self dataError] localizedDescription];
    if ([errorMessage length] == 0) {
        errorMessage = NSLocalizedString(@"voice.settings.error.message", nil);
    }
    return errorMessage;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self dataError] ? 1 : HEMVoiceSettingsRowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    CGFloat height = kHEMVoiceSettingsCellHeight;
    if (row == 0 && [self dataError]) {
        NSString* message = [self dataErrorMessage];
        CGFloat margins = kHEMVoiceSettingsCellTextMargin * 2.0f;
        CGFloat textWidth = CGRectGetWidth([tableView bounds]) - margins;
        height = [message heightBoundedByWidth:textWidth usingFont:[UIFont body]];
        height += margins;
    }
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    if ([self dataError]) {
        reuseId = [HEMSettingsStoryboard errorReuseIdentifier];
    } else if ([indexPath row] != HEMVoiceSettingsRowMute) {
        reuseId = [HEMSettingsStoryboard voiceSettingCellReuseIdentifier];
    } else {
        reuseId = [HEMSettingsStoryboard switchReuseIdentifier];
    }
    return [tableView dequeueReusableCellWithIdentifier:reuseId
                                           forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self dataError] && [indexPath row] == 0) {
        [[cell textLabel] setText:[self dataErrorMessage]];
        [[cell textLabel] setFont:[UIFont body]];
        [[cell textLabel] setTextColor:[UIColor grey4]];
        [[cell textLabel] setNumberOfLines:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell sizeToFit];
    } else if (![self dataError]) {
        HEMBasicTableViewCell* basicCell = (id) cell;
        
        BOOL showCustomAccessory = YES;
        NSString* title = nil;
        NSString* detail = nil;
        UIColor* detailColor = [UIColor grey4];
        UITableViewCellSelectionStyle selectionStyle = UITableViewCellSelectionStyleGray;
        
        switch ([indexPath row]) {
            default:
            case HEMVoiceSettingsRowVolume: {
                title = NSLocalizedString(@"voice.settings.volume", nil);
                NSInteger volumeLevel = [[self voiceService] volumeLevelFrom:[self voiceSettings]];
                detail = [NSString stringWithFormat:@"%ld", volumeLevel];
                break;
            }
            case HEMVoiceSettingsRowMute: {
                title = NSLocalizedString(@"voice.settings.mute", nil);
                selectionStyle = UITableViewCellSelectionStyleNone;
                
                UISwitch* control = (UISwitch*) [basicCell customAccessoryView];
                [control setOnTintColor:[UIColor tintColor]];
                [control setOn:[[self voiceSettings] isMuted]];
                [control addTarget:self
                            action:@selector(toggleMute:)
                  forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case HEMVoiceSettingsRowPrimaryUser: {
                title = NSLocalizedString(@"voice.settings.primary-user", nil);

                if ([[self voiceSettings] isPrimaryUser]) {
                    detail = NSLocalizedString(@"voice.settings.primary-user.you", nil);
                    selectionStyle = UITableViewCellSelectionStyleNone;
                    showCustomAccessory = NO;
                } else {
                    detail = NSLocalizedString(@"voice.settings.primary-user.change", nil);
                    detailColor = [UIColor tintColor];
                }
                break;
            }
        }
        
        [[basicCell customTitleLabel] setText:title];
        [[basicCell customTitleLabel] setFont:[UIFont body]];
        [[basicCell customTitleLabel] setTextColor:[UIColor grey6]];
        [[basicCell customDetailLabel] setText:detail];
        [[basicCell customDetailLabel] setFont:[UIFont body]];
        [[basicCell customDetailLabel] setTextColor:detailColor];
        [basicCell showCustomAccessoryView:showCustomAccessory];
        [basicCell setSelectionStyle:selectionStyle];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![self dataError]) {
        switch ([indexPath row]) {
            case HEMVoiceSettingsRowVolume:
                return [self changeVolume];
            case HEMVoiceSettingsRowPrimaryUser:
                if (![[self voiceSettings] isPrimaryUser]) {
                    return [self showPrimaryUserConfirmation];
                } else {
                    return;
                }
            default:
                return;
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Updates

- (void)update:(SENSenseVoiceSettings*)info
messageIfError:(NSString*)errorMessage
    completion:(void(^)(BOOL updated))completion {
    __weak typeof(self) weakSelf = self;
    
    SENSenseMetadata* metadata = [[[self deviceService] devices] senseMetadata];

    NSString* activityText = NSLocalizedString(@"voice.settings.update.status", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[self activityContainerView] withText:activityText activity:YES completion:^{
        [[self voiceService] updateVoiceSettings:info
                                      forSenseId:[metadata uniqueId]
                                      completion:^(SENSenseVoiceSettings* updated) {
                                          __strong typeof(weakSelf) strongSelf = weakSelf;
                                          if (completion) {
                                              completion (updated != nil);
                                          }
                                      
                                          if (!updated) {
                                              [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                                                  [strongSelf showUpdateError:errorMessage];
                                              }];
                                          } else {
                                              [strongSelf setVoiceSettings:updated];
                                              [[strongSelf tableView] reloadData];
                                              NSString* successText = NSLocalizedString(@"status.success", nil);
                                              [activityView dismissWithResultText:successText showSuccessMark:YES remove:YES completion:nil];
                                          }
                                      }];
    }];
}

#pragma mark - Mute

- (void)toggleMute:(UISwitch*)control {
    NSString* errorMessage = NSLocalizedString(@"voice.settings.update.error.mute-not-changed", nil);
    BOOL mute = [control isOn];
    
    SENSenseVoiceSettings* muteSettings = [SENSenseVoiceSettings new];
    [muteSettings setMuted:@(mute)];
    
    __block SENSenseVoiceSettings* voiceSettings = [self voiceSettings];

    [self update:muteSettings messageIfError:errorMessage completion:^(BOOL updated) {
        if (!updated) {
            [control setOn:!mute];
        } else {
            [voiceSettings setMuted:@(!mute)];
        }
    }];
}

#pragma mark - Primary User

- (void)showPrimaryUserConfirmation {
    NSString* title = NSLocalizedString(@"voice.settings.primary-user.confirm.title", nil);
    NSString* message = NSLocalizedString(@"voice.settings.primary-user.confirm.message", nil);
    
    __weak typeof(self) weakSelf = self;
    HEMAlertViewController *dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"voice.settings.primary-user.confirm.ok", nil)
                           style:HEMAlertViewButtonStyleRoundRect
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              [strongSelf setAsPrimary];
                          }];
    
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil)
                           style:HEMAlertViewButtonStyleBlueText
                          action:nil];
    
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
}

- (void)setAsPrimary {
    NSString* errorMessage = NSLocalizedString(@"voice.settings.update.error.primary-not-set", nil);
    
    SENSenseVoiceSettings* primarySettings = [SENSenseVoiceSettings new];
    [primarySettings setPrimaryUser:@YES];
    
    __block SENSenseVoiceSettings* voiceSettings = [self voiceSettings];

    [self update:primarySettings messageIfError:errorMessage completion:^(BOOL updated) {
        if (updated) {
            [voiceSettings setPrimaryUser:@YES];
        }
    }];
}

#pragma mark - Volume

- (void)changeVolume {
    SENSenseMetadata* metadata = [[[self deviceService] devices] senseMetadata];
    HEMVolumeControlPresenter* presenter =
    [[HEMVolumeControlPresenter alloc] initWithVoiceSettings:[self voiceSettings]
                                                     senseId:[metadata uniqueId]
                                                voiceService:[self voiceService]];
    [presenter setUpdateDelegate:self];
    [[self delegate] showVolumeControlWithPresenter:presenter
                                      fromPresenter:self];
}

#pragma mark - HEMVolumeControlUpdateDelegate

- (void)updatedVolumeFromPresenter:(HEMVolumeControlPresenter *)presenter {
    [self updateUI];
}

#pragma mark - Error

- (void)showUpdateError:(NSString*)message {
    NSString* title = NSLocalizedString(@"voice.settings.update.error.title", nil);
    [[self errorDelegate] showErrorWithTitle:title
                                  andMessage:message
                                withHelpPage:nil
                               fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
