import Foundation

class ParsedSpot {
  var userId: Int?
  var imageUrl: NSURL?
  var createdAt: NSDate?

  init(attributes: NSDictionary) {
    self.imageUrl = NSURL(string:attributes.valueForKey("image_url") as NSString)
    self.userId = attributes.valueForKey("user_id") as? Int
    let dateString = attributes.valueForKey("created_at") as NSString
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    //2015-03-20T21:59:40.394Z
    self.createdAt = dateFormatter.dateFromString(dateString)
  }

}
