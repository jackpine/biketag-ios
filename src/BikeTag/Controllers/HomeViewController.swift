import UIKit

class HomeViewController: ApplicationViewController {

  @IBOutlet var guessSpotButtonView: UIButton! {
    didSet {
      updateSpotControls()
    }
  }

  @IBOutlet var mySpotView: UIView! {
    didSet {
      updateSpotControls()
    }
  }

  @IBOutlet var loadingView: UIView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

  var currentSpots: [Spot] = [] {
    didSet {
      updateCurrentSpotViews()
    }
  }

  var currentSpot: Spot?

  @IBAction func unwindToHome(segue: UIStoryboardSegue) {
  }

  @IBOutlet var gameListView: UIScrollView!

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }

  override func viewDidLoad() {
    self.stylePrimaryButton(self.guessSpotButtonView)
    self.initializeDownSwipe()
    self.refreshCurrentSpotsAfterGettingApiKey()
  }

  func refreshCurrentSpotsAfterGettingApiKey() {
    let displayAuthenticationErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Unable to authenticate you.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.refreshCurrentSpotsAfterGettingApiKey()
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    ApiKey.ensureApiKey({
      self.refreshCurrentSpots()
    }, errorCallback: displayAuthenticationErrorAlert)
  }

  func refreshCurrentSpots() {
    self.startLoadingAnimation()
    let setCurrentSpots = { (currentSpots: [Spot]) -> () in
      self.currentSpots = currentSpots
      self.stopLoadingAnimation()
    }

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Unable to fetch the current Spot.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.refreshCurrentSpots()
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    Spot.fetchCurrentSpots(self.spotsService, callback: setCurrentSpots, errorCallback: displayErrorAlert)
  }

  func updateCurrentSpotViews() {
    let currentSpotViews = self.currentSpots.map { (spot: Spot) -> SpotView in
      let spotView = SpotView(frame: self.gameListView.frame, spot: spot)
      spotView.bounds = self.gameListView.frame
      return spotView
    }

    for oldSpotView: UIView in (self.gameListView.subviews as! [UIView]) {
      oldSpotView.removeFromSuperview()
    }
    for newSpotView: SpotView in currentSpotViews {
      self.gameListView.addSubview(newSpotView)
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

  func updateSpotControls() {
    // There are set async, and we can't proceed until all are set.
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
    refreshCurrentSpots()
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
    //FIXME which one is the current spot?
    guessSpotViewController.currentSpot = self.currentSpots[0]
  }
}

