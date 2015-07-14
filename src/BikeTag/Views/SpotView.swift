import UIKit

class SpotView: UIImageView {
  required init(frame: CGRect, spot: Spot) {
    super.init(frame: frame)
    spot.imageView = self
    self.image = spot.image
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
  }

  required init(coder: NSCoder) {
    super.init(coder: coder)
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
  }
}
