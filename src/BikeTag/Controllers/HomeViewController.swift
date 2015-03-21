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

  @IBOutlet var loadingView: UIView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

  var currentSpot: Spot? {
    didSet {
      updateCurrentSpot()
    }
  }

  @IBAction func unwindToHome(segue: UIStoryboardSegue) {
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    refreshCurrentSpot()
  }

  override func viewDidLoad() {
    self.activityIndicatorView.startAnimating()
  }

  func refreshCurrentSpot() {
    let setCurrentSpot = { (currentSpot: Spot) -> () in
      self.currentSpot = currentSpot
    }

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Darn it!",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
      alertController.addAction(cancelAction)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.refreshCurrentSpot()
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    Spot.fetchCurrentSpot(setCurrentSpot, errorCallback: displayErrorAlert)
  }

  func updateCurrentSpot() {
    if ( self.currentImageView != nil && self.currentSpot != nil ) {
      self.currentImageView.image = self.currentSpot!.image
      self.activityIndicatorView.stopAnimating()
      self.loadingView.hidden = true
      updateSpotCaption()
    }
  }

  func updateSpotCaption() {
    if( self.currentSpot != nil && self.captureInstructionsView != nil && self.mySpotView != nil ) {
      if ( self.currentSpot!.isCurrentUserOwner() ) {
        self.captureInstructionsView.hidden = true
        self.mySpotView.hidden = false
      } else {
        self.captureInstructionsView.hidden = false
        self.mySpotView.hidden = true
      }
    }
  }

}

