import UIKit
import CoreLocation

class NewSpotViewController: CameraViewController {

  var newSpot: Spot?
  var game: Game?

  @IBOutlet var progressView: UIView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

  func createSpotFromData(imageData: NSData, location: CLLocation) -> () {
    var image: UIImage?
    var spotLocation: CLLocation?

    // Fake photo when using the simulator
    if UIDevice.currentDevice().model == "iPhone Simulator" {
      let griffithSpot = Spot.griffithSpot()
      image = griffithSpot.image
      spotLocation = griffithSpot.location
    } else {
      image = UIImage(data: imageData)
      spotLocation = location
    }

    if ( image != nil ) {
      if (self.game == nil) {
        Logger.debug("No existing game, assuming new game.")
        self.game = Game(id: nil)
      }
      let spot = Spot(image: image!, game: self.game!, user: User.getCurrentUser(), location: spotLocation!)
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
      homeViewController.updateGame(self.newSpot!.game, newSpot: self.newSpot!)
      homeViewController.currentSpot = self.newSpot!
      homeViewController.refresh()
    }
  }

  func uploadNewSpot(spot: Spot) {
    self.progressView.hidden = false
    self.activityIndicatorView.startAnimating()
    let capturedImageView = UIImageView(image: spot.image)
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

      var alertController: UIAlertController
      if error.code == 133 {
        alertController = UIAlertController(
          title: "Try a little harder!",
          message: "You're too close to the last spot. Go a bit farther and try again.",
          preferredStyle: .Alert)

        let retryAction = UIAlertAction(title: "OK, I'm Sorry.", style: .Default) { (action) in
          self.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(retryAction)
      } else {
        alertController = UIAlertController(
          title: "There was trouble uploading your new Spot.",
          message: error.localizedDescription,
          preferredStyle: .Alert)

        let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
          self.uploadNewSpot(spot)
        }
        alertController.addAction(retryAction)
      }

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    Spot.createNewSpot(self.spotsService, image: spot.image!, game: spot.game, location: spot.location!, callback: popToHomeViewController, errorCallback: displayErrorAlert)
  }


}
