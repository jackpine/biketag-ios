import AVFoundation
import CoreLocation
import UIKit

class GuessSpotViewController: CameraViewController {
    var currentSpot: Spot!
    var newGuess: Guess?

    weak var guessSpotDelegate: GuessSpotDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(didTapDismiss))
    }

    public class func fromStoryboard(spot: Spot) -> GuessSpotViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "guessSpotViewController") as? GuessSpotViewController else {
            preconditionFailure("unexpected vc")
        }
        vc.currentSpot = spot
        return vc
    }

    func createGuessFromData(imageData: Data, location: CLLocation) {
        var image: UIImage?
        if Platform.isSimulator {
            image = UIImage(named: "952 lucile")!
        } else {
            image = UIImage(data: imageData)!
        }

        newGuess = Guess(spot: currentSpot, user: User.getCurrentUser(), location: location, image: image!)
        performSegue(withIdentifier: "showCheckingGuessSegue", sender: nil)
    }

    @IBAction func takePictureButtonViewTouched(sender _: AnyObject) {
        Logger.debug("capturing image")
        captureImage(callback: createGuessFromData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let checkGuessViewController = segue.destination as! CheckGuessViewController
        checkGuessViewController.guess = newGuess!
    }

    @objc
    func didTapDismiss() {
        guard let guessSpotDelegate = guessSpotDelegate else {
            assertionFailure("guessSpotDelegate was unexpectedly nil")
            return
        }
        guessSpotDelegate.guessSpotDidCancel(self)
    }
}

protocol GuessSpotDelegate: AnyObject {
    func guessSpotDidCancel(_ guessSpotViewController: GuessSpotViewController)
}
