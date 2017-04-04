//
//  HEMPillDfuPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPillMetadata.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSleepPill.h>
#import <SenseKit/SENSleepPillManager.h>

#import "UIDevice+HEMUtils.h"
#import "Sense-Swift.h"

#import "HEMPillDfuPresenter.h"
#import "HEMDeviceService.h"
#import "HEMBluetoothUtils.h"
#import "HEMActivityCoverView.h"
#import "HEMScreenUtils.h"

typedef NS_ENUM(NSInteger, HEMPillDfuErrorCode) {
    HEMPillDfuErrorCodeLowPhoneBattery = -1
};

static NSString* const HEMPillDfuErrorDomain = @"is.hello.app.pill.dfu";
static NSInteger const HEMPillDfuBLECheckAttempts = 10;

static CGFloat const HEMPillDfuSuccessDelay = 2.0f;
static CGFloat const HEMPillDfuWaveAnimeDuration = 1.5f;
static CGFloat const HEMPIllDfuStatus4sBottomMargin = 10.0f;
static CGFloat const HEMPillDfuWaveAnimeFadeDuration = 0.2f;

@interface HEMPillDfuPresenter()

@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UIButton* actionButton;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) UILabel* statusLabel;
@property (nonatomic, weak) UIButton* cancelButton;
@property (nonatomic, weak) UIButton* helpButton;
@property (nonatomic, weak) UIProgressView* progressView;
@property (nonatomic, weak) UIImageView* illustrationView;
@property (nonatomic, weak) NSLayoutConstraint* statusBottomConstraint;
@property (nonatomic, strong) CALayer* waveLayer;
@property (nonatomic, strong) CALayer* illustrationBgLayer;
@property (nonatomic, assign, getter=isUpdating) BOOL updating;

@end

@implementation HEMPillDfuPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService {
    
    self = [super init];
    if (self) {
        _deviceService = deviceService;

        if (![deviceService devices]) {
            [deviceService refreshMetadata:^(SENPairedDevices * devices, NSError * error) {}];
        }
        
        // warm up central
        BOOL bleOn = [_deviceService isBleOn];
        DDLogVerbose(@"ble is on %@", bleOn?@"y":@"n");
    }
    return self;
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    UIFont* font = [SenseStyle fontWithGroup:GroupPillDfu property:ThemePropertyTextFont];
    UIColor* color = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyTextColor];
    [titleLabel setFont:font];
    [titleLabel setTextColor:color];

    UIFont* descFont = [SenseStyle fontWithGroup:GroupPillDfu property:ThemePropertyDetailFont];
    UIColor* descColor = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyDetailColor];
    
    NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
    NSString* description = [descriptionLabel text];
    NSAttributedString* attributedDescription =
        [[NSAttributedString alloc] initWithString:description
                                        attributes:@{NSForegroundColorAttributeName : descColor,
                                                     NSFontAttributeName : descFont,
                                                     NSParagraphStyleAttributeName : style}];
    
    [descriptionLabel setAttributedText:attributedDescription];
    
    [self setTitleLabel:titleLabel];
    [self setDescriptionLabel:descriptionLabel];
}

- (void)bindWithActionButton:(UIButton*)actionButton {
    if (![self pillToDfu]) {
        [actionButton addTarget:self
                         action:@selector(checkConditions)
               forControlEvents:UIControlEventTouchUpInside];
    }

    [actionButton setHidden:[self pillToDfu] != nil];
    [self setActionButton:actionButton];
}

- (void)bindWithIllustrationView:(UIImageView*)illustrationView
                bottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    if (HEMIsIPhone4Family()) {
        [bottomConstraint setConstant:0.0f];
    }
    static NSString* imageKey = @"sense.illustration";
    UIImage* image = [SenseStyle imageWithGroup:GroupPillDfu propertyName:imageKey];
    [illustrationView setImage:image];
    [self setIllustrationView:illustrationView];
}

- (void)bindWithProgressView:(UIProgressView*)progressView
                 statusLabel:(UILabel*)statusLabel
      statusBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    UIColor* tintColor = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyTintColor];
    UIFont* font = [SenseStyle fontWithGroup:GroupPillDfu property:ThemePropertyDetailFont];
    UIColor* color = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyDetailColor];
    [progressView setHidden:[self pillToDfu] == nil];
    [progressView setProgress:0.0f];
    [progressView setProgressTintColor:tintColor];
    [progressView setTrackTintColor:[color colorWithAlphaComponent:0.2f]];
    [statusLabel setHidden:[self pillToDfu] == nil];
    [statusLabel setTextColor:color];
    [statusLabel setFont:font];
    [statusLabel setText:[self statusForState:HEMDeviceDfuStateNotStarted]];
    
    if (HEMIsIPhone4Family()) {
        [bottomConstraint setConstant:HEMPIllDfuStatus4sBottomMargin];
    }
    
    [self setProgressView:progressView];
    [self setStatusLabel:statusLabel];
    [self setStatusBottomConstraint:bottomConstraint];
}

- (void)bindWithMainView:(UIView*)mainView {
    UIColor* bgColor = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyBackgroundColor];
    [mainView setBackgroundColor:bgColor];
}

- (void)bindWithCancelButton:(UIButton*)cancelButton {
    [cancelButton applySecondaryStyle];
    [cancelButton setHidden:[self pillToDfu] != nil];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self setCancelButton:cancelButton];
}

- (void)bindWithHelpButton:(UIButton*)helpButton {
    UIImage* image = [helpButton imageForState:UIControlStateNormal];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [helpButton setImage:image forState:UIControlStateNormal];
    [helpButton setHidden:[self pillToDfu] != nil];
    [helpButton addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [self setHelpButton:helpButton];
}

- (void)showRetryButton {
    [[self actionButton] setHidden:NO];
    [[self actionButton] addTarget:self
                            action:@selector(retry)
                  forControlEvents:UIControlEventTouchUpInside];
    [[self actionButton] setTitle:NSLocalizedString(@"actions.retry", nil)
                         forState:UIControlStateNormal];
    [[self progressView] setHidden:YES];
    [[self progressView] setProgress:0.0f];
    [[self statusLabel] setHidden:YES];
    [[self cancelButton] setHidden:NO];
    [[self helpButton] setHidden:NO];
}

#pragma mark - Animation

- (CALayer*)waveLayer {
    if (!_waveLayer) {
        UIColor* tintColor = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyTintColor];
        CALayer* layer = [CALayer layer];
        [layer setBackgroundColor:[tintColor CGColor]];
        [layer setAnchorPoint:CGPointMake(1.0f, 0.5f)];
        [layer setCornerRadius:CGRectGetWidth([[self illustrationView] bounds]) / 4.0f];
        _waveLayer = layer;
    }
    return _waveLayer;
}

- (CALayer*)illustrationBgLayer {
    if (!_illustrationBgLayer) {
        CGColorRef bgColorRef = [[[UIColor grey3] colorWithAlphaComponent:0.5f] CGColor];
        CALayer* backgroundLayer = [CALayer layer];
        [backgroundLayer setBackgroundColor:bgColorRef];
        _illustrationBgLayer = backgroundLayer;
    }
    return _illustrationBgLayer;
}

- (void)startWaveAnimation {
    CALayer* waveLayer = [self waveLayer];
    [waveLayer removeAllAnimations]; // in case it was paused
    
    CALayer* illustrationLayer = [[self illustrationView] layer];
    CALayer* parentLayer = [illustrationLayer superlayer];
    CALayer* backgroundLayer = [self illustrationBgLayer];

    [waveLayer setCornerRadius:CGRectGetHeight([illustrationLayer frame]) / 3.0f];
    [waveLayer setFrame:[self illustrationContentFrame]];
    [parentLayer insertSublayer:waveLayer above:backgroundLayer];
    
    CABasicAnimation* expand = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    [expand setFromValue:@0];
    [expand setToValue:@((CGRectGetWidth([illustrationLayer bounds]) * 4) / 5)];
    [expand setDuration:HEMPillDfuWaveAnimeDuration];
    [expand setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fade setFromValue:@1];
    [fade setToValue:@0];
    [fade setBeginTime:HEMPillDfuWaveAnimeDuration];
    [fade setDuration:HEMPillDfuWaveAnimeFadeDuration];
    [fade setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    [group setAnimations:@[fade, expand]];
    [group setRepeatCount:MAXFLOAT];
    [group setDuration:HEMPillDfuWaveAnimeFadeDuration + HEMPillDfuWaveAnimeDuration];
    
    [waveLayer addAnimation:group forKey:@"waveAnimation"];
}

- (void)stopWaveAnimation {
    [[self waveLayer] removeAllAnimations];
    [[self waveLayer] removeFromSuperlayer];
}

- (CGRect)illustrationContentFrame {
    CALayer* illustrationLayer = [[self illustrationView] layer];
    CGSize imageSize = [[self illustrationView] image].size;
    CGFloat frameHeight = CGRectGetHeight([illustrationLayer frame]);
    CGRect contentFrame = [illustrationLayer frame];
    
    CGFloat wRatio = CGRectGetWidth(contentFrame) / imageSize.width;
    contentFrame.size.height = imageSize.height * wRatio;
    
    CGFloat currentY = CGRectGetMinY(contentFrame);
    CGFloat heightDiff = (frameHeight - CGRectGetHeight(contentFrame));
    contentFrame.origin.y = currentY + (heightDiff / 2.0f);
    
    return contentFrame;
}

- (void)updateIllustrationBgLayerFrame {
    CALayer* illustrationLayer = [[self illustrationView] layer];
    CALayer* parentLayer = [illustrationLayer superlayer];
    CALayer* backgroundLayer = [self illustrationBgLayer];
    [backgroundLayer setFrame:[self illustrationContentFrame]];
    [parentLayer insertSublayer:backgroundLayer below:illustrationLayer];
}

#pragma mark - Presenter events

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self startWaveAnimation];
}

- (void)willAppear {
    [super willAppear];
    
    // must add it here b/c the layers are not initialized on bind
    [self updateIllustrationBgLayerFrame];
}

- (void)didAppear {
    [super didAppear];
    [self startWaveAnimation];
    
    if ([self pillToDfu] && [[self actionButton] isHidden]) {
        [self startDfu];
    }
}

- (void)didDisappear {
    [super didDisappear];
    [self stopWaveAnimation];
}

- (void)didRelayout {
    [super didRelayout];
    [self updateIllustrationBgLayerFrame];
}

#pragma mark - DFU States

- (NSString*)statusForState:(HEMDeviceDfuState)state {
    switch (state) {
        case HEMDeviceDfuStateUpdating:
        case HEMDeviceDfuStateConnecting:
            return NSLocalizedString(@"dfu.pill.state.updating", nil);
        case HEMDeviceDfuStateValidating:
            return NSLocalizedString(@"dfu.pill.state.validating", nil);
        case HEMDeviceDfuStateDisconnecting:
            return NSLocalizedString(@"dfu.pill.state.disconnecting", nil);
        default:
            return NSLocalizedString(@"dfu.pill.state.not-started", nil);
    }
}

#pragma mark - Actions

- (void)help {
    NSString* slug = NSLocalizedString(@"help.url.slug.pill-dfu", nil);
    [[self dfuDelegate] showHelpWithSlug:slug fromPresenter:self];
}

- (void)cancel {
    [[self dfuDelegate] didCancelDfuFrom:self];
}

- (void)startDfu {
    [[self cancelButton] setHidden:YES];
    [[self helpButton] setHidden:YES];
    
    if (![self isUpdating]) {
        [SENAnalytics track:HEMAnalyticsEventPillDfuOTAStart];
        
        [[self statusLabel] setText:[self statusForState:HEMDeviceDfuStateNotStarted]];
        [self setUpdating:YES];
        
        __weak typeof(self) weakSelf = self;
        [[self deviceService] beginPillDfuFor:[self pillToDfu] progress:^(CGFloat progress, HEMDeviceDfuState state) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf progressView] setProgress:progress];
            [[strongSelf statusLabel] setText:[strongSelf statusForState:state]];
        } completion:^(NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setUpdating:NO];
            if (!error) {
                DDLogVerbose(@"dfu completed");
                [strongSelf showDfuCompletion];
            } else {
                DDLogWarn(@"dfu failed %@", error);
                [strongSelf showRetryButton];
                NSString* title = NSLocalizedString(@"dfu.pill.error.title.update-failed", nil);
                NSString* message = NSLocalizedString(@"dfu.pill.error.update-failed", nil);
                if (![[strongSelf deviceService] isBleOn]) {
                    message = NSLocalizedString(@"dfu.pill.error.update-failed-no-ble", nil);
                }
                [[strongSelf errorDelegate] showErrorWithTitle:title
                                                    andMessage:message
                                                  withHelpPage:nil
                                                 fromPresenter:strongSelf];
            }
        }];
    }
}

- (void)retry {
    [[self actionButton] setHidden:YES];
    [[self progressView] setHidden:NO];
    [[self statusLabel] setHidden:NO];
    [self startDfu];
}

- (void)checkConditions {
    [self checkConditionsWithAttempt:1];
}

- (void)checkConditionsWithAttempt:(NSInteger)attempt {
    NSString* errorMessage = nil;
    NSString* title = nil;
    NSString* helpSlug = nil;
    
    UIDevice* device = [UIDevice currentDevice];
    UIDeviceBatteryState batteryState = [device batteryState];
    
    if (batteryState != UIDeviceBatteryStateCharging && batteryState != UIDeviceBatteryStateFull) {
        float batteryLevel = [device batteryLevel];
        if (![[self deviceService] meetsPhoneBatteryRequirementForDFU:batteryLevel]) {
            title = NSLocalizedString(@"dfu.pill.error.title.phone-battery", nil);
            errorMessage = NSLocalizedString(@"dfu.pill.error.insufficient-phone-battery", nil);
        }
    }
    
    if (errorMessage) {
        [self trackErrorMessage:@"Pill Update Phone Battery Low"
                           code:HEMPillDfuErrorCodeLowPhoneBattery];
        
        [[self errorDelegate] showErrorWithTitle:title
                                      andMessage:errorMessage
                                    withHelpPage:helpSlug
                                   fromPresenter:self];
    } else if (![[self deviceService] isBleStateAvailable]
               && attempt <= HEMPillDfuBLECheckAttempts) {
        [self checkConditionsWithAttempt:attempt + 1];
    } else if (![[self deviceService] isBleOn]){
        [[self dfuDelegate] bleRequiredToProceedFrom:self];
    } else {
        [[self dfuDelegate] shouldStartScanningForPillFrom:self];
    }
}

#pragma mark - Errors

- (void)trackErrorMessage:(NSString*)errorMessage code:(HEMPillDfuErrorCode)code {
    NSDictionary* info = @{NSLocalizedDescriptionKey : errorMessage ?: @""};
    NSError* error = [NSError errorWithDomain:HEMPillDfuErrorDomain code:code userInfo:info];
    [SENAnalytics trackError:error];
}

#pragma mark - Finish

- (void)showDfuCompletion {
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    NSString* doneMessage = NSLocalizedString(@"dfu.pill.state.complete", nil);
    [activityView showInView:[[self dfuDelegate] viewToAttachToWhenFinishedIn:self]
                    withText:doneMessage
                 successMark:YES
                  completion:^{
                      __weak typeof(self) weakSelf = self;
                      int64_t delay = (int64_t)(HEMPillDfuSuccessDelay * NSEC_PER_SEC);
                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,delay), dispatch_get_main_queue(), ^{
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          [[strongSelf dfuDelegate] didCompleteDfuFrom:strongSelf];
                      });
                  }];
}

@end
