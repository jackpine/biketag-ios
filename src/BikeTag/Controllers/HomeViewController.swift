import UIKit

class HomeViewController: UIViewController {
  
  @IBOutlet var currentImageView: UIImageView!
  var currentSpot: Spot?
  
  required init(coder aDecoder: NSCoder) {
    let initialImage = UIImage(named: "952 lucile")!
    self.currentSpot = Spot(image: initialImage, isCurrentUser: false)
    super.init(coder:aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Find This"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.currentImageView.image = currentSpot!.image
  }

}

