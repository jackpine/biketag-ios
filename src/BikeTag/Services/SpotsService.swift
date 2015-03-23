import Alamofire

//let apiEndPoint = "http://172.16.150.109:3000/api/v1/"
let apiEndpoint = "http://192.168.59.103:3000/api/v1/"

class SpotsService {

  class func fetchCurrentSpot(callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint + "games/1/current_spot.json"

    Alamofire.request(.GET, url)
      .responseJSON { (request, response, json, error) in
        if( error != nil ) {
          return errorCallback(error!)
        }

        let responseAttributes = json as NSDictionary
        let spotAttributes = responseAttributes.valueForKey("spot") as NSDictionary
        let parsedSpot = ParsedSpot(attributes: spotAttributes)
        callback(parsedSpot)
    }
  }

  class func postNewSpot(spot: Spot, callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint + "games/1/spots.json"

    let parameters = [ "spot": [
      "location": [
        "type": "Point",
        "coordinates": [spot.location!.coordinate.longitude, spot.location!.coordinate.latitude]
      ],
      "user": userParameters(spot.user)
    ]]

    Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
      .responseJSON { (request, response, json, error) in
        if( error != nil ) {
          return errorCallback(error!)
        }

        let responseAttributes = json as NSDictionary
        let spotAttributes = responseAttributes.valueForKey("spot") as NSDictionary
        let parsedSpot = ParsedSpot(attributes: spotAttributes)
        callback(parsedSpot)
    }
  }

  class func userParameters(user: User) -> NSDictionary {
    let userParameters = NSMutableDictionary()
    assert(user.id != nil || user.deviceId != nil)
    if (user.id != nil) {
      userParameters.setValue(user.id!, forKey: "id")
    } else if (user.deviceId != nil ) {
      userParameters.setValue(user.deviceId!, forKey: "device_id")
    }

    return userParameters
  }

  class func postSpotGuess(guess: Guess, callback: (Bool)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint + "games/1/spots/\(guess.spot.id!)/guesses.json"

    let parameters = [ "guess": [
      "location": [
        "type": "Point",
        "coordinates": [guess.location.coordinate.longitude, guess.location.coordinate.latitude]
      ],
      "user": userParameters(guess.user)
    ]]

    Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
      .responseJSON { (request, response, json, error) in
        if( error != nil ) {
          return errorCallback(error!)
        }

        let responseAttributes = json as NSDictionary
        let guessAttributes = responseAttributes.valueForKey("guess") as NSDictionary
        let guessResult = guessAttributes.valueForKey("correct") as Bool

        callback(guessResult)
    }
  }
}