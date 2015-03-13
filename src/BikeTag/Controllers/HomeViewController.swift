import UIKit

class HomeViewController: UIViewController {
  
  @IBOutlet var currentImageView: UIImageView! {
    didSet {
      updateCurrentSpot()
    }
  }

  @IBOutlet var captureInstructionsView: UIView! {
    didSet {
      updateCurrentSpot()
    }
  }

  @IBOutlet var mySpotView: UIView! {
    didSet {
      updateCurrentSpot()
    }
  }

  var currentSpot: Spot? {
    didSet {
      updateCurrentSpot()
    }
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)

    Spot.fetchCurrentSpot() { (currentSpot: Spot) -> () in
      self.currentSpot = currentSpot
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Current Spot"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  func updateCurrentSpot() {
    if ( self.currentImageView != nil && self.currentSpot != nil ) {
      self.currentImageView.image = self.currentSpot!.image
      updateSpotCaption()
    }
  }

  func updateSpotCaption() {
    if( self.currentSpot != nil && self.captureInstructionsView != nil && self.mySpotView != nil ) {
      if ( self.currentSpot!.isCurrentUserOwner ) {
        self.captureInstructionsView.hidden = true
        self.mySpotView.hidden = false
      } else {
        self.captureInstructionsView.hidden = false
        self.mySpotView.hidden = true
      }
    }
  }

  @IBAction func unwindToHome(segue: UIStoryboardSegue) {
  }

}

