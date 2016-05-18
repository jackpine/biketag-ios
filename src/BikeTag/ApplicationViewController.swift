import Foundation
import UIKit
import Crashlytics

class ApplicationViewController: UIViewController {

  let spotsService = Config.fakeApiCalls() ? FakeSpotsService() : SpotsService()
  let usersService = Config.fakeApiCalls() ? FakeUsersService() : UsersService()
  var scoreButton: UIBarButtonItem?
  var currentUserScore = User.getCurrentUser().score {
    didSet {
      renderScore()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.scoreButton = UIBarButtonItem(title: "score", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ApplicationViewController.scoreButtonTouched))
    self.renderScore()

    self.navigationItem.rightBarButtonItem = scoreButton
  }

  func renderScore() {
    self.scoreButton!.title = "●\(self.currentUserScore)"
  }

  func scoreButtonTouched() {
    Logger.debug("score button touched")
    Answers.logCustomEventWithName("viewed_menu", customAttributes: ["user_id": User.getCurrentUser().id])

    let currentUserName = User.getCurrentUser().name
    let alertController = UIAlertController(
      title: "\(currentUserName)'s Store",
      message: "You've got ●\(currentUserScore) to spend.",
      preferredStyle: .Alert)

    let dismissAction = UIAlertAction(title: "That's it for now.", style: .Cancel, handler: nil)
    alertController.addAction(dismissAction)

    let newSpotAction = UIAlertAction(title: "●\(Spot.newSpotCost) to add your own spot", style: .Default) { (action) in
      self.navigationController!.performSegueWithIdentifier("pushNewSpotViewController", sender: nil)
    }
    newSpotAction.enabled = currentUserScore >= Spot.newSpotCost
    alertController.addAction(newSpotAction)

    self.presentViewController(alertController, animated: true, completion: nil)
  }

}
