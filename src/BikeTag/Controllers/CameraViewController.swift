import UIKit
import AVFoundation
import CoreLocation

class CameraViewController: ApplicationViewController, CLLocationManagerDelegate {

  @IBOutlet var photoPreviewView: UIView!
  @IBOutlet var takePictureButton: PrimaryButton!

  var previewLayer: AVCaptureVideoPreviewLayer?
  let stillImageOutput = AVCaptureStillImageOutput()
  let locationService: LocationService

  required init?(coder aDecoder: NSCoder) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    locationService = appDelegate.locationService
     super.init(coder:aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    if let captureDevice = getCaptureDevice() {
      beginCapturingVideo(captureDevice)
    }

    let tap = UITapGestureRecognizer(target:self, action:#selector(CameraViewController.tappedPhotoPreview(_:)))
    photoPreviewView.addGestureRecognizer(tap)

    takePictureButton.enabled = true
  }

  func tappedPhotoPreview(recognizer: UITapGestureRecognizer) {
    Logger.debug("tapped photoPreviewView: \(recognizer.state)")
    setFocus(recognizer.locationInView(photoPreviewView))
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

  func ensureLocation(onSuccess successCallback:(CLLocation) -> ()) {
    let displayRetryAlert = {
      let alertController = UIAlertController(
        title: "Where you at?",
        message: "We need to verify where you took this photo. Did you disable GPS?",
        preferredStyle: .Alert
      )

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.ensureLocation(onSuccess:successCallback)
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }
    locationService.waitForLocation(onSuccess: successCallback, onTimeout: displayRetryAlert)
  }

  func captureImage(callback:(NSData, CLLocation)->()) {
    guard !Platform.isSimulator else {
      self.ensureLocation( onSuccess: { (location: CLLocation) in
        callback(NSData(), location)
      })
      return
    }

    guard let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) else {
      Logger.error("couldn't find video connection")
      return
    }

    stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) { (imageDataSampleBuffer, error) -> Void in
      guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) else {
        Logger.error("Unable to create image data from captured buffer")
        return
      }

      self.ensureLocation( onSuccess: { (location: CLLocation) in
        callback(imageData, location)
      })
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

    // HACK photo preview was not representative of captured photo.
    // Debugging showed that at this point photoPreview frame was still 600x600,
    // which is the storyboard generic size.
    // Manually overriding frame to be fullscreen here seems to work.
    self.photoPreviewView.frame = self.view.frame
    previewLayer.frame = self.photoPreviewView.frame

    if ( captureSession.canAddOutput(self.stillImageOutput) ) {
      captureSession.addOutput(self.stillImageOutput)
    } else {
      Logger.error("Couldn't add still image output.")
    }

    captureSession.startRunning()
  }
}
