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
    Spot.fetchCurrentSpot() { (currentSpot) -> () in
      if ( !currentSpot.isCurrentUserOwner() ) {
        expectation.fulfill()
      }
    }
    self.waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testCreateNewSpot(){
    let expectation = self.expectationWithDescription("created a new spot")

    let griffithSpot = Spot.griffithSpot()
    let image = griffithSpot.image
    let latitude = griffithSpot.location!.coordinate.latitude
    let longitude = griffithSpot.location!.coordinate.longitude
    let location = CLLocation(latitude: latitude, longitude: longitude)

    Spot.createNewSpot(image, location: location) { (newSpot) in
      if (newSpot.isCurrentUserOwner() &&
            newSpot.image == image &&
            newSpot.location!.coordinate.latitude == latitude &&
            newSpot.location!.coordinate.longitude == longitude) {

        expectation.fulfill()
      }
    }

    self.waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testIsCurrentUserOwner() {
    let me = User.getCurrentUser()!
    let them = User(deviceId: "bar")
    let someImage = Spot.lucileSpot().image
    let someLocation = Spot.lucileSpot().location!

    let mySpot = Spot(image: someImage, user: me, location: someLocation)
    let theirSpot = Spot(image: someImage, user: them, location: someLocation)

    XCTAssert(mySpot.isCurrentUserOwner())
    XCTAssertFalse(theirSpot.isCurrentUserOwner())
  }
}