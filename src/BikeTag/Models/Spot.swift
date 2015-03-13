import UIKit
import CoreLocation

class Spot: NSObject {
  var isCurrentUserOwner = false
  var image: UIImage
  var location: CLLocation
  
  init(image: UIImage, location: CLLocation, isCurrentUser: Bool) {
    self.isCurrentUserOwner = isCurrentUser
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

      //stub network response
      let newSpot = Spot(image: image, location: location, isCurrentUser: true)
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
    return Spot(image: image, location: location, isCurrentUser: false)
  }

  // static spot, used to seed game and for testing
  class func griffithSpot() -> Spot {
    let image = UIImage(named: "griffith")!
    let lat = 34.1186
    let lon = -118.3004
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, location: location, isCurrentUser: true)
  }

}
