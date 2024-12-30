//
//  UserDefaults.swift
//  BikeTag
//
//  Created by Michael Kirk on 4/9/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import Foundation

// TODO: do we *really* want to extend UserDefaults? Convert class funcs to static getters
extension UserDefaults {
  static let defaults = UserDefaults.standard
  static let KeyForApiKey = "apiKey"
  static let KeyForHasPreviouslyCreatedSpot = "HAS_PREVIOUSLY_CREATED_SPOT"
  static let KeyForPrefersReceivingNotifications = "PREFERS_RECEIVING_NOTIFICATIONS"
  static let KeyForLastKnownAPNToken = "LAST_KNOWN_APN_TOKEN"

  class func setApiKey(apiKeyAttributes: [String: Any]) {
    defaults.set(apiKeyAttributes, forKey: KeyForApiKey)
  }

  class func apiKey() -> [String: Any]? {
    return defaults.dictionary(forKey: KeyForApiKey)
  }

  class func setHasPreviouslyCreatedSpot(val: Bool) {
    defaults.set(val, forKey: KeyForHasPreviouslyCreatedSpot)
  }

  class func hasPreviouslyCreatedSpot() -> Bool {
    return defaults.bool(forKey: KeyForHasPreviouslyCreatedSpot)
  }

  class func setPrefersReceivingNotifications(val: Bool) {
    defaults.set(val, forKey: KeyForPrefersReceivingNotifications)
  }

  class func prefersReceivingNotifications() -> Bool {
    return defaults.bool(forKey: KeyForPrefersReceivingNotifications)
  }

  class func lastKnownAPNToken() -> String? {
    return defaults.string(forKey: KeyForLastKnownAPNToken)
  }

  class func setLastKnownAPNToken(val: String) {
    defaults.set(val, forKey: KeyForLastKnownAPNToken)
  }
}
