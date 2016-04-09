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
let KeyForFirstSpotCreated = "FIRST_SPOT_CREATED"

class UserDefaults {

  class func setApiKey(apiKeyAttributes: NSDictionary) {
    defaults.setObject(apiKeyAttributes, forKey: KeyForApiKey)
  }

  class func apiKey() -> NSDictionary? {
    return defaults.dictionaryForKey(KeyForApiKey)
  }

  class func setFirstSpotCreated(val: Bool) {
    defaults.setBool(val, forKey:KeyForFirstSpotCreated)
  }

  class func firstSpotCreated() -> Bool {
    return defaults.boolForKey(KeyForFirstSpotCreated)
  }

}