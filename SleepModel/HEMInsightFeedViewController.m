//
//  HEMInsightFeedViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SenseKit.h>

#import "UIView+HEMSnapshot.h"

#import "HEMInsightFeedViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMInsightsFeedDataSource.h"
#import "HEMQuestionCell.h"
#import "HelloStyleKit.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMInsightViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSinkModalTransition.h"
#import "HEMBounceModalTransition.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMAppReview.h"
#import "HEMSleepQuestionsDataSource.h"

@interface HEMInsightFeedViewController () <
    UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak,   nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) HEMInsightsFeedDataSource* dataSource;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> sinkTransition;
@property (strong, nonatomic) id <UIViewControllerTransitioningDelegate> questionsTransition;

@end

@implementation HEMInsightFeedViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"insights.title", nil);
        self.tabBarItem.image = [HelloStyleKit senseBarIcon];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"senseBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HEMSinkModalTransition* modalTransitionDelegate = [[HEMSinkModalTransition alloc] init];
    [modalTransitionDelegate setSinkView:[self view]];
    [self setSinkTransition:modalTransitionDelegate];
    
    [self setDataSource:[[HEMInsightsFeedDataSource alloc] initWithQuestionTarget:self
                                                             questionSkipSelector:@selector(skipQuestions:)
                                                           questionAnswerSelector:@selector(answerQuestions:)]];
    
    [[self collectionView] setDataSource:[self dataSource]];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setAlwaysBounceVertical:YES];
}

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reload];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload)
                                                 name:SENAPIReachableNotification object:nil];
    
    [SENAnalytics track:kHEMAnalyticsEventFeed];
    
}

- (void)updateLastViewed:(HEMUnreadType)type {
    __weak typeof(self) weakSelf = self;
    [[self dataSource] updateLastViewed:type completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
        } else {
            [strongSelf updateUnreadIndicator];
        }
    }];
}

- (void)updateUnreadIndicator {
    BOOL hasUnreadInsightQuestions = [[self dataSource] hasUnreadItems];
    [[self tabBarItem] setBadgeValue:hasUnreadInsightQuestions ? @"1" : nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self updateUnreadIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    if ([[self dataSource] isLoading]) return;
    
    __weak typeof(self) weakSelf = self;
    [[self dataSource] refresh:^(BOOL didUpdate){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!didUpdate)
            return;
        
        [strongSelf updateLastViewed:HEMUnreadTypeInsights];
        [[strongSelf collectionView] reloadData];
    }];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = [layout itemSize];
    CGFloat textPadding = [[self dataSource] bodyTextPaddingForCellAtIndexPath:indexPath];
    itemSize.height = [[self dataSource] heightForCellAtIndexPath:indexPath
                                                        withWidth:itemSize.width - (textPadding*2)];
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [[self dataSource] displayCell:cell atIndexPath:indexPath];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SENInsight* insight = [[self dataSource] insightAtIndexPath:indexPath];
    if (insight != nil) {
        [self showInsight:insight];
    }
}


- (void)removeCellAtIndexPath:(NSIndexPath*)indexPath {
    [[self collectionView] performBatchUpdates:^{
        [[self dataSource] removeQuestionAtIndexPath:indexPath];
        [[self collectionView] deleteItemsAtIndexPaths:@[indexPath]];
    } completion:nil];
}

#pragma mark - Insights

- (void)showInsight:(SENInsight*)insight {
    HEMInsightViewController* insightVC
        = (HEMInsightViewController*)[HEMMainStoryboard instantiateSleepInsightViewController];
    [insightVC setInsight:insight];
    [insightVC setModalPresentationStyle:UIModalPresentationCustom];
    [insightVC setTransitioningDelegate:[self sinkTransition]];
    [self presentViewController:insightVC animated:YES completion:nil];
}

#pragma mark - Questions

- (void)answerQuestions:(UIButton*)sender {
    HEMSleepQuestionsViewController* qVC
        = (HEMSleepQuestionsViewController*)[HEMMainStoryboard instantiateSleepQuestionsViewController];
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    SENQuestion* question = [[self dataSource] questionAtIndexPath:path];
    
    id<HEMQuestionsDataSource> dataSource = nil;
    if ([question isKindOfClass:[HEMAppReviewQuestion class]]) {
        dataSource = [[HEMAppReviewQuestionsDataSource alloc] initWithAppReviewQuestion:(id)question];
        [SENAnalytics track:HEMAnalyticsEventAppReviewStart];
    } else {
        dataSource = [[HEMSleepQuestionsDataSource alloc] init];
    }
    [qVC setDataSource:dataSource];
    
    if ([self questionsTransition] == nil) {
        HEMBounceModalTransition* transition = [[HEMBounceModalTransition alloc] init];
        [transition setMessage:NSLocalizedString(@"sleep.questions.end.message", nil)];
        [self setQuestionsTransition:transition];
    }
    
    HEMStyledNavigationViewController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:qVC];
    [nav setModalPresentationStyle:UIModalPresentationCustom];
    [nav setTransitioningDelegate:[self questionsTransition]];
    
    [self presentViewController:nav animated:YES completion:^{
        [self removeCellAtIndexPath:path];
    }];
}

- (void)skipQuestions:(UIButton*)sender {
    [sender setEnabled:NO];
    NSIndexPath* path = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    SENQuestion* question = [[self dataSource] questionAtIndexPath:path];
    if ([question isKindOfClass:[HEMAppReviewQuestion class]]) {
        [HEMAppReview markAppReviewPromptCompleted];
        [SENAnalytics track:HEMAnalyticsEventAppReviewSkip];
        [self removeCellAtIndexPath:path];
        [sender setEnabled:YES];
    } else {
        __weak typeof(self) weakSelf = self;
        [[SENServiceQuestions sharedService] skipQuestion:question completion:^(NSError *error) {
            [weakSelf removeCellAtIndexPath:path];
            [weakSelf updateLastViewed:HEMUnreadTypeQuestions];
            [sender setEnabled:YES];
        }];
    }
}

#pragma mark - Clean Up

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end