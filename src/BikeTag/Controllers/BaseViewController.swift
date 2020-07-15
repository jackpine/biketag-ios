import Foundation
import UIKit

public class BaseViewController: UIViewController {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

public class BaseNavController: UINavigationController {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
