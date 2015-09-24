import Foundation

class FakeUsersService: UsersService {

  override func fetchUser(userId: Int, successCallback: (User) -> (), errorCallback: (NSError) -> ()) {
    Logger.debug("fetching fake user with id: \(userId)")
    let fakeResponseAttributes = [
      "user": [
        "id": userId,
        "name": "User numero \(userId)",
        "score": 22
      ]
    ]

    let fakeUserAttributes = fakeResponseAttributes["user"]!

    let user = User(attributes: fakeUserAttributes)
    successCallback(user)
  }
}
