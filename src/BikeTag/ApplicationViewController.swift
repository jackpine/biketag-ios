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
        scoreButton = UIBarButtonItem(title: "score", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ApplicationViewController.scoreButtonTouched))
        renderScore()

        navigationItem.rightBarButtonItem = scoreButton
    }

    func renderScore() {
        scoreButton!.title = "●\(currentUserScore)"
    }

    @objc func scoreButtonTouched() {
        Logger.debug("score button touched")

        let currentUserName = User.getCurrentUser().name
        let alertController = UIAlertController(
            title: "\(currentUserName)'s Store",
            message: "You've got ●\(currentUserScore) to spend.",
            preferredStyle: .alert
        )

        let dismissAction = UIAlertAction(title: "That's it for now.", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)

        let newSpotAction = UIAlertAction(title: "●\(Spot.newSpotCost) to add your own spot", style: .default) { _ in
            self.navigationController!.performSegue(withIdentifier: "pushNewSpotViewController", sender: nil)
        }
        newSpotAction.isEnabled = currentUserScore >= Spot.newSpotCost
        alertController.addAction(newSpotAction)

        present(alertController, animated: true, completion: nil)
    }
}
