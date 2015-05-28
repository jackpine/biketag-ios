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

    let fulfillExpectation = { (currentSpot: Spot) -> () in
      if ( !currentSpot.isCurrentUserOwner() ) {
        expectation.fulfill()
      }
    }

    let failExpectation = { (error: NSError) -> () in
      // This will eventually fail, since we're not calling fulfill,
      // but is there a way to fail fast?
    }

    Spot.fetchCurrentSpot(FakeSpotsService(), callback: fulfillExpectation, errorCallback: failExpectation)
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

    Spot.createNewSpot(FakeSpotsService(), image: image, location: location, callback: fulfillExpectation, errorCallback: failExpectation)

    self.waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testIsCurrentUserOwner() {
    let me = User.getCurrentUser()
    let them = User(deviceId: "bar")
    let someImage = Spot.lucileSpot().image
    let someLocation = Spot.lucileSpot().location!

    let mySpot = Spot(image: someImage, user: me, location: someLocation)
    let theirSpot = Spot(image: someImage, user: them, location: someLocation)

    XCTAssert(mySpot.isCurrentUserOwner())
    XCTAssertFalse(theirSpot.isCurrentUserOwner())
  }
}