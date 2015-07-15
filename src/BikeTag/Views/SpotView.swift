import UIKit

class SpotView: UIImageView {

  var spot: Spot?

  required init(frame: CGRect, spot: Spot) {
    super.init(frame: frame)
    self.image = spot.image
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
    self.spot = spot

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSpotViewImage", name: Spot.DidSetImageNotification, object: spot)
  }

  required init(coder: NSCoder) {
    super.init(coder: coder)
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
  }

  func updateSpotViewImage() {
    if self.spot != nil {
      self.image = self.spot!.image
    }
  }
}
