import UIKit
import CoreLocation

class NewSpotViewController: CameraViewController {

  var newSpot: Spot?

  func createSpotFromData(imageData: NSData, location: CLLocation) -> () {
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
      let spot = Spot(image: image!, user: User.getCurrentUser(), location: location!)
      self.uploadNewSpot(spot)
    } else {
      println("New spot image data not captured")
    }
  }

  @IBAction func newSpotButtonViewTouched(sender: AnyObject) {
    self.captureImage(createSpotFromData)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let homeViewController = segue.destinationViewController as HomeViewController
    homeViewController.currentSpot = self.newSpot
  }

  func uploadNewSpot(spot: Spot) {
    let popToHomeViewController = { (newSpot: Spot) -> () in
      self.newSpot = newSpot
      self.performSegueWithIdentifier("unwindToHome", sender: nil)
      return
    }

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "There was trouble uploading your new Spot.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.uploadNewSpot(spot)
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    Spot.createNewSpot(SpotsService(), image: spot.image, location: spot.location!, callback: popToHomeViewController, errorCallback: displayErrorAlert)
  }


}
