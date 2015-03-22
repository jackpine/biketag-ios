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

  class func postSpotGuess(guessedSpot: Spot, callback: (Bool)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint + "games/1/spots/\(guessedSpot.id!)/guesses.json"

    let parameters = [ "guess": [
      "location": [
        "type": "Point",
        "coordinates": [guessedSpot.location!.coordinate.longitude, guessedSpot.location!.coordinate.latitude]
      ]
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