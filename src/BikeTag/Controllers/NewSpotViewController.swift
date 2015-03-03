import UIKit

class NewSpotViewController: CameraViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Claim This"
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)

    let createImageFromData = {(imageData: NSData) -> () in
      var image: UIImage?
      if UIDevice.currentDevice().model == "iPhone Simulator" {
        image = UIImage(named: "griffith")
      } else {
        image = UIImage(data: imageData)!
      }
        
      if ( image != nil ) {
        let homeViewController = segue.destinationViewController as HomeViewController
        homeViewController.currentSpot = Spot(image:image!, isCurrentUser:true)
      } else {
        println("Image Data not captured")
      }
    }

    self.captureImage(createImageFromData)
  }

}
