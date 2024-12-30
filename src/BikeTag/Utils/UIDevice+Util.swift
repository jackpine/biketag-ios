//
//  UIDevice+Util.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/17/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import UIKit

extension UIDevice {
  // https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x/47067296
  var hasNotch: Bool {
    if #available(iOS 13.0, *) {
      return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 0
        > 20
    } else if #available(iOS 11.0, *) {
      return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    } else {
      return false
    }
  }
}
