import UIKit

class HomeViewController: UIViewController {
  
  @IBOutlet var currentImageView: UIImageView! {
    didSet {
      updateCurrentImage()
    }
  }

  var currentSpot: Spot? {
    didSet {
      updateCurrentImage()
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    let initialImage = UIImage(named: "952 lucile")!
    self.currentSpot = Spot(image: initialImage, isCurrentUser: false)
    super.init(coder:aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Current Spot"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  func updateCurrentImage() {
    if ( self.currentImageView != nil && self.currentSpot != nil ) {
      self.currentImageView.image = self.currentSpot!.image
    }
  }

  @IBAction func unwindToHome(segue: UIStoryboardSegue) {
  }

}

