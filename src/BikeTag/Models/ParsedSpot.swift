import Foundation

class ParsedSpot {
  var userId: Int?
  var imageUrl: NSURL?
  var createdAt: NSDate?

  init(json: AnyObject?) {
    let spotAttributes = json!.valueForKey("spot") as NSDictionary
    self.imageUrl = NSURL(string:spotAttributes.valueForKey("image_url") as NSString)
    self.userId = spotAttributes.valueForKey("user_id") as? Int
    let dateString = spotAttributes.valueForKey("created_at") as NSString
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    //2015-03-20T21:59:40.394Z
    self.createdAt = dateFormatter.dateFromString(dateString)
  }

}
