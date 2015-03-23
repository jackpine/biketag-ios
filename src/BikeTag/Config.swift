import Foundation

private let sharedInstance = Config.Instance()

class Config {
  class Instance {
    var testing: Bool

    init() {
      self.testing = false
    }
  }

  class func testing() -> Bool {
    return sharedInstance.testing
  }

}
