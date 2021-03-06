//
//  HEMTimelineFeedbackViewController.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENTimeline.h>
#import <SenseKit/SENAPITimeline.h>
#import "Sense-Swift.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMClockPickerView.h"
#import "HEMAlertViewController.h"
#import "HEMActivityCoverView.h"
#import "HEMTimelineService.h"

NSString* const HEMTimelineFeedbackSuccessNotification = @"HEMTimelineFeedbackSuccessNotification";

@interface HEMTimelineFeedbackViewController ()
@property (nonatomic, weak) IBOutlet HEMClockPickerView* clockView;
@property (weak, nonatomic) IBOutlet UIView *titleSeparatorView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* tinySeparatorHeight;
@property (nonatomic, weak) IBOutlet UIView* titleContainerView;
@property (nonatomic, weak) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIView *buttonDividerView;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *buttonSeparatorView;
@property (nonatomic, strong) HEMTimelineService* timelineService;
@property (nonatomic, strong) NSCalendar* calendar;
@property (nonatomic, assign, getter=isConfigured) BOOL configured;
@end

@implementation HEMTimelineFeedbackViewController

static NSString* const HEMTimelineFeedbackTitleFormat = @"sleep-event.feedback.title.%@";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyStyle];
    self.timelineService = [HEMTimelineService new];
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];
    [SENAnalytics track:HEMAnalyticsEventTimelineAdjustTime];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self isConfigured]) {
        [self configureSegmentViews];
        [self setConfigured:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[SenseStyle theme] statusBarStyle];
}

- (void)applyStyle {
    [self.titleContainerView applyFillStyle];
    [self.buttonContainerView applyFillStyle];
    [self.cancelButton applySecondaryStyle];
    [self.saveButton applyStyle];
    [self.titleLabel applyTitleStyle];
    [self.titleLabel setFont:[SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont]];
    [self.titleLabel setTextColor:[SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor]];
    [self.titleSeparatorView applySeparatorStyle];
    [self.buttonDividerView applySeparatorStyle];
    [self.buttonSeparatorView applySeparatorStyle];
}

- (void)configureSegmentViews
{
    if (!self.segment)
        return;
    self.calendar.timeZone = self.segment.timezone;
    NSDateComponents* components = [self.calendar components:(NSCalendarUnitHour|NSCalendarUnitMinute)
                                                    fromDate:self.segment.date];
    [self.clockView updateTimeToHour:components.hour minute:components.minute];
    NSString* type = [SENTimelineSegmentTypeNameFromType(self.segment.type) lowercaseString];
    NSString* key = [NSString stringWithFormat:HEMTimelineFeedbackTitleFormat, type];
    NSString* title = NSLocalizedString(key, nil);
    if ([title isEqualToString:key]) {
        title = NSLocalizedString(@"sleep-event.feedback.title.generic", nil);
    }
    self.titleLabel.text = title;
    self.tinySeparatorHeight.constant = 0.5f;
}

- (IBAction)sendUpdatedTime:(UIButton*)sender
{
    sender.enabled = NO;
    
    [[self cancelButton] setEnabled:NO];

    NSString* activityText = NSLocalizedString(@"activity.saving.changes", nil);
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(id, NSError *) = ^(SENTimeline* updatedTimeline, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                [[strongSelf cancelButton] setEnabled:YES];
                [sender setEnabled:YES];
                
                NSString* errorMessage = [error localizedDescription] ?: NSLocalizedString(@"sleep-event.feedback.failed.message", nil);
                [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"sleep-event.feedback.failed.title", nil)
                                                        message:errorMessage
                                                     controller:strongSelf];
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey : HEMAnalyticsEventTimelineAdjustTimeFailed};
                [SENAnalytics trackError:[NSError errorWithDomain:[error domain]
                                                             code:[error code]
                                                         userInfo:userInfo]];
            }];

        } else {
            NSDictionary* properties = @{kHEMAnalyticsEventPropType : SENTimelineSegmentTypeNameFromType(self.segment.type) ?: @"undefined"};
            [SENAnalytics track:kHEMAnalyticsEventTimelineAdjustTimeSaved properties:properties];
            [updatedTimeline save];
            [[NSNotificationCenter defaultCenter] postNotificationName:HEMTimelineFeedbackSuccessNotification object:strongSelf];
            
            NSString* message = NSLocalizedString(@"sleep-event.feedback.success.message", nil);
            UIImage* icon = [UIImage imageNamed:@"check"];
            [activityView updateText:message successIcon:icon hideActivity:YES completion:^(BOOL finished) {
                [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                    NSTimeInterval delayInSeconds = 0.5f;
                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                        [strongSelf dismissViewControllerAnimated:YES completion:NULL];
                    });
                }];
            }];
        }
        
    };
    
    [activityView showInView:[self view] withText:activityText activity:YES completion:^{
        [self.timelineService amendTimelineSegment:self.segment
                                    forDateOfSleep:self.dateForNightOfSleep
                                          withHour:@(self.clockView.hour)
                                        andMinutes:@(self.clockView.minute)
                                        completion:completion];
    }];

}

- (IBAction)cancelAndDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
