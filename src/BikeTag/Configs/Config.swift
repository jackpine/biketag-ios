import Foundation
import UIKit

class Config {
    static let shared = Config()

    let shouldFakeAPICalls: Bool
    let apiEndpoint: String

    private init() {
        let settingsPath = Bundle.main.path(forResource: "Settings", ofType: "plist")!
        let settingsFromFile = NSDictionary(contentsOfFile: settingsPath)!
        Logger.info("Loaded Config: \(settingsFromFile)")

        self.apiEndpoint = settingsFromFile["apiEndpoint"] as! String
        self.shouldFakeAPICalls = settingsFromFile["shouldFakeAPICalls"] as! Bool
    }

    class var shouldFakeAPICalls: Bool {
        return shared.shouldFakeAPICalls
    }

    class var apiEndpoint: String {
        return shared.apiEndpoint
    }

    class var apiKey: String {
        return ApiKey.getCurrentApiKey()!.clientId
    }

    class var currentUserId: Int {
        return ApiKey.getCurrentApiKey()!.userId
    }
}
