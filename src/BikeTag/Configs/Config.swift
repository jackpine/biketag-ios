import Foundation
import UIKit

class Config {
    static let shared = Config()

    var shouldFakeAPICalls: Bool
    var apiEndpoint: String
    var spotsService: SpotsService
    var usersService: UsersService

    private init() {
        let appEnv = Config.appEnv
        let settingsPath = Bundle.main.path(forResource: "Config-\(appEnv)", ofType: "plist")!
        let settingsFromFile = NSDictionary(contentsOfFile: settingsPath)!
        Logger.info("Loaded Config: \(settingsFromFile)")

        apiEndpoint = settingsFromFile["apiEndpoint"] as! String
        shouldFakeAPICalls = settingsFromFile["shouldFakeAPICalls"] as! Bool
        spotsService = shouldFakeAPICalls ? FakeSpotsService() : SpotsService()
        usersService = shouldFakeAPICalls ? FakeUsersService() : UsersService()
    }

    class var appEnv: String {
        #if DEBUG
            let defaultEnv = "Debug"
        #else
            let defaultEnv = "Release"
        #endif

        return ProcessInfo.processInfo.environment["BIKETAG_ENV"] ?? defaultEnv
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

    class var spotsService: SpotsService {
        shared.spotsService
    }

    class var usersService: UsersService {
        shared.usersService
    }
}
