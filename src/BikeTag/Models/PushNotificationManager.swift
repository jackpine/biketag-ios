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
    let application = UIApplication.sharedApplication()
    let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
  }

  class func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var tokenString = ""

    for i in 0..<deviceToken.length {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }

    let logSuccess = {
      Logger.info("Successfully notified provider of new APN token.")
      UserDefaults.setLastKnownAPNToken(tokenString)
    }

    let logError = { (error: NSError) -> () in
      Logger.error("Failed to notifiy provider of new APN token with error: \(error)")
    }

    Logger.debug("Successfully registered for remote notifications with APN token: \(tokenString)")
    if(tokenString == UserDefaults.lastKnownAPNToken()) {
      Logger.debug("Ignoring unchanged APN token.")
    } else {
      DevicesService().postNewDevice(tokenString, successCallback: logSuccess, errorCallback: logError)
    }
  }
}