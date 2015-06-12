import CoreLocation
import Alamofire

class SpotsService: ApiService {

  func fetchCurrentSpots(callback: ([ParsedSpot])->(), errorCallback: (NSError)->()) {
    let currentSpotRequest = APIRequest.build(Method.GET, path: "games/current_spots.json")

    let handleResponseAttributes = { (responseAttributes: AnyObject) -> () in
      let spotsAttributes = responseAttributes as! NSDictionary
      let parsedSpots = (spotsAttributes["spots"] as! [NSDictionary]).map { (spotAttributes) -> ParsedSpot in
        ParsedSpot(attributes: spotAttributes)
      }
      callback(parsedSpots)
    }

    self.request(currentSpotRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

  func postNewSpot(spot: Spot, callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    let spotParameters = [
      "game_id": spot.game.id,
      "location": locationParameters(spot.location!),
      "image_data": spot.base64ImageData()
    ]

    let parameters = [ "spot": spotParameters ]

    let spotParametersWithoutImage = NSMutableDictionary(dictionary: spotParameters)
    spotParametersWithoutImage["image_data"] = "\(spot.base64ImageData().lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) bytes"
    Logger.debug("BODY: { spot: \(spotParametersWithoutImage) }")

    let postSpotRequest = APIRequest.build(Method.POST, path: "spots.json", parameters: parameters)

    let handleResponseAttributes = { (responseAttributes: NSDictionary) -> () in
      let spotAttributes = responseAttributes.valueForKey("spot") as! NSDictionary
      let parsedSpot = ParsedSpot(attributes: spotAttributes)
      callback(parsedSpot)
    }

    self.request(postSpotRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

  func postSpotGuess(guess: Guess, callback: (Guess)->(), errorCallback: (NSError)->()) {
    let parameters = [ "guess": [
      "spot_id": guess.spot.id!,
      "location": locationParameters(guess.location)
    ]]

    let postSpotGuessRequest = APIRequest.build(Method.POST, path: "guesses.json", parameters: parameters)

    let handleResponseAttributes = { (responseAttributes: NSDictionary) -> () in
      let guessAttributes = responseAttributes.valueForKey("guess") as! NSDictionary
      guess.correct = guessAttributes.valueForKey("correct") as? Bool
      callback(guess)
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
