import CoreLocation
import Alamofire

class SpotsService: ApiService {

  func fetchCurrentSpot(callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    let currentSpotRequest = APIRequest(method: Method.GET.rawValue, path: "games/1/current_spot.json")

    let handleResponseAttributes = { (responseAttributes: NSDictionary) -> () in
      let spotAttributes = responseAttributes.valueForKey("spot") as! NSDictionary
      let parsedSpot = ParsedSpot(attributes: spotAttributes)
      callback(parsedSpot)
    }

    self.request(currentSpotRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

  func postNewSpot(spot: Spot, callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    let spotParameters = [
      "game_id": 1,
      "location": locationParameters(spot.location!),
      "image_data": spot.base64ImageData()
    ]

    let parameters = [ "spot": spotParameters ]

    let spotParametersWithoutImage = NSMutableDictionary(dictionary: spotParameters)
    spotParametersWithoutImage["image_data"] = "\(spot.base64ImageData().lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) bytes"
    Logger.debug("BODY: { spot: \(spotParametersWithoutImage) }")

    var postSpotRequest: NSURLRequest {
      let mutableURLRequest = APIRequest(method: Method.POST.rawValue, path: "spots.json")
      return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
    }

    let handleResponseAttributes = { (responseAttributes: NSDictionary) -> () in
      let spotAttributes = responseAttributes.valueForKey("spot") as! NSDictionary
      let parsedSpot = ParsedSpot(attributes: spotAttributes)
      callback(parsedSpot)
    }

    self.request(postSpotRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

  func postSpotGuess(guess: Guess, callback: (Bool)->(), errorCallback: (NSError)->()) {
    let parameters = [ "guess": [
      "spot_id": guess.spot.id!,
      "location": locationParameters(guess.location)
    ]]

    var postSpotGuessRequest: NSURLRequest {
      let mutableURLRequest = APIRequest(method: Method.POST.rawValue, path: "guesses.json")
      return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
    }

    let handleResponseAttributes = { (responseAttributes: NSDictionary) -> () in
      let guessAttributes = responseAttributes.valueForKey("guess") as! NSDictionary
      let guessResult = guessAttributes.valueForKey("correct") as! Bool
      callback(guessResult)
    }

    self.request(postSpotGuessRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

  private func locationParameters(location: CLLocation) -> NSDictionary {
    return [
      "type": "Point",
      "coordinates": [location.coordinate.longitude, location.coordinate.latitude]
    ]
  }
}
