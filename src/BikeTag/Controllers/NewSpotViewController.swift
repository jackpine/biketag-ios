import CoreLocation
import Crashlytics
import UIKit
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

    func createSpotFromData(imageData: Data, location: CLLocation) {
        let image = Platform.isSimulator ? Spot.griffithSpot().image : UIImage(data: imageData)

        guard ( image != nil ) else {
            Logger.error("New spot image data not captured")
            return
        }

        if (self.game == nil) {
            Logger.debug("No existing game, assuming new game.")
            self.game = Game(id: nil)
        }
        Answers.logCustomEvent(withName: "uploading new spot for game", customAttributes: ["game": self.game!, "user_id": User.getCurrentUser().id])

        let spot = Spot(image: image!, game: self.game!, user: User.getCurrentUser(), location: location)
        self.uploadNewSpot(spot: spot)
    }

    @IBAction func takePictureButtonViewTouched(sender: AnyObject) {
        Logger.debug("Touched take picture button")
        self.takePictureButton.isUserInteractionEnabled = false
        self.captureImage(callback: createSpotFromData)
    }

    func stopLoadingAnimation() {
        self.loadingView.isHidden = true
        self.takePictureButton.isEnabled = true
        self.takePictureButton.titleLabel?.text = "Claim this Spot! "
    }

    func startLoadingAnimation() {
        self.loadingView.isHidden = false
        self.takePictureButton.setTitle("Uploading...", for: UIControlState.disabled)
        self.takePictureButton.isEnabled = false
    }

    func uploadNewSpot(spot: Spot) {
        self.startLoadingAnimation()
        let capturedImageView = UIImageView(image: spot.image)
        capturedImageView.frame = self.photoPreviewView.frame
        self.view.insertSubview(capturedImageView, aboveSubview: self.photoPreviewView)

        let displayErrorAlert = { (error: Error) -> Void in
            self.stopLoadingAnimation()

            guard case let ApiService.APIError.serviceError(errorCode, _) = error else {
                assertionFailure("Unhandleable error: \(error)")
                return
            }

            var alertController: UIAlertController
            if errorCode == 133 {
                alertController = UIAlertController(
                    title: "Try a little harder!",
                    message: "You're too close to the last spot. Go a bit farther and try again.",
                    preferredStyle: .alert)

                let retryAction = UIAlertAction(title: "OK, I'm Sorry.", style: .default) { action in
                    if let navigationController = self.navigationController {
                        navigationController.popViewController(animated: true)
                    } else { //presented modally
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(retryAction)
            } else {
                alertController = UIAlertController(
                    title: "There was trouble uploading your new Spot.",
                    message: error.localizedDescription,
                    preferredStyle: .alert)

                let retryAction = UIAlertAction(title: "Retry", style: .default) { action in
                    self.uploadNewSpot(spot: spot)
                }
                alertController.addAction(retryAction)
            }

            self.present(alertController, animated: true, completion: nil)
        }

        Spot.createNewSpot(spotsService: self.spotsService, image: spot.image!, game: spot.game, location: spot.location!, callback: finishedCreatingSpot, errorCallback: displayErrorAlert)
    }

    func finishedCreatingSpot(newSpot: Spot) {
        self.stopLoadingAnimation()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.currentSession.currentSpots.addNewSpot(newSpot: newSpot)

        if UserDefaults.hasPreviouslyCreatedSpot() {
            self.performSegue(withIdentifier: "unwindToHome", sender: nil)
        } else {
            UserDefaults.setHasPreviouslyCreatedSpot(val: true)
            self.performSegue(withIdentifier: "showFirstSpotCreated", sender: nil)
        }
    }

}
