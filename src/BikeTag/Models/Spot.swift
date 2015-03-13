import UIKit

class Spot: NSObject {
  var isCurrentUserOwner = false
  var image:UIImage? = nil
  
  init(image: UIImage, isCurrentUser: Bool) {
    self.isCurrentUserOwner = isCurrentUser
    self.image = image
  }

  class func fetchCurrentSpot(callback:(Spot)->()) {
    dispatch_async(dispatch_get_main_queue(), {
      //simulate network delay
      sleep(1)
      let initialImage = UIImage( named: "952 lucile" )!
      let currentSpot = Spot(image: initialImage, isCurrentUser: false)

      callback(currentSpot)
    })
  }

  class func createNewSpot(image: UIImage, callback: (Spot) ->()) {
    dispatch_async(dispatch_get_main_queue(), {
      //simulate network delay
      sleep(1)

      //stub network response
      let newSpot = Spot(image: image, isCurrentUser: true)
      callback(newSpot)
    })
  }

  class func checkGuess(correctCallback:() -> (), incorrectCallback:() -> ()) {
    dispatch_async(dispatch_get_main_queue(), {
      //simulate network delay
      sleep(1)

      //stub network response
      let guessedCorrectly = true

      if guessedCorrectly {
        correctCallback()
      } else {
        incorrectCallback()
      }
    })
  }

}
