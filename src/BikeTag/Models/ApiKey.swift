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
      return ApiKey(parsedApiKey: ParsedApiKey(attributes: fakeApiAttributes))
    } else {
      return currentApiKey
    }
  }

  required init(parsedApiKey: ParsedApiKey) {
    self.clientId = parsedApiKey.clientId
    self.secret = parsedApiKey.secret
    self.userId = parsedApiKey.userId
  }

  func asDictionary() -> NSDictionary {
    return [
      "client_id": self.clientId,
      "secret": self.secret,
      "user_id": self.userId
    ]
  }

  class func ensureApiKey(successCallback: ()->()) {
    if let currentApiKey = getCurrentApiKey() {
      return successCallback()
    }

    let defaults = NSUserDefaults.standardUserDefaults()

    let setCurrentApiKey = { (parsedApiKey: ParsedApiKey) -> () in
      currentApiKey = ApiKey(parsedApiKey: parsedApiKey)
      defaults.setObject(currentApiKey!.asDictionary(), forKey: "apiKey")
      successCallback()
    }

    let logFailure = {(error: NSError)  in
      Logger.error("Error setting API Key: \(error)")
    }

    if let apiKeyAttributes = defaults.dictionaryForKey("apiKey") {
      Logger.info("Found existing API Key")
      let parsedApiKey = ParsedApiKey(attributes: apiKeyAttributes)
      setCurrentApiKey(parsedApiKey)
    } else {
      Logger.info("Creating new API Key")
      ApiKeysService().createApiKey(setCurrentApiKey, errorCallback: logFailure)
    }
  }

}
