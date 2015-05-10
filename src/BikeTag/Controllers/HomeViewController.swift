import UIKit

class HomeViewController: ApplicationViewController {
  
  @IBOutlet var currentImageView: UIImageView! {
    didSet {
      updateCurrentSpot()
    }
  }

  @IBOutlet var guessSpotButtonView: UIButton! {
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

  required override init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    refreshCurrentSpot()
  }

  override func viewDidLoad() {
    self.startLoadingAnimation()
    self.stylePrimaryButton(self.guessSpotButtonView)
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
      Logger.info("updating currentSpot")
      self.currentImageView.image = self.currentSpot!.image
      self.stopLoadingAnimation()
      updateSpotCaption()
    }
  }

  func stopLoadingAnimation() {
    self.activityIndicatorView.stopAnimating()
    self.loadingView.hidden = true
  }

  func startLoadingAnimation() {
    self.activityIndicatorView.startAnimating()
    self.loadingView.hidden = false
  }


  func updateSpotCaption() {
    if( self.currentSpot != nil && self.guessSpotButtonView != nil && self.mySpotView != nil ) {
      if ( self.currentSpot!.isCurrentUserOwner() ) {
        self.guessSpotButtonView.hidden = true
        self.mySpotView.hidden = false
      } else {
        self.guessSpotButtonView.hidden = false
        self.mySpotView.hidden = true
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let guessSpotViewController = segue.destinationViewController as GuessSpotViewController
    guessSpotViewController.currentSpot = self.currentSpot
  }
}

