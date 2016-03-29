//
//  HEMSoundsTabPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSoundsTabPresenter.h"

@interface HEMSoundsTabPresenter()

@property (nonatomic, weak) UITabBarItem* tabBarItem;

@end

@implementation HEMSoundsTabPresenter

- (void)bindWithTabBarItem:(nonnull UITabBarItem*)tabBarItem {
    tabBarItem.image = [UIImage imageNamed:@"alarmBarIcon"];
    tabBarItem.selectedImage = [UIImage imageNamed:@"alarmBarIconActive"];
    [self setTabBarItem:tabBarItem];
}

@end