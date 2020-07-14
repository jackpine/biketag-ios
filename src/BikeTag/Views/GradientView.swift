//
//  GradientView.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/14/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import UIKit

public class GradientView: UIView {
    let gradientLayer = CAGradientLayer()

    public required init(from fromColor: UIColor, to toColor: UIColor) {
        gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        super.init(frame: CGRect.zero)

        layer.addSublayer(gradientLayer)
    }

    public required init?(coder _: NSCoder) {
        fatalError("not implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
