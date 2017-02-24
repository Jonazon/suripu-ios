//
//  HEMListItemSelectionViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListItemSelectionViewController.h"
#import "HEMListPresenter.h"
#import "HEMActivityIndicatorView.h"

@interface HEMListItemSelectionViewController() <HEMListPresenterDelegate, HEMListDelegate>

// FIXME: this extra navigation bar is a workaround for the mess that is
// the alarm code.  Once we rewrite the alarm code, we should consider
// removing this
@property (weak, nonatomic) IBOutlet UINavigationBar *extraNavigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopConstraint;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@end

@implementation HEMListItemSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    [[self listPresenter] bindWithTableView:[self tableView]
                           bottomConstraint:[self tableViewBottomConstraint]];
    [[self listPresenter] bindWithDefaultNavigationBar:[[self navigationController] navigationBar]];
    [[self listPresenter] bindWithNavigationBar:[self extraNavigationBar]
                              withTopConstraint:[self navigationBarTopConstraint]];
    [[self listPresenter] bindWithActivityIndicator:[self activityIndicator]];
    [[self listPresenter] setPresenterDelegate:self];
    [[self listPresenter] bindWithNavigationItem:[self navigationItem]];
    [[self listPresenter] bindWithActivityContainerView:[[self navigationController] view]];
    
    if (![[self listPresenter] delegate]) {
        [[self listPresenter] setDelegate:self];
    }
    
    [self addPresenter:[self listPresenter]];
}

#pragma mark - Presenter Delegate

- (void)presentErrorWithTitle:(NSString *)title
                      message:(NSString *)message
                         from:(HEMListPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

#pragma mark - List Delegate

- (void)dismissControllerFromPresenter:(HEMListPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
