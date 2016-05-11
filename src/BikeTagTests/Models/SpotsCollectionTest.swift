import XCTest
import Foundation

class SpotsCollectionTest: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  func testInsertAddsCount() {
    let spotsCollection = SpotsCollection()
    XCTAssertEqual(0, spotsCollection.count())

    let spot = Spot.lucileSpot()
    spotsCollection.addNewSpot(spot)
    XCTAssertEqual(1, spotsCollection.count())
  }

  func testInsertRemovesSpotFromSameGame() {
    let spotsCollection = SpotsCollection()
    XCTAssertEqual(0, spotsCollection.count())

    let oldSpot = Spot.lucileSpot()
    let newSpot = Spot(image: oldSpot.image!, game: oldSpot.game, user: oldSpot.user, location: oldSpot.location!)

    spotsCollection.addNewSpot(oldSpot)
    XCTAssertEqual(1, spotsCollection.count())
    XCTAssertEqual(oldSpot, spotsCollection[0])

    spotsCollection.addNewSpot(newSpot)
    XCTAssertEqual(1, spotsCollection.count())
    XCTAssertEqual(newSpot, spotsCollection[0])
  }

  func testReplaceAndFetchSpots() {
    let spotsCollection = SpotsCollection()
    let spot = Spot.lucileSpot()
    let anotherSpot = Spot.griffithSpot()

    spotsCollection.replaceSpots([spot, anotherSpot])

    XCTAssertEqual(spot, spotsCollection[0])
    XCTAssertEqual(anotherSpot, spotsCollection[1])
  }

}
