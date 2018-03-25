//
//  PushNotificationManager.swift
//  BikeTag
//
//  Created by Michael Kirk on 4/29/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

class PushNotificationManager {

    class func register() {
        Logger.debug("Registering for push notifications")
        let application = UIApplication.shared
        let notificationSettings = UIUserNotificationSettings(types: [.alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }

    class func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {

        // TODO verify token format
        let tokenString = deviceToken.base64EncodedString()

        let logSuccess = {
            Logger.info("Successfully notified provider of new APN token.")
            UserDefaults.setLastKnownAPNToken(val: tokenString)
        }

        let logError = { (error: Error) -> Void in
            Logger.error("Failed to notifiy provider of new APN token with error: \(error)")
        }

        Logger.debug("Successfully registered for remote notifications with APN token: \(tokenString)")
        if(tokenString == UserDefaults.lastKnownAPNToken()) {
            Logger.debug("Ignoring unchanged APN token.")
        } else {
            DevicesService().postNewDevice(deviceNotificationToken: tokenString, successCallback: logSuccess, errorCallback: logError)
        }
    }
}
