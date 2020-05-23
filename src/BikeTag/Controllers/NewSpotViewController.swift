import CoreLocation
import UIKit
class NewSpotViewController: CameraViewController {
    var game: Game?

    @IBOutlet var loadingView: UIView!
    @IBOutlet var activityIndicatorImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorImageView.image = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)!
        loadingView.layer.cornerRadius = 5
        loadingView.layer.masksToBounds = true
    }

    func createSpotFromData(imageData: Data, location: CLLocation) {
        let image = Platform.isSimulator ? Spot.griffithSpot().image : UIImage(data: imageData)

        guard image != nil else {
            Logger.error("New spot image data not captured")
            return
        }

        if game == nil {
            Logger.debug("No existing game, assuming new game.")
            game = Game(id: nil)
        }

        let spot = Spot(image: image!, game: game!, user: User.getCurrentUser(), location: location)
        uploadNewSpot(spot: spot)
    }

    @IBAction func takePictureButtonViewTouched(sender _: AnyObject) {
        Logger.debug("Touched take picture button")
        takePictureButton.isUserInteractionEnabled = false
        captureImage(callback: createSpotFromData)
    }

    func stopLoadingAnimation() {
        loadingView.isHidden = true
        takePictureButton.isEnabled = true
        takePictureButton.titleLabel?.text = "Claim this Spot! "
    }

    func startLoadingAnimation() {
        loadingView.isHidden = false
        takePictureButton.setTitle("Uploading...", for: UIControl.State.disabled)
        takePictureButton.isEnabled = false
    }

    func uploadNewSpot(spot: Spot) {
        startLoadingAnimation()
        let capturedImageView = UIImageView(image: spot.image)
        capturedImageView.frame = photoPreviewView.frame
        view.insertSubview(capturedImageView, aboveSubview: photoPreviewView)

        let displayErrorAlert = { (error: Error) -> Void in
            self.stopLoadingAnimation()

            let alertController: UIAlertController
            if case let ApiService.APIError.serviceError(errorCode, _) = error,
                errorCode == 133 {
                alertController = UIAlertController(
                    title: "Try a little harder!",
                    message: "You're too close to the last spot. Go a bit farther and try again.",
                    preferredStyle: .alert
                )

                let retryAction = UIAlertAction(title: "OK, I'm Sorry.", style: .default) { _ in
                    if let navigationController = self.navigationController {
                        navigationController.popViewController(animated: true)
                    } else { // presented modally
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(retryAction)
            } else {
                Logger.error("unexpected error: \(error)")
                alertController = UIAlertController(
                    title: "There was trouble uploading your new Spot.",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )

                let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                    self.uploadNewSpot(spot: spot)
                }
                alertController.addAction(retryAction)
            }

            self.present(alertController, animated: true, completion: nil)
        }

        Spot.createNewSpot(spotsService: spotsService, image: spot.image!, game: spot.game, location: spot.location!, callback: finishedCreatingSpot, errorCallback: displayErrorAlert)
    }

    func finishedCreatingSpot(newSpot: Spot) {
        stopLoadingAnimation()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.currentSession.currentSpots.addNewSpot(newSpot: newSpot)

        if UserDefaults.hasPreviouslyCreatedSpot() {
            performSegue(withIdentifier: "unwindToHomeWithSegue", sender: nil)
        } else {
            UserDefaults.setHasPreviouslyCreatedSpot(val: true)
            performSegue(withIdentifier: "showFirstSpotCreated", sender: nil)
        }
    }
}
