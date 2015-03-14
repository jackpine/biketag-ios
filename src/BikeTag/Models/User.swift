import Foundation

private var currentUser: User?

class User: Equatable {
  class func getCurrentUser() -> User? {
    return currentUser;
  }

  class func setCurrentUser(user: User?) {
    currentUser = user
  }
}

// MARK: Equatable

func ==(lhs: User, rhs: User) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
