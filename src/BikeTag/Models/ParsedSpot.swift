import Foundation

class ParsedSpot {
  var spotId: Int
  var userId: Int
  var imageUrl: NSURL
  var createdAt: NSDate

  init(attributes: NSDictionary) {
    let imageUrlString = attributes.valueForKey("image_url") as! String
    self.imageUrl = NSURL(string:imageUrlString)!
    self.userId = attributes.valueForKey("user_id") as! Int
    self.spotId = attributes.valueForKey("id") as! Int
    let dateString = attributes.valueForKey("created_at") as! NSString
    let dateFormatter = NSDateFormatter()
    //e.g. 2015-03-20T21:59:40.394Z
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    self.createdAt = dateFormatter.dateFromString(dateString as String)!
  }

}
