
import UIKit

class PrimaryButton: UIButton {

  override var enabled: Bool {
    didSet {
      applyStyle()
    }
  }
  
  required override init(frame: CGRect) {
    super.init(frame: frame)
    self.applyStyle()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    self.applyStyle()
  }

  func applyStyle() {
    self.backgroundColor = UIColor.clearColor()
    self.titleLabel?.font = Font.titleFont
    self.setTitleColor(Color.grayColor, forState: .Disabled)
    self.setTitleColor(Color.redColor, forState: .Normal)
  }
  
}