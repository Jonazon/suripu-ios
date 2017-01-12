
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENPreference.h>

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMStyle.h"
#import "HEMWeightPickerViewController.h"
#import "HEMOnboardingService.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMMathUtil.h"
#import "HEMRulerView.h"
#import "HEMAccountUpdateDelegate.h"
#import "HEMHealthKitService.h"

NSInteger const HEMWeightPickerMaxWeight = 900;

static CGFloat const HEMWeightDefaultFemale = 49895.2f;
static CGFloat const HEMWeightDefaultMale = 74842.7f;

@interface HEMWeightPickerViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel* weightLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIView *currentWeightMarker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottomConstraint;

@property (strong, nonatomic) HEMRulerView* ruler;
@property (assign, nonatomic) CGFloat weightInGrams;
@property (strong, nonatomic) NSDictionary* valueAttributes;

@end

@implementation HEMWeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureButtons];
    [self configureScale];
    [self trackAnalyticsEvent:HEMAnalyticsEventWeight];
}

- (void)configureScale {
    [self setValueAttributes:@{NSFontAttributeName : [UIFont h1],
                               NSForegroundColorAttributeName : [UIColor blue6]}];

    [self setRuler:[[HEMRulerView alloc] initWithSegments:HEMWeightPickerMaxWeight
                                                direction:HEMRulerDirectionHorizontal]];
    
    [[self scrollView] addSubview:[self ruler]];
    [[self scrollView] setBackgroundColor:[UIColor clearColor]];
    
    [[self currentWeightMarker] setBackgroundColor:[UIColor tintColor]];
    [[self view] bringSubviewToFront:[self currentWeightMarker]];
}

- (void)configureButtons {
    [self stylePrimaryButton:[self doneButton]
             secondaryButton:[self skipButton]
                withDelegate:[self delegate] != nil];
    
    [self enableBackButton:NO];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self updateConstraint:[self scrollBottomConstraint] withDiff:35.0f];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect rulerFrame = [[self ruler] frame];
    rulerFrame.origin.x = CGRectGetMidX([[self currentWeightMarker] frame]);
    [[self ruler] setFrame:rulerFrame];
    
    CGSize contentSize = CGSizeZero;
    contentSize.width = CGRectGetWidth(rulerFrame) + (CGRectGetMinX(rulerFrame)*2);
    contentSize.height = CGRectGetHeight([[self scrollView] bounds]);
    [[self scrollView] setContentSize:contentSize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToSetWeight];
}

- (void)scrollToSetWeight {
    SENAccountGender gender = [[[HEMOnboardingService sharedService] currentAccount] gender];
    CGFloat genderWeight = gender == SENAccountGenderFemale ? HEMWeightDefaultFemale : HEMWeightDefaultMale;
    NSNumber* initWeightInGrams = [self defaultWeightInGrams] ?: @(genderWeight);
    CGFloat initialWeightInLbs = roundCGFloat(HEMGramsToPounds(initWeightInGrams));
    CGFloat initialOffset = (initialWeightInLbs*(HEMRulerSegmentSpacing+HEMRulerSegmentWidth))-[[self scrollView] contentInset].left;
    [[self scrollView] setContentOffset:CGPointMake(initialOffset, 0.0f) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offX = [scrollView contentOffset].x;
    CGFloat markX = ((offX + [scrollView contentInset].left) / (HEMRulerSegmentSpacing+HEMRulerSegmentWidth));
    CGFloat lbs = MAX(0.0f, markX);
    
    NSString* format = nil;
    NSAttributedString* attributedValue = nil;
    
    if ([SENPreference useMetricUnitForWeight]) {
        format = NSLocalizedString(@"measurement.kg.attributed.format", nil);
        NSString* textValue = [NSString stringWithFormat:@"%.0f", roundCGFloat(HEMPoundsToKilograms(@(lbs)))];
        attributedValue = [[NSAttributedString alloc] initWithString:textValue attributes:[self valueAttributes]];
    } else {
        format = NSLocalizedString(@"measurement.lb.attributed.format", nil);
        NSString* textValue = [NSString stringWithFormat:@"%.0f", lbs];
        attributedValue = [[NSAttributedString alloc] initWithString:textValue attributes:[self valueAttributes]];
    }
    
    NSAttributedString* attrText = [[NSMutableAttributedString alloc] initWithFormat:format args:@[attributedValue]
                                                                           baseColor:[UIColor blue6]
                                                                            baseFont:[UIFont h5]];
    [[self weightLabel] setAttributedText:attrText];
    [self setWeightInGrams:HEMPoundsToGrams(@(lbs))];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self delegate]) {
        SENAccount* tempAccount = [SENAccount new];
        [tempAccount setWeight:@([self weightInGrams])];
        [[self delegate] update:tempAccount];
    } else {
        SENAccount* account = [[HEMOnboardingService sharedService] currentAccount];
        [account setWeight:@([self weightInGrams])];
        [self next];
    }
}

- (IBAction)skip:(id)sender {
    if ([self delegate]) {
        [[self delegate] cancel];
    } else {
        [self next];
    }
}

- (void)next {
    NSString* segueId = nil;
    if ([[HEMHealthKitService sharedService] isSupported]) {
        segueId = [HEMOnboardingStoryboard weightToHealthKitSegueIdentifier];
    } else {
        segueId = [HEMOnboardingStoryboard weightToLocationSegueIdentifier];
    }
    
    [self performSegueWithIdentifier:segueId sender:self];
}

@end
