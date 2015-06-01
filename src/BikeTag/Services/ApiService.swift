import Foundation
import Alamofire

class ApiService {
  let apiEndpoint = NSURL(string: Config.apiEndpoint())!

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
