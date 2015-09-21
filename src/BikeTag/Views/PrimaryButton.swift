import UIKit

class PrimaryButton: UIButton {

  required override init(frame: CGRect) {
    super.init(frame: frame)
    self.applyStyle()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    self.applyStyle()
  }

  func applyStyle() {
    self.layer.cornerRadius = 8.0
    self.layer.masksToBounds = true
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.grayColor().CGColor
  }

}