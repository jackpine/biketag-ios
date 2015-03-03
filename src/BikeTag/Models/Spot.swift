import UIKit

class Spot: NSObject {
  var isCurrentUserOwner = false
  var image:UIImage? = nil
  
  init(image: UIImage, isCurrentUser: Bool) {
    self.isCurrentUserOwner = isCurrentUser
    self.image = image
  }
}
