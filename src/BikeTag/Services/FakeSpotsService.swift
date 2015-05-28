import Foundation

class FakeSpotsService: SpotsService {

  override func fetchCurrentSpot(callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    Logger.info("FAKE fetch current spot")

    let base64EncodedImageUrlString = "data:image/png;base64,R0lGODlhDAAMALMBAP8AAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUKAAEALAAAAAAMAAwAQAQZMMhJK7iY4p3nlZ8XgmNlnibXdVqolmhcRQA7"

    let spot = Spot.lucileSpot()
    let parameters = [
      "location": [
        "type": "Point",
        "coordinates": [spot.location!.coordinate.longitude, spot.location!.coordinate.latitude]
      ],
      "image_url": base64EncodedImageUrlString,
      "user_id": 1,
      "created_at": "2015-03-20T21:59:40.394Z",
      "id": 1
    ]

    let parsedSpot = ParsedSpot(attributes: parameters)
    callback(parsedSpot)
  }

  override func postNewSpot(spot: Spot, callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    Logger.info("FAKE post new spot")

    let base64EncodedImageUrlString = "data:image/gif;base64,R0lGODlhDwAPAKECAAAAzMzM/////wAAACwAAAAADwAPAAACIISPeQHsrZ5ModrLlN48CXF8m2iQ3YmmKqVlRtW4MLwWACH+H09wdGltaXplZCBieSBVbGVhZCBTbWFydFNhdmVyIQAAOw=="
    let spot = Spot.griffithSpot()
    let mockResponse = [
      "image_url": base64EncodedImageUrlString,
      "user_id": 2,
      "created_at": "2015-03-20T21:59:40.394Z",
      "id": 2
    ]

    let parsedSpot = ParsedSpot(attributes: mockResponse)
    callback(parsedSpot)
  }

  override func postSpotGuess(guess: Guess, callback: (Bool)->(), errorCallback: (NSError)->()) {
    Logger.info("FAKE post new guess")
    callback(true)
  }
}

