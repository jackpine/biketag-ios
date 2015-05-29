import Foundation
import XCTest

class UserTest: XCTestCase {

  func testUserEquality() {
    let user1 = User(id: 1)
    XCTAssertEqual(user1, user1)

    let anotherUser1 = User(id: 1)
    XCTAssertEqual(user1, anotherUser1)

    let user2 = User(id: 2)
    XCTAssertNotEqual(user1, user2)
  }

  func testCurrentUser() {
    let user = User(id: 1)
    let userWithSameId = User(id: 1)

    User.setCurrentUser(user)
    XCTAssertEqual(User.getCurrentUser(), userWithSameId)
  }

}
