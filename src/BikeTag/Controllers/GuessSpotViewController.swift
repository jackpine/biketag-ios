import AVFoundation
import CoreLocation
import UIKit

class GuessSpotViewController: CameraViewController {
    var currentSpot: Spot?
    var newGuess: Guess?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func createGuessFromData(imageData: Data, location: CLLocation) {
        var image: UIImage?
        if Platform.isSimulator {
            image = UIImage(named: "952 lucile")!
        } else {
            image = UIImage(data: imageData)!
        }

        newGuess = Guess(spot: currentSpot!, user: User.getCurrentUser(), location: location, image: image!)
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
}
