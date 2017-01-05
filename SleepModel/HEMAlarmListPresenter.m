//
//  HEMAlarmListPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 6/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>
#import <SenseKit/SENLocalPreferences.h>

#import "NSMutableAttributedString+HEMFormat.h"
#import "NSString+HEMUtils.h"

#import "HEMAlarmListPresenter.h"
#import "HEMSubNavigationView.h"
#import "HEMAlarmService.h"
#import "HEMNavigationShadowView.h"
#import "NSString+HEMUtils.h"
#import "HEMAlarmListCell.h"
#import "HEMStyle.h"
#import "HEMMarkdown.h"
#import "HEMMainStoryboard.h"
#import "HEMNoAlarmCell.h"
#import "HEMActionButton.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMAlarmAddButton.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAlarmCache.h"
#import "HEMAlarmExpansionListCell.h"
#import "HEMExpansionService.h"
#import "HEMDeviceService.h"
#import "HEMSenseRequiredCollectionViewCell.h"

static CGFloat const HEMAlarmListButtonMinimumScale = 0.95f;
static CGFloat const HEMAlarmListButtonMaximumScale = 1.2f;
static CGFloat const HEMAlarmListCellHeight = 96.f;
static CGFloat const HEMAlarmListNoAlarmCellBaseHeight = 292.0f;
static CGFloat const HEMAlarmListPairViewHeight = 352.0f;
static CGFloat const HEMAlarmListItemSpacing = 8.f;
static NSString* const HEMAlarmListTimeKey = @"alarms.alarm.meridiem.%@";
static NSString* const HEMAlarmListErrorDomain = @"is.hello.app.alarm";

typedef NS_ENUM(NSInteger, HEMAlarmListErrorCode) {
    HEMAlarmListErrorCodeNoSense = -1
};

@interface HEMAlarmListPresenter() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) HEMSubNavigationView* subNav;
@property (nonatomic, weak) HEMAlarmAddButton* addButton;
@property (nonatomic, strong) HEMActivityIndicatorView* addButtonActivityIndicator;
@property (nonatomic, weak) HEMActivityIndicatorView* dataLoadingIndicator;
@property (nonatomic, strong) NSAttributedString* attributedNoAlarmText;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSError* loadError;
@property (nonatomic, strong) NSDateFormatter *hour24Formatter;
@property (nonatomic, strong) NSDateFormatter *hour12Formatter;
@property (nonatomic, strong) NSDateFormatter *meridiemFormatter;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) HEMAlarmService* alarmService;
@property (nonatomic, weak) HEMDeviceService* deviceService;

@end

@implementation HEMAlarmListPresenter

- (instancetype)initWithAlarmService:(HEMAlarmService*)alarmService
                    expansionService:(HEMExpansionService*)expansionService
                       deviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
        _alarmService = alarmService;
        _expansionService = expansionService;
        _deviceService = deviceService;
        _hour12Formatter = [NSDateFormatter new];
        _hour12Formatter.dateFormat = @"hh:mm";
        _hour24Formatter = [NSDateFormatter new];
        _hour24Formatter.dateFormat = @"HH:mm";
        _meridiemFormatter = [NSDateFormatter new];
        _meridiemFormatter.dateFormat = @"a";
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    UICollectionViewFlowLayout *layout = (id)[collectionView collectionViewLayout];
    layout.minimumInteritemSpacing = HEMAlarmListItemSpacing;
    layout.minimumLineSpacing = HEMAlarmListItemSpacing;

    [collectionView setHidden:YES];
    [collectionView setBackgroundColor:[UIColor backgroundColor]];
    
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNav {
    [self setSubNav:subNav];
}

- (void)bindWithAddButton:(HEMAlarmAddButton*)addButton {
    [addButton setEnabled:YES];
    [addButton setTitle:@"" forState:UIControlStateDisabled];
    [addButton addTarget:self action:@selector(touchDownAddAlarmButton:) forControlEvents:UIControlEventTouchDown];
    [addButton addTarget:self action:@selector(touchUpOutsideAddAlarmButton:) forControlEvents:UIControlEventTouchUpOutside];
    [addButton addTarget:self action:@selector(addNewAlarm:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setAddButton:addButton];
    [[self addButton] setHidden:YES];
    [self setAddButtonActivityIndicator:[self activityIndicator]];
}

- (void)bindWithDataLoadingIndicator:(HEMActivityIndicatorView*)dataLoadingIndicator {
    [self setDataLoadingIndicator:dataLoadingIndicator];
}

- (void)update {
    [[self collectionView] reloadData];
    [self loadData];
}

#pragma mark - Add Alarm Button Animation

- (void)touchDownAddAlarmButton:(id)sender {
    [UIView animateWithDuration:0.05f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat scale = HEMAlarmListButtonMinimumScale;
                         [[[self addButton] layer] setTransform:CATransform3DMakeScale(scale, scale, 1.f)];
                     }
                     completion:NULL];
}

- (void)touchUpOutsideAddAlarmButton:(id)sender {
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[[self addButton] layer] setTransform:CATransform3DIdentity];
                     }
                     completion:NULL];
}

- (HEMActivityIndicatorView*)activityIndicator {
    CGSize buttonSize = [[self addButton] bounds].size;
    UIImage* indicatorImage = [UIImage imageNamed:@"loaderWhite"];
    CGRect indicatorFrame = CGRectZero;
    indicatorFrame.size = indicatorImage.size;
    indicatorFrame.origin.x = (buttonSize.width - indicatorImage.size.width) / 2.f;
    indicatorFrame.origin.y = (buttonSize.height - indicatorImage.size.height) / 2.f;
    return [[HEMActivityIndicatorView alloc] initWithImage:indicatorImage
                                                  andFrame:indicatorFrame];
}

- (void)hideAddButton {
    [[self addButton] setHidden:YES];
}

- (void)showAddButtonIfAllowed {
    [self showAddButtonAsLoading:NO];
    [[self addButton] setHidden:[[[self alarmService] alarms] count] == 0];
}

- (void)showAddButtonAsLoading:(BOOL)loading {
    if (loading) {
        [[self addButton] setEnabled:NO];
        [[self addButton] addSubview:[self addButtonActivityIndicator]];
        [[self addButtonActivityIndicator] start];
    } else {
        [[self addButton] setEnabled:YES];
        [[self addButtonActivityIndicator] stop];
        [[self addButtonActivityIndicator] removeFromSuperview];
    }
}

#pragma mark - Presenter Events

- (void)willAppear {
    [super willAppear];
    [self loadData];
    [self.collectionView reloadData];
}

- (void)willDisappear {
    [super willDisappear];
    [self touchUpOutsideAddAlarmButton:nil];
}

- (void)didAppear {
    [super didAppear];
    CGFloat offset = [[self collectionView] contentOffset].y;
    // if there is a subnav, we need to update the visibility in case the neighbor
    // updated the shared shadowview
    [[[self subNav] shadowView] updateVisibilityWithContentOffset:offset];
    [SENAnalytics track:kHEMAnalyticsEventAlarms];
}

- (void)wasRemovedFromParent {
    [super wasRemovedFromParent];
    [[self addButton] setHidden:YES];
}

- (void)didGainConnectivity {
    [super didGainConnectivity];
    [self loadData];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self loadData];
}

#pragma mark - Retrieving Data

- (void)loadData {
    if ([self isLoading]) {
        return;
    }
    
    [self setLoading:YES];
    [self setLoadError:nil];
    [self showDataLoadingIndicatorIfNeeded:YES];
    [self showAddButtonAsLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    void(^loadAlarms)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf alarmService] refreshAlarms:^(NSArray<SENAlarm *> * alarms, NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setLoading:NO];
            [strongSelf showDataLoadingIndicatorIfNeeded:NO];
            [strongSelf setLoadError:error];
            
            if (error) {
                [[strongSelf addButton] setHidden:YES];
                [[strongSelf collectionView] reloadData];
            } else {
                [strongSelf showAddButtonIfAllowed];
                [strongSelf setLoading:NO];
                [[strongSelf collectionView] reloadData];
                
                if ([[strongSelf delegate] respondsToSelector:@selector(didFinishLoadingDataFrom:)]) {
                    [[strongSelf delegate] didFinishLoadingDataFrom:strongSelf];
                }
            }
        }];
    };
    
    if (![[self deviceService] devices] || ![[[self deviceService] devices] hasPairedSense]) {
        [[self deviceService] refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            BOOL hasSense = [devices hasPairedSense];
            NSError* deviceError = error;
            if (deviceError || !hasSense) {
                if (!hasSense && !deviceError) {
                    deviceError = [NSError errorWithDomain:HEMAlarmListErrorDomain
                                                      code:HEMAlarmListErrorCodeNoSense
                                                  userInfo:nil];
                }
                [strongSelf setLoading:NO];
                [strongSelf showDataLoadingIndicatorIfNeeded:NO];
                [strongSelf setLoadError:deviceError];
                [[strongSelf addButton] setHidden:YES];
                [[strongSelf collectionView] reloadData];
            } else {
                loadAlarms();
            }
        }];
    } else {
        loadAlarms();
    }
    
}

- (void)showDataLoadingIndicatorIfNeeded:(BOOL)show {
    if (![[self alarmService] hasLoadedAlarms]) {
        if (show) {
            [[self dataLoadingIndicator] start];
            [[self dataLoadingIndicator] setHidden:NO];
            [[self collectionView] setHidden:YES];
        }
    }
    
    if (!show) {
        [[self dataLoadingIndicator] stop];
        [[self dataLoadingIndicator] setHidden:YES];
        [[self collectionView] setHidden:NO];
    }
}

#pragma mark - Error

- (BOOL)isNoSenseError:(NSError*)error {
    return error != nil
        && [[error domain] isEqualToString:HEMAlarmListErrorDomain]
        && [error code] == HEMAlarmListErrorCodeNoSense;
}

#pragma mark - Collection View Delegate / Data Source

- (NSAttributedString*)attributedNoAlarmText {
    if (!_attributedNoAlarmText) {
        NSMutableParagraphStyle *paraStyle = DefaultBodyParagraphStyle();
        [paraStyle setAlignment:NSTextAlignmentCenter];
        
        NSDictionary* attributes = @{NSFontAttributeName : [UIFont body],
                                     NSParagraphStyleAttributeName : paraStyle};
        
        NSString* text = NSLocalizedString(@"alarms.no-alarm.message", nil);
        _attributedNoAlarmText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    return _attributedNoAlarmText;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray* alarms = [[self alarmService] alarms];
    if (!alarms && ![self loadError]) {
        return 0;
    } else if ([[[self alarmService] alarms] count] > 0) {
        return [[[self alarmService] alarms] count];
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoSenseError:[self loadError]]) {
        return [self collectionView:collectionView pairSenseCellAtIndexPath:indexPath];
    } else if ([self loadError]) {
        return [self collectionView:collectionView statusCellAtIndexPath:indexPath];
    } else if ([[[self alarmService] alarms] count] > 0) {
        SENAlarm* alarm = [[self alarmService] alarms][[indexPath row]];
        if ([[self alarmService] numberOfEnabledExpansionsIn:alarm]) {
            return [self collectionView:collectionView alarmExpansionCellAtIndexPath:indexPath];
        } else {
            return [self collectionView:collectionView alarmCellAtIndexPath:indexPath];
        }
    } else {
        return [self collectionView:collectionView emptyCellAtIndexPath:indexPath];
    }
}

- (NSAttributedString*)attributedExpansionTextFor:(SENAlarmExpansion*)expansion
                                         forAlarm:(SENAlarm*)alarm {
    SENExpansionValueRange range = [expansion targetRange];
    UIColor* titleColor = [alarm isOn] ? [UIColor grey6] : [UIColor grey4];
    NSDictionary* titleAttributes = @{NSFontAttributeName : [UIFont h7],
                                      NSForegroundColorAttributeName : titleColor};
    NSDictionary* valueAttributes = @{NSFontAttributeName : [UIFont h7],
                                      NSForegroundColorAttributeName : [UIColor grey4]};
    NSString* format = nil;
    NSArray* args = nil;
    
    switch ([expansion type]) {
        default:
        case SENExpansionTypeLights: {
            NSString* title = NSLocalizedString(@"alarm.light.title", nil);
            NSString* unitSymbol = NSLocalizedString(@"measurement.percentage.unit", nil);
            NSString* value = [NSString stringWithFormat:@"%.0f%@", range.max, unitSymbol];
            NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
            NSAttributedString* attributedValue = [[NSAttributedString alloc] initWithString:value attributes:valueAttributes];
            
            args = @[attributedTitle, attributedValue];
            format = NSLocalizedString(@"alarm.light.attribution.format", nil);
            break;
        }
        case SENExpansionTypeThermostat: {
            range = [[self expansionService] convertThermostatRangeBasedOnPreference:range];
            
            NSString* title = NSLocalizedString(@"alarm.thermostat.title", nil);
            NSAttributedString* attributedTitle =
                [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
            
            NSString* maxValue = [NSString stringWithFormat:@"%.0f", range.max];
            NSAttributedString* attributedMaxValue =
                [[NSAttributedString alloc] initWithString:maxValue attributes:valueAttributes];
            
            if (range.max == range.min) {
                format = NSLocalizedString(@"alarm.thermostat.attribution.format", nil);
                
                args = @[attributedTitle, attributedMaxValue];
            } else {
                format = NSLocalizedString(@"alarm.thermostat.attribution.range.format", nil);
                
                NSString* minValue = [NSString stringWithFormat:@"%.0f", range.min];
                NSAttributedString* attributedMinValue =
                    [[NSAttributedString alloc] initWithString:minValue attributes:valueAttributes];
                
                args = @[attributedTitle, attributedMinValue, attributedMaxValue];
            }

            break;
        }
    }
    
    return [[NSMutableAttributedString alloc] initWithFormat:format
                                                        args:args
                                                   baseColor:[UIColor grey4]
                                                    baseFont:[UIFont h7]];
    
}

- (UIImage*)iconForExpansion:(SENAlarmExpansion*)expansion {
    switch ([expansion type]) {
        case SENExpansionTypeThermostat:
            return [UIImage imageNamed:@"alarmThermostatIcon"];
        case SENExpansionTypeLights:
            return [UIImage imageNamed:@"alarmLightIcon"];
        default:
            return nil;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
           alarmExpansionCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmExpansionCellReuseIdentifier];
    HEMAlarmExpansionListCell* cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                  forIndexPath:indexPath];
    
    NSArray* alarms = [[self alarmService] alarms];
    SENAlarm *alarm = alarms[indexPath.item];

    for (SENAlarmExpansion* expansion in [alarm expansions]) {
        if ([expansion isEnable]) {
            [cell showExpansionWithIcon:[self iconForExpansion:expansion]
                                   text:[self attributedExpansionTextFor:expansion
                                                                forAlarm:alarm]
                                   tyep:[expansion type]];
        }
    }

    [[cell timeLabel] setTextColor:[UIColor grey5]];
    [[cell meridiemLabel] setTextColor:[UIColor grey5]];
    
    [self updateSwitchInCell:cell forAlarm:alarm atIndexPath:indexPath];
    [self updateDetailTextInCell:cell fromAlarm:alarm];
    [self updateTimeTextInCell:cell fromAlarm:alarm];
    
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    alarmCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListCellReuseIdentifier];
    HEMAlarmListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSArray* alarms = [[self alarmService] alarms];
    SENAlarm *alarm = alarms[indexPath.item];
    
    [self updateSwitchInCell:cell forAlarm:alarm atIndexPath:indexPath];
    [self updateDetailTextInCell:cell fromAlarm:alarm];
    [self updateTimeTextInCell:cell fromAlarm:alarm];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                    emptyCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListEmptyCellReuseIdentifier];
    HEMNoAlarmCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [[cell detailLabel] setAttributedText:[self attributedNoAlarmText]];
    [[cell alarmButton] addTarget:self action:@selector(addNewAlarm:) forControlEvents:UIControlEventTouchUpInside];
    [[cell alarmButton] setTitle:[NSLocalizedString(@"alarms.first-alarm.button-title", nil) uppercaseString]
                        forState:UIControlStateNormal];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
               pairSenseCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString *identifier = [HEMMainStoryboard pairReuseIdentifier];
    HEMSenseRequiredCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSString* buttonTitle = NSLocalizedString(@"actions.pair-sense", nil);
    NSString* message = NSLocalizedString(@"alarms.no-sense.description", nil);
    [[cell descriptionLabel] setText:message];
    [[cell pairSenseButton] addTarget:self
                               action:@selector(pairSense)
                     forControlEvents:UIControlEventTouchUpInside];
    [[cell pairSenseButton] setTitle:[buttonTitle uppercaseString]
                            forState:UIControlStateNormal];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                   statusCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmListStatusCellReuseIdentifier];
    HEMAlarmListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.detailLabel.text = NSLocalizedString(@"alarms.no-data", nil);
    return cell;
}

- (void)updateTimeTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm {
    UIColor* textColor = [alarm isOn] ? [UIColor grey6] : [UIColor grey4];
    cell.timeLabel.text = [self localizedTimeForAlarm:alarm];
    cell.timeLabel.textColor = textColor;
    cell.meridiemLabel.textColor = textColor;
    if (![[self alarmService] useMilitaryTimeFormat]) {
        NSString *meridiem = alarm.hour < 12 ? @"am" : @"pm";
        NSString *key = [NSString stringWithFormat:HEMAlarmListTimeKey, meridiem];
        cell.meridiemLabel.text = NSLocalizedString(key, nil);
    } else {
        cell.meridiemLabel.text = nil;
    }
}

- (void)updateSwitchInCell:(HEMAlarmListCell *)cell
                  forAlarm:(SENAlarm *)alarm
               atIndexPath:(NSIndexPath*)indexPath {
    cell.enabledSwitch.on = [alarm isOn];
    cell.enabledSwitch.tag = indexPath.item;
    [cell.enabledSwitch addTarget:self
                           action:@selector(toggleEnableSwitch:)
                 forControlEvents:UIControlEventValueChanged];
}

- (void)updateDetailTextInCell:(HEMAlarmListCell *)cell fromAlarm:(SENAlarm *)alarm {
    NSString *detailFormat;
    
    if ([alarm source] == SENAlarmSourceVoice) {
        detailFormat = NSLocalizedString(@"alarms.voice-alarm.format", nil);
    } else if ([alarm isSmartAlarm]) {
        detailFormat = NSLocalizedString(@"alarms.smart-alarm.format", nil);
    } else {
        detailFormat = NSLocalizedString(@"alarms.alarm.format", nil);
    }
    
    NSString *repeatText = [[self alarmService] localizedTextForRepeatFlags:alarm.repeatFlags];
    NSString *detailText = [[NSString stringWithFormat:detailFormat, repeatText] uppercaseString];
    NSDictionary *attributes = [HEMMarkdown attributesForBackViewTitle][@(PARA)];
    
    cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
}

- (NSString *)localizedTimeForAlarm:(SENAlarm *)alarm {
    NSString *const HEMAlarm12HourFormat = @"%ld:%@";
    NSString *const HEMAlarm24HourFormat = @"%02ld:%@";
    struct SENAlarmTime time = (struct SENAlarmTime){.hour = alarm.hour, .minute = alarm.minute };
    NSString *minuteText = [NSString stringWithFormat:@"%02ld", (long)time.minute];
    NSString* format = HEMAlarm24HourFormat;
    if (![[self alarmService] useMilitaryTimeFormat]) {
        format = HEMAlarm12HourFormat;
        if (time.hour > 12) {
            time.hour = (long)(time.hour - 12);
        } else if (time.hour == 0) {
            time.hour = 12;
        }
    }
    return [NSString stringWithFormat:format, time.hour, minuteText];
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self alarmService] alarms] count] > indexPath.item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SENAlarm *alarm = [[[self alarmService] alarms] objectAtIndex:indexPath.item];
    [[self delegate] didSelectAlarm:alarm fromPresenter:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat const HEMAlarmListEmptyCellBaseHeight = 98.f;
    static CGFloat const HEMAlarmListEmptyCellWidthInset = 32.f;
    UICollectionViewFlowLayout *layout = (id)collectionViewLayout;
    CGFloat width = layout.itemSize.width;
    NSInteger alarmCount = [[[self alarmService] alarms] count];
    
    if ([self loadError]) {
        BOOL noSense = [self isNoSenseError:[self loadError]];
        return CGSizeMake(width, noSense ? HEMAlarmListPairViewHeight : HEMAlarmListCellHeight);
    } else if ([[[self alarmService] alarms] count] > 0) {
        SENAlarm* alarm = [[self alarmService] alarms][[indexPath row]];
        CGFloat height = HEMAlarmListCellHeight;
        NSInteger expansions = [[self alarmService] numberOfEnabledExpansionsIn:alarm];
        CGFloat expansionHeight = expansions * kHEMAlarmExpansionViewHeight;
        return CGSizeMake(width, height + expansionHeight);
    } else if (alarmCount == 0) {
        NSAttributedString* attributedText = [self attributedNoAlarmText];
        CGFloat textHeight = [HEMNoAlarmCell heightWithDetail:attributedText cellWidth:width];
        return CGSizeMake(width, textHeight);
    }
    
    CGFloat textWidth = width - HEMAlarmListEmptyCellWidthInset;
    NSString *text = NSLocalizedString(@"alarms.no-alarm.message", nil);
    CGFloat textHeight = [text heightBoundedByWidth:textWidth usingFont:[UIFont body]];
    return CGSizeMake(width, textHeight + HEMAlarmListEmptyCellBaseHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = [scrollView contentOffset].y;
    if (![[self subNav] hasControls]) {
        [[self shadowView] updateVisibilityWithContentOffset:yOffset];
    } else {
        [[[self subNav] shadowView] updateVisibilityWithContentOffset:yOffset];
    }
}

#pragma mark - Actions

- (void)pairSense {
    [[self pairDelegate] pairSenseFrom:self];
}

- (void)addNewAlarm:(id)sender {
    if (![[self addButton] isEnabled]) {
        return;
    }

    if (![[self alarmService] canCreateMoreAlarms]) {
        NSString* message = NSLocalizedString(@"alarms.error.message.limit-reached", nil);
        NSString* title = NSLocalizedString(@"alarms.error.title.limit-reached", nil);
        [[self delegate] showErrorWithTitle:title message:message fromPresenter:self];
    }
    
    [SENAnalytics track:HEMAnalyticsEventCreateNewAlarm];
    
    void (^animations)() = ^{
        [UIView addKeyframeWithRelativeStartTime:0
                                relativeDuration:0.5
                                      animations:^{
                                          CGFloat scale = HEMAlarmListButtonMaximumScale;
                                          self.addButton.layer.transform = CATransform3DMakeScale(scale, scale, 1.f);
                                      }];
        [UIView addKeyframeWithRelativeStartTime:0.5
                                relativeDuration:0.5
                                      animations:^{ self.addButton.layer.transform = CATransform3DIdentity; }];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished) {
        [[self delegate] addNewAlarmFromPresenter:self];
    };
    
    NSUInteger options = (UIViewKeyframeAnimationOptionCalculationModeCubicPaced | UIViewAnimationOptionCurveEaseIn
                          | UIViewKeyframeAnimationOptionBeginFromCurrentState);
    [UIView animateKeyframesWithDuration:0.35f delay:0.15f options:options animations:animations completion:completion];
}


- (void)toggleEnableSwitch:(UISwitch *)sender {
    NSArray* alarms = [[self alarmService] alarms];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    __block SENAlarm *alarm = [alarms objectAtIndex:sender.tag];
    BOOL on = [sender isOn];
    
    if (on == alarm.on) {
        return; //  ignore
    }
    
    if (on
        && [[self alarmService] isAlarmTimeTooSoon:alarm]
        && [[self alarmService] willAlarmRingToday:alarm]) {
        [[self delegate] showErrorWithTitle:NSLocalizedString(@"alarm.save-error.too-soon.title", nil)
                                    message:NSLocalizedString(@"alarm.save-error.too-soon.message", nil)
                              fromPresenter:self];
        sender.on = NO;
        return;
    }
    
    alarm.on = on;
    
    __weak typeof(self) weakSelf = self;
    [[self alarmService] updateAlarms:alarms completion:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            alarm.on = !on;
            sender.on = !on;
            [SENAnalytics trackError:error];
            
            NSString* title = NSLocalizedString(@"alarm.save-error.title", nil);
            [[strongSelf delegate] showErrorWithTitle:title
                                              message:[error localizedDescription]
                                        fromPresenter:strongSelf];
        } else {
            [[strongSelf collectionView] reloadItemsAtIndexPaths:@[indexPath]];
            [SENAnalytics trackAlarmToggle:alarm];
        }
    }];
}

#pragma mark - Clean Up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
