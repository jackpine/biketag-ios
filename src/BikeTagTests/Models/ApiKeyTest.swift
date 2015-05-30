import Foundation
import XCTest

class ApiKeyTest: XCTestCase {
  func testInitWithAttributes() {
    let apiKeyAttributes: NSDictionary = [
      "client_id": "fake-client-id",
      "secret": "fake-secret",
      "user_id": 666
    ]

    let apiKey = ApiKey(attributes: apiKeyAttributes)
    XCTAssertEqual(apiKey.clientId, "fake-client-id")
    XCTAssertEqual(apiKey.secret, "fake-secret")
    XCTAssertEqual(apiKey.userId, 666)
  }
}