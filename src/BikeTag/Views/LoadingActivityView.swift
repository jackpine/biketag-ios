//
//  LoadingView.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/13/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import Foundation
import UIKit

public class LoadingActivityView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    translatesAutoresizingMaskIntoConstraints = false

    backgroundColor = .bt_background

    addSubview(rows)

    _ = {
      rows.translatesAutoresizingMaskIntoConstraints = false
      let offset: CGFloat = 8
      NSLayoutConstraint.activate([
        rows.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset),
        rows.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -offset),
        rows.topAnchor.constraint(equalTo: topAnchor, constant: offset),
        rows.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset),
        imageView.heightAnchor.constraint(equalToConstant: 80),
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
      ])
    }()

    layer.cornerRadius = 16
    layer.masksToBounds = true
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Subviews

  lazy var imageView: UIImageView = {
    let image = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)
    let imageView = UIImageView(image: image)
    return imageView
  }()

  lazy var label: UILabel = {
    let label = UILabel()
    label.font = .bt_bold_label
    label.text = NSLocalizedString("Finding spots near you...", comment: "loading indicator label")
    return label
  }()

  lazy var rows: UIStackView = {
    let rows = UIStackView(arrangedSubviews: [imageView, label])
    rows.axis = .vertical
    rows.alignment = .center

    return rows
  }()
}
