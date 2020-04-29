import Alamofire
import Foundation

let apiEndpoint = URL(string: Config.apiEndpoint)!

class ApiService {

    enum APIError: Error {
        case clientError(description: String)
        case serviceError(code: Int, message: String)
    }

    func unauthenticatedRequest(_ method: HTTPMethod, path: String, parameters: Parameters?, handleResponseAttributes: @escaping ([String: Any]) -> Void, errorCallback: @escaping (Error) -> Void ) {
        self.request(method, path: path, parameters: parameters, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback, isAuthenticated: false)
    }

    func request(_ method: HTTPMethod, path: String, parameters: Parameters?, handleResponseAttributes: @escaping ([String: Any]) -> Void, errorCallback: @escaping (Error) -> Void, isAuthenticated: Bool = true) {

        let url = apiEndpoint.appendingPathComponent(path)

        let encoding: ParameterEncoding = {
            if method == .post {
                return JSONEncoding.default
            } else { // if method == Method.GET {
                return URLEncoding.default
            }
        }()

        let headers: HTTPHeaders? = isAuthenticated ? ["Authorization": "Token \(Config.apiKey)"] : nil

        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            switch response.result {
            case .failure(let error):
                // Protocol level errors, e.g. connection timed out
                Logger.warning("\(method) \(url) HTTP Error: \(error)")

                return errorCallback(error as Error)
            case .success(let result):
                guard let responseAttributes = result as? [String: Any] else {
                    // Protocol level errors, e.g. connection timed out
                    Logger.error("\(method) \(url) unexpected result: \(result)")
                    return errorCallback(APIError.clientError(description: "unprocessable service response"))
                }

                // Application level errors e.g. missing required attribute
                if let errorDict = responseAttributes["error"] as? [String: Any] {
                    let code = errorDict["code"] as! Int
                    let message = errorDict["message"] as! String

                    Logger.error("\(method) \(url) API Error: \(errorDict)")
                    errorCallback(APIError.serviceError(code: code, message: message))
                    return
                }

                Logger.debug("\(method) \(url) success: \(responseAttributes)")
                handleResponseAttributes(responseAttributes)
            }
        }
    }
}
