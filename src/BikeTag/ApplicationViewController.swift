import Foundation
import UIKit

class BaseViewController: UIViewController {
    let spotsService = Config.shouldFakeAPICalls ? FakeSpotsService() : SpotsService()
    let usersService = Config.shouldFakeAPICalls ? FakeUsersService() : UsersService()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

class BaseNavController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
