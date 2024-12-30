import CoreLocation
import Foundation

class FakeSpotsService: SpotsService {
  override func fetchCurrentSpots(
    location _: CLLocation, successCallback: @escaping ([ParsedSpot]) -> Void,
    errorCallback _: @escaping (Error) -> Void
  ) {
    Logger.info("FAKE fetch current spot")

    let firstImageAsbase64Encoded =
      "data:image/gif;base64,R0lGODlhDwAPAKECAAAAzMzM/////wAAACwAAAAADwAPAAACIISPeQHsrZ5ModrLlN48CXF8m2iQ3YmmKqVlRtW4MLwWACH+H09wdGltaXplZCBieSBVbGVhZCBTbWFydFNhdmVyIQAAOw=="

    let secondImageAsbase64Encoded =
      "data:image/png;base64,R0lGODlhDAAMALMBAP8AAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUKAAEALAAAAAAMAAwAQAQZMMhJK7iY4p3nlZ8XgmNlnibXdVqolmhcRQA7"

    let firstGameSpot = Spot.lucileSpot
    let secondGameSpot = Spot.griffithSpot

    let fakeResponse = [
      [
        "location": [
          "type": "Point",
          "coordinates": [
            firstGameSpot.location!.coordinate.longitude,
            firstGameSpot.location!.coordinate.latitude,
          ],
        ],
        "image_url": firstImageAsbase64Encoded,
        "user_id": firstGameSpot.user.id,
        "user_name": firstGameSpot.user.name,
        "created_at": "2015-03-20T21:59:40.394Z",
        "game_id": 1,
        "id": 1,
      ],
      [
        "location": [
          "type": "Point",
          "coordinates": [
            secondGameSpot.location!.coordinate.longitude,
            secondGameSpot.location!.coordinate.latitude,
          ],
        ],
        "image_url": secondImageAsbase64Encoded,
        "user_id": secondGameSpot.user.id,
        "user_name": secondGameSpot.user.name,
        "created_at": "2015-03-20T21:59:40.394Z",
        "game_id": 2,
        "id": 2,
      ],
    ]

    let parsedSpots = fakeResponse.map { ParsedSpot(attributes: $0) }
    successCallback(parsedSpots)
  }

  override func postNewSpot(
    spot _: Spot, callback: @escaping (ParsedSpot) -> Void,
    errorCallback _: @escaping (Error) -> Void
  ) {
    Logger.info("FAKE post new spot")

    let base64EncodedImageUrlString =
      "data:image/gif;base64,R0lGODlhDwAPAKECAAAAzMzM/////wAAACwAAAAADwAPAAACIISPeQHsrZ5ModrLlN48CXF8m2iQ3YmmKqVlRtW4MLwWACH+H09wdGltaXplZCBieSBVbGVhZCBTbWFydFNhdmVyIQAAOw=="
    let mockResponse: [String: Any] = [
      "image_url": base64EncodedImageUrlString,
      "user_id": User.getCurrentUser().id,
      "user_name": "my user",
      "created_at": "2015-03-20T21:59:40.394Z",
      "game_id": 2,
      "id": 2,
    ]

    let parsedSpot = ParsedSpot(attributes: mockResponse)
    callback(parsedSpot)
  }

  override func postSpotGuess(
    guess: Guess, callback: @escaping (Guess) -> Void, errorCallback _: @escaping (Error) -> Void
  ) {
    Logger.info("FAKE post new guess")
    callback(guess)
  }
}
