//
//  CGPoint+Helpers.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/15/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import CoreGraphics
import Foundation

extension CGPoint {
  public func isApproxEqual(
    to other: Self,
    comparison: BinaryFloatingPointComparison<CGFloat>? = nil
  ) -> Bool {
    if let comparison = comparison {
      return x.isApproxEqual(to: other.x, comparison: comparison)
        && y.isApproxEqual(to: other.y, comparison: comparison)
    } else {
      return x.isApproxEqual(to: other.x) && y.isApproxEqual(to: other.y)
    }
  }

  public func distance(to other: CGPoint) -> CGFloat {
    return sqrt(pow(other.x - x, 2) + pow(other.y - y, 2))
  }

  public func scaled(by factor: CGFloat) -> CGPoint {
    CGPoint(x: x * factor, y: y * factor)
  }

  public static func add(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  public static func subtract(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  public func toUnitCoordinates(viewBounds: CGRect, shouldClamp: Bool) -> CGPoint {
    return CGPoint(
      x: (x - viewBounds.origin.x).inverseLerp(0, viewBounds.width, shouldClamp: shouldClamp),
      y: (y - viewBounds.origin.y).inverseLerp(0, viewBounds.height, shouldClamp: shouldClamp))
  }

  public func toUnitCoordinates(viewSize: CGSize, shouldClamp: Bool) -> CGPoint {
    return toUnitCoordinates(
      viewBounds: CGRect(origin: .zero, size: viewSize), shouldClamp: shouldClamp)
  }

  public func fromUnitCoordinates(viewBounds: CGRect) -> CGPoint {
    return CGPoint(
      x: viewBounds.origin.x + x.lerp(0, viewBounds.size.width),
      y: viewBounds.origin.y + y.lerp(0, viewBounds.size.height))
  }

  public func fromUnitCoordinates(viewSize: CGSize) -> CGPoint {
    return fromUnitCoordinates(viewBounds: CGRect(origin: .zero, size: viewSize))
  }

  public func inverse() -> CGPoint {
    return CGPoint(x: -x, y: -y)
  }

  public func plus(_ value: CGPoint) -> CGPoint {
    return CGPoint.add(self, value)
  }

  public func minus(_ value: CGPoint) -> CGPoint {
    return CGPoint.subtract(self, value)
  }

  public func min(_ value: CGPoint) -> CGPoint {
    // We use "Swift" to disambiguate the global function min() from this method.
    return CGPoint(
      x: Swift.min(x, value.x),
      y: Swift.min(y, value.y))
  }

  public func max(_ value: CGPoint) -> CGPoint {
    // We use "Swift" to disambiguate the global function max() from this method.
    return CGPoint(
      x: Swift.max(x, value.x),
      y: Swift.max(y, value.y))
  }

  public var length: CGFloat {
    return sqrt(x * x + y * y)
  }

  @inlinable
  public func distance(_ other: CGPoint) -> CGFloat {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
  }

  @inlinable
  public func within(_ delta: CGFloat, of other: CGPoint) -> Bool {
    return distance(other) <= delta
  }

  public static let unit: CGPoint = CGPoint(x: 1.0, y: 1.0)

  public static let unitMidpoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

  public func applyingInverse(_ transform: CGAffineTransform) -> CGPoint {
    return applying(transform.inverted())
  }

  public static func tan(angle: CGFloat) -> CGPoint {
    return CGPoint(
      x: sin(angle),
      y: cos(angle))
  }

  public func clamp(_ rect: CGRect) -> CGPoint {
    return CGPoint(
      x: x.clamped(by: rect.minX...rect.maxX),
      y: y.clamped(by: rect.minY...rect.maxY))
  }

  public func clamped(by range: ClosedRange<CGFloat>) -> CGPoint {
    CGPoint(x: range.clamp(x), y: range.clamp(y))
  }
}

extension CGRect {
  public var center: CGPoint {
    return CGPoint(x: midX, y: midY)
  }

  public var topLeft: CGPoint {
    return origin
  }

  public var topRight: CGPoint {
    return CGPoint(x: maxX, y: minY)
  }

  public var bottomLeft: CGPoint {
    return CGPoint(x: minX, y: maxY)
  }

  public var bottomRight: CGPoint {
    return CGPoint(x: maxX, y: maxY)
  }
}

extension CGSize {
  public init(square size: CGFloat) {
    self.init(width: size, height: size)
  }
}

extension CGAffineTransform {
  public static func translate(_ point: CGPoint) -> CGAffineTransform {
    return CGAffineTransform(translationX: point.x, y: point.y)
  }

  public static func scale(_ scaling: CGFloat) -> CGAffineTransform {
    return CGAffineTransform(scaleX: scaling, y: scaling)
  }

  public func translate(_ point: CGPoint) -> CGAffineTransform {
    return translatedBy(x: point.x, y: point.y)
  }

  public func scale(_ scaling: CGFloat) -> CGAffineTransform {
    return scaledBy(x: scaling, y: scaling)
  }

  public func rotate(_ angleRadians: CGFloat) -> CGAffineTransform {
    return rotated(by: angleRadians)
  }
}

extension BinaryFloatingPoint {
  // Linear interpolation
  public func lerp(_ min: Self, _ max: Self) -> Self {
    (min * (1 - self)) + (max * self)
  }

  // Inverse linear interpolation
  public func inverseLerp(_ min: Self, _ max: Self, shouldClamp: Bool = false) -> Self {
    let value = (self - min) / (max - min)
    return shouldClamp ? value.clamped(by: 0...1) : value
  }

  public func clamped(by range: ClosedRange<Self>) -> Self {
    range.clamp(self)
  }

  public func squared() -> Self {
    return self * self
  }
}
