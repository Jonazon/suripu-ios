//
//  HEMInsightPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>

#import <SenseKit/SENInsight.h>
#import "SENRemoteImage+HEMDeviceSpecific.h"

#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "NSShadow+HEMStyle.h"
#import "UIImage+HEMPixelColor.h"

#import "HEMInsightPresenter.h"
#import "HEMInsightsService.h"
#import "HEMMainStoryboard.h"
#import "HEMMarkdown.h"
#import "HEMURLImageView.h"
#import "HEMImageCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMLoadingCollectionViewCell.h"
#import "HEMActivityIndicatorView.h"
#import "HEMInsightCollectionViewCell.h"

typedef NS_ENUM(NSInteger, HEMInsightRow) {
    HEMInsightRowImage = 0,
    HEMInsightRowTitleOrLoading,
    HEMInsightRowDetail,
    HEMInsightAbout,
    HEMInsightRowSummary,
    HEMInsightRowCount
};

static NSString* const HEMInsightHeaderReuseId = @"header";

static NSInteger const HEMInsightRowCountWhileLoading = 2;
static NSInteger const HEMInsightRowCountForGenerics = 3;

static CGFloat const HEMInsightCellSummaryTopMargin = 20.0f;
static CGFloat const HEMInsightCellSummaryBotMargin = 33.0f;
static CGFloat const HEMInsightCellSummaryLeftMargin = 50.0f; // 48 + 2 for divider
static CGFloat const HEMInsightCellSummaryRightMargin = 24.0f;

static CGFloat const HEMInsightCellTitleTopMargin = 32.0f;
static CGFloat const HEMInsightCellTitleBotMargin = 12.0f;

static CGFloat const HEMInsightCellDetailBotMarginForGenerics = 32.0f;

static CGFloat const HEMInsightCellAboutTopMargin = 36.0f;

static CGFloat const HEMInsightCellTextHorizontalMargin = 24.0f;
static CGFloat const HEMInsightCellHeightImage = 178.66f; // keep aspect ratio relatively the same as insight card
static CGFloat const HEMInsightTextAppearanceAnimation = 0.6f;

@interface HEMInsightPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) HEMInsightsService* insightsService;
@property (nonatomic, strong) SENInsight* insight;
@property (nonatomic, strong) SENInsightInfo* insightDetail;
@property (nonatomic, strong) NSError* loadError;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSAttributedString* attributedSummary;
@property (nonatomic, strong) NSAttributedString* attributedTitle;
@property (nonatomic, strong) NSAttributedString* attributedDetail;
@property (nonatomic, strong) NSAttributedString* attributedAbout;
@property (nonatomic, weak) UIImageView* buttonShadow;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) UIColor* imageColor;

@end

@implementation HEMInsightPresenter

- (instancetype)initWithInsightService:(HEMInsightsService*)insightsService
                            forInsight:(SENInsight*)insight {
    self = [super init];
    if (self) {
        _insightsService = insightsService;
        _insight = insight;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView withImageColor:(UIColor*)imageColor {
    [self setImageColor:imageColor];
    [self setCollectionView:collectionView];
    [[self collectionView] setDelegate:self];
    [[self collectionView] setDataSource:self];
    [self loadInfo];
}

- (void)bindWithButtonShadow:(UIImageView*)buttonShadow {
    [buttonShadow setAlpha:0.0f];
    [self setButtonShadow:buttonShadow];
}

- (void)updateCloseButtonShadowOpacity {
    CGFloat contentHeight = [[self collectionView] contentSize].height;
    CGFloat scrollHeight = CGRectGetHeight([[self collectionView] bounds]);
    if (contentHeight > scrollHeight) {
        CGFloat yOffset = [[self collectionView] contentOffset].y;
        CGFloat amountDisplayed = contentHeight - yOffset;
        CGFloat percentage = MIN(1.0f, (amountDisplayed / scrollHeight) - 1.0f);
        [[self buttonShadow] setAlpha:percentage];
    }
}

- (void)loadInfo {
    [self setLoading:YES];
    __weak typeof(self) weakSelf = self;
    [[self insightsService] getInsightForSummary:[self insight] completion:^(SENInsightInfo * _Nullable insight, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [[strongSelf insightErrorDelegate] didFailToLoadInsight:[strongSelf insight]
                                                      fromPresenter:strongSelf];
        }
        [strongSelf setLoading:NO];
        [strongSelf setLoadError:error];
        [strongSelf setInsightDetail:insight];
        [[strongSelf collectionView] reloadData];
        [strongSelf updateCloseButtonShadowOpacity];
    }];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    [self updateCloseButtonShadowOpacity];
}

- (void)didRelayout {
    [super didRelayout];
    
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    
    itemSize.width = CGRectGetWidth([[[self collectionView] superview] bounds]);
    [layout setItemSize:itemSize];
    [[self collectionView] reloadData];
}

#pragma mark - Collection View

#pragma mark Helpers

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        default:
        case HEMInsightRowImage:
            return [HEMMainStoryboard imageReuseIdentifier];
        case HEMInsightAbout:
            return [HEMMainStoryboard aboutReuseIdentifier];
        case HEMInsightRowSummary:
            return [HEMMainStoryboard summaryReuseIdentifier];
        case HEMInsightRowTitleOrLoading:
            return [self isLoading] ? [HEMMainStoryboard loadingReuseIdentifier] : [HEMMainStoryboard titleReuseIdentifier];
        case HEMInsightRowDetail:
            return [HEMMainStoryboard detailReuseIdentifier];
            
    }
}

- (NSAttributedString*)attributedAbout {
    if (!_attributedAbout) {
        NSString* about = [NSLocalizedString(@"insight.about", nil) uppercaseString];
        NSDictionary* attributes = @{NSFontAttributeName : [UIFont h8],
                                     NSForegroundColorAttributeName : [UIColor lowImportanceTextColor]};
        _attributedAbout = [[NSAttributedString alloc] initWithString:about attributes:attributes];
    }
    return _attributedAbout;
}

- (NSAttributedString*)attributedSummary {
    if (!_attributedSummary) {
        NSString* summary = [[[self insight] message] trim];
        if (summary) {
            // use same as insight card attributes
            NSDictionary* attributes = [HEMInsightCollectionViewCell messageAttributes];
            _attributedSummary = [markdown_to_attr_string(summary, 0, attributes) trim];
        }
    }
    return _attributedSummary;
}

- (NSAttributedString*)attributedErrorTitle {
    NSDictionary* attributes = [HEMMarkdown attributesForInsightTitleViewText][@(PARA)];
    NSString* errorTitle = NSLocalizedString(@"sleep.insight.info.title.no-text", nil);
    return [[NSAttributedString alloc] initWithString:errorTitle attributes:attributes];
}

- (NSAttributedString*)attributedErrorBody {
    NSDictionary* attributes = [HEMMarkdown attributesForInsightViewText][@(PARA)];
    NSString* body = NSLocalizedString(@"sleep.insight.info.message.no-text", nil);
    return [[NSAttributedString alloc] initWithString:body attributes:attributes];
}

- (NSAttributedString*)attributedTitle {
    if (!_attributedTitle) {
        NSString* title = [[[self insightDetail] title] trim];
        if (title) {
            NSDictionary* attributes = [HEMMarkdown attributesForInsightTitleViewText][@(PARA)];
            _attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                               attributes:attributes];
        }
    }
    return _attributedTitle;
}

- (NSAttributedString*)attributedDetail {
    if (!_attributedDetail) {
        NSString* detail = [[[self insightDetail] info] trim];
        if (detail) {
            NSDictionary* attributes = [HEMMarkdown attributesForInsightViewText];
            _attributedDetail = [markdown_to_attr_string(detail, 0, attributes) trim];
        }
    }
    return _attributedDetail;
}

- (NSAttributedString*)attributedTextForCellAtIndexPath:(NSIndexPath*)indexPath {
    switch ([indexPath row]) {
        case HEMInsightAbout:
            return [self attributedAbout];
        case HEMInsightRowSummary:
            return [self attributedSummary];
        case HEMInsightRowTitleOrLoading: {
            if ([self isLoading]) {
                return nil;
            } else if ([self loadError]) {
                return [self attributedErrorTitle];
            }
            return [self attributedTitle];
        }
        case HEMInsightRowDetail: {
            if ([self loadError]) {
                return [self attributedErrorBody];
            }
            return [self attributedDetail];
        }
        case HEMInsightRowImage:
        default:
            return nil;
            
    }
}

- (CGFloat)heightForTextCellAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewFlowLayout* layout = (id)[[self collectionView] collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    NSAttributedString* attrText = [self attributedTextForCellAtIndexPath:indexPath];
    CGFloat horizontalMargins = 0.0f;
    
    switch ([indexPath row]) {
        case HEMInsightRowSummary:
            horizontalMargins = HEMInsightCellSummaryLeftMargin + HEMInsightCellSummaryRightMargin;
            break;
        case HEMInsightAbout:
        case HEMInsightRowTitleOrLoading: // if it's asking for text, assume is for summary
        case HEMInsightRowDetail:
            horizontalMargins = HEMInsightCellTextHorizontalMargin * 2;
            break;
        default:
            break;
    }

    CGSize textSize = [attrText sizeWithWidth:itemSize.width - horizontalMargins];
    return textSize.height;
}

- (void)setAttributedText:(NSAttributedString*)attributedText
               inTextCell:(HEMTextCollectionViewCell*)cell {
    
    [[cell textLabel] setAttributedText:attributedText];
    
    [UIView animateWithDuration:HEMInsightTextAppearanceAnimation animations:^{
        [[cell textLabel] setAlpha:1.0f];
    }];
    
}

#pragma mark End of helpers

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger count = HEMInsightRowCount;
    if ([self isLoading]) {
        count = HEMInsightRowCountWhileLoading;
    } else if ([[self insightsService] isGenericInsight:[self insight]]) {
        count = HEMInsightRowCountForGenerics;
    }
    return count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [self reuseIdentifierForIndexPath:indexPath];
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:HEMInsightHeaderReuseId
                                                     forIndexPath:indexPath];;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view
        forElementKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath {
    [view setBackgroundColor:[self imageColor]];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath row]) {
        case HEMInsightRowImage: {
            HEMImageCollectionViewCell* imageCell = (id)cell;
            [[imageCell urlImageView] setBackgroundColor:[UIColor backgroundColor]];
            

            SENRemoteImage* remoteImage = [[self insight] remoteImage];
            NSString* imageUrl = [remoteImage uriForCurrentDevice];
            UIImage* cachedImage = [[self insightsService] cachedImageForUrl:imageUrl]; // in memory
            
            if (!cachedImage) { // check disk
                cachedImage = [remoteImage locallyCachedImageForCurrentDevice];
            }

            if (cachedImage) {
                [[imageCell urlImageView] setImage:cachedImage];
            } else {
                __weak typeof(self) weakSelf = self;
                [[imageCell urlImageView] setImageWithURL:imageUrl completion:^(UIImage * image, NSString * url, NSError * error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (error) {
                        [SENAnalytics trackError:error];
                    } else if (image && url) {
                        [[strongSelf insightsService] cacheImage:image forInsightUrl:url];
                    }
                }];
            }
            
            break;
        }
        case HEMInsightRowTitleOrLoading:
            if ([self isLoading]) {
                HEMLoadingCollectionViewCell* loadingCell = (id)cell;
                [[loadingCell activityIndicator] start];
                break;
            }
        case HEMInsightAbout:
        case HEMInsightRowSummary:
        case HEMInsightRowDetail: {
            HEMTextCollectionViewCell* textCell = (id)cell;
            [textCell setBackgroundColor:[UIColor whiteColor]];
            NSAttributedString* attributedText = [self attributedTextForCellAtIndexPath:indexPath];
            [self setAttributedText:attributedText inTextCell:textCell];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewFlowLayout* layout = (id)[collectionView collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    
    switch ([indexPath row]) {
        case HEMInsightRowImage:
            itemSize.height = HEMInsightCellHeightImage;
            break;
        case HEMInsightAbout: {
            CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
            itemSize.height = textHeight + HEMInsightCellAboutTopMargin;
            break;
        }
        case HEMInsightRowSummary: {
            CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
            itemSize.height = textHeight + HEMInsightCellSummaryTopMargin + HEMInsightCellSummaryBotMargin;
            break;
        }
        case HEMInsightRowTitleOrLoading:
            if ([self isLoading]) {
                itemSize.height = CGRectGetHeight([collectionView bounds]) - HEMInsightCellHeightImage;
            } else {
                CGFloat textHeight = [self heightForTextCellAtIndexPath:indexPath];
                itemSize.height = textHeight + HEMInsightCellTitleTopMargin + HEMInsightCellTitleBotMargin;
            }
            break;
        case HEMInsightRowDetail: {
            itemSize.height = [self heightForTextCellAtIndexPath:indexPath];
            if ([[self insightsService] isGenericInsight:[self insight]]) {
                itemSize.height += HEMInsightCellDetailBotMarginForGenerics;
            }
            break;
        }
        default:
            break;
    }
    
    return itemSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCloseButtonShadowOpacity];
}

#pragma mark - Clean up

- (void)dealloc {
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end
