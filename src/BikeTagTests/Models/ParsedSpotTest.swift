import Foundation
import XCTest

class ParsedSpotTest: XCTestCase {

  let mockAttributes = [
    "id": 1,
    "url": "http://www.example.com/api/v1/games/1/spot/1.json",
    "user_id": 2,
    "user_name": "michael",
    "game_id": 1,
    "image_url": "https://example.com/image.jpg",
    "created_at": "2015-03-20T21:59:40.000Z"
  ]

  func testInit() {
    let parsedSpot = ParsedSpot(attributes: mockAttributes)
    XCTAssertEqual(parsedSpot.spotId, 1)
    XCTAssertEqual(parsedSpot.userId, 2)
    XCTAssertEqual(parsedSpot.imageUrl, NSURL(string: "https://example.com/image.jpg")!)

    let calendar = NSCalendar.currentCalendar()
    let comps = NSDateComponents()
    comps.day = 20
    comps.year = 2015
    comps.month = 3
    comps.hour = 14
    comps.minute = 59
    comps.second = 40
    comps.timeZone = NSTimeZone(name: "America/Los_Angeles")
    // For a list of valid timeZone names...
    // let knownTimeZoneNames = NSTimeZone.knownTimeZoneNames()
    let expectedDate = calendar.dateFromComponents(comps)!
    let dateComparison = expectedDate.compare(parsedSpot.createdAt)
    XCTAssertEqual(dateComparison, NSComparisonResult.OrderedSame)
  }
}
