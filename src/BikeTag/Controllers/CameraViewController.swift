import AVFoundation
import CoreLocation
import UIKit

class CameraViewController: BaseViewController, CLLocationManagerDelegate {
    @IBOutlet var photoPreviewView: UIView!

    lazy var takePictureButton: CaptureButton = {
        let button = CaptureButton()
        button.addTarget(self, action: #selector(didTapCaptureButton), for: .touchUpInside)
        return button
    }()

    var previewLayer: AVCaptureVideoPreviewLayer?
    let stillImageOutput = AVCaptureStillImageOutput()
    let locationService: LocationService

    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationService = appDelegate.locationService
        super.init(coder: aDecoder)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        if let captureDevice = getCaptureDevice() {
            beginCapturingVideo(captureDevice: captureDevice)
        }

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Retake", style: .plain, target: nil, action: nil)

        view.addSubview(bottomSection)
        bottomSection.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedPhotoPreview(recognizer:)))
        photoPreviewView.addGestureRecognizer(tap)

        takePictureButton.isEnabled = true

        view.insertSubview(blinkView, aboveSubview: photoPreviewView)
        blinkView.autoPinEdgesToSuperviewEdges()
        blinkView.alpha = 0
    }

    func flashBlinkView() {
        blinkView.alpha = 1
        UIView.animate(withDuration: 0.2) { self.blinkView.alpha = 0 }
    }

    // MARK: - Subviews

    lazy var bottomSection: UIView = {
        let bottomSection = UIView()
        bottomSection.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        bottomSection.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        bottomSection.preservesSuperviewLayoutMargins = true

        takePictureButton.autoSetDimensions(to: CGSize(square: 80))

        let label = UILabel()
        label.font = UIFont.bt_bold_label.withSize(18)
        label.textColor = .bt_whiteText
        label.text = NSLocalizedString("Don't forget to include your bike in the shot!", comment: "label text overlaying camera view")
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true

        let stack = UIStackView(arrangedSubviews: [label, takePictureButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        bottomSection.addSubview(stack)
        stack.autoPinEdgesToSuperviewMargins()

        return bottomSection
    }()

    lazy var blinkView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    // MARK: - For override

    @objc
    func didTapCaptureButton() {
        // better to do delegation or composition or something, but this was the smallest incremental step away
        // from the old storyboard based code
        flashBlinkView()
    }

    // MARK: -

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

        stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { [weak self] imageDataSampleBuffer, _ -> Void in
            guard let self = self else { return }

            guard let previewLayer = self.previewLayer else {
                assertionFailure("previewLayer was unexpectedly nil")
                return
            }

            guard let imageDataSampleBuffer = imageDataSampleBuffer else {
                Logger.error("imageDataSampleBuffer was unexpectedly nil")
                return
            }

            guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) else {
                Logger.error("Unable to create image data from captured buffer")
                return
            }

            let originalSize: CGSize
            let visibleLayerFrame = self.photoPreviewView.bounds

            // Calculate the fractional size that is shown in the preview
            let metaRect = previewLayer.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame)

            let image = UIImage(data: imageData)!
            switch image.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                // For these images (which are portrait), swap the size of the
                // image, because here the output image is actually rotated
                // relative to what you see on screen.
                originalSize = CGSize(width: image.size.height, height: image.size.width)
            default:
                originalSize = image.size
            }

            let cropRect: CGRect = CGRect(x: metaRect.origin.x * originalSize.width,
                                          y: metaRect.origin.y * originalSize.height,
                                          width: metaRect.size.width * originalSize.width,
                                          height: metaRect.size.height * originalSize.height).integral

            let finalCgImage = image.cgImage!.cropping(to: cropRect)!
            let finalImage = UIImage(cgImage: finalCgImage, scale: 1.0, orientation: image.imageOrientation)
            self.ensureLocation(onSuccess: { (location: CLLocation) in
                callback(finalImage.jpegData(compressionQuality: 0.95)!, location)
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
        self.previewLayer = previewLayer

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

class CaptureButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        alpha = 0.8
        backgroundColor = .red
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }

    override var bounds: CGRect {
        didSet {
            layer.cornerRadius = bounds.height / 2
        }
    }

    override var frame: CGRect {
        didSet {
            layer.cornerRadius = bounds.height / 2
        }
    }
}
