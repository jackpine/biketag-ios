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
      var location: CLLocation?
      if UIDevice.currentDevice().model == "iPhone Simulator" {
        let griffithSpot = Spot.griffithSpot()
        image = griffithSpot.image
        location = griffithSpot.location
      } else {
        image = UIImage(data: imageData)
        location = self.mostRecentLocation
      }

      if ( image != nil ) {
        Spot.createNewSpot(image!, location: location!, callback: {(newSpot: Spot) -> () in
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
