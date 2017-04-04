//
//  HEMPillFinderPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSleepPill.h>
#import "Sense-Swift.h"
#import "HEMPillFinderPresenter.h"
#import "HEMDeviceService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMAnimationUtils.h"
#import "HEMActionButton.h"

static NSString* const HEMPillFinderErrorDomain = @"is.hello.app.pill";
static CGFloat const HEMPillFinderAnimeDuration = 0.5f;
static CGFloat const HEMPillFinderSuccessDuration = 1.0f;
static CGFloat const HEMPillFinderScanTimeout = 30.0f;

@interface HEMPillFinderPresenter()

@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) UILabel* statusLabel;
@property (nonatomic, weak) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, weak) HEMEmbeddedVideoView* videoView;
@property (nonatomic, weak) SENSleepPill* sleepPill;
@property (nonatomic, weak) HEMActionButton *retryButton;
@property (nonatomic, weak) UIButton *cancelButton;
@property (nonatomic, weak) UIButton *helpButton;
@property (nonatomic, assign) BOOL autoStart;
@property (nonatomic, strong) NSTimer* scanTimer;

@end

@implementation HEMPillFinderPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
        _deviceService = deviceService;
        _autoStart = YES;
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
    
    NSMutableParagraphStyle* style = [NSMutableParagraphStyle senseStyle];
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

- (void)bindWithMainView:(UIView*)mainView {
    UIColor* bgColor = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyBackgroundColor];
    [mainView setBackgroundColor:bgColor];
}

- (void)bindWithStatusLabel:(UILabel*)statusLabel andIndicator:(HEMActivityIndicatorView*)indicatorView {
    UIFont* textFont = [SenseStyle fontWithGroup:GroupPillDfu property:ThemePropertyDetailFont];
    UIColor* textColor = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyDetailColor];
    
    [indicatorView start];
    [statusLabel setTextColor:textColor];
    [statusLabel setFont:textFont];
    [self setStatusLabel:statusLabel];
    [self setIndicatorView:indicatorView];
}

- (void)bindWithVideoView:(HEMEmbeddedVideoView*)videoView {
    static NSString* firstFrameKey = @"sense.shake.pill.image";
    static NSString* videoKey = @"sense.shake.pill.video.key";
    UIColor* bgColor = [SenseStyle colorWithGroup:GroupPillDfu property:ThemePropertyBackgroundColor];
    UIImage* image = [SenseStyle imageWithGroup:GroupPillDfu propertyName:firstFrameKey];
    NSString* stringsKey = [SenseStyle valueWithGroup:GroupPillDfu propertyName:videoKey];
    NSString* videoPath = NSLocalizedString(stringsKey, nil);
    [videoView setFirstFrame:image videoPath:videoPath];
    [videoView setBackgroundColor:bgColor];
    [self setVideoView:videoView];
}

- (void)bindWithRetryButton:(HEMActionButton*)retryButton {
    [retryButton setHidden:YES];
    [retryButton addTarget:self
                    action:@selector(retry)
          forControlEvents:UIControlEventTouchUpInside];
    [self setRetryButton:retryButton];
}

- (void)bindWithCancelButton:(UIButton*)cancelButton helpButton:(UIButton*)helpButton {
    UIImage* image = [helpButton imageForState:UIControlStateNormal];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [helpButton setImage:image forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    [helpButton setHidden:YES];
    [cancelButton applySecondaryStyle];
    [cancelButton setHidden:YES];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self setHelpButton:helpButton];
    [self setCancelButton:cancelButton];
}

- (void)showNavButtons:(BOOL)show {
    [[self cancelButton] setHidden:!show];
    [[self helpButton] setHidden:!show];
}

- (void)showRetryButton:(BOOL)show {
    [[self retryButton] setHidden:!show];
    [[self statusLabel] setHidden:show];
    [[self indicatorView] setHidden:show];
}

- (void)timeout {
    [[self scanTimer] invalidate];
    [self setScanTimer:nil];
    [self showPillNotFoundError];
}

- (void)showPillNotFoundError {
    NSString* errorTitle = NSLocalizedString(@"dfu.pill.error.title.pill-not-found", nil);
    NSString* errorMessage = NSLocalizedString(@"dfu.pill.error.pill-not-found", nil);
    NSString* helpSlug = NSLocalizedString(@"help.url.slug.pill-dfu-not-found", nil);
    [[self errorDelegate] showErrorWithTitle:errorTitle
                                  andMessage:errorMessage
                                withHelpPage:helpSlug
                               fromPresenter:self];
    
    [[self videoView] stop];
    [self showRetryButton:YES];
    [self showNavButtons:YES];
}

- (void)findNearestPillIfNotFound {
    if (![[self deviceService] isScanningPill] && ![self sleepPill]) {
        [[self scanTimer] invalidate]; // in case 1 exists that never fired
        [self setScanTimer:[NSTimer scheduledTimerWithTimeInterval:HEMPillFinderScanTimeout
                                                            target:self
                                                          selector:@selector(timeout)
                                                          userInfo:nil
                                                           repeats:NO]];
        
        __weak typeof(self) weakSelf = self;
        void(^scanDone)(SENSleepPill * sleepPill, NSError * error) = ^(SENSleepPill * sleepPill, NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf scanTimer] invalidate];
            [strongSelf setScanTimer:nil];
            
            if (sleepPill) {
                [strongSelf finishWithSleepPill:sleepPill];
            } else {
                NSDictionary* info = @{NSLocalizedDescriptionKey : @"Pill Update Pill Not Detected"};
                NSError* error = [NSError errorWithDomain:HEMPillFinderErrorDomain code:-1 userInfo:info];
                [SENAnalytics trackError:error];
                
                [strongSelf showPillNotFoundError];
            }
        };
        
        [[self deviceService] findNearestPillWithVersion:SENSleepPillAdvertisedVersionOneFive
                                              completion:scanDone];
    }
}

- (void)finishWithSleepPill:(SENSleepPill*)sleepPill {
    [[self videoView] stop];
    [self setSleepPill:sleepPill];
    
    UIImageView* successView = [[UIImageView alloc] initWithFrame:[[self indicatorView] frame]];
    [successView setImage:[UIImage imageNamed:@"check"]];
    [successView setContentMode:UIViewContentModeScaleAspectFit];
    [successView setTransform:CGAffineTransformMakeScale(0.0f, 0.0f)];
    [[[self indicatorView] superview] addSubview:successView];
    
    NSString* foundText = NSLocalizedString(@"dfu.pill.connected", nil);
    
    [UIView animateWithDuration:HEMPillFinderAnimeDuration animations:^{
        [[self indicatorView] setAlpha:0.0f];
        [[self statusLabel] setText:foundText];
    } completion:^(BOOL finished) {
        [HEMAnimationUtils grow:successView completion:^(BOOL finished) {
            __weak typeof(self) weakSelf = self;
            int64_t delay = (int64_t) (HEMPillFinderSuccessDuration * NSEC_PER_SEC);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [[strongSelf finderDelegate] didFindSleepPill:sleepPill from:strongSelf];
            });
        }];
    }];
    
}

#pragma mark - Actions

- (void)retry {
    [self showNavButtons:NO];
    [self showRetryButton:NO];
    [[self videoView] setReady:YES];
    [[self videoView] playVideoWhenReady];
    [self findNearestPillIfNotFound];
}

- (void)help {
    NSString* helpSlug = NSLocalizedString(@"help.url.slug.pill-dfu-not-found", nil);
    [[self finderDelegate] showHelpTopic:helpSlug from:self];
}

- (void)cancel {
    [[self finderDelegate] cancelFrom:self];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    if ([self autoStart]) {
        [[self videoView] setReady:YES];
        [[self videoView] playVideoWhenReady];
        [self findNearestPillIfNotFound];
        [self setAutoStart:NO];
    }
}

@end
