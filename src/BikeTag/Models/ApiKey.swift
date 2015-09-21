import Foundation

private var currentApiKey: ApiKey?

class ApiKey {
  let clientId: String
  let secret: String
  let userId: Int

  class func getCurrentApiKey() -> ApiKey? {
    if (Config.fakeApiCalls()) {
      let fakeApiAttributes = [
        "client_id": "fake-client-id",
        "secret": "fake-secret",
        "user_id": 666
      ]
      return ApiKey(attributes: fakeApiAttributes)
    } else {
      return currentApiKey
    }
  }

  required init(attributes: NSDictionary) {
    self.clientId = attributes["client_id"] as! String
    self.secret = attributes["secret"] as! String
    self.userId = attributes["user_id"] as! Int
  }

  class func setCurrentApiKey(apiKeyAttributes: NSDictionary) -> () {
    currentApiKey = ApiKey(attributes: apiKeyAttributes)
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(apiKeyAttributes, forKey: "apiKey")
  }

  class func ensureApiKey(successCallback: ()->(), errorCallback: (NSError)->()) {
    if getCurrentApiKey() != nil {
      return successCallback()
    }

    let defaults = NSUserDefaults.standardUserDefaults()

    let sucessWithApiKey = { (apiKeyAttributes: NSDictionary) -> () in
      ApiKey.setCurrentApiKey(apiKeyAttributes)
      successCallback()
    }

    let handleFailure = {(error: NSError) -> () in
      Logger.error("Error setting API Key: \(error)")
      errorCallback(error)
    }

    if let apiKeyAttributes = defaults.dictionaryForKey("apiKey") {
      Logger.info("Found existing API Key")
      sucessWithApiKey(apiKeyAttributes)
    } else {
      Logger.info("Creating new API Key")
      ApiKeysService().createApiKey(sucessWithApiKey, errorCallback: handleFailure)
    }
  }

}
