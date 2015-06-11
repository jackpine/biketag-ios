import UIKit
import CoreLocation

class NewSpotViewController: CameraViewController {

  var newSpot: Spot?
  var game: Game?

  @IBOutlet var progressView: UIView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

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
      let spot = Spot(image: image!, game: self.game!, user: User.getCurrentUser(), location: location!)
      self.uploadNewSpot(spot)
    } else {
      Logger.error("New spot image data not captured")
    }
  }

  @IBAction func takePictureButtonViewTouched(sender: AnyObject) {
    Logger.debug("Touched take picture button")
    self.takePictureButton.userInteractionEnabled = false
    self.captureImage(createSpotFromData)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let homeViewController = segue.destinationViewController as! HomeViewController
    if self.newSpot != nil {
      homeViewController.currentSpots[self.newSpot!.game.id] = self.newSpot!
    }
  }

  func uploadNewSpot(spot: Spot) {
    self.progressView.hidden = false
    self.activityIndicatorView.startAnimating()
    var capturedImageView = UIImageView(image: spot.image)
    capturedImageView.frame = self.photoPreviewView.frame
    self.view.insertSubview(capturedImageView, aboveSubview:self.photoPreviewView)

    let popToHomeViewController = { (newSpot: Spot) -> () in
      self.activityIndicatorView.stopAnimating()
      self.newSpot = newSpot
      self.performSegueWithIdentifier("unwindToHome", sender: nil)
      return
    }

    let displayErrorAlert = { (error: NSError) -> () in
      self.activityIndicatorView.stopAnimating()

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

    Spot.createNewSpot(self.spotsService, image: spot.image, game: spot.game, location: spot.location!, callback: popToHomeViewController, errorCallback: displayErrorAlert)
  }


}
