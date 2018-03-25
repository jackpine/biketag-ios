import Foundation
import UIKit

class ApplicationViewController: UIViewController {

    let spotsService = Config.shouldFakeAPICalls ? FakeSpotsService() : SpotsService()
    let usersService = Config.shouldFakeAPICalls ? FakeUsersService() : UsersService()
    var scoreButton: UIBarButtonItem?
    var currentUserScore = User.getCurrentUser().score {
        didSet {
            renderScore()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scoreButton = UIBarButtonItem(title: "score", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ApplicationViewController.scoreButtonTouched))
        self.renderScore()

        self.navigationItem.rightBarButtonItem = scoreButton
    }

    func renderScore() {
        self.scoreButton!.title = "●\(self.currentUserScore)"
    }

    @objc func scoreButtonTouched() {
        Logger.debug("score button touched")

        let currentUserName = User.getCurrentUser().name
        let alertController = UIAlertController(
            title: "\(currentUserName)'s Store",
            message: "You've got ●\(currentUserScore) to spend.",
            preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "That's it for now.", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)

        let newSpotAction = UIAlertAction(title: "●\(Spot.newSpotCost) to add your own spot", style: .default) { action in
            self.navigationController!.performSegue(withIdentifier: "pushNewSpotViewController", sender: nil)
        }
        newSpotAction.isEnabled = currentUserScore >= Spot.newSpotCost
        alertController.addAction(newSpotAction)

        self.present(alertController, animated: true, completion: nil)
    }

}
