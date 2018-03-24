import Foundation
import Alamofire

class UsersService: ApiService {

    func fetchUser(userId: Int, successCallback: @escaping (User)->(), errorCallback:  @escaping (Error)->()) {

        // TODO guard parse
    let handleResponseAttributes = { (responseData: Any) -> () in
      let responseAttributes = responseData as! [String: Any]
      let userAttributes = responseAttributes["user"] as! [String: Any]
      let user = User(attributes: userAttributes)
      successCallback(user)
    }

    self.request(.get, path: "users/\(userId).json", parameters: nil, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

}
