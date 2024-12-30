//
//  BottomSectionView.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/17/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import Foundation
import UIKit

class BottomSectionView: UIView {
  let label = UILabel()

  required init(frame: CGRect, button: UIView) {
    super.init(frame: frame)
    backgroundColor = UIColor.black.withAlphaComponent(0.2)

    layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    if UIDevice.current.hasNotch {
      layoutMargins.bottom = 0
    }
    preservesSuperviewLayoutMargins = true

    button.autoSetDimension(.height, toSize: 80)

    label.font = UIFont.bt_bold_label.withSize(16)
    label.textColor = .bt_whiteText
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true

    let stack = UIStackView(arrangedSubviews: [label, button])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 16

    addSubview(stack)
    stack.autoPinEdgesToSuperviewMargins()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
