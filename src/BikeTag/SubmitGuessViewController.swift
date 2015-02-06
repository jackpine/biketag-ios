import UIKit
import AVFoundation

class SubmitGuessViewController: UIViewController {

  @IBOutlet var photoPreviewView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let captureSession = AVCaptureSession()
    captureSession.sessionPreset = AVCaptureSessionPresetLow

    let devices = AVCaptureDevice.devices()
    var captureDevice : AVCaptureDevice?
    for device in devices {
      // Make sure this particular device supports video
      if (device.hasMediaType(AVMediaTypeVideo)) {
        // Finally check the position and confirm we've got the back camera
        if(device.position == AVCaptureDevicePosition.Back) {
          captureDevice = device as? AVCaptureDevice
        }
      }
    }
    if captureDevice != nil {
      beginSession(captureSession, captureDevice: captureDevice!)
    }
  }

  func beginSession(captureSession: AVCaptureSession, captureDevice: AVCaptureDevice) -> Void {
    var err : NSError? = nil
    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))

    if err != nil {
      println("error: \(err?.localizedDescription)")
    }

    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    //FIXME previewLayer is not being scaled to fit inside photopreview layer.
    self.photoPreviewView.layer.addSublayer(previewLayer)
    previewLayer.frame = self.photoPreviewView.layer.frame
    captureSession.startRunning()
  }

}