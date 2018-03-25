import Foundation

class FakeUsersService: UsersService {

    override func fetchUser(userId: Int, successCallback: @escaping (User) -> Void, errorCallback: @escaping (Error) -> Void) {
        Logger.debug("fetching fake user with id: \(userId)")
        let fakeResponseAttributes: [String: Any] = [
            "user": [
                "id": userId,
                "name": "User numero \(userId)",
                "score": 120
            ]
        ]

        let fakeUserAttributes: [String: Any] = fakeResponseAttributes["user"] as! [String: Any]

        let user = User(attributes: fakeUserAttributes)
        successCallback(user)
    }
}
