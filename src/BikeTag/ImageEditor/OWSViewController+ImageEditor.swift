//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import UIKit

extension NSObject {
  public func navigationBarButton(
    imageName: String,
    selector: Selector
  ) -> UIView {
    let button = ImageEditorButton()
    button.setImage(imageName: imageName)
    button.tintColor = .white
    button.addTarget(self, action: selector, for: .touchUpInside)
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowRadius = 2
    button.layer.shadowOpacity = 0.66
    button.layer.shadowOffset = .zero
    return button
  }
}

// MARK: -

extension UIViewController {
  public func updateNavigationBar(navigationBarItems: [UIView]) {
    guard navigationBarItems.count > 0 else {
      navigationItem.rightBarButtonItems = []
      return
    }

    let spacing: CGFloat = 16
    let stackView = UIStackView(arrangedSubviews: navigationBarItems)
    stackView.axis = .horizontal
    stackView.spacing = spacing
    stackView.alignment = .center

    // Ensure layout works on older versions of iOS.
    var stackSize = CGSize.zero
    for item in navigationBarItems {
      let itemSize = item.sizeThatFits(.zero)
      stackSize.width += itemSize.width + spacing
      stackSize.height = max(stackSize.height, itemSize.height)
    }
    if navigationBarItems.count > 0 {
      stackSize.width -= spacing
    }
    stackView.frame = CGRect(origin: .zero, size: stackSize)

    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
  }
}
