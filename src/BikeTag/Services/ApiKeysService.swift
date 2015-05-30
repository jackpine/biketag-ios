import Foundation
import Alamofire

class ApiKeysService {
  let apiEndpoint = NSURL(string: Config.apiEndpoint())!

  func createApiKey(callback: (NSDictionary)->(), errorCallback: (NSError)->()) {
    let url = apiEndpoint.URLByAppendingPathComponent("api_keys")
    Logger.info("POST \(url)")

    Alamofire.request(.POST, url)
      .responseJSON { (request, response, json, requestError) in
        if( requestError != nil ) {
          Logger.warning("HTTP Error: \(requestError)")
          return errorCallback(requestError!)
        }

        let responseAttributes = json as! NSDictionary

        if let apiError = responseAttributes["error"] as! [NSObject: AnyObject]? {
          Logger.error("API Error: \(apiError)")
          return errorCallback(APIError(errorDict: apiError))
        }

        let apiKeyAttributes = responseAttributes.valueForKey("api_key") as! NSDictionary
        callback(apiKeyAttributes)
    }
  }
}