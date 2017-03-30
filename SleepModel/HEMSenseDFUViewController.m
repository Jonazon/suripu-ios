//
//  HEMSenseDFUViewController.m
//  Sense
//
//  Created by Jimmy Lu on 7/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSenseDFUViewController.h"
#import "HEMActionButton.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSenseDFUPresenter.h"
#import "HEMOnboardingService.h"
#import "HEMAlertViewController.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSenseDFUViewController () <HEMSenseDFUDelegate, HEMPresenterErrorDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *laterButton;

@end

@implementation HEMSenseDFUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureHelpButton];
    [self configurePresenter];
    [self trackAnalyticsEvent:HEMAnalyticsEventSenseDFU];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self isCancellable]) {
        [self showCancelButtonWithSelector:@selector(dismiss)];
    }
}

- (void)trackAnalyticsEvent:(NSString *)event {
    if ([self flow]) {
        [SENAnalytics track:event];
    } else {
        [SENAnalytics track:event properties:nil onboarding:YES];
    }
}

- (void)configureHelpButton {
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.sense-dfu", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropSenseDFU];
}

- (void)configurePresenter {
    HEMOnboardingService* onbService = [HEMOnboardingService sharedService];
    HEMSenseDFUPresenter* presenter = [[HEMSenseDFUPresenter alloc] initWithOnboardingService:onbService];
    [presenter bindWithUpdateButton:[self continueButton]];
    [presenter bindWithActivityIndicator:[self activityIndicator]
                             statusLabel:[self statusLabel]];
    [presenter bindWithLaterButton:[self laterButton]];
    [presenter setErrorDelegate:self];
    [presenter setDfuDelegate:self];
    [presenter setOnboarding:![self flow]];
    [self addPresenter:presenter];
}

#pragma mark - Actions

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DFU Delegate

- (UIView*)parentContentViewFor:(HEMSenseDFUPresenter*)presenter {
    return [[[self navigationController] view] superview];
}

- (void)senseUpdateLaterFrom:(HEMSenseDFUPresenter *)presenter {
    [self next:YES];
}

- (void)senseUpdateCompletedFrom:(HEMSenseDFUPresenter *)presenter {
    [self next:NO];
}

- (void)showConfirmationWithTitle:(NSString*)title
                          message:(NSString*)message
                         okAction:(HEMSenseDFUActionCallback)okAction
                     cancelAction:(HEMSenseDFUActionCallback)cancelAction
                             from:(HEMSenseDFUPresenter*)presenter {
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title
                                                                             message:message];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil)
                           style:HEMAlertViewButtonStyleRoundRect
                          action:okAction];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil)
                           style:HEMAlertViewButtonStyleBlueText
                          action:cancelAction];
    [dialogVC showFrom:self];
}

#pragma mark - Error Delegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message
                      title:title
                      image:nil
               withHelpPage:nil];
}

#pragma mark - Flow

- (void)next:(BOOL)skip {
    if (![self continueWithFlowBySkipping:skip]) {
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        if ([service isVoiceAvailable]) {
            NSString* voiceSegue = [HEMOnboardingStoryboard voiceTutorialSegueIdentifier];
            [self performSegueWithIdentifier:voiceSegue sender:self];
        } else {
            [self completeOnboarding];
        }
    }
}

@end
