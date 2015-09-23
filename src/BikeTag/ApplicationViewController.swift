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

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.scoreButton = UIBarButtonItem(title: "● \(self.currentUserScore)", style: UIBarButtonItemStyle.Plain, target: self, action: "scoreButtonTouched")

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
      message: "You've got \(currentUserScore) points. Keep saving and you'll be able to spend them on something!",
      preferredStyle: .Alert)

    let dismissAction = UIAlertAction(title: "S'Ok!", style: .Cancel, handler: nil)
    alertController.addAction(dismissAction)

    self.presentViewController(alertController, animated: true, completion: nil)
  }

}
