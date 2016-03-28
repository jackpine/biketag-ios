
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
    self.layer.cornerRadius = 8.0
    self.layer.masksToBounds = true
    self.layer.borderWidth = 1
    self.titleLabel?.font = Font.titleFont
    self.setTitleColor(Color.grayColor, forState: .Disabled)
    applyStyle(state: self.state)
  }

  func applyStyle(state aState:UIControlState) {
    switch(aState) {
    case UIControlState.Disabled:
      self.layer.borderColor = Color.grayColor.CGColor

    default:
      self.layer.borderColor = Color.redColor.CGColor
    }
  }
  
}