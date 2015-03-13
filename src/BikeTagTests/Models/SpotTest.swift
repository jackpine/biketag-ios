import XCTest
import UIKit

class SpotTests: XCTestCase {

  func testFetchCurrentSpot(){
    let expectation = self.expectationWithDescription("fetched current spot")
    Spot.fetchCurrentSpot() { (currentSpot) -> () in
      if ( !currentSpot.isCurrentUserOwner && currentSpot.image != nil ) {
        expectation.fulfill()
      }
    }
    self.waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testCreateNewSpot(){
    let expectation = self.expectationWithDescription("created a new spot")
    let image = UIImage(named: "griffith")!
    Spot.createNewSpot(image) { (newSpot) in
      if ( newSpot.isCurrentUserOwner && newSpot.image == image ) {
        expectation.fulfill()
      }
    }
    self.waitForExpectationsWithTimeout(5.0, handler:nil)
  }
}