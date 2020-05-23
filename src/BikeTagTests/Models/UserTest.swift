import Foundation
import XCTest

class UserTest: XCTestCase {
    func testUserEquality() {
        let user1 = User(id: 1, name: "some user")
        XCTAssertEqual(user1, user1)

        let anotherUser1 = User(id: 1, name: "same user")
        XCTAssertEqual(user1, anotherUser1)

        let user2 = User(id: 2, name: "other user")
        XCTAssertNotEqual(user1, user2)
    }

    func testCurrentUser() {
        let user = User(id: 1, name: "some user")
        let userWithSameId = User(id: 1, name: "same user")

        User.setCurrentUser(user: user)
        XCTAssertEqual(User.getCurrentUser(), userWithSameId)
    }

    func testUserInit() {
        let userAttributes: [String: Any] = [
            "id": 100,
            "name": "my user",
            "score": 200,
        ]

        let user = User(attributes: userAttributes)
        XCTAssertEqual(user.id, 100)
        XCTAssertEqual(user.name, "my user")
        XCTAssertEqual(user.score, 200)
    }
}
