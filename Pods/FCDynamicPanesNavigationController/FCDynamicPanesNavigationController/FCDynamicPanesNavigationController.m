//
//  FCDynamicPanesNavigationController.m
//
//  Created by Florent Crivello on 3/17/14.
//

#import "FCDynamicPanesNavigationController.h"

#define DEGREE_TO_RADIAN(x) x* M_PI / 180
#define MINIMUM_VELOCITY 0

@interface FCDynamicPanesNavigationController ()

@property (nonatomic) BOOL showBounceHintOnLoad;
@property (nonatomic) FCMutableArray* viewControllers;
@property (nonatomic, weak) UIViewController* activeViewController;

@end

@implementation FCDynamicPanesNavigationController

- (id)init
{
    if (self = [super init]) {
        _viewControllers = [[FCMutableArray alloc] initWithDelegate:self];
        _paneSwitchingEnabled = YES;
    }

    return self;
}

- (id)initWithRootViewController:(UIViewController*)viewController
{
    self = [self initWithViewControllers:@[ viewController ]];
    return self;
}

- (id)initWithViewControllers:(NSArray*)viewControllers
{
    return [self initWithViewControllers:viewControllers hintOnLoad:NO];
}

- (id)initWithViewControllers:(NSArray *)viewControllers hintOnLoad:(BOOL)hintOnLoad {
    if (self = [super init]) {
        _showBounceHintOnLoad = hintOnLoad;
        _viewControllers = [[FCMutableArray alloc] initWithDelegate:self];
        [_viewControllers addObjectsFromArray:viewControllers];
    }
    return self;
}

- (void)dealloc
{
    _viewControllers = nil;
}

- (void)pushViewController:(UIViewController*)viewController retracted:(BOOL)retracted
{
    FCDynamicPane* dynamicPane = [[FCDynamicPane alloc] initWithViewController:viewController];
    [_viewControllers addObject:dynamicPane];
}

- (void)setPaneSwitchingEnabled:(BOOL)paneSwitchingEnabled
{
    _paneSwitchingEnabled = paneSwitchingEnabled;
    for (FCDynamicPane* pane in _viewControllers) {
        pane.swipeEnabled = paneSwitchingEnabled;
    }
}

- (void)popToViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 1) {
        FCDynamicPane* pane = [viewController isKindOfClass:[FCDynamicPane class]] ? (FCDynamicPane*)viewController : ([viewController.parentViewController isKindOfClass:[FCDynamicPane class]] ? (FCDynamicPane*)viewController.parentViewController : nil);
        if (!pane || [[self.viewControllers firstObject] isEqual:pane]) {
            return;
        }

        if (animated) {
            pane.gravityBehavior.gravityDirection = CGVectorMake(0, 3);
            pane.gravityBehavior.action = nil;
            pane.state = FCDynamicPaneLeavingScreen;
            [pane.behavior removeChildBehavior:pane.attachmentBehavior];
        } else {
            [self.viewControllers removeObject:pane];
        }
    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    [self popToViewController:self.viewControllers[self.viewControllers.count - 2] animated:animated];
}

#pragma mark - FCMutableArray delegate

- (void)object:(FCDynamicPane*)object wasAddedToArray:(FCMutableArray*)array
{
    if (![array indexOfObject:object]) {
        [object removeFromParentViewController];
        [self addChildViewController:object];
        object.view.frame = CGRectMake(0, 0, object.view.frame.size.width, object.view.frame.size.height);
        [self.view addSubview:object.view];
        [object didMoveToParentViewController:self];
        object.state = FCDynamicPaneStateRoot;
    } else {
        FCDynamicPane* includingViewController = ((FCDynamicPane*)[array firstObject]);
        UIView* includingView = includingViewController.view;
        object.view.frame = object.view.bounds;

        [object removeFromParentViewController];
        [includingViewController addChildViewController:object];
        [includingView addSubview:object.view];
        [includingView bringSubviewToFront:object.view];
        [object didMoveToParentViewController:includingViewController];

        object.state = FCDynamicPaneStateActive;
        if ([object.viewController respondsToSelector:@selector(viewDidPush)]) {
            [(UIViewController<FCDynamicPaneViewController>*)object.viewController viewDidPush];
        }
    }
}

- (void)object:(id)object willBeRemovedFromArray:(FCMutableArray*)array
{
    // Looks like we're popping a ViewController
    if ([object isKindOfClass:[FCDynamicPane class]]) {
        FCDynamicPane* pane = (FCDynamicPane*)object;
        //1. Move its childViewController (N+1) into its parentViewController (N-1)
        __block FCDynamicPane* childPane = nil;
        [pane.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
			if ([obj isKindOfClass:[FCDynamicPane class]]) {
				childPane = obj;
				*stop = YES;
			}
        }];
        if (childPane) {
            [childPane.view removeFromSuperview];
            [childPane willMoveToParentViewController:nil];
            [childPane removeFromParentViewController];
            childPane.view.frame = CGRectMake(0, 0, childPane.view.frame.size.width, childPane.view.frame.size.height);
            [pane.parentViewController.view addSubview:childPane.view];
            [pane.parentViewController addChildViewController:childPane];
            [childPane didMoveToParentViewController:pane.parentViewController];

            if (![array indexOfObject:pane]) {
                // The Root Pane just got removed
                childPane.state = FCDynamicPaneStateRoot;
            }
        }

        //2. Remove from its parentViewController
        [pane.view removeFromSuperview];
        [pane removeFromParentViewController];
        [pane didMoveToParentViewController:nil];

        //3. Bring back the child view's child view on top
        __block FCDynamicPane* childChildPane = nil;
        [childPane.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
			if ([obj isKindOfClass:[FCDynamicPane class]]) {
				childChildPane = obj;
				*stop = YES;
			}
        }];
        [childPane.view bringSubviewToFront:childChildPane.view];
    }
}

- (BOOL)shouldAddObject:(id)object toArray:(FCMutableArray*)array
{
    if ([object isKindOfClass:[FCDynamicPane class]]) {
        ((FCDynamicPane*)object).delegate = self;
        return YES;
    } else if ([object isKindOfClass:[UIViewController class]]) {
        FCDynamicPane* compositeItem = [[FCDynamicPane alloc] initWithViewController:object];
        [compositeItem setShowBounceHintOnLoad:[self showBounceHintOnLoad]];
        [array addObject:compositeItem];
    }
    return NO;
}

- (void)dynamicPaneDidGoOutOfScreen:(FCDynamicPane*)pane
{
    if (pane.state == FCDynamicPaneLeavingScreen) {
        [self.viewControllers removeObject:pane];
    }
}

@end

@implementation UIViewController (FCDynamicPanesNavigationController)

- (FCDynamicPanesNavigationController*)panesNavigationController
{
    UIViewController* currentTestingViewController = self.parentViewController;

    while (![currentTestingViewController isKindOfClass:[FCDynamicPanesNavigationController class]] && currentTestingViewController != nil) {
        currentTestingViewController = currentTestingViewController.parentViewController;
    }

    return (FCDynamicPanesNavigationController*)currentTestingViewController;
}

- (UIPanGestureRecognizer*)panePanGestureRecognizer
{
    for (FCDynamicPane* pane in [self panesNavigationController].viewControllers) {
        UIViewController* viewController = pane.viewController;
        if (viewController == self
            || ([viewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)viewController viewControllers] containsObject:self])
            || ([viewController isKindOfClass:[UIPageViewController class]] && [[(UIPageViewController*)viewController viewControllers] containsObject:self])
            || [[viewController childViewControllers] containsObject:self]) {
            return pane.panGestureRecognizer;
        }
    }
    return nil;
}

@end