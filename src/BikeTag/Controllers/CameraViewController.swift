import AVFoundation
import CoreLocation
import UIKit

class CameraViewController: BaseViewController, CLLocationManagerDelegate {
    @IBOutlet var photoPreviewView: UIView!
    @IBOutlet var takePictureButton: PrimaryButton!

    var previewLayer: AVCaptureVideoPreviewLayer?
    let stillImageOutput = AVCaptureStillImageOutput()
    let locationService: LocationService

    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationService = appDelegate.locationService
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let captureDevice = getCaptureDevice() {
            beginCapturingVideo(captureDevice: captureDevice)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedPhotoPreview(recognizer:)))
        photoPreviewView.addGestureRecognizer(tap)

        takePictureButton.isEnabled = true
    }

    @objc func tappedPhotoPreview(recognizer: UITapGestureRecognizer) {
        Logger.debug("tapped photoPreviewView: \(recognizer.state)")
        setFocus(viewLocation: recognizer.location(in: photoPreviewView))
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
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    Logger.debug("Set focus point of interest")
                    device.focusMode = .autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    Logger.debug("Set exposure point of interest")
                    device.exposureMode = .autoExpose
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
            if device.hasMediaType(.video) {
                // Finally check the position and confirm we've got the back camera
                if device.position == .back {
                    return device
                }
            }
        }
        return nil
    }

    func ensureLocation(onSuccess successCallback: @escaping (CLLocation) -> Void) {
        let displayRetryAlert = {
            let alertController = UIAlertController(
                title: "Where you at?",
                message: "We need to verify where you took this photo. Did you disable GPS?",
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.ensureLocation(onSuccess: successCallback)
            }
            alertController.addAction(retryAction)

            self.present(alertController, animated: true, completion: nil)
        }
        locationService.waitForLocation(onSuccess: successCallback, onTimeout: displayRetryAlert)
    }

    func captureImage(callback: @escaping (Data, CLLocation) -> Void) {
        guard !Platform.isSimulator else {
            ensureLocation(onSuccess: { (location: CLLocation) in
                callback(Data(), location)
            })
            return
        }

        guard let videoConnection = stillImageOutput.connection(with: .video) else {
            Logger.error("couldn't find video connection")
            return
        }

        stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { imageDataSampleBuffer, _ -> Void in

            guard let imageDataSampleBuffer = imageDataSampleBuffer else {
                Logger.error("ImageDataSampleBuffer was unexpectedly nil")
                return
            }

            guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) else {
                Logger.error("Unable to create image data from captured buffer")
                return
            }

            self.ensureLocation(onSuccess: { (location: CLLocation) in
                callback(imageData, location)
            })
        }
    }

    func beginCapturingVideo(captureDevice: AVCaptureDevice) {
        var err: Error?
        let captureDeviceInput: AVCaptureDeviceInput!
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            err = error
            captureDeviceInput = nil
        }
        if let err = err {
            Logger.error("error initializing camera: \(err.localizedDescription)")
        }

        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        if captureSession.canAddInput(captureDeviceInput) {
            captureSession.addInput(captureDeviceInput)
        } else {
            Logger.error("Couldn't add capture device input.")
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill

        photoPreviewView.layer.addSublayer(previewLayer)

        // HACK photo preview was not representative of captured photo.
        // Debugging showed that at this point photoPreview frame was still 600x600,
        // which is the storyboard generic size.
        // Manually overriding frame to be fullscreen here seems to work.
        photoPreviewView.frame = view.frame
        previewLayer.frame = photoPreviewView.frame

        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        } else {
            Logger.error("Couldn't add still image output.")
        }

        captureSession.startRunning()
    }
}
