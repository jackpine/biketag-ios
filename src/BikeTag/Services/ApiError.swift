import Foundation

class APIError: NSError {
  required init(errorDict: [NSObject: AnyObject]) {
    let domain = "BikeTagApi"
    let code = errorDict["code"] as! Int
    let errorMessage = errorDict["message"] as! String
    let userInfo = [
      NSLocalizedDescriptionKey: errorMessage
    ]
    super.init(domain: domain, code: code, userInfo: userInfo)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
}