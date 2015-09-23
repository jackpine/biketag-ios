import Foundation
import Alamofire

class UsersService: ApiService {

  func fetchUser(userId: Int, successCallback: (User)->(), errorCallback: (NSError)->()) {
    let getUserRequest = APIRequest.build(Method.GET, path: "users/\(userId).json")

    let handleResponseAttributes = { (responseData: AnyObject) -> () in
      let responseAttributes = responseData as! NSDictionary
      let userAttributes = responseAttributes["user"] as! NSDictionary
      let user = User(attributes: userAttributes)
      successCallback(user)
    }

    self.request(getUserRequest, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
  }

}
