//
//  UIApplication+Notification.swift
//  Sense
//
//  Created by Jimmy Lu on 1/27/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIApplication {
    
    /**
        Convenience method that simply puts a different name to the native
        registerForRemoteNotifications method, which can lead to confusion
    */
    @objc func renewPushNotificationToken() {
        self.registerForRemoteNotifications()
    }
    
    /**
        Prompt the user for permission to send push notifications.
     
        Callers should override the application delegate method to know that the
        user notification settings were registered to then call renew push notification
        to retrieve the token.
    */
    @objc func askForPermissionToSendPushNotifications() {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                  categories: nil)
        self.registerUserNotificationSettings(settings)
    }
    
    /**
        Convenience method to clear the badge, if one was created from a push
        notification by first setting it to 1, then setting it to 0.  Without
        this, the badge may not properly clear
    */
    @objc func clearBadgeFromNotification() {
        self.applicationIconBadgeNumber = 1
        self.applicationIconBadgeNumber = 0
    }
    
}