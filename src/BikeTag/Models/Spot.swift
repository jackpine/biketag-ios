import UIKit

class Spot: NSObject {
  var isCurrentUserOwner = false
  var image:UIImage? = nil

  func initWithImage(image:UIImage, isCurrentUserOwner:Bool) {
    self.isCurrentUserOwner = isCurrentUserOwner
    self.image = image
  }
}
