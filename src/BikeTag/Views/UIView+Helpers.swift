//
//  UIView+Helpers.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/14/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import UIKit

public extension UIView {
    class func hStretchingSpacer() -> UIView {
        let spacer = UIView()
        NSLayoutConstraint.autoSetPriority(.defaultLow) {
            spacer.autoSetContentCompressionResistancePriority(for: .horizontal)
            spacer.autoSetContentHuggingPriority(for: .horizontal)
        }
        return spacer
    }

    func setDropShadow() {
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
    }

    func addRedBorder() {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
    }

    func addRedBorderRecursively() {
        addRedBorder()
        for subview in subviews {
            subview.addRedBorderRecursively()
        }
    }
}
