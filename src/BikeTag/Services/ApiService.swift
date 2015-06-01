import Foundation
import Alamofire

class ApiService {
  let apiEndpoint = NSURL(string: Config.apiEndpoint())!

  // an authenticated request against our API
  class APIRequest: NSMutableURLRequest {
    required init(URL: NSURL) {
      super.init(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: NSTimeInterval(60))
      super.setValue("Token \(Config.getApiKey())", forHTTPHeaderField: "Authorization")
    }

    required init(coder: NSCoder) {
      super.init(coder: coder)
    }
  }

  func request(request: NSURLRequest, handleResponseAttributes: (NSDictionary) -> (), errorCallback: (NSError)->() ) {
    Alamofire.request(request).responseJSON { (request, response, json, error) in
        // Protocol level errors, e.g. connection timed out
        if( error != nil ) {
          Logger.warning("HTTP Error: \(error)")
          return errorCallback(error!)
        }

        let responseAttributes = json as! NSDictionary

        // Application level errors e.g. missing required attribute
        if let apiError = responseAttributes["error"] as! [NSObject: AnyObject]? {
          Logger.error("API Error: \(apiError)")
          return errorCallback(APIError(errorDict: apiError))
        }

        handleResponseAttributes(responseAttributes)
    }
  }
}
