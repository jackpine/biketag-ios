import UIKit
import AVFoundation
import CoreLocation

class CameraViewController: ApplicationViewController, CLLocationManagerDelegate {

  @IBOutlet var photoPreviewView: UIView!
  @IBOutlet var takePictureButton: PrimaryButton!

  var previewLayer: AVCaptureVideoPreviewLayer?
  var mostRecentLocation: CLLocation?
  let stillImageOutput = AVCaptureStillImageOutput()
  let locationManager = CLLocationManager()

  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    locationManager.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    if let captureDevice = getCaptureDevice() {
      beginCapturingVideo(captureDevice)
    }

    let tap = UITapGestureRecognizer(target:self, action:"tappedPhotoPreview:")
    photoPreviewView.addGestureRecognizer(tap)

    self.takePictureButton.setTitle("Pinpointing Location...", forState: .Disabled)
    self.takePictureButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
    setUpLocationServices()
  }

  func tappedPhotoPreview(recognizer: UITapGestureRecognizer) {
    Logger.debug("tapped photoPreviewView: \(recognizer.state)")
    setFocus(recognizer.locationInView(photoPreviewView))
    if(recognizer.state == UIGestureRecognizerState.Ended){
      Logger.debug("photoPreviewView has been tapped by the user.")
    }
  }

  func setFocus(viewLocation: CGPoint) {
    let screenSize = photoPreviewView.bounds.size

    // Lifted from http://stackoverflow.com/questions/28086096/ios-tap-to-focus
    let projected_x = viewLocation.y / screenSize.height
    let projected_y = 1.0 - viewLocation.x / screenSize.width
    let focusPoint = CGPoint(x: projected_x, y: projected_y)

    if let device = getCaptureDevice() {
      do {
        try device.lockForConfiguration()
        if device.focusPointOfInterestSupported {
          device.focusPointOfInterest = focusPoint
          Logger.debug("Set focus point of interest")
          device.focusMode = AVCaptureFocusMode.AutoFocus
        }
        if device.exposurePointOfInterestSupported {
          device.exposurePointOfInterest = focusPoint
          Logger.debug("Set exposure point of interest")
          device.exposureMode = AVCaptureExposureMode.AutoExpose
        }

        device.unlockForConfiguration()
      } catch {
        Logger.error("Unable to obtain capture lock")
      }
    }
  }

  func getCaptureDevice() -> AVCaptureDevice? {
    let devices = AVCaptureDevice.devices()
    for device in devices {
      // Make sure this particular device supports video
      if (device.hasMediaType(AVMediaTypeVideo)) {
        // Finally check the position and confirm we've got the back camera
        if(device.position == AVCaptureDevicePosition.Back) {
          return device as? AVCaptureDevice
        }
      }
    }
    return nil
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
        self.takePictureButton.enabled = true
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

  func captureImage(callback:(NSData, CLLocation)->()) {
    assert(self.mostRecentLocation != nil )
    Logger.debug("Location is not nil")

    if ( UIDevice.currentDevice().model == "iPhone Simulator" ) {
      callback(NSData(), self.mostRecentLocation!)
      return
    }

    let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
    if ( videoConnection != nil && self.mostRecentLocation != nil ) {
      stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) { (imageDataSampleBuffer, error) -> Void in

        let image = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
        Logger.debug("calling callback")
        callback(image!, self.mostRecentLocation!)
      }
    } else {
      Logger.error("couldn't find video connection")
    }
  }

  func beginCapturingVideo(captureDevice: AVCaptureDevice) {
    var err : NSError? = nil
    let captureDeviceInput: AVCaptureDeviceInput!
    do {
      captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
    } catch let error as NSError {
      err = error
      captureDeviceInput = nil
    }
    if err != nil {
      Logger.error("error initializing camera: \(err?.localizedDescription)")
    }

    let captureSession = AVCaptureSession()
    captureSession.sessionPreset = AVCaptureSessionPresetHigh

    if ( captureSession.canAddInput(captureDeviceInput) ) {
      captureSession.addInput(captureDeviceInput)
    } else {
      Logger.error("Couldn't add capture device input.")
    }

    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    self.photoPreviewView.layer.addSublayer(previewLayer)

    // FIXME Preview layer is not being positioned as expected. This is an arbitrary hack to make it "look right" on my iphone6
    // previewLayer.frame = self.photoPreviewView.frame
    previewLayer.frame = CGRect(x: 0, y: 0, width: 400, height: 680)


    if ( captureSession.canAddOutput(self.stillImageOutput) ) {
      captureSession.addOutput(self.stillImageOutput)
    } else {
      Logger.error("Couldn't add still image output.")
    }

    captureSession.startRunning()
  }
}
