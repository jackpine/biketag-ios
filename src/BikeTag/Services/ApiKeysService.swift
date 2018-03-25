import Alamofire
import Foundation

class ApiKeysService: ApiService {

    func createApiKey(callback: @escaping ([String: Any]) -> Void, errorCallback: @escaping (Error) -> Void) {

        if (Config.fakeApiCalls()) {
            let fakeApiKeyAttributes: [String: Any] = [
                "client_id": "fake-client-id",
                "secret": "fake-secret",
                "user_id": 666
            ]
            callback(fakeApiKeyAttributes)
        } else {
            let handleResponseAttributes = { (responseAttributes: [String: Any]) -> Void in
                let apiKeyAttributes = responseAttributes["api_key"] as! [String: Any]
                callback(apiKeyAttributes)
            }

            self.unauthenticatedRequest(.post, path: "api_keys", parameters: nil, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
        }
    }
}
