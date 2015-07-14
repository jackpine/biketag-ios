import UIKit
import Alamofire

class SpotView: UIImageView {
  required init(frame: CGRect, spot: Spot) {
    super.init(frame: frame)
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
    self.image = spot.image
  }

  required init(coder: NSCoder) {
    super.init(coder: coder)
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
  }
}
