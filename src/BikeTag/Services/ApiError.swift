import Foundation

class APIError: NSError {
  required init(errorDict: [NSObject: AnyObject]) {
    let domain = "BikeTagApi"
    let code = errorDict["code"] as! Int
    let userInfo = [
      NSLocalizedDescriptionKey: errorDict["message"] as! String
    ]
    super.init(domain: domain, code: code, userInfo: userInfo)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
}