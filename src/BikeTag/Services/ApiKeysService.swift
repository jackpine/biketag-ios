import Foundation
import Alamofire

class ApiKeysService: ApiService {
    
    func createApiKey(callback: @escaping ([String: Any])->(), errorCallback: @escaping (Error)->()) {
        
        if (Config.fakeApiCalls()) {
            let fakeApiKeyAttributes: [String : Any] = [
                "client_id": "fake-client-id",
                "secret": "fake-secret",
                "user_id": 666
                ]
            callback(fakeApiKeyAttributes)
        } else {            
            let handleResponseAttributes = { (responseAttributes: [String: Any]) -> () in
                let apiKeyAttributes = responseAttributes["api_key"] as! [String: Any]
                callback(apiKeyAttributes)
            }
            
            self.unauthenticatedRequest(.post, path: "api_keys", parameters: nil, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback)
        }
    }
}
