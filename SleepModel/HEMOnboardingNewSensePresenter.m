//
//  HEMOnboardingHaveSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "UIBarButtonItem+HEMNav.h"

#import "HEMOnboardingNewSensePresenter.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMStyle.h"

@implementation HEMOnboardingNewSensePresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [super bindWithTitleLabel:titleLabel descriptionLabel:descriptionLabel];
    
    [titleLabel setText:NSLocalizedString(@"onboarding.new-sense.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"onboarding.new-sense.desc", nil)];
    [SENAnalytics track:HEMAnalyticsEventOnbStart];
}

- (void)bindWithNavigationItem:(UINavigationItem *)navItem {
    [super bindWithNavigationItem:navItem];
    
    UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:nil
                                                                 image:BackIndicator()
                                                                target:self
                                                                action:@selector(cancel)];
    [navItem setLeftBarButtonItem:cancelItem];
}

- (void)bindWithNextButton:(UIButton*)nextButton {
    [super bindWithNextButton:nextButton];
    [nextButton addTarget:self action:@selector(proceed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithNeedButton:(UIButton*)needButton {
    [super bindWithNeedButton:needButton];
    [needButton addTarget:self action:@selector(order) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions

- (void)cancel {
    [[self actionDelegate] shouldDismissFrom:self];
}

- (void)proceed {
    [[self actionDelegate] shouldProceedFrom:self];
}

- (void)order {
    NSString* orderURLString = NSLocalizedString(@"help.url.order-form", nil);
    [[self actionDelegate] shouldOpenPageTo:orderURLString from:self];
    [SENAnalytics track:kHEMAnalyticsEventOnBNoSense];
}

@end
