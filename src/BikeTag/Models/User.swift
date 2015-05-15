import Foundation
import UIKit

private var currentUser: User?

class User: Equatable {

  let deviceId: String?
  let id: Int?

  init(deviceId: String) {
    self.deviceId = deviceId
    self.id = nil
  }

  init(id: Int) {
    self.id = id
    self.deviceId = nil
  }

  class func getCurrentUser() -> User {
    if ( currentUser == nil ) {
      // TODO: have a device agnostic login.
      let deviceId = UIDevice.currentDevice().identifierForVendor.UUIDString
      self.setCurrentUser( User(deviceId: deviceId) )
    }

    return currentUser!;
  }

  class func setCurrentUser(user: User?) {
    currentUser = user
  }
}

// MARK: Equatable

func ==(lhs: User, rhs: User) -> Bool {
  return lhs.deviceId == rhs.deviceId
}
