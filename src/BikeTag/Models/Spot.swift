import UIKit

class Spot: NSObject {
  var isCurrentUserOwner = false
  var image:UIImage? = nil
  
  init(image: UIImage, isCurrentUser: Bool) {
    self.isCurrentUserOwner = isCurrentUser
    self.image = image
  }

  class func fetchCurrentSpot(callback:(Spot)->()) -> () {
    dispatch_async(dispatch_get_main_queue(), {
      //simulate network delay
      sleep(1)
      let initialImage = UIImage( named: "952 lucile" )!
      let currentSpot = Spot(image: initialImage, isCurrentUser: false)

      callback(currentSpot)
    })
  }

}
