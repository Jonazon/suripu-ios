
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import "HEMSleepGraphCollectionViewController.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewFlowLayout.h"
#import "HEMSensorDataHeaderView.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HelloStyleKit.h"
#import "HEMFakeDataGenerator.h"

@interface HEMSleepGraphCollectionViewController () <UICollectionViewDelegateFlowLayout, FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
@property (nonatomic, weak) HEMSensorDataHeaderView* sensorDataHeaderView;
@property (nonatomic) UIStatusBarStyle oldBarStyle;
@end

@implementation HEMSleepGraphCollectionViewController

static CGFloat const HEMSleepHistoryViewSensorViewHeight = 65.f;
static CGFloat const HEMSleepHistoryViewEventMinimumHeight = 55.f;
static CGFloat const HEMSleepHistoryViewEventMaximumHeight = 95.f;
static CGFloat const HEMSleepHistoryViewNumberOfHoursOnscreen = 4.f;
static CGFloat const HEMSleepSummaryCellHeight = 300.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                        sleepData:[HEMFakeDataGenerator sleepDataForDate:self.dateForNightOfSleep]];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewLayout = [HEMSleepGraphCollectionViewFlowLayout new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.panePanGestureRecognizer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.panePanGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.panePanGestureRecognizer.delegate = nil;
}

- (void)viewDidPop
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.oldBarStyle];
    self.collectionView.scrollEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.collectionView.contentOffset = CGPointMake(0, 0);
        self.view.backgroundColor = [HelloStyleKit lightestBlueColor];
    }];
    self.oldBarStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidPush
{
    self.panePanGestureRecognizer.delegate = self;
    self.oldBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.1f animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.f];
    }];
    self.collectionView.scrollEnabled = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return self.collectionView.contentOffset.y < 20.f;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [self.dataSource updateSensorViewText];
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* sleepData = [self.dataSource sleepSegmentForIndexPath:indexPath];
    return ![sleepData[@"type"] isEqualToString:@"none"];
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* sleepData = [self.dataSource sleepSegmentForIndexPath:indexPath];
    return ![sleepData[@"type"] isEqualToString:@"none"];
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.dataSource toggleExpansionOfEventCellAtIndexPath:indexPath];
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return CGSizeMake(width, HEMSleepSummaryCellHeight);

    case HEMSleepGraphCollectionViewSegmentSection: {
        NSDictionary* sleepData = [self.dataSource sleepSegmentForIndexPath:indexPath];

        CGFloat durationHeight = ([sleepData[@"duration"] doubleValue] / 1000 / 3600) * (CGRectGetHeight([UIScreen mainScreen].bounds) / HEMSleepHistoryViewNumberOfHoursOnscreen);
        if ([sleepData[@"type"] isEqualToString:@"none"]) {
            return CGSizeMake(width, durationHeight);
        } else {
            if ([self.dataSource eventCellAtIndexPathIsExpanded:indexPath]) {
                return CGSizeMake(width, HEMSleepHistoryViewEventMaximumHeight);
            } else {
                return CGSizeMake(width, MAX(durationHeight, HEMSleepHistoryViewEventMinimumHeight));
            }
        }
    }

    case HEMSleepGraphCollectionViewHistorySection:
    default:
        return CGSizeMake(width, HEMSleepHistoryViewEventMinimumHeight);
    }
}

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case HEMSleepGraphCollectionViewSegmentSection:
        return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMSleepHistoryViewSensorViewHeight);

    default:
        return CGSizeZero;
    }
}

@end