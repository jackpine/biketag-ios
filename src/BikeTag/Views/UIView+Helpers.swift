//
//  UIView+Helpers.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/14/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import UIKit

public extension UIView {
    func addDropShadow() {
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
    }

    func addBorder(colored color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = 1
    }

    func addRedBorderRecursively() {
        addBorder(colored: .red)
        for subview in subviews {
            subview.addRedBorderRecursively()
        }
    }

    func renderAsImage() -> UIImage? {
        return renderAsImage(opaque: false, scale: UIScreen.main.scale)
    }

    func renderAsImage(opaque: Bool, scale: CGFloat) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = opaque
        let renderer = UIGraphicsImageRenderer(bounds: bounds,
                                               format: format)
        return renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
    }
}

// MARK: - Layout

extension UIView {
    class func hStretchingSpacer() -> UIView {
        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return spacer
    }

    func applyScaleAspectFitLayout(subview: UIView, aspectRatio: CGFloat) -> [NSLayoutConstraint] {
        guard subviews.contains(subview) else {
            assertionFailure("Not a subview.")
            return []
        }

        // This emulates the behavior of contentMode = .scaleAspectFit using
        // iOS auto layout constraints.
        //
        // This allows ConversationInputToolbar to place the "cancel" button
        // in the upper-right hand corner of the preview content.
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: subview.autoCenterInSuperview())
        constraints.append(subview.autoPin(toAspectRatio: aspectRatio))
        constraints.append(subview.autoMatch(.width, to: .width, of: self, withMultiplier: 1.0, relation: .lessThanOrEqual))
        constraints.append(subview.autoMatch(.height, to: .height, of: self, withMultiplier: 1.0, relation: .lessThanOrEqual))
        NSLayoutConstraint.autoSetPriority(UILayoutPriority.defaultHigh) {
            constraints.append(subview.autoMatch(.width, to: .width, of: self, withMultiplier: 1.0, relation: .equal))
            constraints.append(subview.autoMatch(.height, to: .height, of: self, withMultiplier: 1.0, relation: .equal))
        }

        return constraints
    }
}

// MARK: - PureLayout extras

public extension UIView {
    @discardableResult
    func autoPin(toEdgesOf other: UIView) -> [NSLayoutConstraint] {
        return [
            autoPinEdge(.left, to: .left, of: other),
            autoPinEdge(.right, to: .right, of: other),
            autoPinEdge(.top, to: .top, of: other),
            autoPinEdge(.bottom, to: .bottom, of: other),
        ]
    }

    func setContentHuggingLow() {
        setContentHuggingHorizontalLow()
        setContentHuggingVerticalLow()
    }

    func setContentHuggingHigh() {
        setContentHuggingHorizontalHigh()
        setContentHuggingVerticalHigh()
    }

    func setContentHuggingHorizontalLow() {
        setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    func setContentHuggingHorizontalHigh() {
        setContentHuggingPriority(.required, for: .horizontal)
    }

    func setContentHuggingVerticalLow() {
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    func setContentHuggingVerticalHigh() {
        setContentHuggingPriority(.required, for: .vertical)
    }

    func setCompressionResistanceLow() {
        setCompressionResistanceHorizontalLow()
        setCompressionResistanceVerticalLow()
    }

    func setCompressionResistanceHigh() {
        setCompressionResistanceHorizontalHigh()
        setCompressionResistanceVerticalHigh()
    }

    func setCompressionResistanceHorizontalLow() {
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func setCompressionResistanceHorizontalHigh() {
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func setCompressionResistanceVerticalLow() {
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    func setCompressionResistanceVerticalHigh() {
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    @discardableResult
    func autoPin(toAspectRatio ratio: CGFloat) -> NSLayoutConstraint {
        return autoPin(toAspectRatio: ratio, relation: .equal)
    }

    func autoPin(toAspectRatio ratio: CGFloat, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint {
        // Clamp to ensure view has reasonable aspect ratio.
        let clampedRatio = ratio.clamped(by: 0.05 ... 95.0)
        if clampedRatio != ratio {
            assertionFailure("Invalid aspect ratio: \(ratio) for view: \(self)")
        }

        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: relation,
                                            toItem: self,
                                            attribute: .height,
                                            multiplier: clampedRatio,
                                            constant: 0)
        constraint.autoInstall()

        return constraint
    }
}

class CircleView: PillView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoPin(toAspectRatio: 1)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PillView: UIView {
    override var bounds: CGRect {
        didSet {
            layer.cornerRadius = bounds.size.height / 2
        }
    }
}
