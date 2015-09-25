import Foundation
import UIKit

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
    self.scoreButton = UIBarButtonItem(title: "score", style: UIBarButtonItemStyle.Plain, target: self, action: "scoreButtonTouched")
    self.renderScore()

    self.navigationItem.rightBarButtonItem = scoreButton
  }

  func renderScore() {
    self.scoreButton!.title = "● \(self.currentUserScore)"
  }

  func scoreButtonTouched() {
    Logger.debug("score button touched")

    let currentUserName = User.getCurrentUser().name
    let alertController = UIAlertController(
      title: currentUserName,
      message: "You've got ●\(currentUserScore) you can spend.",
      preferredStyle: .Alert)

    let dismissAction = UIAlertAction(title: "Nothing for now.", style: .Cancel, handler: nil)
    alertController.addAction(dismissAction)

    let newSpotCost = 25
    let newSpotAction = UIAlertAction(title: "●\(newSpotCost) to start a new game", style: .Default) { (action) in
      self.performSegueWithIdentifier("pushNewSpotViewController", sender: nil)
    }
    newSpotAction.enabled = currentUserScore >= newSpotCost
    alertController.addAction(newSpotAction)

    self.presentViewController(alertController, animated: true, completion: nil)
  }

}
