import UIKit
import AVFoundation

class SubmitGuessViewController: CameraViewController {

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    AVCaptureStillImageOutput.captureStillImageAsynchronouslyFromConnection(connection: captureSession.connection, completionHandler:{ (imageBuffer: CMSampleBuffer!, error: NSError!) -> Void in
      self.saveImage(imageBuffer, error)
    })
  }

  func saveImage(imageBuffer: CMSampleBuffer, error: NSError) -> Void {

  }
}