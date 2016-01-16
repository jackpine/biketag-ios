import UIKit
import AVFoundation
import CoreLocation

class CameraViewController: ApplicationViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

  @IBOutlet var photoPreviewView: UIView!
  @IBOutlet var takePictureButton: PrimaryButton!
  var mostRecentLocation: CLLocation?
  let locationManager = CLLocationManager()
  let imagePicker = UIImagePickerController()

  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    locationManager.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpLocationServices()

    imagePicker.delegate = self

    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      imagePicker.sourceType = .Camera
    }

    // TODO Custom overlay for system camera controls should saw "Include your bike in the shot" and maybe style to fit the app better.
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

  func waitForLocation() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in

      if(self.mostRecentLocation == nil) {
        let alertController = UIAlertController(
          title: "Where you at?",
          message: "We're having trouble pinpointing your location",
          preferredStyle: .Alert)

        let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
          self.waitForLocation()
        }
        alertController.addAction(retryAction)

        self.presentViewController(alertController, animated: true, completion: nil)
        return
      } else {
        // TODO self.takePictureButton.enabled = true
      }
    }
  }

  func setUpLocationServices() {
    switch CLLocationManager.authorizationStatus() {
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      locationManager.startUpdatingLocation()
      self.waitForLocation()
    case .NotDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .Restricted, .Denied:
      let alertController = UIAlertController(
        title: "Background Location Access Disabled",
        message: "In order to verify your location, please open this app's settings and set location access to 'While Using the App'.",
        preferredStyle: .Alert)

      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        self.waitForLocation()
      }

      alertController.addAction(cancelAction)

      let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
          UIApplication.sharedApplication().openURL(url)
        }
      }
      alertController.addAction(openAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }
  }

  func locationManager(manager: CLLocationManager,
    didChangeAuthorizationStatus status: CLAuthorizationStatus)
  {
    setUpLocationServices()
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if( self.mostRecentLocation == nil ) {
        Logger.debug("Initialized location: \(locations.last)")
    }
    self.mostRecentLocation = locations.last
  }

  // MARK - UIImagePickerControllerDelegate
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    Logger.debug("finished picking image")
    //TODO is this cast safe?
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    handleImage(image, location: self.mostRecentLocation!)
  }

  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    Logger.debug("canceled guess spot image picker")
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
  }

  func handleImage(image: UIImage, location: CLLocation) {
    preconditionFailure("This method must be overridden")
  }

}
