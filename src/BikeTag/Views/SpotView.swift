import UIKit
import Alamofire

private var imageCache = [Int:UIImage]()
class SpotView: UIImageView {

  required init(frame: CGRect, spot: Spot) {
    super.init(frame: frame)
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
    let spotId = spot.id!
    if imageCache[spotId] == nil {
      self.image = UIImage(named: "sketchy bike")
      Alamofire.request(.GET, spot.imageUrl!).response() {
        (_, _, data, _) in
        let image = UIImage(data: data! as! NSData)
        self.image = image
        imageCache[spotId] = image
      }
    } else {
      self.image = imageCache[spotId]
    }
  }

  required init(coder: NSCoder) {
    super.init(coder: coder)
    self.contentMode = .ScaleAspectFill
    self.clipsToBounds = true
  }
}