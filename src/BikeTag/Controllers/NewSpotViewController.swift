import UIKit
import CoreLocation

class NewSpotViewController: CameraViewController {

  var newSpot: Spot?
  var game: Game?

  @IBOutlet var progressView: UIView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

  override func handleImage(image: UIImage, location: CLLocation) {
    let spot = Spot(image: image, game: self.game!, user: User.getCurrentUser(), location: location)
    imagePicker.dismissViewControllerAnimated(true) {
      self.uploadNewSpot(spot)
    }
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
    // TODO
    // capturedImageView.frame = self.photoPreviewView.frame
    // self.view.insertSubview(capturedImageView, aboveSubview:self.photoPreviewView)

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

    Spot.createNewSpot(self.spotsService, image: spot.image, game: spot.game, location: spot.location!, callback: popToHomeViewController, errorCallback: displayErrorAlert)
  }


}
