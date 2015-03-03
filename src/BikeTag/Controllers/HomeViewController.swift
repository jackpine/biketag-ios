import UIKit
//import Spot

class HomeViewController: UIViewController {

  
  @IBOutlet var currentImageView: UIImageView!
  var currentImage = UIImage(named: "952 lucile")
  var currentSpot = Spot.initWithImage(image:currentImage, isCurrentUserOwner:false)

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Find This";
    self.currentImageView.image = currentSpot.image
  }

}

