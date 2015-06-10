import UIKit

class SpotView: UIView {
  let imageView: UIImageView?
  let spot: Spot?

  required init(frame: CGRect, spot: Spot) {
    self.spot = spot
    self.imageView = UIImageView(image: spot.image)
    super.init(frame: frame)
  }

  required init(coder: NSCoder) {
    self.imageView = nil
    self.spot = nil
    super.init(coder: coder)
  }


}