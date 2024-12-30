import Foundation

class ParsedSpot {
  let spotId: Int
  let userId: Int
  let gameId: Int
  let imageUrl: URL
  let createdAt: Date
  let userName: String

  init(attributes: [String: Any]) {
    let imageUrlString = attributes["image_url"] as! String
    imageUrl = URL(string: imageUrlString)!
    userId = attributes["user_id"] as! Int
    userName = attributes["user_name"] as! String
    spotId = attributes["id"] as! Int
    gameId = attributes["game_id"] as! Int

    let dateString = attributes["created_at"] as! String
    let dateFormatter = DateFormatter()
    // e.g. 2015-03-20T21:59:40.394Z
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    createdAt = dateFormatter.date(from: dateString)!
  }
}
