import Foundation
import XCTest

class UserTest: XCTestCase {

  func testUserEquality() {
    let user1 = User(deviceId: "foo")
    XCTAssertEqual(user1, user1)

    let anotherUser1 = User(deviceId: "foo")
    XCTAssertEqual(user1, anotherUser1)

    let user2 = User(deviceId: "bar")
    XCTAssertNotEqual(user1, user2)
  }

  func testCurrentUser() {
    let user = User(deviceId: "foo")
    let userWithSameDeviceId = User(deviceId: "foo")

    User.setCurrentUser(user)
    XCTAssertEqual(User.getCurrentUser(), userWithSameDeviceId)
  }

}
