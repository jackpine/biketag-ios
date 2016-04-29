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

    if UserDefaults.prefersReceivingNotifications() {
      Logger.debug("Registering for push notifications")
      let application = UIApplication.sharedApplication()
      let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert], categories: nil)
      application.registerUserNotificationSettings(notificationSettings)
    } else {
      Logger.debug("Skipping push notification registration, as the user hasn't opted in (yet?).")
    }
  }

}