import Foundation

class ParsedSpot {
  let spotId: Int
  let userId: Int
  let gameId: Int
  let imageUrl: NSURL
  let createdAt: NSDate
  let userName: String

  init(attributes: NSDictionary) {
    let imageUrlString = attributes.valueForKey("image_url") as! String
    self.imageUrl = NSURL(string:imageUrlString)!
    self.userId = attributes.valueForKey("user_id") as! Int
    self.userName = attributes.valueForKey("user_name") as! String
    self.spotId = attributes.valueForKey("id") as! Int
    self.gameId = attributes.valueForKey("game_id") as! Int

    let dateString = attributes.valueForKey("created_at") as! NSString
    let dateFormatter = NSDateFormatter()
    //e.g. 2015-03-20T21:59:40.394Z
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    self.createdAt = dateFormatter.dateFromString(dateString as String)!
  }

}
