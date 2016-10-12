//
//  HEMSettingsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>

#import "HEMSettingsPresenter.h"
#import "HEMDeviceService.h"
#import "HEMExpansionService.h"
#import "HEMAccountService.h"
#import "HEMBreadcrumbService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMMainStoryboard.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMTellAFriendItemProvider.h"
#import "HEMStyle.h"

static CGFloat const HEMSettingsSectionHeaderHeight = 12.0f;
static CGFloat const HEMSettingsBottomMargin = 10.0f;

typedef NS_ENUM(NSUInteger, HEMSettingsSection) {
    HEMSettingsSectionAccount = 0,
    HEMSettingsSectionExpansion,
    HEMSettingsSectionSupport,
    HEMSettingsSectionShare,
    HEMSettingsSections
};

typedef NS_ENUM(NSUInteger, HEMSettingsAccountRow) {
    HEMSettingsAccountRowProfile = 0,
    HEMSettingsAccountRowDevices,
    HEMSettingsAccountRowNotifications,
    HEMSettingsAccountRowPreferences,
    HEMSettingsAccountRowCount
};

typedef NS_ENUM(NSUInteger, HEMSettingsExpansionRow) {
    HEMSettingsExpansionRowExpansion = 0,
    HEMSettingsExpansionRowCount
};

typedef NS_ENUM(NSUInteger, HEMSettingsSupportRow) {
    HEMSettingsSupportRowSupport = 0,
    HEMSettingsSupportRowCount
};

typedef NS_ENUM(NSUInteger, HEMSettingsShareRow) {
    HEMSettingsShareRowTellFriend = 0,
    HEMSettingsShareRowCount
};

@interface HEMSettingsPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) HEMBreadcrumbService* breadcrumbService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, strong) NSArray<NSNumber*>* sections;
@property (nonatomic, strong) UIView* versionView;
@property (nonatomic, weak) UILabel* versionLabel;

@end

@implementation HEMSettingsPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService
                     expansionService:(HEMExpansionService*)expansionService
                    breadCrumbService:(HEMBreadcrumbService*)breadcrumbService {
    if (self = [super init]) {
        _deviceService = deviceService;
        _expansionService = expansionService;
        _breadcrumbService = breadcrumbService;
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    CGFloat width = CGRectGetWidth([[tableView superview] bounds]);
    
    // header
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = width;
    [tableView setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    
    // add footer after sections are loaded
    [tableView setTableFooterView:[self versionView]];
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [self setTableView:tableView];
}

- (void)bindWithActivityView:(HEMActivityIndicatorView*)activityView {
    [activityView start];
    [activityView setHidden:NO];
    [self setIndicatorView:activityView];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [self refreshSections];
}

#pragma mark - Presentation logic

- (UIView*)versionView {
    if (!_versionView) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *vers = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *versionText = [NSString stringWithFormat:@"%@ %@", name, vers];
        
        UILabel *versionLabel = [UILabel new];
        [versionLabel setText:versionText];
        [versionLabel setContentMode:UIViewContentModeBottom];
        [versionLabel setTextAlignment:NSTextAlignmentCenter];
        [versionLabel setFont:[UIFont settingsHelpFont]];
        [versionLabel setTextColor:[UIColor textColor]];
        
        UIView* containerView = [UIView new];
        [containerView addSubview:versionLabel];
        [containerView setHidden:YES];
        
        _versionView = containerView;
        _versionLabel = versionLabel;
    }
    return _versionView;
}

- (void)layoutVersionView {
    [[self versionLabel] sizeToFit];
    
    CGRect versionLabelFrame = [[self versionLabel] frame];
    CGRect versionViewFrame = [[self versionView] frame];
    
    [[self versionView] sizeToFit];

    CGFloat versionRequiredHeight = CGRectGetHeight([[self versionLabel] frame]);
    CGFloat contentHeight = [[self tableView] contentSize].height;
    CGFloat tableHeight = CGRectGetHeight([[self tableView] bounds]);
    CGFloat tableWidth = CGRectGetWidth([[self tableView] bounds]);
    CGFloat minSpacing = HEMSettingsSectionHeaderHeight;
    
    CGFloat spaceAtBottom = tableHeight - contentHeight - HEMSettingsBottomMargin;
    CGFloat versionHeight = MAX(minSpacing + versionRequiredHeight, spaceAtBottom);
    
    versionLabelFrame.origin.y = versionHeight - versionRequiredHeight;
    versionLabelFrame.origin.x = (tableWidth - CGRectGetWidth([[self versionLabel] bounds])) / 2;
    [[self versionLabel] setFrame:versionLabelFrame];
    
    versionViewFrame.size.height = versionHeight;
    versionViewFrame.size.width = tableWidth;
    [[self versionView] setFrame:versionViewFrame];
}

- (void)refreshSections {
    if (![self sections]) {
        [[self indicatorView] start];
        [[self indicatorView] setHidden:NO];
    }
    
    __weak typeof(self) weakSelf = self;
    void(^refresh)(SENSenseHardware version) = ^(SENSenseHardware version) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray* sections = [NSMutableArray arrayWithCapacity:HEMSettingsSections];
        [sections addObject:@(HEMSettingsSectionAccount)];
        if ([[strongSelf expansionService] isEnabledForHardware:version]) {
            [sections addObject:@(HEMSettingsSectionExpansion)];
        }
        [sections addObject:@(HEMSettingsSectionSupport)];
        [sections addObject:@(HEMSettingsSectionShare)];
        [strongSelf setSections:sections];
        [[strongSelf indicatorView] stop];
        [[strongSelf indicatorView] setHidden:YES];
        [[strongSelf tableView] reloadData];
        [strongSelf layoutVersionView];
        [[strongSelf versionView] setHidden:NO];
    };
    
    SENSenseHardware savedVersion = [[self deviceService] savedHardwareVersion];
    if (savedVersion != SENSenseHardwareUnknown) {
        refresh (savedVersion);
    } else {
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            refresh ([[devices senseMetadata] hardwareVersion]);
        }];
    }
}

- (BOOL)showIndicatorForCrumb:(NSString*)crumb {
    NSString* topCrumb = [[self breadcrumbService] peek];
    return [topCrumb isEqualToString:crumb];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
   HEMSettingsSection dynaSection = [[self sections][[indexPath section]] unsignedIntegerValue];
    NSInteger row = [indexPath row];
    
    if (dynaSection == HEMSettingsSectionAccount) {
        switch (row) {
            default:
            case HEMSettingsAccountRowProfile:
                return NSLocalizedString(@"settings.account", nil);
            case HEMSettingsAccountRowDevices:
                return NSLocalizedString(@"settings.devices", nil);
            case HEMSettingsAccountRowNotifications:
                return NSLocalizedString(@"settings.notifications", nil);
            case HEMSettingsAccountRowPreferences:
                return NSLocalizedString(@"settings.units", nil);
        }
    } else if (dynaSection == HEMSettingsSectionExpansion) {
        return NSLocalizedString(@"settings.expansions", nil);
    } else if (dynaSection == HEMSettingsSectionSupport) {
        return NSLocalizedString(@"settings.support", nil);
    } else if (dynaSection == HEMSettingsSectionShare) {
        return NSLocalizedString(@"settings.tell-a-friend", nil);
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    HEMSettingsSection dynaSection = [[self sections][section] unsignedIntegerValue];
    switch (dynaSection) {
        case HEMSettingsSectionAccount:
            return HEMSettingsAccountRowCount;
        case HEMSettingsSectionExpansion:
            return HEMSettingsExpansionRowCount;
        case HEMSettingsSectionSupport:
            return HEMSettingsSupportRowCount;
        case HEMSettingsSectionShare:
            return HEMSettingsShareRowCount;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    HEMSettingsSection dynaSection = [[self sections][section] unsignedIntegerValue];
    switch (dynaSection) {
        case HEMSettingsSectionExpansion:
        case HEMSettingsSectionSupport:
        case HEMSettingsSectionShare:
            return HEMSettingsSectionHeaderHeight;
        case HEMSettingsSectionAccount:
        default:
            return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = [HEMMainStoryboard settingsCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    HEMSettingsSection dynaSection = [[self sections][section] unsignedIntegerValue];
    HEMSettingsTableViewCell *settingsCell = (HEMSettingsTableViewCell *)cell;
    [[settingsCell titleLabel] setText:[self titleForRowAtIndexPath:indexPath]];
    
    
    if (dynaSection == HEMSettingsSectionAccount
        && [indexPath row] == HEMSettingsAccountRowProfile) {
        BOOL show = [self showIndicatorForCrumb:HEMBreadcrumbAccount];
        [settingsCell showNewIndicator:show];
    } else {
        [settingsCell showNewIndicator:NO];
    }
    
    NSInteger numberOfRows = [tableView numberOfRowsInSection:section];
    
    if ([indexPath row] == 0 && [indexPath row] == numberOfRows - 1) {
        [settingsCell showTopAndBottomCorners];
    } else if ([indexPath row] == 0) {
        [settingsCell showTopCorners];
    } else if ([indexPath row] == numberOfRows - 1) {
        [settingsCell showBottomCorners];
    } else {
        [settingsCell showNoCorners];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    HEMSettingsSection dynaSection = [[self sections][section] unsignedIntegerValue];
    
    if (dynaSection == HEMSettingsSectionShare) {
        [self tellAFriend];
    } else {
        HEMSettingsCategory category = [self categoryForSection:dynaSection andRow:row];
        [[self delegate] didSelectSettingsCategory:category fromPresenter:self];
    }
}

#pragma mark - Actions

- (HEMSettingsCategory)categoryForSection:(HEMSettingsSection)section andRow:(NSInteger)row {
    if (section == HEMSettingsSectionAccount) {
        switch (row) {
            default:
            case HEMSettingsAccountRowProfile:
                return HEMSettingsCategoryProfile;
            case HEMSettingsAccountRowDevices:
                return HEMSettingsCategoryDevices;
            case HEMSettingsAccountRowNotifications:
                return HEMSettingsCategoryNotifications;
            case HEMSettingsAccountRowPreferences:
                return HEMSettingsCategoryPreferences;
        }
    } else if (section == HEMSettingsSectionExpansion) {
        return HEMSettingsCategoryExpansions;
    } else if (section == HEMSettingsSectionSupport) {
        return HEMSettingsCategorySupport;
    } else {
        return HEMSettingsCategoryTellFriend;
    }
}

- (void)tellAFriend {
    [SENAnalytics track:HEMAnalyticsEventTellAFriendTapped];
    
    NSString *subject = NSLocalizedString(@"settings.tell-a-friend.subject", nil);
    NSString *body = NSLocalizedString(@"settings.tell-a-friend.body", nil);
    HEMTellAFriendItemProvider *itemProvider = [[HEMTellAFriendItemProvider alloc] initWithSubject:subject
                                                                                              body:body];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[itemProvider]
                                                                                         applicationActivities:nil];
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error) {
        if (error) {
            DDLogError(@"Could not complete share action: %@", error);
        }
        
        if (completed) {
            NSString *type = activityType ?: @"Unknown";
            [SENAnalytics track:HEMAnalyticsEventTellAFriendCompleted
                     properties:@{HEMAnalyticsEventTellAFriendCompletedPropType : type}];
        }
    }];
    
    [[self delegate] showController:activityViewController fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end