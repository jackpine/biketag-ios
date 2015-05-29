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
    self.id = id
  }

  init(image: UIImage, user: User, location: CLLocation) {
    self.user = user
    self.image = image
    self.location = location
  }

  init(parsedSpot: ParsedSpot) {
    let imageData = NSData(contentsOfURL: parsedSpot.imageUrl)
    if( imageData == nil ) {
      self.image = UIImage(named: "952 lucile")!
    } else {
      self.image = UIImage(data: imageData!)!
    }
    self.user = User(id: parsedSpot.userId)
    self.id = parsedSpot.spotId
  }

  class func fetchCurrentSpot(spotsService: SpotsService, callback:(Spot)->(), errorCallback:(NSError)->()) {
    let callbackWithBuiltSpot = { (parsedSpot: ParsedSpot) -> () in
      let spot = Spot(parsedSpot: parsedSpot)
      callback(spot)
    }

    spotsService.fetchCurrentSpot(callbackWithBuiltSpot, errorCallback: errorCallback)
  }

  class func createNewSpot(spotsService: SpotsService, image: UIImage, location: CLLocation, callback: (Spot) ->(), errorCallback:(NSError)->()) {
    let callbackWithBuiltSpot = { (parsedSpot: ParsedSpot) -> () in
      //hydrate spot with server response - should be more-or-less identical to newSpot
      let spot = Spot(parsedSpot: parsedSpot)
      callback(spot)
    }

    let newSpot = Spot(image: image, user: User.getCurrentUser(), location: location)
    spotsService.postNewSpot(newSpot, callback: callbackWithBuiltSpot, errorCallback: errorCallback)
  }

  // static spot, used to seed game and for testing
  class func lucileSpot() -> Spot {
    let image = UIImage( named: "952 lucile" )!
    let lat = 34.086582
    let lon = -118.281633
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, user: User(id: 2), location: location)
  }

  // static spot, used to seed game and for testing
  class func griffithSpot() -> Spot {
    let image = UIImage(named: "griffith")!
    let lat = 34.1186
    let lon = -118.3004
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, user: User(id: 1), location: location)
  }

  func isCurrentUserOwner() -> Bool {
    if User.getCurrentUser() == self.user {
      return true
    } else {
      return false
    }
  }

  func base64ImageData() -> String {
    return UIImageJPEGRepresentation(self.image, 0.9).base64EncodedStringWithOptions(nil)
  }
}
