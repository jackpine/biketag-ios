import Foundation

class ApiKeysService: ApiService {

  func createApiKey(callback: (NSDictionary)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint.URLByAppendingPathComponent("api_keys")
    Logger.info("POST \(url)")

    var postApiKeyRequest: NSURLRequest {
      let mutableURLRequest = NSMutableURLRequest(URL: url)
      mutableURLRequest.HTTPMethod = Method.POST.rawValue
      // Note that this request is the only one not authenticated. It's how we *get* our authentication token
      // mutableURLRequest.setValue("Token \(Config.getApiKey())", forHTTPHeaderField: "Authorization")
      return mutableURLRequest
    }

    let handleResponseAttributes = { (responseAttributes: NSDictionary) -> () in
      let apiKeyAttributes = responseAttributes.valueForKey("api_key") as! NSDictionary
      callback(apiKeyAttributes)
    }

    self.request(postApiKeyRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }
}