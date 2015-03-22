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
      let guessedSpot = Spot(image: image!, user: User.getCurrentUser(), location: location, id:self.currentSpot!.id!)
      checkGuessViewController.guessedSpot = guessedSpot
    }

    self.captureImage(createImageFromData)
  }

}