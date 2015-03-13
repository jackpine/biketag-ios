import UIKit
import AVFoundation
import CoreLocation

class CameraViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet var photoPreviewView: UIView!
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer?
  var captureDevice: AVCaptureDevice?
  var imageData: NSData?
  let locationManager = CLLocationManager()

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    locationManager.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium

    let devices = AVCaptureDevice.devices()
    for device in devices {
      // Make sure this particular device supports video
      if (device.hasMediaType(AVMediaTypeVideo)) {
        // Finally check the position and confirm we've got the back camera
        if(device.position == AVCaptureDevicePosition.Back) {
          self.captureDevice = device as? AVCaptureDevice
        }
      }
    }
    if captureDevice != nil {
      beginSession()
    }
    setUpLocationServices()
  }

  func setUpLocationServices() {
    switch CLLocationManager.authorizationStatus() {
    case .Authorized, .AuthorizedWhenInUse:
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

  func captureImage(callback:(NSData)->()) {
    if ( UIDevice.currentDevice().model == "iPhone Simulator" ) {
      callback(NSData())
      return
    }
    let stillImageOutput = AVCaptureStillImageOutput()
    if ( self.captureSession.canAddOutput(stillImageOutput) ) {
      self.captureSession.addOutput(stillImageOutput)
    }
    
    let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
    if ( videoConnection != nil ) {
      stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) { (imageDataSampleBuffer, error) -> Void in
        callback(AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer))
      }
    } else {
      println("couldn't find video connection")
    }
  }

  func beginSession() {
    var err : NSError? = nil
    let captureDeviceInput = AVCaptureDeviceInput(device: captureDevice, error: &err)
    self.captureSession.addInput(captureDeviceInput)
    if err != nil {
      println("error: \(err?.localizedDescription)")
    }

    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    self.photoPreviewView.layer.addSublayer(previewLayer)

    //FIXME Preview layer is not being positioned as expected. This is an arbitrary hack to make it "look right" on my iphone6
    previewLayer.frame = CGRect(x: -64, y: 0, width: 504, height: 504)


    captureSession.startRunning()
  }
}
