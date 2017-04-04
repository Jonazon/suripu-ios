//
//  HEMPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAPIClient.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMPresenter.h"
#import "HEMNavigationShadowView.h"

@interface HEMPresenter()

@property (nullable, nonatomic, weak) HEMNavigationShadowView* shadowView;
@property (nonatomic, assign, getter=isVisible) BOOL visible;

@end

@implementation HEMPresenter

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        [self listenForAppEvents];
        [self listenForNetworkChanges];
        [self listenForAuthChanges];
    }
    return self;
}

- (void)listenForAppEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lowMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (void)listenForNetworkChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGainConnectivity)
                                                 name:SENAPIReachableNotification
                                               object:nil];
}

- (void)listenForAuthChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userDidSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)bindWithShadowView:(HEMNavigationShadowView*)shadowView {
    if (![self hasShadowView] && shadowView) {
        [self setShadowView:shadowView];
    }
}

- (void)didScrollContentIn:(UIScrollView*)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

- (BOOL)hasShadowView {
    return [self shadowView] != nil;
}

- (void)lowMemory {}

- (void)willAppear {}
- (void)didAppear {
    [self setVisible:YES];
}

- (void)willDisappear {
    [self setVisible:NO];
}
- (void)didDisappear {}

- (void)didRelayout {}
- (void)willRelayout {}

- (void)didEnterBackground {}
- (void)didComeBackFromBackground {}
- (void)didMoveToParent {}
- (void)wasRemovedFromParent {}
- (void)didGainConnectivity {}
- (void)didChangeTheme:(Theme*)theme auto:(BOOL)automatically {}

- (void)userDidSignOut {}

- (BOOL)isViewFullyVisible:(UIView*)view {
    if (view.window == nil) {
        return NO;
    }
    CGRect windowFrame = [[view window] frame];
    CGPoint viewCenter = [view convertPoint:[view center] toView:[view window]];
    return CGRectContainsPoint(windowFrame, viewCenter);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
