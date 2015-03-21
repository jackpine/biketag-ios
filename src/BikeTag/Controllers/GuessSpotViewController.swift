import UIKit
import AVFoundation
import CoreLocation

class GuessSpotViewController: CameraViewController {

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)

    let createImageFromData = {(imageData: NSData, location: CLLocation) -> () in
      var image: UIImage?
      if UIDevice.currentDevice().model == "iPhone Simulator" {
        image = UIImage(named: "952 lucile")!
      } else {
        image = UIImage(data: imageData)!
      }
      
      if ( imageData.length > 0 ) {
        let checkGuessViewController = segue.destinationViewController as CheckGuessViewController
        checkGuessViewController.submittedImage = image
      } else {
        println("Image Data not captured")
      }

    }

    self.captureImage(createImageFromData)
  }

}