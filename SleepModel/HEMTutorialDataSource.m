//
//  HEMTutorialDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 6/9/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMTutorialDataSource.h"
#import "HEMTutorialContent.h"
#import "HEMImageCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMVideoCollectionViewCell.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMURLImageView.h"
#import "HEMStyle.h"

static NSString* const HEMTutorialCellReuseIdImage = @"image";
static NSString* const HEMTutorialCellReuseIdVideo = @"video";
static NSString* const HEMTutorialCellReuseIdTitle = @"title";
static NSString* const HEMTutorialCellReuseIdDesc = @"description";

static CGFloat const HEMTutorialTextVerticalInset = 24.0f;
static CGFloat const HEMTutorialTextSpacing = 16.0f;

typedef NS_ENUM(NSUInteger, HEMTutorialCellSection) {
    HEMTutorialCellSectionIllustration = 0,
    HEMTutorialCellSectionText = 1,
    HEMTutorialCellSections = 2
};

typedef NS_ENUM(NSUInteger, HEMTutorialCellTextRow) {
    HEMTutorialCellTextRowTitle = 0,
    HEMTutorialCellTextRowDescription = 1,
    HEMTutorialCellTextRows = 2
};

@interface HEMTutorialDataSource()

@property (nonatomic, strong) HEMTutorialContent* content;
@property (nonatomic, strong) NSAttributedString* attributedBody;
@property (nonatomic, weak)   UICollectionView* collectionView;
@property (nonatomic, weak)   HEMVideoCollectionViewCell* videoCell;

@end

@implementation HEMTutorialDataSource

- (instancetype)initWithContent:(HEMTutorialContent*)content
              forCollectionView:(UICollectionView*)collectionView {
    self = [super init];
    if (self) {
        [collectionView applyFillStyle];
        _content = content;
        _collectionView = collectionView;
        [self registerCells];
    }
    return self;
}

- (void)registerCells {
    [[self collectionView] registerClass:[HEMImageCollectionViewCell class]
              forCellWithReuseIdentifier:HEMTutorialCellReuseIdImage];
    [[self collectionView] registerClass:[HEMVideoCollectionViewCell class]
              forCellWithReuseIdentifier:HEMTutorialCellReuseIdVideo];
    [[self collectionView] registerClass:[HEMTextCollectionViewCell class]
              forCellWithReuseIdentifier:HEMTutorialCellReuseIdTitle];
    [[self collectionView] registerClass:[HEMTextCollectionViewCell class]
              forCellWithReuseIdentifier:HEMTutorialCellReuseIdDesc];
}

- (NSAttributedString*)attributedBody {
    if (!_attributedBody) {
        UIColor* color = [SenseStyle colorWithGroup:GroupInfo property:ThemePropertyDetailColor];
        UIFont* font = [SenseStyle fontWithGroup:GroupInfo property:ThemePropertyDetailFont];
        NSDictionary* attributes = @{NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : color,
                                     NSParagraphStyleAttributeName : DefaultBodyParagraphStyle()};
        _attributedBody = [[NSAttributedString alloc] initWithString:[[self content] text]
                                                          attributes:attributes];
    }
    return _attributedBody;
}

- (CGSize)sizeForContentAtIndexPath:(NSIndexPath*)indexPath {
    UIEdgeInsets insets = [[self collectionView] contentInset];
    CGSize size = [[self collectionView] bounds].size;
    size.width -= (insets.left + insets.right);
    
    if ([indexPath section] == HEMTutorialCellSectionIllustration) {
        CGFloat imageWidth = [[self content] image].size.width;
        CGFloat scaledFactor = size.width / imageWidth;
        size.height = [[self content] image].size.height * scaledFactor;
    } else if ([indexPath section] == HEMTutorialCellSectionText) {
        if ([indexPath row] == HEMTutorialCellTextRowTitle) {
            size.height = [HEMTextCollectionViewCell heightWithText:[[self content] title]
                                                               font:[UIFont h6]
                                                          cellWidth:size.width];
        } else if ([indexPath row] == HEMTutorialCellTextRowDescription) {
            size.height = [HEMTextCollectionViewCell heightWithAttributedText:[self attributedBody]
                                                                    cellWidth:size.width];
        }
    }
    
    return size;
}

- (CGFloat)contentSpacingAtSection:(NSInteger)section {
    return section == HEMTutorialCellSectionText ? HEMTutorialTextSpacing : 0.0f;
}

- (UIEdgeInsets)contentInsetAtSection:(NSInteger)section {
    if (section == HEMTutorialCellSectionText) {
        return UIEdgeInsetsMake(HEMTutorialTextVerticalInset, 0.0f, HEMTutorialTextVerticalInset, 0.0f);
    } else {
        return UIEdgeInsetsZero;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return HEMTutorialCellSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == HEMTutorialCellSectionIllustration) {
        return 1;
    } else if (section == HEMTutorialCellSectionText) {
        return HEMTutorialCellTextRows;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell* cell = nil;
    
    if ([indexPath section] == HEMTutorialCellSectionIllustration) {
        if ([[self content] hasVideoContent]) {
            cell = [self videoCellFor:collectionView atIndexPath:indexPath];
        } else {
            cell = [self imageCellFor:collectionView atIndexPath:indexPath];
        }
    } else if ([indexPath section] == HEMTutorialCellSectionText) {
        if ([indexPath row] == HEMTutorialCellTextRowTitle) {
            cell = [self titleCellFor:collectionView atIndexPath:indexPath];
        } else if ([indexPath row] == HEMTutorialCellTextRowDescription) {
            cell = [self descriptionCellFor:collectionView atIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (UICollectionViewCell* )imageCellFor:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    HEMImageCollectionViewCell* imageCell =
        (id)[collectionView dequeueReusableCellWithReuseIdentifier:HEMTutorialCellReuseIdImage forIndexPath:indexPath];
    [[imageCell urlImageView] setImage:[[self content] image]];
    [[imageCell urlImageView] setContentMode:UIViewContentModeScaleAspectFit];
    return imageCell;
}

- (UICollectionViewCell*)videoCellFor:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    HEMVideoCollectionViewCell* videoCell =
        (id)[collectionView dequeueReusableCellWithReuseIdentifier:HEMTutorialCellReuseIdVideo forIndexPath:indexPath];
    [[videoCell videoView] setFirstFrame:[[self content] image] videoPath:[[self content] videoPath]];
    [self setVideoCell:videoCell];
    
    return videoCell;
}

- (UICollectionViewCell*)titleCellFor:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    HEMTextCollectionViewCell* titleCell =
        (id)[collectionView dequeueReusableCellWithReuseIdentifier:HEMTutorialCellReuseIdTitle forIndexPath:indexPath];
    [[titleCell textLabel] setText:[[self content] title]];
    [self applyStyleToTitleCell:titleCell];
    return titleCell;
}

- (UICollectionViewCell*)descriptionCellFor:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath {
    HEMTextCollectionViewCell* descriptionCell =
        (id)[collectionView dequeueReusableCellWithReuseIdentifier:HEMTutorialCellReuseIdDesc forIndexPath:indexPath];
    [[descriptionCell textLabel] setAttributedText:[self attributedBody]];
    [self applyBackgroundColorTo:descriptionCell];
    return descriptionCell;
}

- (void)setVisible:(BOOL)visible {
    if ([self videoCell]) {
        if (visible) {
            if (![[[self videoCell] videoView] isReady]) {
                [[[self videoCell] videoView] setReady:YES];
            } else {
                [[[self videoCell] videoView] playVideoWhenReady];
            }
        } else {
            [[[self videoCell] videoView] pause];
        }
    }

}

- (void)applyStyleToTitleCell:(HEMTextCollectionViewCell*)cell {
    UIColor* color = [SenseStyle colorWithGroup:GroupInfo property:ThemePropertyTextColor];
    UIFont* font = [SenseStyle fontWithGroup:GroupInfo property:ThemePropertyTextFont];
    [[cell textLabel] setFont:font];
    [[cell textLabel] setTextColor:color];
    [self applyBackgroundColorTo:cell];
}

- (void)applyBackgroundColorTo:(HEMTextCollectionViewCell*)cell {
    UIColor* bgColor = [SenseStyle colorWithGroup:GroupInfo property:ThemePropertyBackgroundColor];
    [[cell textLabel] setBackgroundColor:bgColor];
    [cell setBackgroundColor:bgColor];
    [[cell contentView] setBackgroundColor:bgColor];
}

@end
