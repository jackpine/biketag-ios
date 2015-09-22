import Foundation
import UIKit

class ApplicationViewController: UIViewController {

  let spotsService = Config.fakeApiCalls() ? FakeSpotsService() : SpotsService()
  var scoreButton: UIBarButtonItem?
  let score = 100

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.scoreButton = UIBarButtonItem(title: "points", style: UIBarButtonItemStyle.Plain, target: self, action: "scoreButtonTouched")
    self.scoreButton!.title = "● \(score)"
    self.navigationItem.rightBarButtonItem = scoreButton
  }

  func scoreButtonTouched() {
    Logger.debug("score button touched")
  }

}
