import UIKit
import AVFoundation
import CoreLocation

class GuessSpotViewController: CameraViewController {

  var currentSpot: Spot?
  var newGuess: Guess?

  func createGuessFromData(imageData: NSData, location: CLLocation) -> () {
    var image: UIImage?
    if Platform.isSimulator {
      image = UIImage(named: "952 lucile")!
    } else {
      image = UIImage(data: imageData)!
    }

    self.newGuess = Guess(spot: self.currentSpot!, user: User.getCurrentUser(), location: location, image:image!)
    self.performSegueWithIdentifier("showCheckingGuessSegue", sender: nil)
  }

  @IBAction func takePictureButtonViewTouched(sender: AnyObject) {
    Logger.debug("capturing image")
    self.captureImage(createGuessFromData)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let checkGuessViewController = segue.destinationViewController as! CheckGuessViewController
    checkGuessViewController.guess = self.newGuess!
  }

}
