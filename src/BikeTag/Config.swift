import Foundation
import UIKit

private let sharedInstance = Config.Instance()

class Config {
  class Instance {
    let testing: Bool
    let apiEndpoint: String

    init() {
      self.testing = false

      let settingsPath = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!
      let settingsFromFile = NSDictionary(contentsOfFile: settingsPath)!
      println("Loaded Config:")
      println(settingsFromFile)

      self.apiEndpoint = settingsFromFile["apiEndpoint"] as String

    }
  }

  class func testing() -> Bool {
    return sharedInstance.testing
  }

  class func apiEndpoint() -> String {
    return sharedInstance.apiEndpoint
  }

}
