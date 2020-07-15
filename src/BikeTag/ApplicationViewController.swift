import Foundation
import UIKit

public class BaseViewController: UIViewController {
    let spotsService = Config.shouldFakeAPICalls ? FakeSpotsService() : SpotsService()
    let usersService = Config.shouldFakeAPICalls ? FakeUsersService() : UsersService()
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

public class BaseNavController: UINavigationController {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
