//
//  CGPoint+Helpers.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/15/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import CoreGraphics
import Foundation

public extension CGPoint {
    func isApproxEqual(to other: Self,
                       comparison: BinaryFloatingPointComparison<CGFloat>? = nil) -> Bool {
        if let comparison = comparison {
            return x.isApproxEqual(to: other.x, comparison: comparison) && y.isApproxEqual(to: other.y, comparison: comparison)
        } else {
            return x.isApproxEqual(to: other.x) && y.isApproxEqual(to: other.y)
        }
    }

    func distance(to other: CGPoint) -> CGFloat {
        return sqrt(pow(other.x - x, 2) + pow(other.y - y, 2))
    }

    func scaled(by factor: CGFloat) -> CGPoint {
        CGPoint(x: x * factor, y: y * factor)
    }

    static func add(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func subtract(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    func toUnitCoordinates(viewBounds: CGRect, shouldClamp: Bool) -> CGPoint {
        return CGPoint(x: (x - viewBounds.origin.x).inverseLerp(0, viewBounds.width, shouldClamp: shouldClamp),
                       y: (y - viewBounds.origin.y).inverseLerp(0, viewBounds.height, shouldClamp: shouldClamp))
    }

    func toUnitCoordinates(viewSize: CGSize, shouldClamp: Bool) -> CGPoint {
        return toUnitCoordinates(viewBounds: CGRect(origin: .zero, size: viewSize), shouldClamp: shouldClamp)
    }

    func fromUnitCoordinates(viewBounds: CGRect) -> CGPoint {
        return CGPoint(x: viewBounds.origin.x + x.lerp(0, viewBounds.size.width),
                       y: viewBounds.origin.y + y.lerp(0, viewBounds.size.height))
    }

    func fromUnitCoordinates(viewSize: CGSize) -> CGPoint {
        return fromUnitCoordinates(viewBounds: CGRect(origin: .zero, size: viewSize))
    }

    func inverse() -> CGPoint {
        return CGPoint(x: -x, y: -y)
    }

    func plus(_ value: CGPoint) -> CGPoint {
        return CGPoint.add(self, value)
    }

    func minus(_ value: CGPoint) -> CGPoint {
        return CGPoint.subtract(self, value)
    }

    func min(_ value: CGPoint) -> CGPoint {
        // We use "Swift" to disambiguate the global function min() from this method.
        return CGPoint(x: Swift.min(x, value.x),
                       y: Swift.min(y, value.y))
    }

    func max(_ value: CGPoint) -> CGPoint {
        // We use "Swift" to disambiguate the global function max() from this method.
        return CGPoint(x: Swift.max(x, value.x),
                       y: Swift.max(y, value.y))
    }

    var length: CGFloat {
        return sqrt(x * x + y * y)
    }

    @inlinable
    func distance(_ other: CGPoint) -> CGFloat {
        return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }

    @inlinable
    func within(_ delta: CGFloat, of other: CGPoint) -> Bool {
        return distance(other) <= delta
    }

    static let unit: CGPoint = CGPoint(x: 1.0, y: 1.0)

    static let unitMidpoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

    func applyingInverse(_ transform: CGAffineTransform) -> CGPoint {
        return applying(transform.inverted())
    }

    static func tan(angle: CGFloat) -> CGPoint {
        return CGPoint(x: sin(angle),
                       y: cos(angle))
    }

    func clamp(_ rect: CGRect) -> CGPoint {
        return CGPoint(x: x.clamped(by: rect.minX ... rect.maxX),
                       y: y.clamped(by: rect.minY ... rect.maxY))
    }

    func clamped(by range: ClosedRange<CGFloat>) -> CGPoint {
        CGPoint(x: range.clamp(x), y: range.clamp(y))
    }
}

public extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }

    var topLeft: CGPoint {
        return origin
    }

    var topRight: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }

    var bottomLeft: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }

    var bottomRight: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}

public extension CGSize {
    init(square size: CGFloat) {
        self.init(width: size, height: size)
    }
}

public extension CGAffineTransform {
    static func translate(_ point: CGPoint) -> CGAffineTransform {
        return CGAffineTransform(translationX: point.x, y: point.y)
    }

    static func scale(_ scaling: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(scaleX: scaling, y: scaling)
    }

    func translate(_ point: CGPoint) -> CGAffineTransform {
        return translatedBy(x: point.x, y: point.y)
    }

    func scale(_ scaling: CGFloat) -> CGAffineTransform {
        return scaledBy(x: scaling, y: scaling)
    }

    func rotate(_ angleRadians: CGFloat) -> CGAffineTransform {
        return rotated(by: angleRadians)
    }
}

public extension BinaryFloatingPoint {
    // Linear interpolation
    func lerp(_ min: Self, _ max: Self) -> Self {
        (min * (1 - self)) + (max * self)
    }

    // Inverse linear interpolation
    func inverseLerp(_ min: Self, _ max: Self, shouldClamp: Bool = false) -> Self {
        let value = (self - min) / (max - min)
        return shouldClamp ? value.clamped(by: 0 ... 1) : value
    }

    func clamped(by range: ClosedRange<Self>) -> Self {
        range.clamp(self)
    }

    func squared() -> Self {
        return self * self
    }
}
