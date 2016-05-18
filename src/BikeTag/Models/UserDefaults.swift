//
//  UserDefaults.swift
//  BikeTag
//
//  Created by Michael Kirk on 4/9/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import Foundation

let defaults = NSUserDefaults.standardUserDefaults()
let KeyForApiKey = "apiKey"
let KeyForHasPreviouslyCreatedSpot = "HAS_PREVIOUSLY_CREATED_SPOT"
let KeyForPrefersReceivingNotifications = "PREFERS_RECEIVING_NOTIFICATIONS"
let KeyForLastKnownAPNToken = "LAST_KNOWN_APN_TOKEN"

class UserDefaults {

  class func setApiKey(apiKeyAttributes: NSDictionary) {
    defaults.setObject(apiKeyAttributes, forKey: KeyForApiKey)
  }

  class func apiKey() -> NSDictionary? {
    return defaults.dictionaryForKey(KeyForApiKey)
  }

  class func setHasPreviouslyCreatedSpot(val: Bool) {
    defaults.setBool(val, forKey:KeyForHasPreviouslyCreatedSpot)
  }

  class func hasPreviouslyCreatedSpot() -> Bool {
    return defaults.boolForKey(KeyForHasPreviouslyCreatedSpot)
  }

  class func setPrefersReceivingNotifications(val: Bool) {
    defaults.setBool(val, forKey: KeyForPrefersReceivingNotifications)
  }

  class func prefersReceivingNotifications() -> Bool {
    return defaults.boolForKey(KeyForPrefersReceivingNotifications)
  }

  class func lastKnownAPNToken() -> String? {
    return defaults.stringForKey(KeyForLastKnownAPNToken)
  }

  class func setLastKnownAPNToken(val: String) {
    defaults.setObject(val, forKey:KeyForLastKnownAPNToken)
  }

}