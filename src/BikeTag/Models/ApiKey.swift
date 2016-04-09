import Foundation

private var currentApiKey: ApiKey?

class ApiKey {
  let clientId: String
  let secret: String
  let userId: Int

  class func getCurrentApiKey() -> ApiKey? {
    return currentApiKey
  }

  required init(attributes: NSDictionary) {
    self.clientId = attributes["client_id"] as! String
    self.secret = attributes["secret"] as! String
    self.userId = attributes["user_id"] as! Int
  }

  class func setCurrentApiKey(apiKeyAttributes: NSDictionary) -> () {
    currentApiKey = ApiKey(attributes: apiKeyAttributes)
    UserDefaults.setApiKey(apiKeyAttributes)
  }

  class func ensureApiKey(successCallback: ()->(), errorCallback: (NSError)->()) {
    if getCurrentApiKey() != nil {
      return successCallback()
    }


    let sucessWithApiKey = { (apiKeyAttributes: NSDictionary) -> () in
      ApiKey.setCurrentApiKey(apiKeyAttributes)
      successCallback()
    }

    if let apiKeyAttributes = UserDefaults.apiKey() {
      Logger.info("Found existing API Key")
      sucessWithApiKey(apiKeyAttributes)
    } else {
      Logger.info("Creating new API Key")

      let handleFailure = {(error: NSError) -> () in
        Logger.error("Error setting API Key: \(error)")
        errorCallback(error)
      }

      ApiKeysService().createApiKey(sucessWithApiKey, errorCallback: handleFailure)
    }
  }

}
