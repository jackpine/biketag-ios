import UIKit
import AVFoundation
import CoreLocation

class CameraViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet var photoPreviewView: UIView!
  @IBOutlet var takePictureButton: UIButton!

  var previewLayer: AVCaptureVideoPreviewLayer?
  var mostRecentLocation: CLLocation?
  let stillImageOutput = AVCaptureStillImageOutput()
  let locationManager = CLLocationManager()

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    locationManager.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if let captureDevice = getCaptureDevice() {
      beginCapturingVideo(captureDevice)
    }

    setUpLocationServices()
    waitForLocation()
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
          title: "Hang on a second.",
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
    case .NotDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .Restricted, .Denied:
      let alertController = UIAlertController(
        title: "Background Location Access Disabled",
        message: "In order to verify your location, please open this app's settings and set location access to 'While Using the App'.",
        preferredStyle: .Alert)

      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
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

  func locationManager(manager: CLLocationManager!,
    didChangeAuthorizationStatus status: CLAuthorizationStatus)
  {
    setUpLocationServices()
  }

  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if( self.mostRecentLocation == nil ) {
        Logger.debug("Initialized location: \(locations.last)")
    }
    self.mostRecentLocation = locations.last as? CLLocation
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
    let captureDeviceInput = AVCaptureDeviceInput(device: captureDevice, error: &err)
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

    //FIXME Preview layer is not being positioned as expected. This is an arbitrary hack to make it "look right" on my iphone6
    previewLayer.frame = CGRect(x: -64, y: 0, width: 504, height: 504)

    if ( captureSession.canAddOutput(self.stillImageOutput) ) {
      captureSession.addOutput(self.stillImageOutput)
    } else {
      Logger.error("Couldn't add still image output.")
    }

    captureSession.startRunning()
  }
}
