import Foundation

private var currentUser: User?

class User: Equatable {

  let deviceId: String?
  let id: Int?

  init(deviceId: String) {
    self.deviceId = deviceId
  }

  init(id: Int) {
    self.id = id
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
