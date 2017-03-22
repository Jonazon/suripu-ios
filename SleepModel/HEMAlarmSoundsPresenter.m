//
//  HEMAlarmSoundsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 4/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSound.h>

#import "HEMAlarmSoundsPresenter.h"
#import "HEMListItemCell.h"
#import "HEMAlarmService.h"
#import "HEMActivityIndicatorView.h"

@interface HEMAlarmSoundsPresenter()

@property (nonatomic, weak) HEMAlarmService* alarmService;
@property (nonatomic, strong) SENSound* selectedSound;
@property (nonatomic, copy) NSString* navTitle;
@property (nonatomic, assign, getter=isLoading) BOOL loading;

@end

@implementation HEMAlarmSoundsPresenter

- (instancetype)initWithNavTitle:(NSString *)title
                        subtitle:(NSString*)subtitle
                           items:(NSArray *)items
                selectedItemName:(NSString*)selectedItemName
                    audioService:(HEMAudioService*)audioService
                    alarmService:(HEMAlarmService*)alarmService {
    
    self = [super initWithTitle:subtitle
                          items:items
               selectedItemName:selectedItemName
                   audioService:audioService];
    
    if (self) {
        _alarmService = alarmService;
        _navTitle = [title copy];
        
        if ([items count] == 0) {
            [self loadSoundsThenConfigure];
        } else {
            [self configureSelectedSound];
        }
    }
    
    return self;
}

- (void)bindWithNavigationItem:(UINavigationItem *)navItem {
    [super bindWithNavigationItem:navItem];
    [navItem setTitle:[self navTitle]];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView *)indicatorView {
    [super bindWithActivityIndicator:indicatorView];
    
    [indicatorView setHidden:![self isLoading]];
    
    if ([self isLoading]) {
        [indicatorView start];
    } else {
        [indicatorView stop];
    }
}

- (void)loadSoundsThenConfigure {
    [self setLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self alarmService] loadAvailableAlarmSounds:^(NSArray<SENSound *> * _Nullable sounds, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoading:NO];
        
        if (!error) {
            NSArray* sortedSounds = [sounds sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                SENSound* sound1 = obj1;
                SENSound* sound2 = obj2;
                return [[sound1 displayName] compare:[sound2 displayName]];
            }];
            
            [strongSelf setItems:sortedSounds];
            [strongSelf configureSelectedSound];
            [[strongSelf tableView] reloadData];
            [strongSelf preSelectItems];
        }
        
    }];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        [[self indicatorView] start];
    } else {
        [[self indicatorView] stop];
    }
    [[self indicatorView] setHidden:!loading];
}

- (void)configureSelectedSound {
    NSString* selectedName = [[self selectedItemNames] firstObject];
    if (selectedName) {
        for (SENSound* sound in [self items]) {
            if ([[sound displayName] isEqualToString:selectedName]) {
                [self setSelectedSound:sound];
                break;
            }
        }
    }
}

#pragma mark - HEMSoundListPresenter Overrides

- (NSInteger)indexOfItemWithName:(NSString*)name {
    NSInteger index = -1;
    NSInteger itemIndex = 0;
    for (SENSound* sound in [self items]) {
        if ([[sound displayName] isEqualToString:name]) {
            index = itemIndex;
            break;
        }
        itemIndex++;
    }
    return index;
}

- (NSString*)selectedPreviewUrl {
    return [[self selectedSound] URLPath];
}

- (BOOL)item:(id)item matchesCurrentPreviewUrl:(NSString *)currentUrl {
    SENSound* sound = item;
    return [currentUrl isEqualToString:[sound URLPath]];
}

- (void)updateCell:(UITableViewCell *)cell withItem:(id)item selected:(BOOL)selected {
    [super updateCell:cell withItem:item selected:selected];
    if (selected) {
        [self setSelectedSound:item];
    }
}

#pragma mark -

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    
    SENSound* sound = item;
    [[cell itemLabel] setText:[sound displayName]];
    
    NSString* selectedName = [[self selectedSound] displayName];
    BOOL selected = [selectedName isEqualToString:[sound displayName]];
    [cell setSelected:selected];
}

@end
