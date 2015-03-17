import Alamofire

class SpotsService {

  let apiEndpoint = "http://192.168.59.103:3000/api/v1/"

  func getCurrentSpot() {
    let url = apiEndpoint + "/games/1/current_spot.json"
    Alamofire.request(.GET, url)
      .responseJSON { (_, _, JSON, _) in
        spotJson = JSON["spot"]
        callBack({
          "id": spotJson["id"],
          "createdAt": spotJson["created_at"],
          "imageUrl": spotJson["image_url"],
          "url": spotJson["url"],
          "userId": spotJson["user_id"],
          "userName": spotJson["user_name"]
        })
    }
  }
}