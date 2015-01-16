//
//  HEMTrendsViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAPITrends.h>
#import <SenseKit/SENTrend.h>
#import "HEMTrendsViewController.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMCardFlowLayout.h"
#import "HEMTrendCollectionViewCell.h"
#import "HEMEmptyTrendCollectionViewCell.h"
#import "HEMGraphSectionOverlayView.h"

@interface HEMTrendsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, HEMTrendCollectionViewCellDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* defaultTrends;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@end

@implementation HEMTrendsViewController

static CGFloat const HEMTrendsViewCellHeight = 184.f;
static CGFloat const HEMTrendsViewOptionsCellHeight = 235.f;

static NSString* const HEMScoreTrendType = @"SLEEP_SCORE";
static NSString* const HEMDurationTrendType = @"SLEEP_DURATION";
static NSString* const HEMDayOfWeekScopeType = @"DOW";
static NSString* const HEMMonthScopeType = @"M";
static NSString* const HEMWeekScopeType = @"W";
static NSString* const HEMAllScopeType = @"ALL";

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.image = [HelloStyleKit trendsBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView setAlwaysBounceVertical:YES];
    HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
    [layout setItemHeight:184];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)refreshData
{
    if ([self isLoading])
        return;
    self.loading = YES;
    [SENAPITrends defaultTrendsListWithCompletion:^(NSArray* data, NSError *error) {
        if (error) {
            self.loading = NO;
            [self.collectionView reloadData];
            return;
        }
        self.defaultTrends = [data mutableCopy];
        HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
        [layout clearCache];
        [self.collectionView reloadData];
        self.loading = NO;
    }];
}

#pragma mark HEMTrendCollectionViewCellDelegate

- (void)didTapTimeScopeInCell:(HEMTrendCollectionViewCell *)cell withText:(NSString *)text
{
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath)
        return;
    SENTrend* trend = self.defaultTrends[indexPath.row];
    void (^completion)(NSArray*,NSError*) = ^(NSArray* data, NSError *error) {
        if (error) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else if (![[data firstObject] isKindOfClass:[SENTrend class]]) {
            cell.statusLabel.hidden = NO;
            cell.statusLabel.text = NSLocalizedString(@"trends.not-enough-data.message", nil);
        } else {
            SENTrend* trend = [data firstObject];
            [self.defaultTrends replaceObjectAtIndex:indexPath.row withObject:trend];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        self.loading = NO;
    };
    self.loading = YES;
    [cell showGraphOfType:HEMTrendCellGraphTypeNone withData:nil];
    cell.statusLabel.text = NSLocalizedString(@"activity.loading", nil);
    if ([trend.dataType isEqualToString:HEMScoreTrendType]) {
        [SENAPITrends sleepScoreTrendForTimePeriod:text completion:completion];
    } else if ([trend.dataType isEqualToString:HEMDurationTrendType]) {
        [SENAPITrends sleepDurationTrendForTimePeriod:text completion:completion];
    } else {
        cell.statusLabel.text = NSLocalizedString(@"trends.not-enough-data.message", nil);
    }
}

#pragma mark UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HEMCardFlowLayout* layout = (id)collectionViewLayout;
    CGFloat width = layout.itemSize.width;
    if (self.defaultTrends.count == 0) {
        return CGSizeMake(width, layout.itemSize.height);
    }
    SENTrend* trend = self.defaultTrends[indexPath.row];
    CGFloat height = trend.options.count > 0 ? HEMTrendsViewOptionsCellHeight : HEMTrendsViewCellHeight;
    return CGSizeMake(width, height);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.defaultTrends.count > 0 ? self.defaultTrends.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* attributes = @{NSKernAttributeName: @(2.2)};
    if (self.defaultTrends.count == 0) {
        return [self collectionView:collectionView emptyCellForItemAtIndexPath:indexPath];
    }
    SENTrend* trend = self.defaultTrends[indexPath.row];
    NSAttributedString* title = [[NSAttributedString alloc] initWithString:trend.title attributes:attributes];;
    if (trend.dataPoints.count <= 2) {
        HEMEmptyTrendCollectionViewCell* cell = [self collectionView:collectionView emptyCellForItemAtIndexPath:indexPath];
        cell.titleLabel.attributedText = title;
        return cell;
    }
    NSString* identifier = [HEMMainStoryboard trendGraphReuseIdentifier];
    HEMTrendCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                 forIndexPath:indexPath];
    cell.titleLabel.attributedText = title;
    cell.statusLabel.hidden = YES;
    cell.delegate = self;
    [self configureGraphForCell:cell withTrend:trend];
    return cell;
}

- (HEMEmptyTrendCollectionViewCell*)collectionView:(UICollectionView *)collectionView emptyCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard overTimeReuseIdentifier];
    NSDictionary* attributes = @{NSKernAttributeName: @(2.2)};
    HEMEmptyTrendCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                      forIndexPath:indexPath];
    if ([self isLoading]) {
        cell.titleLabel.text = nil;
        cell.detailLabel.text = NSLocalizedString(@"activity.loading", nil);
    } else {
        NSString* title = [NSLocalizedString(@"trends.not-enough.data.title", nil) uppercaseString];
        cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
        cell.detailLabel.text = NSLocalizedString(@"trends.not-enough.data.message", nil);
    }
    return cell;
}

- (void)configureGraphForCell:(HEMTrendCollectionViewCell*)cell withTrend:(SENTrend*)trend
{
    NSString* period = trend.timePeriod;
    HEMTrendCellGraphType type = trend.graphType == SENTrendGraphTypeTimeSeriesLine
        ? HEMTrendCellGraphTypeLine : HEMTrendCellGraphTypeBar;
    BOOL useBarGraph = (type == HEMTrendCellGraphTypeBar);
    [cell setTimeScopesWithOptions:trend.options selectedOptionIndex:[trend.options indexOfObject:period]];
    cell.numberOfGraphSections = type == HEMTrendCellGraphTypeBar ? trend.dataPoints.count : 7;
    if ([period isEqualToString:HEMDayOfWeekScopeType]) {
        cell.showGraphLabels = YES;
        cell.topLabelType = HEMTrendCellGraphLabelTypeDayOfWeek;
        cell.bottomLabelType = HEMTrendCellGraphLabelTypeValue;
    } else if ([period hasSuffix:HEMMonthScopeType] && period.length == 2) {
        cell.showGraphLabels = YES;
        cell.topLabelType = HEMTrendCellGraphLabelTypeNone;
        NSInteger months = [[period substringWithRange:NSMakeRange(0, 1)] integerValue];
        if (months > 1) {
            cell.bottomLabelType = HEMTrendCellGraphLabelTypeMonth;
            if (!useBarGraph)
                cell.numberOfGraphSections = months;
        } else {
            cell.bottomLabelType = HEMTrendCellGraphLabelTypeDate;
        }
    } else if ([period hasSuffix:HEMWeekScopeType] && period.length == 2) {
        NSInteger weeks = [[period substringWithRange:NSMakeRange(0, 1)] integerValue];
        cell.showGraphLabels = YES;
        cell.topLabelType = HEMTrendCellGraphLabelTypeNone;
        cell.bottomLabelType = weeks < 2 ? HEMTrendCellGraphLabelTypeDayOfWeek : HEMTrendCellGraphLabelTypeDate;
    } else {
        cell.showGraphLabels = useBarGraph;
    }
    [cell showGraphOfType:type withData:trend.dataPoints];
}

@end
