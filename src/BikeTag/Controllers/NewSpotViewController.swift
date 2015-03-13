import UIKit
import CoreLocation

class NewSpotViewController: CameraViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Claim This"
  }

  @IBAction func newSpotButtonViewTouched(sender: AnyObject) {
    self.navigationController?.popToRootViewControllerAnimated(true)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)

    let createImageFromData = {(imageData: NSData, location: CLLocation) -> () in
      var image: UIImage?
      if UIDevice.currentDevice().model == "iPhone Simulator" {
        image = UIImage(named: "griffith")
      } else {
        image = UIImage(data: imageData)
      }

      if ( image != nil ) {
        Spot.createNewSpot(image!, callback: {(newSpot: Spot) -> () in
          let homeViewController = segue.destinationViewController as HomeViewController
          homeViewController.currentSpot = newSpot
        })
      } else {
        println("New spot image data not captured")
      }
    }

    self.captureImage(createImageFromData)
  }

}
