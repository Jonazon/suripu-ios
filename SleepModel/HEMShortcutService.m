//
//  HEMShortcutService.m
//  Sense
//
//  Created by Jimmy Lu on 3/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENService+Protected.h>
#import "Sense-Swift.h"
#import "HEMShortcutService.h"

static NSString* const HEMShortcut3DTouchTypeAlarmNew = @"is.hello.sense.shortcut.addalarm";
static NSString* const HEMShortcut3DTouchTypeAlarmEdit = @"is.hello.sense.shortcut.editalarms";
static NSString* const HEMShortcutExtensionRoomExtPath = @"ext/room";

@implementation HEMShortcutService

+ (HEMShortcutAction)actionForType:(NSString*)type {
    HEMShortcutAction action = HEMShortcutActionUnknown;
    if ([SENAuthorizationService isAuthorized]) {
        if ([type isEqualToString:HEMShortcut3DTouchTypeAlarmNew]) {
            action = HEMShortcutActionAlarmNew;
        } else if ([type isEqualToString:HEMShortcut3DTouchTypeAlarmEdit]) {
            action = HEMShortcutActionAlarmEdit;
        } else if ([type isEqualToString:HEMShortcutExtensionRoomExtPath]) {
            action = HEMShortcutActionRoomConditionsShow;
        }
    }
    return action;
}

+ (HEMShortcutAction)actionForNotification:(PushNotification*)notification {
    switch ([notification type]) {
        case InfoTypeSleepScore:
            return  HEMShortcutActionPushTimeline;
        case InfoTypeUnknown:
        default:
            return  HEMShortcutActionUnknown;
    }
}

@end
