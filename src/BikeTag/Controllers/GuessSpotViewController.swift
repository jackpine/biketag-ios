import UIKit
import AVFoundation
import CoreLocation

class GuessSpotViewController: CameraViewController {

  var currentSpot: Spot?
  var newGuess: Guess?
  @IBOutlet var cameraControls: UIView!


  override func handleImage(image: UIImage, location: CLLocation) -> () {
    Logger.debug("Building and checking guess with image: \(image), location: \(location).")
    self.newGuess = Guess(spot: self.currentSpot!, user: User.getCurrentUser(), location: location, image: image)
    imagePicker.dismissViewControllerAnimated(true) {
      self.performSegueWithIdentifier("showCheckingGuessSegue", sender: nil)
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let checkGuessViewController = segue.destinationViewController as! CheckGuessViewController
    checkGuessViewController.guess = self.newGuess!
  }
  
}
