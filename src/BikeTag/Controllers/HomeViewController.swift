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
        title: "Unable to fetch the current Spot.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.refreshCurrentSpot()
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    Spot.fetchCurrentSpot(SpotsService(), setCurrentSpot, errorCallback: displayErrorAlert)
  }

  func updateCurrentSpot() {
    if ( self.currentImageView != nil && self.currentSpot != nil ) {
      self.currentImageView.image = self.currentSpot!.image
      self.activityIndicatorView.stopAnimating()
      self.loadingView.hidden = true
      updateSpotCaption()

      if (self.currentSpot!.location != nil) {
        //It's a new spot. Upload it. This is some spaghetti horse shit.
        self.uploadNewSpot()
      }
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

  func uploadNewSpot() {
    let assignNewSpot = { (newSpot: Spot) -> () in
      self.currentSpot = newSpot
    }

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "There was trouble uploading your new Spot.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.uploadNewSpot()
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    Spot.createNewSpot(SpotsService(), image: self.currentSpot!.image, location: self.currentSpot!.location!, callback: assignNewSpot, errorCallback: displayErrorAlert)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let guessSpotViewController = segue.destinationViewController as GuessSpotViewController
    guessSpotViewController.currentSpot = self.currentSpot
  }
}

