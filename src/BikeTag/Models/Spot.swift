import UIKit
import CoreLocation

class Spot: NSObject {
  var image: UIImage
  var location: CLLocation?
  var id: Int?
  let user: User

  init(image: UIImage, user: User, id: Int) {
    self.user = user
    self.image = image
  }

  init(image: UIImage, user: User, location: CLLocation) {
    self.user = user
    self.image = image
    self.location = location
  }

  class func fetchCurrentSpot(callback:(Spot)->(), errorCallback:(NSError)->()) {
    let buildSpotFromResponse = { (parsedSpot: ParsedSpot) -> () in
      let imageData = NSData(contentsOfURL: parsedSpot.imageUrl)
      let image = UIImage(data: imageData!)
      let user = User(id: parsedSpot.userId)
      let currentSpot = Spot(image: image!, user: user, id: parsedSpot.spotId)
      callback(currentSpot)
    }

    SpotsService.fetchCurrentSpot(buildSpotFromResponse, errorCallback: errorCallback)
  }

  class func createNewSpot(image: UIImage, location: CLLocation, callback: (Spot) ->()) {
    dispatch_async(dispatch_get_main_queue(), {
      //simulate network delay
      sleep(1)

      let newSpot = Spot(image: image, user: User.getCurrentUser(), location: location)
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
    return Spot(image: image, user: User(deviceId: "lucile-device-id"), location: location)
  }

  // static spot, used to seed game and for testing
  class func griffithSpot() -> Spot {
    let image = UIImage(named: "griffith")!
    let lat = 34.1186
    let lon = -118.3004
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, user: User(deviceId: "griffith-device-id"), location: location)
  }

  func isCurrentUserOwner() -> Bool {
    if User.getCurrentUser() == self.user {
      return true
    } else {
      return false
    }
  }
}
