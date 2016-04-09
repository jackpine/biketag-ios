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

}