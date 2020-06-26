import Alamofire
import Foundation

let apiEndpoint = URL(string: Config.apiEndpoint)!

class ApiService {
    enum APIError: Error {
        case clientError(description: String)
        case serviceError(code: Int, message: String)
    }

    func unauthenticatedRequest(_ method: HTTPMethod, path: String, parameters: Parameters?, handleResponseAttributes: @escaping ([String: Any]) -> Void, errorCallback: @escaping (Error) -> Void) {
        request(method, path: path, parameters: parameters, handleResponseAttributes: handleResponseAttributes, errorCallback: errorCallback, isAuthenticated: false)
    }

    func request(_ method: HTTPMethod, path: String, parameters: Parameters?, handleResponseAttributes: @escaping ([String: Any]) -> Void, errorCallback: @escaping (Error) -> Void, isAuthenticated: Bool = true) {
        let url = apiEndpoint.appendingPathComponent(path)

        let encoding: ParameterEncoding
        switch method {
        case .post:
            encoding = JSONEncoding.default
        case .get:
            encoding = URLEncoding.default
        default:
            assertionFailure("unexpected method: \(method)")
            encoding = URLEncoding.default
        }

        let headers: HTTPHeaders? = isAuthenticated ? ["Authorization": "Token \(Config.apiKey)"] : nil

        Logger.info("\(method.rawValue) \(url) starting")
        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            switch response.result {
            case let .failure(error):
                // Protocol level errors, e.g. connection timed out
                Logger.warning("\(method.rawValue) \(url) HTTP Error: \(error)")

                return errorCallback(error as Error)
            case let .success(result):
                guard let responseAttributes = result as? [String: Any] else {
                    // Protocol level errors, e.g. connection timed out
                    Logger.error("\(method.rawValue) \(url) unexpected result: \(result)")
                    return errorCallback(APIError.clientError(description: "unprocessable service response"))
                }

                // Application level errors e.g. missing required attribute
                if let errorDict = responseAttributes["error"] as? [String: Any] {
                    let code = errorDict["code"] as! Int
                    let message = errorDict["message"] as! String

                    Logger.error("\(method.rawValue) \(url) API Error: \(errorDict)")
                    errorCallback(APIError.serviceError(code: code, message: message))
                    return
                }

                Logger.debug("\(method.rawValue) \(url) success: \(responseAttributes)")
                handleResponseAttributes(responseAttributes)
            }
        }
    }
}
