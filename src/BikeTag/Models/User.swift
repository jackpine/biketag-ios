import Foundation
import UIKit

private var currentUser: User?

class User: Equatable {

  let id: Int

  init(id: Int) {
    self.id = id
  }

  class func getCurrentUser() -> User {
    if ( currentUser == nil ) {
      let userId = Config.getCurrentUserId()
      self.setCurrentUser( User(id: userId) )
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
