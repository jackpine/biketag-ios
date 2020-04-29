import Alamofire
import CoreLocation

class SpotsService: ApiService {

    func fetchCurrentSpots(location: CLLocation, successCallback: @escaping ([ParsedSpot]) -> Void, errorCallback:  @escaping (Error) -> Void) {
        // TODO use param struct
        let parameters: [String: Any] = [
            "filter": [
                "location": locationParameters(location: location)
            ],
            "limit": 200
        ]

        // TODO parse with guard
        let handleResponseAttributes = { (responseAttributes: [String: Any]) -> Void in
            let spotsAttributes = responseAttributes
            let parsedSpots = (spotsAttributes["spots"] as! [[String: Any]]).map { spotAttributes -> ParsedSpot in
                ParsedSpot(attributes: spotAttributes)
            }
            successCallback(parsedSpots)
        }

        self.request(.get, path: "games/current_spots.json", parameters: parameters, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
    }

    func postNewSpot(spot: Spot, callback: @escaping (ParsedSpot) -> Void, errorCallback: @escaping (Error) -> Void) {
        // TODO use param struct
        var spotParameters: [String: Any] = [
            "location": locationParameters(location: spot.location!),
            "image_data": spot.base64ImageData()
        ]

        if spot.game.id != nil {
            spotParameters["game_id"] = spot.game.id!
        }

        let parameters: [String: Any] = [ "spot": spotParameters ]

        var spotParametersForLogging = spotParameters
        spotParametersForLogging["image_data"] = "\(spot.base64ImageData().lengthOfBytes(using: .utf8)) bytes"
        Logger.debug("BODY: { spot: \(spotParametersForLogging) }")

        // TODO parse with guard
        let handleResponseAttributes = { (responseAttributes: [String: Any]) -> Void in
            let spotAttributes = responseAttributes["spot"] as! [String: Any]
            let parsedSpot = ParsedSpot(attributes: spotAttributes)
            callback(parsedSpot)
        }

        self.request(.post, path: "spots.json", parameters: parameters, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
    }

    func postSpotGuess(guess: Guess, callback: @escaping (Guess) -> Void, errorCallback: @escaping (Error) -> Void) {
        // TODO use param struct
        let parameters = [ "guess": [
            "spot_id": guess.spot.id!,
            "location": locationParameters(location: guess.location),
            "image_data": guess.base64ImageData()
        ]]

        // TODO parse with guard
        let handleResponseAttributes = { (responseAttributes: [String: Any]) -> Void in
            let guessAttributes = responseAttributes["guess"] as! [String: Any]
            guess.correct = guessAttributes["correct"] as? Bool
            guess.distance = guessAttributes["distance"] as? Double
            callback(guess)
        }

        self.request(.post, path: "guesses.json", parameters: parameters, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
    }

    private func locationParameters(location: CLLocation) -> [String: Any] {
        return [
            "type": "Point",
            "coordinates": [location.coordinate.longitude, location.coordinate.latitude]
        ]
    }
}
