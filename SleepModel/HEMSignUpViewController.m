
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAccount.h>

#import "NSString+HEMUtils.h"

#import "UIFont+HEMStyle.h"

#import "HEMSignUpViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"

@interface HEMSignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField* emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet UITextField *hiddenField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (copy, nonatomic) NSString* doneButtonTitle;

@property (nonatomic, getter=isSigningUp) BOOL signingUp;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;
@end

@implementation HEMSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [[[self doneButton] titleLabel] setFont:[UIFont navButtonTitleFont]];
    [[self doneButton] setTitleColor:[HelloStyleKit senseBlueColor]
                            forState:UIControlStateNormal];
    [SENAnalytics track:kHEMAnalyticsEventOnBStart];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self nameField] becomeFirstResponder];
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self nameTopConstraint]
                  withDiff:8.0f];
}

#pragma mark - Activity

- (void)enableControls:(BOOL)enable {
    if (!enable) {
        // keep the keyboard up at all times
        [[self hiddenField] becomeFirstResponder];
    }
    
    [[self nameField] setEnabled:enable];
    [[self emailAddressField] setEnabled:enable];
    [[self passwordField] setEnabled:enable];
    [[self doneButton] setEnabled:enable];
    [[self navigationItem] setHidesBackButton:!enable animated:YES];
    
    if (enable) {
        [[self nameField] becomeFirstResponder];
    }
}

- (void)showActivity {
    self.signingUp = YES;
    [self enableControls:NO];
    [[self activityIndicator] startAnimating];
}

- (void)stopActivity {
    self.signingUp = NO;
    [[self activityIndicator] stopAnimating];
    [self enableControls:YES];
}

#pragma mark - Sign Up

- (void)signup {
    NSString* emailAddress = [self.emailAddressField.text trim];
    NSString* password = self.passwordField.text;
    NSString* name = [self.nameField.text trim];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount createAccountWithName:name
                            emailAddress:emailAddress
                                password:password
                              completion:^(SENAccount* account, NSError* error) {
                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                  if (!strongSelf) return;
                                  
                                  if (error) {
                                      [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                                      [strongSelf stopActivity];
                                      
                                      NSString* title = NSLocalizedString(@"sign-up.failed.title", nil);
                                      [HEMOnboardingUtils showAlertForHTTPError:error
                                                                      withTitle:title
                                                                           from:strongSelf];
                                      return;
                                  }
                                  // cache the account as that is needed post sign up
                                  // to update the account with further information
                                  [[HEMOnboardingCache sharedCache] setAccount:account];
                                  [strongSelf authenticate:emailAddress password:password rety:YES];
                                  
                                  // save a checkpoint so that user does not have to try and create
                                  // another account
                                  [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountCreated];
                              }];
}

- (void)authenticate:(NSString*)email password:(NSString*)password rety:(BOOL)retry {
    NSString* userName = [self.nameField.text trim];
    __weak typeof(self) weakSelf = self;
    [SENAuthorizationService authorizeWithUsername:email password:password callback:^(NSError *signInError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf stopActivity];
        
        if (signInError && !retry) {
            // TODO: what should happen if we land in this case?
            DDLogInfo(@"authentication failed post sign up %@", signInError);
            [SENAnalytics trackError:signInError withEventName:kHEMAnalyticsEventError];
            NSString* errTitle = NSLocalizedString(@"sign-up.failed.title", nil);
            [HEMOnboardingUtils showAlertForHTTPError:signInError
                                            withTitle:errTitle
                                                 from:strongSelf];
            return;
        } else if (signInError) { // retry once
            [SENAnalytics trackError:signInError withEventName:kHEMAnalyticsEventError];
            DDLogInfo(@"retrying authentication post sign up %@", signInError);
            [strongSelf authenticate:email password:password rety:NO];
            return;
        }

        [HEMAnalytics trackSignUpWithName:userName];
        [strongSelf next];
    }];
}

- (IBAction)didTapSignUp:(id)sender {
    if ([self validateFieldValuesAndShowAlert:YES] && ![self isSigningUp]) {
        [self showActivity];
        [self signup];
    }
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.nameField]) {
        [self.emailAddressField becomeFirstResponder];
    } else if ([textField isEqual:self.emailAddressField]) {
        [self.passwordField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordField]) {
        if ([self validateFieldValuesAndShowAlert:YES]) {
            [self showActivity];
            [self signup];
        }
    }

    return YES;
}

#pragma mark - Field Validation

- (BOOL)validateFieldValuesAndShowAlert:(BOOL)shouldShowAlert {
    NSString* errorMessage = nil;
    if ([[self.nameField.text trim] length] == 0) {
        errorMessage = NSLocalizedString(@"sign-up.error.name-length", nil);
    } else if (![[self.emailAddressField.text trim] isValidEmail]) {
        errorMessage = NSLocalizedString(@"sign-up.error.email-invalid", nil);
    } else if ([self.passwordField.text length] == 0) {
        errorMessage = NSLocalizedString(@"sign-up.error.password-length", nil);
    } else {
        return YES;
    }
    
    if (errorMessage && shouldShowAlert) {
        [self showMessageDialog:errorMessage title:NSLocalizedString(@"sign-up.failed.title", nil)];
    }
    return NO;
}

#pragma mark - Segues / Navigation

- (void)next {
    if (![HEMBluetoothUtils stateAvailable]) {
        [self performSelector:@selector(next)
                   withObject:nil
                   afterDelay:0.1f];
        return;
    }
    
    NSString* segueId
        = ![HEMBluetoothUtils isBluetoothOn]
        ? [HEMOnboardingStoryboard signupToNoBleSegueIdentifier]
        : [HEMOnboardingStoryboard moreInfoSegueIdentifier];

    [self performSegueWithIdentifier:segueId sender:self];
}

@end
