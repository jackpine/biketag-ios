import CoreLocation
import UIKit

protocol SpotCreationDelegate: AnyObject {
  func spotCreation(
    _ newSpotVC: NewSpotViewController, didCaptureImageData imageData: Data, location: CLLocation)
  func spotCreation(
    _ newSpotVC: NewSpotViewController, didApproveImageData imageData: Data, location: CLLocation,
    errorCallback: @escaping (Error) -> Void)
}

class NewSpotViewController: CameraViewController {
  var game: Game?
  weak var spotCreationDelegate: SpotCreationDelegate?

  // MARK: - Init

  class func fromStoryboard() -> NewSpotViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard
      let vc = storyboard.instantiateViewController(withIdentifier: "newSpotViewController")
        as? NewSpotViewController
    else {
      preconditionFailure("unexpected vc")
    }
    return vc
  }

  // MARK: -

  @objc
  override func didTapCaptureButton() {
    Logger.debug("Touched take picture button")
    super.didTapCaptureButton()
    takePictureButton.isUserInteractionEnabled = false
    captureImage { [weak self] capturedImageData, location in
      guard let self = self else { return }
      let imageData =
        Platform.isSimulator
        ? Spot.griffithSpot.image!.jpegData(compressionQuality: 0.9)!
        : capturedImageData

      self.spotCreationDelegate?.spotCreation(
        self, didCaptureImageData: imageData, location: location)
      self.takePictureButton.isUserInteractionEnabled = true
    }
  }
}

extension NewSpotViewController: ApprovalDelegate {
  var approvalButtonText: String {
    NSLocalizedString(
      "Post this Spot! ", comment: "primary button, confirm to upload snapped photo")
  }

  func approvalView(
    _: ApprovalViewController, didApproveImageData imageData: Data, location: CLLocation,
    errorCallback: @escaping (Error) -> Void
  ) {
    spotCreationDelegate?.spotCreation(
      self, didApproveImageData: imageData, location: location, errorCallback: errorCallback)
  }
}
