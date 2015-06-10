import UIKit

class SpotView: UIImageView {
  required init(frame: CGRect, spot: Spot) {
    super.init(image: spot.image)
  }

  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
}