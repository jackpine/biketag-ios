import Foundation
import UIKit

private let sharedInstance = Config.Instance()

class Config {
  class Instance {
    var testing: Bool
    var apiEndpoint: String

    init() {
      self.testing = false
      if ( true ) {
        self.apiEndpoint = "http://api.biketag-staging.jackpine.me/api/v1/"
      } else { //development

        if ( UIDevice.currentDevice().model == "iPhone Simulator" ) {
          self.apiEndpoint = "http://192.168.59.103:3000/api/v1/"
        } else {
          self.apiEndpoint = "http://10.0.1.53:3000/api/v1/"
        }
      }
    }
  }

  class func testing() -> Bool {
    return sharedInstance.testing
  }

  class func apiEndpoint() -> String {
    return sharedInstance.apiEndpoint
  }

}
