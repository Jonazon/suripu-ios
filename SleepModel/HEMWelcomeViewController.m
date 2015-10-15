//
//  HEMWelcomeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <MediaPlayer/MPMoviePlayerViewController.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMWelcomeViewController.h"
#import "HEMSignUpViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMMeetSenseView.h"
#import "HEMIntroDescriptionView.h"
#import "HEMRootViewController.h"

typedef NS_ENUM(NSUInteger, HEMWelcomePage) {
    HEMWelcomePageMeetSense = 0,
    HEMWelcomeIntroPageSmartAlarm = 1,
    HEMWelcomeIntroPageMeetTimeline = 2,
    HEMWelcomeIntroPageMeetSleepScore = 3,
    HEMWelcomeIntroPageMeetCurrentConditions = 4
};

@interface HEMWelcomeViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *introImageView;
@property (weak, nonatomic) IBOutlet UIImageView *introSecondImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *contentPageControl;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logInButtonTrailingConstraint;

@property (weak, nonatomic) HEMMeetSenseView* meetSenseView;
@property (assign, nonatomic) CGFloat previousScrollOffsetX;
@property (assign, nonatomic) CGFloat origLogInTrailingConstraintConstant;
@property (weak, nonatomic) UIImageView* currentIntroImageView;
@property (weak, nonatomic) UIImageView* nextIntroImageView;

@end

@implementation HEMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideStatusBar:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self hideStatusBar:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (![self meetSenseView]) {
        [self configureContent];
    }
}

- (void)hideStatusBar:(BOOL)hide {
    HEMRootViewController* root = [HEMRootViewController rootViewControllerForKeyWindow];
    if (hide) {
        [root hideStatusBar];
    } else {
        [root showStatusBar];
    }
}

- (void)configureAppearance {
    // controller is launched in to a container controller that is styled and
    // always shows a left bar button, which we don't want
    [[self navigationItem] setLeftBarButtonItem:nil];
    
    [[[self logInButton] titleLabel] setFont:[UIFont welcomeButtonFont]];
    [[self logInButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[[self signUpButton] titleLabel] setFont:[UIFont welcomeButtonFont]];
    [[self signUpButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self setOrigLogInTrailingConstraintConstant:[[self logInButtonTrailingConstraint] constant]];
}

- (void)configureContent {
    [[self introImageView] setAlpha:0.0f];
    
    CGRect contentBounds = [[self contentScrollView] bounds];
    
    // initial page / screen in the content
    HEMMeetSenseView* meetSense = [HEMMeetSenseView createMeetSenseViewWithFrame:contentBounds];
    [[meetSense videoButton] setTitleColor:[UIColor welcomeVideoButtonColor] forState:UIControlStateNormal];
    [[meetSense videoButton] addTarget:self
                                action:@selector(playVideo:)
                      forControlEvents:UIControlEventTouchUpInside];
    [self setMeetSenseView:meetSense];
    
    // add all the content screens
    CGSize contentSize = [[self contentScrollView] contentSize];
    contentSize.width += CGRectGetWidth([meetSense bounds]);
    
    [[self contentScrollView] addSubview:meetSense];
    for (NSUInteger i = HEMWelcomeIntroPageSmartAlarm; i <= HEMWelcomeIntroPageMeetCurrentConditions; i++) {
        UIView* introView = [self introViewForPage:i];
        [[self contentScrollView] addSubview:introView];
        contentSize.width += CGRectGetWidth([introView bounds]);
    }
    
    [[self contentScrollView] setContentSize:contentSize];
}

- (UIView*)introViewForPage:(NSUInteger)page {
    CGFloat bottomOfIntroImageView = CGRectGetHeight([[self introImageView] bounds]);
    CGFloat contentFullHeight = CGRectGetHeight([[self contentScrollView] bounds]);
    CGFloat contentFullWidth = CGRectGetWidth([[self contentScrollView] bounds]);
    CGFloat viewHeight = contentFullHeight - bottomOfIntroImageView;
    CGFloat viewXOrigin = contentFullWidth * page;
    
    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(viewXOrigin, bottomOfIntroImageView);
    frame.size = CGSizeMake(contentFullWidth, viewHeight);
    
    NSString* title = [self introTitleForPage:page];
    NSString* desc = [self introDescriptionForPage:page];
    return [HEMIntroDescriptionView createDescriptionViewWithFrame:frame
                                                             title:title
                                                    andDescription:desc];
}

- (UIImage*)introImageForPage:(NSUInteger)page {
    switch (page) {
        case HEMWelcomeIntroPageSmartAlarm:
            return [UIImage imageNamed:@"introSmartAlarm"];
        case HEMWelcomeIntroPageMeetTimeline:
            return [UIImage imageNamed:@"introTimeline"];
        case HEMWelcomeIntroPageMeetSleepScore:
            return [UIImage imageNamed:@"introSleepScore"];
        case HEMWelcomeIntroPageMeetCurrentConditions:
            return [UIImage imageNamed:@"introConditions"];
        case HEMWelcomePageMeetSense:
        default:
            return nil;
    }
}

- (NSString*)introTitleForPage:(NSUInteger)page {
    switch (page) {
        case HEMWelcomeIntroPageSmartAlarm:
            return NSLocalizedString(@"welcome.intro.title.alarm", nil);
        case HEMWelcomeIntroPageMeetTimeline:
            return NSLocalizedString(@"welcome.intro.title.timeline", nil);
        case HEMWelcomeIntroPageMeetSleepScore:
            return NSLocalizedString(@"welcome.intro.title.sleep-score", nil);
        case HEMWelcomeIntroPageMeetCurrentConditions:
            return NSLocalizedString(@"welcome.intro.title.current-conditions", nil);
        case HEMWelcomePageMeetSense:
        default:
            return nil;
    }
}

- (NSString*)introDescriptionForPage:(NSUInteger)page {
    switch (page) {
        case HEMWelcomeIntroPageSmartAlarm:
            return NSLocalizedString(@"welcome.intro.desc.alarm", nil);
        case HEMWelcomeIntroPageMeetTimeline:
            return NSLocalizedString(@"welcome.intro.desc.timeline", nil);
        case HEMWelcomeIntroPageMeetSleepScore:
            return NSLocalizedString(@"welcome.intro.desc.sleep-score", nil);
        case HEMWelcomeIntroPageMeetCurrentConditions:
            return NSLocalizedString(@"welcome.intro.desc.current-conditions", nil);
        case HEMWelcomePageMeetSense:
        default:
            return nil;
    }
}

#pragma mark - Actions

- (void)playVideo:(UIButton*)videoButton {
    NSURL* introductoryVideoURL = [NSURL URLWithString:NSLocalizedString(@"video.url.intro", nil)];
    MPMoviePlayerViewController* videoPlayer
        = [[MPMoviePlayerViewController alloc] initWithContentURL:introductoryVideoURL];
    [self presentMoviePlayerViewControllerAnimated:videoPlayer];
    [SENAnalytics track:kHEMAnalyticsEventVideo];
}

// log in and sign up actions are done through segues in the storyboard

#pragma mark - Scrolling

- (void)crossFadeIntroImageWithPagePercentage:(CGFloat)percentage
                                  forNextPage:(NSUInteger)nextPage
                              andPreviousPage:(NSUInteger)prevPage {
    UIImage* nextImage = [self introImageForPage:nextPage];
    UIImage* prevImage = [self introImageForPage:prevPage];
    
    if ([[[self introImageView] image] isEqual:prevImage]) {
        
        [self updateImageView:[self introSecondImageView]
                    withImage:nextImage
               pagePercentage:percentage];
        
    } else {
        
        [self updateImageView:[self introImageView]
                    withImage:nextImage
               pagePercentage:percentage];
        
    }
}

- (void)updateImageView:(UIImageView*)imageView
              withImage:(UIImage*)image
         pagePercentage:(CGFloat)pagePercentage {
    
    UIImageView* secondaryImageView = nil;
    if (imageView == [self introImageView]) {
        secondaryImageView = [self introSecondImageView];
    } else {
        secondaryImageView = [self introImageView];
    }
    
    [imageView setImage:image];
    [imageView setAlpha:1 - pagePercentage];
    [secondaryImageView setAlpha:pagePercentage];
}

- (void)updateActionButtonLayoutWithPercentage:(CGFloat)percentage {
    CGFloat halfWidth = CGRectGetWidth([[self view] bounds]) / 2.0f;
    CGFloat hiddenConstant = halfWidth + (2 * [self origLogInTrailingConstraintConstant]);
    [[self logInButtonTrailingConstraint] setConstant:percentage * hiddenConstant];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = [scrollView contentOffset].x;
    CGFloat maxOffsetX = [scrollView contentSize].width;
    CGFloat pageWidth = CGRectGetWidth([scrollView bounds]);
    CGFloat totalPercentage = offsetX / pageWidth;
    
    if (offsetX >= 0.0f && offsetX <= maxOffsetX) {
        CGFloat pageWidth = CGRectGetWidth([scrollView bounds]);
        CGFloat totalPercentage = offsetX / pageWidth;
        BOOL movingRight = offsetX > [self previousScrollOffsetX];
        NSUInteger nextPage = movingRight ? ceilCGFloat(totalPercentage) : floorCGFloat(totalPercentage);
        NSUInteger prevPage = movingRight ? nextPage - 1 : nextPage + 1;
        CGFloat pagePercentage = absCGFloat(nextPage - totalPercentage);
        
        if (movingRight && nextPage == HEMWelcomeIntroPageSmartAlarm) {
            
            [self updateActionButtonLayoutWithPercentage:1 - pagePercentage];
            
            if (pagePercentage < 0.25f) {
                
                [self updateImageView:[self introImageView]
                            withImage:[self introImageForPage:nextPage]
                       pagePercentage:pagePercentage];
                
            }
            
        } else if (!movingRight && nextPage == HEMWelcomePageMeetSense) {
            
            [self updateActionButtonLayoutWithPercentage:pagePercentage];
            [[self introSecondImageView] setImage:nil];
            [[self introImageView] setAlpha:pagePercentage];
            
        } else if (nextPage >= HEMWelcomeIntroPageSmartAlarm
                   && nextPage <= HEMWelcomeIntroPageMeetCurrentConditions) {
            
            [self crossFadeIntroImageWithPagePercentage:pagePercentage
                                            forNextPage:nextPage
                                        andPreviousPage:prevPage];
            
        }
    }
    
    [[self contentPageControl] setCurrentPage:roundCGFloat(totalPercentage)];
    [self setPreviousScrollOffsetX:offsetX];
}

@end
