import UIKit

class SpotView: UIImageView {

  var spot: Spot?
  //TODO make these singletons?
  let loadingImage = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)
  let loadingView = UIImageView()

  required init(frame: CGRect, spot: Spot) {
    super.init(frame: frame)
    if (spot.image == nil) {
      loadingView.frame = CGRect(x: 150, y: 300, width: 100, height: 100)
      loadingView.center = self.center
      loadingView.image = loadingImage
      self.addSubview(loadingView)
    } else {
      self.image = spot.image
    }
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
    self.spot = spot

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSpotViewImage", name: Spot.DidSetImageNotification, object: spot)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
  }

  func updateSpotViewImage() {
    if self.spot == nil {
      self.loadingView.hidden = false
      self.image = nil
    } else {
      self.loadingView.hidden = true
      self.image = self.spot!.image
    }
  }
}
