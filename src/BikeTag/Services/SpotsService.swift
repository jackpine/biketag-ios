import Alamofire
import CoreLocation

let apiEndpoint = NSURL(string: Config.apiEndpoint())!
let apiKey = "6A6ArqBokMSSXACamqn-"

class SpotsService {
  func fetchCurrentSpot(callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint.URLByAppendingPathComponent("games/1/current_spot.json")
    Logger.info("GET \(url)")

    var currentSpotRequest: NSURLRequest {
      let mutableURLRequest = NSMutableURLRequest(URL: url)
      mutableURLRequest.HTTPMethod = Method.GET.rawValue
      mutableURLRequest.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
      return mutableURLRequest
    }

    Alamofire.request(currentSpotRequest)
      .responseJSON { (request, response, json, error) in
        if( error != nil ) {
          Logger.warning("HTTP Error: \(error)")
          return errorCallback(error!)
        }

        let responseAttributes = json as! NSDictionary
        let spotAttributes = responseAttributes.valueForKey("spot") as! NSDictionary
        let parsedSpot = ParsedSpot(attributes: spotAttributes)
        callback(parsedSpot)
    }

  }

  func postNewSpot(spot: Spot, callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint.URLByAppendingPathComponent("spots.json")
    Logger.info("POST \(url)")

    let spotParameters = [
      "game_id": 1,
      "location": locationParameters(spot.location!),
      "image_data": spot.base64ImageData(),
      "user": userParameters(spot.user)
    ]
    let parameters = [ "spot": spotParameters ]

    let spotParametersWithoutImage = NSMutableDictionary(dictionary: spotParameters)
    spotParametersWithoutImage["image_data"] = "\(spot.base64ImageData().lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) bytes"
    Logger.debug("BODY: { spot: \(spotParametersWithoutImage) }")

    var postSpotRequest: NSURLRequest {
      let mutableURLRequest = NSMutableURLRequest(URL: url)
      mutableURLRequest.HTTPMethod = Method.POST.rawValue
      mutableURLRequest.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
      return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
    }

    Alamofire.request(postSpotRequest)
      .responseJSON { (request, response, json, error) in
        if( error != nil ) {
          Logger.warning("HTTP Error: \(error)")
          return errorCallback(error!)
        }

        let responseAttributes = json as! NSDictionary
        let spotAttributes = responseAttributes.valueForKey("spot") as! NSDictionary
        let parsedSpot = ParsedSpot(attributes: spotAttributes)
        callback(parsedSpot)
    }
  }

  func postSpotGuess(guess: Guess, callback: (Bool)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint.URLByAppendingPathComponent("guesses.json")
    Logger.info("POST \(url)")

    let parameters = [ "guess": [
      "spot_id": guess.spot.id!,
      "location": locationParameters(guess.location),
      "user": userParameters(guess.user)
    ]]

    var postSpotGuessRequest: NSURLRequest {
      let mutableURLRequest = NSMutableURLRequest(URL: url)
      mutableURLRequest.HTTPMethod = Method.POST.rawValue
      mutableURLRequest.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
      return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
    }

    Alamofire.request(postSpotGuessRequest)
      .responseJSON { (request, response, json, error) in
        if( error != nil ) {
          Logger.warning("HTTP Error: \(error)")
          return errorCallback(error!)
        }

        let responseAttributes = json as! NSDictionary
        let guessAttributes = responseAttributes.valueForKey("guess") as! NSDictionary
        let guessResult = guessAttributes.valueForKey("correct") as! Bool

        callback(guessResult)
    }
  }

  private func userParameters(user: User) -> NSDictionary {
    let userParameters = NSMutableDictionary()
    assert(user.id != nil || user.deviceId != nil)
    if (user.id != nil) {
      userParameters.setValue(user.id!, forKey: "id")
    } else if (user.deviceId != nil ) {
      userParameters.setValue(user.deviceId!, forKey: "device_id")
    }

    return userParameters
  }

  private func locationParameters(location: CLLocation) -> NSDictionary {
    return [
      "type": "Point",
      "coordinates": [location.coordinate.longitude, location.coordinate.latitude]
    ]
  }
}