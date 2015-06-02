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

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }

  override func viewDidLoad() {
    self.stylePrimaryButton(self.guessSpotButtonView)
    self.initializeDownSwipe()
    self.refreshCurrentSpotAfterGettingApiKey()
  }

  func refreshCurrentSpotAfterGettingApiKey() {
    let displayAuthenticationErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Unable to authenticate you.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.refreshCurrentSpotAfterGettingApiKey()
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    ApiKey.ensureApiKey({
      self.refreshCurrentSpot()
    }, errorCallback: displayAuthenticationErrorAlert)
  }

  func refreshCurrentSpot() {
    self.startLoadingAnimation()
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

    Spot.fetchCurrentSpot(self.spotsService, callback: setCurrentSpot, errorCallback: displayErrorAlert)
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
        self.title = "This is YOUR Spot!"
        self.guessSpotButtonView.hidden = true
        self.mySpotView.hidden = false
      } else {
        self.title = "Do you know this spot?"
        self.guessSpotButtonView.hidden = false
        self.mySpotView.hidden = true
      }
    }
  }

  func handleDownSwipe(sender:UISwipeGestureRecognizer) {
    refreshCurrentSpot()
  }

  func initializeDownSwipe() {
    Logger.info("setting up swipe gesture")
    var downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleDownSwipe:"))
    downSwipe.direction = .Down
    view.addGestureRecognizer(downSwipe)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let guessSpotViewController = segue.destinationViewController as! GuessSpotViewController
    guessSpotViewController.currentSpot = self.currentSpot
  }
}

