import Foundation

private var currentApiKey: ApiKey?

//TODO rename to ApiCredentials since it's 2 keys
class ApiKey {
  let clientId: String
  let secret: String
  let userId: Int

  class func getCurrentApiKey() -> ApiKey? {
    return currentApiKey
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
    let defaults = NSUserDefaults.standardUserDefaults()

    let setCurrentApiKey = { (parsedApiKey: ParsedApiKey) -> () in
      currentApiKey = ApiKey(parsedApiKey: parsedApiKey)
      defaults.setObject(currentApiKey!.asDictionary(), forKey: "apiCredentials")
      successCallback()
    }

    let logFailure = {(error: NSError)  in
      Logger.error("Error setting API Credentials: \(error)")
    }

    if let apiCredentialsAttributes = defaults.dictionaryForKey("apiCredentials") {
      Logger.info("Found existing API credentials")
      let parsedApiKey = ParsedApiKey(attributes: apiCredentialsAttributes)
      setCurrentApiKey(parsedApiKey)
    } else {
      Logger.info("Creating new API credentials")
      ApiKeysService().createApiKey(setCurrentApiKey, errorCallback: logFailure)
    }
  }

}
