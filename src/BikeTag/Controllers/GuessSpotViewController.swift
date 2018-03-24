import UIKit
import AVFoundation
import CoreLocation
import Crashlytics

class GuessSpotViewController: CameraViewController {

  var currentSpot: Spot?
  var newGuess: Guess?

  override func viewDidLoad() {
    super.viewDidLoad()
    Answers.logLevelStart(currentSpot!.name(),
                          customAttributes: ["user_id": User.getCurrentUser().id])
  }

  func createGuessFromData(imageData: Data, location: CLLocation) -> () {
    var image: UIImage?
    if Platform.isSimulator {
      image = UIImage(named: "952 lucile")!
    } else {
      image = UIImage(data: imageData)!
    }

    self.newGuess = Guess(spot: self.currentSpot!, user: User.getCurrentUser(), location: location, image:image!)
    self.performSegue(withIdentifier: "showCheckingGuessSegue", sender: nil)
  }

  @IBAction func takePictureButtonViewTouched(sender: AnyObject) {
    Logger.debug("capturing image")
    self.captureImage(callback: createGuessFromData)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) -> Void {
    super.prepare(for: segue, sender: sender)
    let checkGuessViewController = segue.destination as! CheckGuessViewController
    checkGuessViewController.guess = self.newGuess!
  }

}
