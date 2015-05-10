import Foundation
import UIKit

class ApplicationViewController: UIViewController {

  func stylePrimaryButton(button: UIButton) {
    button.layer.cornerRadius = 8.0
    button.layer.masksToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.grayColor().CGColor
  }

}
