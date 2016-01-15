import UIKit
import AVFoundation
import CoreLocation

class GuessSpotViewController: CameraViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  var currentSpot: Spot?
  var newGuess: Guess?
  let imagePicker = UIImagePickerController()
  @IBOutlet var cameraControls: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self

    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      imagePicker.sourceType = .Camera
    }

    //    imagePicker.cameraOverlayView = cameraControls
    //    //    imagePicker.showsCameraControls = false
    //
    //    let screenBounds = UIScreen.mainScreen().bounds.size
    //    let cameraAspectRatio = CGFloat(4.0/3.0)
    //
    //    let camViewHeight = screenBounds.width * cameraAspectRatio
    //    let scale = screenBounds.height / camViewHeight;
    //
    //    let transform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0)
    //    imagePicker.cameraViewTransform = CGAffineTransformScale(transform, scale, scale);

    presentViewController(imagePicker, animated: true, completion: nil)
  }



  // MARK - UIImagePickerControllerDelegate
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    Logger.debug("finished guess spot image picker")
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    self.newGuess = Guess(spot: self.currentSpot!, user: User.getCurrentUser(), location: self.mostRecentLocation!, image:image)
    imagePicker.dismissViewControllerAnimated(true) {
      self.performSegueWithIdentifier("showCheckingGuessSegue", sender: nil)
    }
  }

  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    Logger.debug("canceled guess spot image picker")
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
  }

  func createGuessFromData(imageData: NSData, location: CLLocation) -> () {
    var image: UIImage?
    if UIDevice.currentDevice().model == "iPhone Simulator" {
      image = UIImage(named: "952 lucile")!
    } else {
      image = UIImage(data: imageData)!
    }

    self.newGuess = Guess(spot: self.currentSpot!, user: User.getCurrentUser(), location: location, image:image!)
    self.performSegueWithIdentifier("showCheckingGuessSegue", sender: nil)
  }

  @IBAction func takePictureButtonViewTouched(sender: AnyObject) {
    Logger.debug("capturing image")
    self.captureImage(createGuessFromData)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let checkGuessViewController = segue.destinationViewController as! CheckGuessViewController
    checkGuessViewController.guess = self.newGuess!
  }
  
}
