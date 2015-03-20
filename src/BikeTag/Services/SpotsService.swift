import Alamofire

class SpotsService {

  class func fetchCurrentSpot(callback: (ParsedSpot)->()) {
    let apiEndpoint = "http://192.168.59.103:3000/api/v1/"
    let url = apiEndpoint + "/games/1/current_spot.json"

    Alamofire.request(.GET, url)
      .responseJSON { (_, _, json, _) in
        let parsedSpot = ParsedSpot(json: json)
        callback(parsedSpot)
    }
  }
}