import UIKit
import CoreLocation
import Alamofire

class Spot: NSObject {

  static let DidSetImageNotification = "SpotDidSetImageNotification"

  var image: UIImage {
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName(Spot.DidSetImageNotification, object: self)
    }
  }
  var imageUrl: NSURL?
  var location: CLLocation?
  var imageView: UIImageView?
  var id: Int?
  let game: Game
  let user: User

  init(image: UIImage, game: Game, user: User, id: Int) {
    self.user = user
    self.image = image
    self.id = id
    self.game = game
  }

  init(image: UIImage, game: Game, user: User, location: CLLocation) {
    self.user = user
    self.image = image
    self.location = location
    self.game = game
  }

  init(parsedSpot: ParsedSpot) {
    self.user = User(id: parsedSpot.userId, name: parsedSpot.userName)
    self.id = parsedSpot.spotId
    self.game = Game(id: parsedSpot.gameId)
    self.imageUrl = parsedSpot.imageUrl
    //placeholder while image is fetched async
    self.image = UIImage(named: "sketchy bike")!
    super.init()

    Alamofire.request(.GET, parsedSpot.imageUrl).response() {
      (_, _, data, _) in
      if data != nil {
        let image = UIImage(data: data!)
        if image != nil {
          self.image = image!
        }
      }
    }
  }

  class func fetchCurrentSpots(spotsService: SpotsService, location: CLLocation, callback:([Spot])->(), errorCallback:(NSError)->()) {
    let callbackWithBuiltSpots = { (parsedSpots: [ParsedSpot]) -> () in
      let spots = parsedSpots.map { Spot(parsedSpot: $0) }
      callback(spots)
    }

    spotsService.fetchCurrentSpots(location, successCallback: callbackWithBuiltSpots, errorCallback: errorCallback)
  }

  class func createNewSpot(spotsService: SpotsService, image: UIImage, game: Game, location: CLLocation, callback: (Spot) ->(), errorCallback:(NSError)->()) {
    let callbackWithBuiltSpot = { (parsedSpot: ParsedSpot) -> () in
      //hydrate spot with server response - should be more-or-less identical to newSpot
      let spot = Spot(parsedSpot: parsedSpot)
      callback(spot)
    }

    let newSpot = Spot(image: image, game: game, user: User.getCurrentUser(), location: location)
    spotsService.postNewSpot(newSpot, callback: callbackWithBuiltSpot, errorCallback: errorCallback)
  }

  // static spot, used to seed game and for testing
  class func lucileSpot() -> Spot {
    let image = UIImage( named: "952 lucile" )!
    let lat = 34.086582
    let lon = -118.281633
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, game: Game(id: 2), user: User(id: 2, name: "lucile user"), location: location)
  }

  // static spot, used to seed game and for testing
  class func griffithSpot() -> Spot {
    let image = UIImage(named: "griffith")!
    let lat = 34.1186
    let lon = -118.3004
    let location = CLLocation(latitude: lat, longitude: lon)
    return Spot(image: image, game: Game(id: 1), user: User(id: 1, name: "griffith user"), location: location)
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
