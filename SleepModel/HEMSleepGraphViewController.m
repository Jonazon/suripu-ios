
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAuthorizationService.h>
#import <markdown_peg.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSleepResult.h>
#import <UIImageEffects/UIImage+ImageEffects.h>

#import "HelloStyleKit.h"
#import "HEMAlertController.h"
#import "HEMAppDelegate.h"
#import "HEMRootViewController.h"
#import "HEMAudioCache.h"
#import "HEMMainStoryboard.h"
#import "HEMPaddedRoundedLabel.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphUtils.h"
#import "HEMSleepGraphView.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepSummarySlideViewController.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMZoomAnimationTransitionDelegate.h"

CGFloat const HEMTimelineHeaderCellHeight = 50.f;
CGFloat const HEMTimelineFooterCellHeight = 50.f;

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, retain) HEMSleepGraphView* view;
@property (nonatomic, strong) HEMSleepHistoryViewController* historyViewController;
@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
@property (nonatomic, strong) HEMZoomAnimationTransitionDelegate* animationDelegate;
@property (nonatomic, strong) NSIndexPath* expandedIndexPath;
@property (nonatomic, getter=presleepSectionIsExpanded) BOOL presleepExpanded;
@end

@implementation HEMSleepGraphViewController

static CGFloat const HEMSleepSummaryCellHeight = 350.f;
static CGFloat const HEMPresleepItemExpandedCellHeight = 196.f;
static CGFloat const HEMPresleepItemDefaultCellHeight = 134.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 40.f;
static CGFloat const HEMSleepGraphCollectionViewEventMaximumHeight = 184.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;
static CGFloat const HEMTopItemsConstraintConstant = 10.f;
static CGFloat const HEMTopItemsMinimumConstraintConstant = -6.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    [self reloadData];
    self.animationDelegate = [HEMZoomAnimationTransitionDelegate new];
    self.transitioningDelegate = self.animationDelegate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.panePanGestureRecognizer.delegate = self;
    [self checkForDateChanges];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.panePanGestureRecognizer.delegate = self;
    [self registerForNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.panePanGestureRecognizer.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidPop
{
    [UIView animateWithDuration:0.5f animations:^{
        self.collectionView.contentOffset = CGPointMake(0, 0);
        [self updateTopBarActionsWithState:NO];
    }];
}

- (void)viewDidPush
{
    self.panePanGestureRecognizer.delegate = self;
    [UIView animateWithDuration:0.5f animations:^{
        [self updateTopBarActionsWithState:YES];
    }];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData)
                                                 name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
}

- (void)dealloc {
    _historyViewController = nil;
    _dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark HEMSleepGraphActionDelegate

- (void)toggleDrawer
{
    HEMAppDelegate* delegate = (id)[UIApplication sharedApplication].delegate;
    HEMRootViewController* root = (id)delegate.window.rootViewController;
    [root toggleSettingsDrawer];
}

- (BOOL)shouldEnableZoomButton
{
    return [self isViewPushed];
}

- (BOOL)shouldHideShareButton
{
    return ![self isViewPushed] || [self.dataSource.sleepResult.score integerValue] == 0;
}

- (void)willShowDetailsForInsight:(SENSleepResultSensorInsight *)insight
{
    if (![self presleepSectionIsExpanded]) {
        self.presleepExpanded = YES;
        [self animateAllCellHeightChanges];
    }
}

- (void)willHideInsightDetails
{
    if ([self presleepSectionIsExpanded]) {
        self.presleepExpanded = NO;
        [self animateAllCellHeightChanges];
    }
}

#pragma mark Top cell actions

- (void)updateTopBarActionsWithState:(BOOL)pushed
{
    self.collectionView.scrollEnabled = pushed;
    UIImage* drawerIcon = pushed ? [UIImage imageNamed:@"Menu"] : [UIImage imageNamed:@"caret up"];
    CGFloat constant = pushed ? HEMTopItemsConstraintConstant : HEMTopItemsMinimumConstraintConstant;
    HEMSleepSummaryCollectionViewCell* cell = self.dataSource.sleepSummaryCell;
    [cell.shareButton setHidden:!pushed || self.dataSource.numberOfSleepSegments == 0];
    [cell.dateButton setAlpha:pushed ? 1.f : 0.5f];
    [cell.dateButton setEnabled:pushed];
    [cell.drawerButton setImage:drawerIcon forState:UIControlStateNormal];
    cell.topItemsVerticalConstraint.constant = constant;
    [cell updateConstraintsIfNeeded];
}

- (void)drawerButtonTapped:(UIButton*)button
{
    [self toggleDrawer];
}

- (void)shareButtonTapped:(UIButton*)button
{
    long score = [self.dataSource.sleepResult.score longValue];
    if (score > 0) {
        NSString* message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.format", nil), score];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)zoomButtonTapped:(UIButton*)sender
{
    if (![self isViewPushed])
        return;
    self.historyViewController = (id)[HEMMainStoryboard instantiateSleepHistoryController];
    self.historyViewController.selectedDate = self.dateForNightOfSleep;
    self.historyViewController.transitioningDelegate = self.animationDelegate;
    [self presentViewController:self.historyViewController animated:YES completion:NULL];
}

- (void)checkForDateChanges
{
    if (self.historyViewController.selectedDate) {
        [self loadDataSourceForDate:self.historyViewController.selectedDate];
//        HEMSleepSummarySlideViewController* parent = (id)self.parentViewController;
//        [parent reloadData];
    }

    self.historyViewController = nil;
}

- (void)loadDataSourceForDate:(NSDate*)date
{
    self.dateForNightOfSleep = date;
    self.expandedIndexPath = nil;
    self.dataSource = [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                                  sleepDate:date];
    self.collectionView.dataSource = self.dataSource;
    [self.collectionView reloadData];
}

#pragma mark Event Info

- (void)didTapEventButton:(UIButton*)sender
{
    NSIndexPath* indexPath = [self indexPathForEventCellWithSubview:sender];
    HEMSleepEventCollectionViewCell* cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    BOOL shouldExpand = ![self.expandedIndexPath isEqual:indexPath];
    if (shouldExpand) {
        if (self.expandedIndexPath) {
            HEMSleepEventCollectionViewCell* oldCell = (id)[self.collectionView cellForItemAtIndexPath:self.expandedIndexPath];
            [oldCell useExpandedLayout:NO animated:YES];
        }
        self.expandedIndexPath = indexPath;
    } else {
        self.expandedIndexPath = nil;
    }
    [cell useExpandedLayout:shouldExpand animated:YES];
    [self animateAllCellHeightChanges];
    CGRect cellRect = [self.collectionView convertRect:cell.frame toView:self.collectionView.superview];
    if (shouldExpand && !CGRectContainsRect(self.collectionView.frame, cellRect))
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                animated:YES];
}

- (void)didTapDataVerifyButton:(UIButton*)sender
{

    NSIndexPath* indexPath = [self indexPathForEventCellWithSubview:sender];
    [HEMSleepGraphUtils presentTimePickerForDate:self.dateForNightOfSleep
                                         segment:[self.dataSource sleepSegmentForIndexPath:indexPath]
                                  fromController:self];
}

- (NSIndexPath*)indexPathForEventCellWithSubview:(UIView*)view
{
    UIView* superview = view.superview;
    if (superview) {
        if ([superview isKindOfClass:[HEMSleepEventCollectionViewCell class]])
            return [self.collectionView indexPathForCell:(UICollectionViewCell*)superview];
        else
            return [self indexPathForEventCellWithSubview:superview];
    }
    return nil;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)isViewPushed
{
    CGPoint location = [self.view.superview convertPoint:self.view.frame.origin fromView:nil];
    return location.y > -10.f;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return self.collectionView.contentOffset.y < 20.f;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return [self.collectionView contentSize].height > CGRectGetHeight([self.collectionView bounds]);
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:[self view]];
    return fabsf(translation.y) > fabsf(translation.x);
}

#pragma mark UICollectionViewDelegate

- (void)reloadData
{
    if (![SENAuthorizationService isAuthorized])
        return;

    [self loadDataSourceForDate:self.dateForNightOfSleep];
}

- (void)configureCollectionView
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    return [cell isKindOfClass:[HEMSleepEventCollectionViewCell class]];
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
        HEMSleepEventCollectionViewCell* eventCell = (HEMSleepEventCollectionViewCell*)cell;
        [eventCell.eventTypeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.expandedIndexPath isEqual:indexPath]) {
        HEMSleepEventCollectionViewCell* eventCell = (id)cell;
        [eventCell useExpandedLayout:YES animated:NO];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (void)animateAllCellHeightChanges
{
    [self.collectionView setCollectionViewLayout:[UICollectionViewFlowLayout new] animated:YES];
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return CGSizeMake(width, hasSegments ? HEMSleepSummaryCellHeight : CGRectGetHeight(self.view.bounds));

    case HEMSleepGraphCollectionViewPresleepSection: {
        return CGSizeMake(width, [self presleepSectionIsExpanded]
                          ? HEMPresleepItemExpandedCellHeight : HEMPresleepItemDefaultCellHeight);
    }
    case HEMSleepGraphCollectionViewSegmentSection: {
        SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
        CGFloat durationHeight = [self heightForCellWithSegment:segment];
        if ([self.dataSource segmentForSleepExistsAtIndexPath:indexPath]) {
            return CGSizeMake(width, ceilf(durationHeight));
        } else if ([self.expandedIndexPath isEqual:indexPath]) {
            return CGSizeMake(width, HEMSleepGraphCollectionViewEventMaximumHeight);
        } else {
            return CGSizeMake(width, MAX(durationHeight, HEMSleepGraphCollectionViewEventMinimumHeight));
        }
    }

    default:
        return CGSizeMake(width, HEMSleepGraphCollectionViewEventMinimumHeight);
    }
}

- (CGFloat)heightForCellWithSegment:(SENSleepResultSegment*)segment
{
    return ([segment.duration doubleValue] / 3600) * (CGRectGetHeight([UIScreen mainScreen].bounds)
                                                      / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    if (!hasSegments || section != HEMSleepGraphCollectionViewSegmentSection)
        return CGSizeZero;

    return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineHeaderCellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    if (!hasSegments || section != HEMSleepGraphCollectionViewSegmentSection)
        return CGSizeZero;

    return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineFooterCellHeight);
}

- (CGFloat)collectionView:(UICollectionView*)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
