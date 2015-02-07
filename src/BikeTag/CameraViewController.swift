import UIKit
import AVFoundation
class CameraViewController: UIViewController {

  @IBOutlet var photoPreviewView: UIView!
  let captureSession = AVCaptureSession()
  var previewLayer : AVCaptureVideoPreviewLayer?

  // If we find a device we'll store it here for later use
  var captureDevice : AVCaptureDevice?

  override func viewDidLoad() {
    super.viewDidLoad()
    captureSession.sessionPreset = AVCaptureSessionPresetLow

    let devices = AVCaptureDevice.devices()
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
      beginSession()
    }
  }

  func beginSession() {
    var err : NSError? = nil
    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))

    if err != nil {
      println("error: \(err?.localizedDescription)")
    }

    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    photoPreviewView.layer.addSublayer(previewLayer)

    //FIXME Preview layer is not being positioned as expected. This is an arbitrary hack to make it "look right" on my iphone6
    previewLayer.frame = CGRect(x: -74, y: 0, width: 500, height: 500)
    captureSession.startRunning()
  }
}
