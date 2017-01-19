//
//  HEMAlertViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import "UIView+HEMSnapshot.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "HEMAlertViewController.h"
#import "HEMAlertView.h"
#import "HEMSupportUtil.h"
#import "HEMAnimationUtils.h"
#import "HEMMarkdown.h"

@interface HEMAlertViewController()

@property (nonatomic, strong) HEMAlertView* dialogView;
@property (nonatomic, weak)   UIViewController* myPresentingController;

@end

@implementation HEMAlertViewController

+ (void)showInfoDialogWithTitle:(NSString *)title
                        message:(NSString *)message
                     controller:(UIViewController *)controller {
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC addButtonWithTitle:[NSLocalizedString(@"actions.ok", nil) uppercaseString]
                           style:HEMAlertViewButtonStyleRoundRect
                          action:nil];
    [dialogVC showFrom:controller];
}

+ (NSAttributedString *)attributedMessageText:(NSString *)text {
    NSDictionary *attributes = [HEMMarkdown attributesForAlertMessageText][@(PARA)];
    NSAttributedString* attributedMessage = nil;
    if (text.length > 0)
        attributedMessage = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attributedMessage;
}

+ (instancetype)confirmationDialogWithTitle:(NSString*)title
                                    message:(NSString*)message
                             yesButtonTitle:(NSString*)yesTitle
                              noButtonTitle:(NSString*)noTitle
                                     action:(void(^)(void))action {
    HEMAlertViewController* alert = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [alert addButtonWithTitle:yesTitle style:HEMAlertViewButtonStyleRoundRect action:action];
    [alert addButtonWithTitle:noTitle style:HEMAlertViewButtonStyleBlueText action:nil];
    return alert;
}

+ (instancetype)confirmationDialogWithTitle:(NSString*)title
                          attributedMessage:(NSAttributedString*)message
                             yesButtonTitle:(NSString*)yesTitle
                              noButtonTitle:(NSString*)noTitle
                                     action:(void(^)(void))action {
    HEMAlertViewController* alert = [HEMAlertViewController new];
    [alert setTitle:title];
    [alert setAttributedMessage:message];
    [alert addButtonWithTitle:yesTitle style:HEMAlertViewButtonStyleRoundRect action:action];
    [alert addButtonWithTitle:noTitle style:HEMAlertViewButtonStyleBlueText action:nil];
    return alert;
}

- (instancetype)initBooleanDialogWithTitle:(NSString *)title
                                   message:(NSString *)message
                             defaultsToYes:(BOOL)defaultsToYes
                                    action:(void (^)())action {
    if (self = [super init]) {
        self.title = title;
        _type = HEMAlertViewTypeBoolean;
        _attributedMessage = [[self class] attributedMessageText:message];
        [self addButtonWithTitle:[NSLocalizedString(@"actions.yes", nil) uppercaseString]
                           style:defaultsToYes ? HEMAlertViewButtonStyleBlueBoldText : HEMAlertViewButtonStyleGrayText
                          action:action];
        [self addButtonWithTitle:[NSLocalizedString(@"actions.no", nil) uppercaseString]
                           style:defaultsToYes ? HEMAlertViewButtonStyleGrayText : HEMAlertViewButtonStyleBlueBoldText
                          action:nil];
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message {
    if (self = [super init]) {
        self.title = title;
        _attributedMessage = [HEMAlertViewController attributedMessageText:message];
        [self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor seeThroughBackgroundColor]];
    [self configureGestures];
}

- (void)setDefaults {
    [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
}

- (void)configureGestures {
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(didTapOnBackground:)];
    [[self view] addGestureRecognizer:tapGesture];
}

- (HEMAlertView *)dialogView {
    if (!_dialogView) {
        _dialogView = [[HEMAlertView alloc] initWithImage:self.dialogImage
                                                    title:self.title
                                                     type:self.type
                                        attributedMessage:self.attributedMessage];
    }
    return _dialogView;
}

- (void)addButtonWithTitle:(NSString*)title style:(HEMAlertViewButtonStyle)style action:(HEMDialogActionBlock)block {
    __weak typeof(self) weakSelf = self;
    [[self dialogView] addActionButtonWithTitle:title style:style action:^{
        [weakSelf dismissViewControllerAnimated:YES completion:block];
    }];
}

- (void)onLinkTapOf:(NSString*)url takeAction:(HEMDialogLinkActionBlock)action {
    __weak typeof(self) weakSelf = self;
    [[self dialogView] onLink:url tap:^(NSURL* linkURL) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (action) {
                action(linkURL);
            }
        }];
    }];
}

- (void)showFrom:(UIViewController*)controller {
    self.dialogView.center = self.view.center;
    [self setMyPresentingController:controller];
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [controller presentViewController:self animated:YES completion:^{
        [[self dialogView] setTransform:CGAffineTransformMakeScale(0.1f, 0.1f)];
        [[self view] addSubview:[self dialogView]];
        [HEMAnimationUtils grow:[self dialogView] completion:nil];
    }];
}

- (void)didTapOnBackground:(UITapGestureRecognizer*)gesture {
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [gesture locationInView:[self view]];
        if (!CGRectContainsPoint([[self dialogView] frame], tapPoint)) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
