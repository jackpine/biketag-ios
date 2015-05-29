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
    self.save()
  }

  func save() {
    currentApiKey = self
    //TODO persist this somewhere non-volitile
  }

  class func createApiKey(successCallback: ()->()) {
    let setCurrentApiKey = { (newParsedApiKey: ParsedApiKey) -> () in
      Logger.info("setting new api key")
      currentApiKey = ApiKey(parsedApiKey: newParsedApiKey)
      successCallback()
    }

    let logFailure = {(error: NSError)  in
      Logger.error("Error setting API Credentials: \(error)")
    }

    ApiKeysService().createApiKey(setCurrentApiKey, errorCallback: logFailure)
  }

}
