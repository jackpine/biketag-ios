import UIKit
import CoreLocation

class NewSpotViewController: CameraViewController {

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
        let assignNewSpot = { (newSpot: Spot) -> () in
          let homeViewController = segue.destinationViewController as HomeViewController
          homeViewController.currentSpot = newSpot
        }

        let displayError = { (error: NSError) -> () in
          println(error)
        }

        Spot.createNewSpot(image!, location: location!, callback: assignNewSpot, errorCallback: displayError)

      } else {
        println("New spot image data not captured")
      }
    }

    self.captureImage(createImageFromData)
  }

}
