import UIKit

class NewSpotViewController: CameraViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Claim This"
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)

    let createImageFromData = {(imageData: NSData) -> () in
      if ( imageData.length > 0 ) {
        let homeViewController = segue.destinationViewController as HomeViewController
        homeViewController.submittedImage = UIImage(data: imageData)
      } else {
        println("Image Data not captured")
      }
    }

    self.captureImage(createImageFromData)
  }

}
