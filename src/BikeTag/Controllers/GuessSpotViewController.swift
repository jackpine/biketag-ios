import UIKit
import AVFoundation
import CoreLocation

class GuessSpotViewController: CameraViewController {

  var currentSpot: Spot?

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)

    let createImageFromData = {(imageData: NSData, location: CLLocation) -> () in
      var image: UIImage?
      if UIDevice.currentDevice().model == "iPhone Simulator" {
        image = UIImage(named: "952 lucile")!
      } else {
        image = UIImage(data: imageData)!
      }

      let checkGuessViewController = segue.destinationViewController as CheckGuessViewController
      let guess = Guess(spot: self.currentSpot!, user: User.getCurrentUser(), location: location, image:image!)
      checkGuessViewController.guess = guess
    }

    self.captureImage(createImageFromData)
  }

}