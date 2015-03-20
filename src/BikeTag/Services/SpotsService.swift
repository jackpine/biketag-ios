import Alamofire

class SpotsService {

  class func fetchCurrentSpot(callback: (ParsedSpot)->()) {
    let apiEndpoint = "http://192.168.59.103:3000/api/v1/"
    let url = apiEndpoint + "/games/1/current_spot.json"

    Alamofire.request(.GET, url)
      .responseJSON { (_, _, json, _) in
        let responseAttributes = json as NSDictionary
        let spotAttributes = responseAttributes.valueForKey("spot") as NSDictionary
        let parsedSpot = ParsedSpot(attributes: spotAttributes)
        callback(parsedSpot)
    }
  }
}