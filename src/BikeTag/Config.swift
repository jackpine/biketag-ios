import Foundation
import UIKit

private let sharedInstance = Config.Instance()

class Config {
  class Instance {
    let fakeApiCalls: Bool
    let apiEndpoint: String

    init() {
      let settingsPath = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!
      let settingsFromFile = NSDictionary(contentsOfFile: settingsPath)!
      Logger.info("Loaded Config: \(settingsFromFile)")

      self.apiEndpoint = settingsFromFile["apiEndpoint"] as! String
      self.fakeApiCalls = settingsFromFile["fakeApiCalls"] as! Bool
    }
  }

  class func fakeApiCalls() -> Bool {
    return sharedInstance.fakeApiCalls
  }

  class func apiEndpoint() -> String {
    return sharedInstance.apiEndpoint
  }

}
