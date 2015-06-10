import UIKit

class SpotView: UIImageView {
  required init(frame: CGRect, spot: Spot) {
    super.init(image: spot.image)
    self.frame = frame
  }

  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
}