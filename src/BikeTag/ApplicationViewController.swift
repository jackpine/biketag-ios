import Foundation
import UIKit

class ApplicationViewController: UIViewController {
    let spotsService = Config.shouldFakeAPICalls ? FakeSpotsService() : SpotsService()
    let usersService = Config.shouldFakeAPICalls ? FakeUsersService() : UsersService()
}
