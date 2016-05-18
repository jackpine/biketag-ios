import UIKit
import CoreLocation
import Crashlytics
class NewSpotViewController: CameraViewController {

  var game: Game?

  @IBOutlet var loadingView: UIView!
  @IBOutlet var activityIndicatorImageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.activityIndicatorImageView.image = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)!
    self.loadingView.layer.cornerRadius = 5
    self.loadingView.layer.masksToBounds = true
  }

  func createSpotFromData(imageData: NSData, location: CLLocation) -> () {
    let image = Platform.isSimulator ? Spot.griffithSpot().image : UIImage(data: imageData)

    guard ( image != nil ) else {
      Logger.error("New spot image data not captured")
      return
    }

    if (self.game == nil) {
      Logger.debug("No existing game, assuming new game.")
      self.game = Game(id: nil)
    }
    Answers.logCustomEventWithName("uploading new spot for game", customAttributes: ["game": self.game!, "user_id": User.getCurrentUser().id])

    let spot = Spot(image: image!, game: self.game!, user: User.getCurrentUser(), location: location)
    self.uploadNewSpot(spot)
  }

  @IBAction func takePictureButtonViewTouched(sender: AnyObject) {
    Logger.debug("Touched take picture button")
    self.takePictureButton.userInteractionEnabled = false
    self.captureImage(createSpotFromData)
  }

  func stopLoadingAnimation() {
    self.loadingView.hidden = true
    self.takePictureButton.enabled = true
    self.takePictureButton.titleLabel?.text = "Claim this Spot! "
  }

  func startLoadingAnimation() {
    self.loadingView.hidden = false
    self.takePictureButton.setTitle("Uploading...", forState: UIControlState.Disabled)
    self.takePictureButton.enabled = false
  }

  func uploadNewSpot(spot: Spot) {
    self.startLoadingAnimation()
    let capturedImageView = UIImageView(image: spot.image)
    capturedImageView.frame = self.photoPreviewView.frame
    self.view.insertSubview(capturedImageView, aboveSubview:self.photoPreviewView)

    let displayErrorAlert = { (error: NSError) -> () in
      self.stopLoadingAnimation()

      var alertController: UIAlertController
      if error.code == 133 {
        alertController = UIAlertController(
          title: "Try a little harder!",
          message: "You're too close to the last spot. Go a bit farther and try again.",
          preferredStyle: .Alert)

        let retryAction = UIAlertAction(title: "OK, I'm Sorry.", style: .Default) { (action) in
          if let navigationController = self.navigationController {
            navigationController.popViewControllerAnimated(true)
          } else { //presented modally
            self.dismissViewControllerAnimated(true, completion: nil)
          }
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

    Spot.createNewSpot(self.spotsService, image: spot.image!, game: spot.game, location: spot.location!, callback:finishedCreatingSpot, errorCallback: displayErrorAlert)
  }

  func finishedCreatingSpot(newSpot: Spot) {
    self.stopLoadingAnimation()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    appDelegate.currentSession.currentSpots.addNewSpot(newSpot)

    if UserDefaults.hasPreviouslyCreatedSpot() {
      self.performSegueWithIdentifier("unwindToHome", sender: nil)
    } else {
      UserDefaults.setHasPreviouslyCreatedSpot(true)
      self.performSegueWithIdentifier("showFirstSpotCreated", sender: nil)
    }
  }


}
