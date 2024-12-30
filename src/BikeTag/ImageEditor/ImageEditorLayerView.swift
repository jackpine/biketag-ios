//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

@objc
public class ImageEditorLayerView: UIView {
  @objc
  public var shouldAnimate = true

  @objc
  public var layoutCallback: (UIView) -> Void

  @objc
  public init() {
    layoutCallback = { _ in
    }
    super.init(frame: .zero)
  }

  @objc
  public init(frame: CGRect, layoutCallback: @escaping (UIView) -> Void) {
    self.layoutCallback = layoutCallback
    super.init(frame: frame)
  }

  public required init?(coder aDecoder: NSCoder) {
    layoutCallback = { _ in
    }
    super.init(coder: aDecoder)
  }

  override public var bounds: CGRect {
    didSet {
      if oldValue != bounds {
        layoutCallback(self)
      }
    }
  }

  override public var frame: CGRect {
    didSet {
      if oldValue != frame {
        layoutCallback(self)
      }
    }
  }

  override public var center: CGPoint {
    didSet {
      if oldValue != center {
        layoutCallback(self)
      }
    }
  }

  public func updateContent() {
    if shouldAnimate {
      layoutCallback(self)
    } else {
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      layoutCallback(self)
      CATransaction.commit()
    }
  }
}
