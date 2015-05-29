import Foundation

private var apiKey: ApiKey?

class ApiKey {
  let clientId: String
  let secret: String

  class func currentApiKey() -> ApiKey? {
    return apiKey
  }

  required init(parsedApiKey: ParsedApiKey) {
    self.clientId = parsedApiKey.clientId
    self.secret = parsedApiKey.secret
    self.save()
  }

  func save() {
    apiKey = self
    //TODO persist this somewhere non-volitile
  }

  class createApiKey() {

    let success = {(newApiKeyAttributes: ParsedApiKey)
      let newApiKey =
    }

    ApiKeysService.createApiKey(
  }

}
