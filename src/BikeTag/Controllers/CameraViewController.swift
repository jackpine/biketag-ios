import UIKit
import AVFoundation

class CameraViewController: UIViewController {

  @IBOutlet var photoPreviewView: UIView!
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer?
  var captureDevice: AVCaptureDevice?
  var imageData: NSData?

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
