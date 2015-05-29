import Foundation

class ParsedApiKey {
  let clientId: String
  let secret: String
  let userId: Int

  required init(attributes: NSDictionary) {
    self.clientId = attributes["client_id"] as! String
    self.secret = attributes["secret"] as! String
    self.userId = attributes["user_id"] as! Int
  }
}