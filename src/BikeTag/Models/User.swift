import Foundation
import UIKit

private var currentUser = User.anonymousUser()

class User: Equatable {

    let id: Int
    let name: String
    let score: Int

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.score = 0
    }

    // e.g. init from API response
    init(attributes: [String: Any]) {
        self.id = attributes["id"] as! Int
        self.name = attributes["name"] as! String
        self.score = attributes["score"] as! Int
    }

    class func getCurrentUser() -> User {
        return currentUser
    }

    class func setCurrentUser(user: User) {
        currentUser = user
    }

    class func anonymousUser() -> User {
        return User(id: 0, name: "Anonymous User")
    }
}

// MARK: Equatable

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
