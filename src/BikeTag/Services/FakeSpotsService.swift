import Foundation

class FakeSpotsService: SpotsService {

  override func fetchCurrentSpots(callback: ([ParsedSpot])->(), errorCallback: (NSError)->()) {
    Logger.info("FAKE fetch current spot")

    let firstImageAsbase64Encoded = "data:image/png;base64,R0lGODlhDAAMALMBAP8AAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUKAAEALAAAAAAMAAwAQAQZMMhJK7iY4p3nlZ8XgmNlnibXdVqolmhcRQA7"

    let secondImageAsbase64Encoded = "data:image/gif;base64,R0lGODlhDwAPAKECAAAAzMzM/////wAAACwAAAAADwAPAAACIISPeQHsrZ5ModrLlN48CXF8m2iQ3YmmKqVlRtW4MLwWACH+H09wdGltaXplZCBieSBVbGVhZCBTbWFydFNhdmVyIQAAOw=="

    let firstGameSpot = Spot.lucileSpot()
    let secondGameSpot = Spot.griffithSpot()

    let fakeResponse = [[
      "location": [
        "type": "Point",
        "coordinates": [firstGameSpot.location!.coordinate.longitude, firstGameSpot.location!.coordinate.latitude]
      ],
      "image_url": firstImageAsbase64Encoded,
      "user_id": firstGameSpot.user.id,
      "created_at": "2015-03-20T21:59:40.394Z",
      "id": 1
      ],
      [
        "location": [
          "type": "Point",
          "coordinates": [secondGameSpot.location!.coordinate.longitude, secondGameSpot.location!.coordinate.latitude]
        ],
        "image_url": secondImageAsbase64Encoded,
        "user_id": secondGameSpot.user.id,
        "created_at": "2015-03-20T21:59:40.394Z",
        "id": 1
      ]]

    let parsedSpots = fakeResponse.map( { ParsedSpot(attributes: $0) })
    callback(parsedSpots)
  }

  override func postNewSpot(spot: Spot, callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
    Logger.info("FAKE post new spot")

    let base64EncodedImageUrlString = "data:image/gif;base64,R0lGODlhDwAPAKECAAAAzMzM/////wAAACwAAAAADwAPAAACIISPeQHsrZ5ModrLlN48CXF8m2iQ3YmmKqVlRtW4MLwWACH+H09wdGltaXplZCBieSBVbGVhZCBTbWFydFNhdmVyIQAAOw=="
    let spot = Spot.griffithSpot()
    let mockResponse = [
      "image_url": base64EncodedImageUrlString,
      "user_id": User.getCurrentUser().id,
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

