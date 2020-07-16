import AVFoundation
import CoreLocation
import UIKit

protocol GuessCreationDelegate: AnyObject {
    func guessCreation(_ newGuessVC: GuessSpotViewController, didCaptureImageData imageData: Data, location: CLLocation)
    func guessCreation(_ newGuessVC: GuessSpotViewController, didApproveImageData imageData: Data, location: CLLocation, errorCallback: @escaping (Error) -> Void)
}

class GuessSpotViewController: CameraViewController {
    weak var guessCreationDelegate: GuessCreationDelegate?

    // MARK: Init

    public class func fromStoryboard(spot _: Spot) -> GuessSpotViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "guessSpotViewController") as? GuessSpotViewController else {
            preconditionFailure("unexpected vc")
        }
        return vc
    }

    // MARK: -

    @objc
    override func didTapCaptureButton() {
        Logger.debug("capturing image")
        captureImage { [weak self] capturedImageData, location in
            guard let self = self else { return }
            let imageData = Platform.isSimulator
                ? Spot.lucileSpot.image!.jpegData(compressionQuality: 0.9)!
                : capturedImageData

            self.guessCreationDelegate?.guessCreation(self, didCaptureImageData: imageData, location: location)
        }
    }
}

extension GuessSpotViewController: ApprovalDelegate {
    var approvalButtonText: String {
        NSLocalizedString("Claim this Spot! ", comment: "primary button, confirm to upload snapped photo")
    }

    func approvalView(_: ApprovalViewController, didApproveImageData imageData: Data, location: CLLocation, errorCallback: @escaping (Error) -> Void) {
        guessCreationDelegate?.guessCreation(self, didApproveImageData: imageData, location: location, errorCallback: errorCallback)
    }
}
