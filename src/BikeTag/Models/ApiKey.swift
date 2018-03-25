import Foundation

private var currentApiKey: ApiKey?

class ApiKey {
    let clientId: String
    let secret: String
    let userId: Int

    class func getCurrentApiKey() -> ApiKey? {
        return currentApiKey
    }

    required init(attributes: [String: Any]) {
        self.clientId = attributes["client_id"] as! String
        self.secret = attributes["secret"] as! String
        self.userId = attributes["user_id"] as! Int
    }

    class func setCurrentApiKey(apiKeyAttributes: [String: Any]) {
        currentApiKey = ApiKey(attributes: apiKeyAttributes)
        UserDefaults.setApiKey(apiKeyAttributes: apiKeyAttributes)
    }

    class func ensureApiKey(successCallback: @escaping () -> Void, errorCallback: @escaping (Error) -> Void) {
        if getCurrentApiKey() != nil {
            return successCallback()
        }

        let sucessWithApiKey = { (apiKeyAttributes: [String: Any]) -> Void in
            ApiKey.setCurrentApiKey(apiKeyAttributes: apiKeyAttributes)
            successCallback()
        }

        if let apiKeyAttributes = UserDefaults.apiKey() {
            Logger.info("Found existing API Key")
            sucessWithApiKey(apiKeyAttributes)
        } else {
            Logger.info("Creating new API Key")

            let handleFailure = {(error: Error) -> Void in
                Logger.error("Error setting API Key: \(error)")
                errorCallback(error)
            }

            ApiKeysService().createApiKey(callback: sucessWithApiKey, errorCallback: handleFailure)
        }
    }

}
