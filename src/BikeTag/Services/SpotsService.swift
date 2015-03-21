import Alamofire

class SpotsService {

  class func fetchCurrentSpot(callback: (ParsedSpot)->(), errorCallback: (NSError)->()) {
//    let apiEndPoint = "http://172.16.150.109:3000/api/v1/"
    let apiEndpoint = "http://192.168.59.103:3000/api/v1/"
    let url = apiEndpoint + "/games/1/current_spot.json"

    Alamofire.request(.GET, url)
      .responseJSON { (request, response, json, error) in
        if( error != nil ) {
          return errorCallback(error!)
        }

        let responseAttributes = json as NSDictionary
        let spotAttributes = responseAttributes.valueForKey("spot") as NSDictionary
        let parsedSpot = ParsedSpot(attributes: spotAttributes)
        callback(parsedSpot)
    }
  }
}