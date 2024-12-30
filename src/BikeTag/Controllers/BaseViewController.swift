import Foundation
import UIKit

public class BaseViewController: UIViewController {
  lazy var logger: Logger = {
    Logger(category: Self.description())
  }()

  override public var preferredStatusBarStyle: UIStatusBarStyle {
    .lightContent
  }
}

public class BaseNavController: UINavigationController {
  override public var preferredStatusBarStyle: UIStatusBarStyle {
    .lightContent
  }
}

extension UINavigationController {
  func fadeTo(_ viewController: UIViewController) {
    let transition: CATransition = CATransition()
    transition.duration = 0.3
    transition.type = CATransitionType.fade
    view.layer.add(transition, forKey: nil)
    pushViewController(viewController, animated: false)
  }
}
