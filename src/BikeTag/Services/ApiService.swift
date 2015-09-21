import Foundation
import Alamofire

let apiEndpoint = NSURL(string: Config.apiEndpoint())!

class ApiService {

  // an authenticated request against our API
  class APIRequest  {
    class func build(method: Alamofire.Method, path: String, parameters: [String: AnyObject]? = nil) -> NSURLRequest {
      let url = apiEndpoint.URLByAppendingPathComponent(path)
      Logger.info("[API] \(method.rawValue): \(url)")
      let mutableRequest = NSMutableURLRequest(URL: url)
      mutableRequest.HTTPMethod = method.rawValue
      mutableRequest.setValue("Token \(Config.getApiKey())", forHTTPHeaderField: "Authorization")

      if parameters != nil {
        if method == Method.POST {
          return Alamofire.ParameterEncoding.JSON.encode(mutableRequest, parameters: parameters!).0
        } else { // if method == Method.GET {
          return Alamofire.ParameterEncoding.URL.encode(mutableRequest, parameters: parameters!).0
        }
      } else {
        return mutableRequest as NSURLRequest
      }
    }
  }

  func request(request: NSURLRequest, handleResponseAttributes: (NSDictionary) -> (), errorCallback: (NSError)->() ) {
    Alamofire.request(request).responseJSON { (_, _, result) in
      // (FORMERLY) request, response, json, error) in

      switch result {
      case .Failure(_, let error):
        // Protocol level errors, e.g. connection timed out
        Logger.warning("HTTP Error: \(error)")

        return errorCallback(error as NSError)
      case .Success:
        let responseAttributes = result.value as! NSDictionary

        Logger.debug("Response: \(responseAttributes)")

        // Application level errors e.g. missing required attribute
        if let apiError = responseAttributes["error"] as! [NSObject: AnyObject]? {
          Logger.error("API Error: \(apiError)")
          return errorCallback(APIError(errorDict: apiError))
        }

        handleResponseAttributes(responseAttributes)
      }
    }
  }
}
