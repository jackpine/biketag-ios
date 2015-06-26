import XCTest
import UIKit
import CoreLocation

class SpotTests: XCTestCase {

  override func setUp() {
    super.setUp()
    User.setCurrentUser(Spot.griffithSpot().user)
  }

  func testFetchCurrentSpot(){
    let expectation = self.expectationWithDescription("fetched current spot")

    let fulfillExpectation = { (currentSpots: [Spot]) -> () in
      if ( !currentSpots[0].isCurrentUserOwner() ) {
        expectation.fulfill()
      } else {
        println("FAILURE. Current user should not be owner of current spot.")
      }
    }

    let failExpectation = { (error: NSError) -> () in
      // This will eventually fail, since we're not calling fulfill,
      // but is there a way to fail fast?
    }

    Spot.fetchCurrentSpots(FakeSpotsService(), callback: fulfillExpectation, errorCallback: failExpectation)
    self.waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testCreateNewSpot(){
    let expectation = self.expectationWithDescription("created a new spot")

    let griffithSpot = Spot.griffithSpot()
    let image = griffithSpot.image
    let latitude = griffithSpot.location!.coordinate.latitude
    let longitude = griffithSpot.location!.coordinate.longitude
    let location = CLLocation(latitude: latitude, longitude: longitude)

    let fulfillExpectation = { (newSpot: Spot) -> () in
      if (newSpot.id == 2) {
          expectation.fulfill()
      }
    }

    let failExpectation = { (error: NSError) -> () in
      // This will eventually fail, since we're not calling fulfill,
      // but is there a way to fail fast?
    }

    Spot.createNewSpot(FakeSpotsService(), image: image, game: Game(id: 1), location: location, callback: fulfillExpectation, errorCallback: failExpectation)

    self.waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testIsCurrentUserOwner() {
    let me = User.getCurrentUser()
    let them = User(id: me.id + 1, name: "other user")
    let someImage = Spot.lucileSpot().image
    let someLocation = Spot.lucileSpot().location!
    let game = Game(id: 1)

    let mySpot = Spot(image: someImage, game: game, user: me, location: someLocation)
    let theirSpot = Spot(image: someImage, game: game, user: them, location: someLocation)

    XCTAssert(mySpot.isCurrentUserOwner())
    XCTAssertFalse(theirSpot.isCurrentUserOwner())
  }
}