import Foundation
import UIKit

private var currentUser: User?

class User: Equatable {

  let id: Int
  let name: String

  init(id: Int, name: String) {
    self.id = id
    self.name = name
  }

  class func getCurrentUser() -> User {
    if ( currentUser == nil ) {
      let userId = Config.getCurrentUserId()
      self.setCurrentUser( User(id: userId, name: "you") )
    }

    return currentUser!
  }

  class func setCurrentUser(user: User?) {
    currentUser = user
  }
}

// MARK: Equatable

func ==(lhs: User, rhs: User) -> Bool {
  return lhs.id == rhs.id
}
