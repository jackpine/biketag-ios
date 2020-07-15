//
//  Color.swift
//  BikeTag
//
//  Created by Michael Kirk on 3/27/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Theme

extension UIColor {
    static let bt_red: UIColor = UIColor(rgbHex: 0xFC0D1B)
    static let bt_gray: UIColor = .gray
    static let bt_primaryText: UIColor = .black
    static let bt_background: UIColor = .white
}

// MARK: - Helpers

extension UIColor {
    convenience init(rgbHex value: UInt) {
        let red = CGFloat((value >> 16) & 0xFF) / 255.0
        let green = CGFloat((value >> 8) & 0xFF) / 255.0
        let blue = CGFloat((value >> 0) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    func blended(with otherColor: UIColor, alpha alphaParam: CGFloat) -> UIColor {
        var r0: CGFloat = 0
        var g0: CGFloat = 0
        var b0: CGFloat = 0
        var a0: CGFloat = 0
        let result0 = getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
        assert(result0)

        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        let result1 = otherColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        assert(result1)

        let alpha = alphaParam.clamped(by: 0 ... 1)
        return UIColor(red: alpha.lerp(r0, r1),
                       green: alpha.lerp(g0, g1),
                       blue: alpha.lerp(b0, b1),
                       alpha: alpha.lerp(a0, a1))
    }
}
