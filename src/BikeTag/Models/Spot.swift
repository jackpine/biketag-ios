import UIKit
import CoreLocation

class Spot: NSObject {
  var image: UIImage
  var location: CLLocation
  let user: User
  
  init(image: UIImage, location: CLLocation, user: User) {
    self.user = user
    self.image = image
    self.location = location
  }

  class func fetchCurrentSpot(callback:(Spot)->()) {
    dispatch_async(dispatch_get_main_queue(), {
      //simulate network delay
      sleep(1)

      let currentSpot = self.lucileSpot()
      callback(currentSpot)
    })
  }

  class func createNewSpot(image: UIImage, location: CLLocation, callback: (Spot) ->()) {
    dispatch_async(dispatch_get_main_queue(), {
      //simulate network delay
      sleep(1)

      //TODO enforce login before creating new spot
      assert(User.getCurrentUser() != nil)
      let newSpot = Spot(image: image, location: location, user: User.getCurrentUser()!)
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

  // static spot, used to seed game and for testing
  class func lucileSpot() -> Spot {
    let image = UIImage( named: "952 lucile" )!
    let lat = 34.086582
    let lon = -118.281633
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, location: location, user: User())
  }

  // static spot, used to seed game and for testing
  class func griffithSpot() -> Spot {
    let image = UIImage(named: "griffith")!
    let lat = 34.1186
    let lon = -118.3004
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, location: location, user: User())
  }

  func isCurrentUserOwner() -> Bool {
    if User.getCurrentUser() == self.user {
      return true
    } else {
      return false
    }
  }
}
