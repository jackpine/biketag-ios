import Foundation
import XCTest

class UserTest: XCTestCase {

  func testUserEquality() {
    let user1 = User()
    let user2 = User()
    XCTAssertEqual(user1, user1)
    XCTAssertNotEqual(user1, user2)
  }

  func testCurrentUser() {
    User.setCurrentUser(nil)
    XCTAssert(User.getCurrentUser() == nil)

    let user = User()
    User.setCurrentUser(user)
    XCTAssertEqual(User.getCurrentUser()!, user)
  }

}
