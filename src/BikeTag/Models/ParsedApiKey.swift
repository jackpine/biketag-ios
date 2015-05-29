import Foundation

class ParsedApiKey {
  let clientId: String
  let secret: String

  required init(attributes: NSDictionary) {
    self.clientId = attributes["clientId"] as! String
    self.secret = attributes["secret"] as! String
  }
}