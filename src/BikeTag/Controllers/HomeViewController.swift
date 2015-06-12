import UIKit

class HomeViewController: ApplicationViewController, UIScrollViewDelegate {

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

  var currentSpots: [Int: Spot] = Dictionary<Int, Spot>() {
    didSet {
      renderCurrentSpots()
    }
  }

  var currentSpot: Spot? {
    didSet {
      updateSpotControls()
    }
  }

  @IBAction func unwindToHome(segue: UIStoryboardSegue) {
  }

  @IBOutlet var gameListView: UIScrollView!

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }

  override func viewDidLoad() {
    self.stylePrimaryButton(self.guessSpotButtonView)
    self.initializeRefreshSwipe()
    self.gameListView.delegate = self
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
      for currentSpot in currentSpots {
        self.currentSpots[currentSpot.game.id] = currentSpot
      }
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

  func currentSpotsArray() -> [Spot] {
    // XXX I'm making an (unfounded) assumption that the order of the values 
    // returned by the dictionary is opposite of that in which they were inserted
    // and that it is stable. This has been true anecdotally, but I'm leaving this
    // comment here as a bread crumb for when it inevitably breaks. If it does,
    // consider a more sophisticated data structure like this: 
    //      http://timekl.com/blog/2014/06/02/learning-swift-ordered-dictionaries/
    // reverse here to respect the order of the API
    return self.currentSpots.values.array.reverse()
  }

  func renderCurrentSpots() {
    for oldSpotView: UIView in (self.gameListView.subviews as! [UIView]) {
      oldSpotView.removeFromSuperview()
    }

    let currentSpotViews = self.currentSpotsArray().map { (spot: Spot) -> SpotView in
      let spotView = SpotView(frame: self.view.frame, spot: spot)
      return spotView
    }

    var yOffset: CGFloat = 0
    for newSpotView: SpotView in currentSpotViews {
      newSpotView.frame = CGRect(x: 0, y: yOffset, width: self.view.frame.width, height: self.spotViewHeight())
      self.gameListView.addSubview(newSpotView)
      yOffset = self.spotViewHeight() + yOffset
    }
    self.gameListView.contentSize = CGSize(width: self.gameListView.frame.width,
                                           height: self.spotViewHeight() * CGFloat(currentSpots.count))

    // HACK - scroll view is intially offset 30px or so. Not sure why. Future scrolls land it at the right spot.
    // putting this partial workaround for now. It's kind of jarring in that it resets your position to the top,
    // but since I'm planning a pulldown to refresh anyway, I think this will be less invasive in the future.
    self.gameListView.contentOffset = CGPoint(x:0, y:0)
    self.currentSpot = self.currentSpotsArray()[0]
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

  func handleRefreshSwipe(sender:UISwipeGestureRecognizer) {
    refreshCurrentSpots()
  }

  func initializeRefreshSwipe() {
    var refreshSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleRefreshSwipe:"))
    refreshSwipe.direction = .Left
    view.addGestureRecognizer(refreshSwipe)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    let guessSpotViewController = segue.destinationViewController as! GuessSpotViewController
    guessSpotViewController.currentSpot = self.currentSpot
  }

  func spotViewHeight() -> CGFloat {
    // FIXME - I was expecting to use gameListView.frame.height here, but the gameListView is only 
    // something like 300X125 pixels in 'viewDidLoad'.
    // By the time subsequent spot refreshes have happened it is full size.
    //return self.gameListView.frame.height
    return self.view.frame.height
  }

  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // Snap SpotView to fill frame - we don't want to stop scrolling between two SpotViews.
    let cellIndex = Int(round(targetContentOffset.memory.y / self.spotViewHeight()))
    self.currentSpot = self.currentSpotsArray()[cellIndex]
    targetContentOffset.memory.y = CGFloat(cellIndex) * self.spotViewHeight()
  }
}
