import Foundation

private var currentUser: User?

class User: Equatable {

  let deviceId: String

  init(deviceId: String) {
    self.deviceId = deviceId
  }

  class func getCurrentUser() -> User? {
    return currentUser;
  }

  class func setCurrentUser(user: User?) {
    currentUser = user
  }
}

// MARK: Equatable

func ==(lhs: User, rhs: User) -> Bool {
  return lhs.deviceId == rhs.deviceId
}
