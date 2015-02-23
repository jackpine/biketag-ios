import UIKit
import AVFoundation

class GuessSpotViewController: CameraViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Capture It";
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)


    let createImageFromData = {(imageData: NSData) -> () in
      if ( imageData.length > 0 ) {
        let checkGuessViewController = segue.destinationViewController as CheckGuessViewController
        checkGuessViewController.submittedImage = UIImage(data: imageData)
      } else {
        println("Image Data not captured")
      }
    }

    self.captureImage(createImageFromData)
  }

}