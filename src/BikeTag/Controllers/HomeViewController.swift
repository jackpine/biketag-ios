import UIKit
import CoreLocation

class HomeViewController: ApplicationViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet var guessSpotButtonView: PrimaryButton! {
    didSet {
      updateSpotControls()
    }
  }

  // Last Cell / Add Spot Stuff
  var lastCellInSpotsTableView: UIView!
  @IBOutlet var newSpotCostLabel: UILabel!
  @IBOutlet var newSpotButton: PrimaryButton!
  @IBAction func didTouchUpInsideAddSpotButton(sender: AnyObject) {
    self.navigationController!.performSegueWithIdentifier("pushNewSpotViewController", sender: nil)
  }

  @IBOutlet var mySpotView: UIView! {
    didSet {
      updateSpotControls()
    }
  }

  @IBOutlet var loadingView: UIView!
  @IBOutlet var activityIndicatorImageView: UIImageView!

  let currentSpots: SpotsCollection
  let locationService: LocationService
  let spotViewCache = NSCache()

  var currentSpot: Spot? {
    didSet {
      updateSpotControls()
    }
  }

  var refreshControl:UIRefreshControl!

  @IBAction func unwindToHome(segue: UIStoryboardSegue) {
    self.gameTableView.setContentOffset(CGPointZero, animated: true)
    refresh()
  }

  @IBOutlet var gameTableView: UITableView!

  required init?(coder aDecoder: NSCoder) {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    currentSpots = appDelegate.currentSession.currentSpots
    locationService = appDelegate.locationService
    super.init(coder:aDecoder)
  }

  var timeOfLastReload: NSDate = NSDate()

  override func renderScore() {
    super.renderScore()
    if self.newSpotCostLabel != nil {
      if self.currentUserScore >= Spot.newSpotCost {
        self.newSpotCostLabel.text = "This costs ●\(Spot.newSpotCost) of your ●\(self.currentUserScore)."
        self.newSpotButton.enabled = true
      } else {
        self.newSpotCostLabel.text = "You need at least ●\(Spot.newSpotCost - self.currentUserScore) more to add a spot."
        self.newSpotButton.enabled = false
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.lastCellInSpotsTableView = LastCellInSpotsTableView(frame: self.view.frame, owner: self)

    self.activityIndicatorImageView.image = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)!
    self.loadingView.layer.cornerRadius = 5
    self.loadingView.layer.masksToBounds = true

    self.guessSpotButtonView.setTitle("Fetching Spots...", forState: .Disabled)

    self.refreshControl = UIRefreshControl()
    let titleAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    self.refreshControl.attributedTitle = NSAttributedString(string: "", attributes: titleAttributes)
    self.refreshControl.tintColor = UIColor.whiteColor()
    self.refreshControl.addTarget(self, action: #selector(HomeViewController.refreshControlPulled(_:)), forControlEvents: UIControlEvents.ValueChanged)
    self.gameTableView.addSubview(self.refreshControl)
    self.gameTableView.allowsSelection = false
    self.gameTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    startTrackingLocation()
    refresh()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func startTrackingLocation() {
    let showLocationServicesDisabledAlert = {
      let alertController = UIAlertController(
        title: "Background Location Access Disabled",
        message: "In order to get spots near you, please open this app's settings and set location access to 'While Using the App'.",
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.startTrackingLocation()
      }

      alertController.addAction(retryAction)

      let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
          UIApplication.sharedApplication().openURL(url)
        }
      }

      alertController.addAction(openAction)
      self.presentViewController(alertController, animated: true, completion: nil)
    }

    self.locationService.startTrackingLocation(onDenied: showLocationServicesDisabledAlert)
  }

  func refresh() {
    // Getting current spots requires the ApiKey *and* Location.
    // *Order is important*. We get the APIKey first, meanwhile 
    // the Location manager fetches the location in the background (started previously)
    // minimizing the overall wait time.
    startLoadingAnimation()
    ensureApiKey() {
      self.fetchCurrentUser()
      self.ensureLocation(onSuccess: self.fetchCurrentSpots)
    }
  }

  func refreshControlPulled(sender:AnyObject) {
    refresh()
  }

  func ensureApiKey(success:()->()) {
    let displayAuthenticationErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Unable to authenticate you.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.ensureApiKey(success)
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    ApiKey.ensureApiKey({
      success()
    }, errorCallback: displayAuthenticationErrorAlert)
  }

  func ensureLocation(onSuccess successCallback:(CLLocation) -> ()) {
    let displayRetryAlert = {
      let alertController = UIAlertController(
        title: "Hang on a second.",
        message: "We're having trouble pinpointing your location",
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.ensureLocation(onSuccess: successCallback)
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    locationService.waitForLocation(onSuccess: successCallback,
                                    onTimeout: displayRetryAlert)
  }

  func fetchCurrentSpots(near: CLLocation) {
    Logger.info("refreshing spots list near \(near)")
    self.timeOfLastReload = NSDate()
    let setCurrentSpots = { (newSpots: [Spot]) -> () in
      self.currentSpots.replaceSpots(newSpots)
      self.gameTableView.setContentOffset(CGPointZero, animated: true)
      self.currentSpot = self.currentSpots[0]
      self.gameTableView.reloadData()

      self.guessSpotButtonView.enabled = true
      self.stopLoadingAnimation()
      self.refreshControl.endRefreshing()
    }

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Darn. Can't fetch spots right now.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.fetchCurrentSpots(near)
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    Spot.fetchCurrentSpots(self.spotsService, location: near, callback: setCurrentSpots, errorCallback: displayErrorAlert)
  }

  func fetchCurrentUser() {
    Logger.debug("fetching current user")

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Hrm. Trouble fetching your user data right now.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.fetchCurrentUser()
      }
      alertController.addAction(retryAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }

    let updateCurrentUser = { (user: User) -> () in
      User.setCurrentUser(user)
      self.currentUserScore = user.score
    }

    self.usersService.fetchUser(Config.getCurrentUserId(), successCallback: updateCurrentUser, errorCallback: displayErrorAlert)
  }

  func stopLoadingAnimation() {
    self.loadingView.hidden = true
  }

  func startLoadingAnimation() {
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
        self.title = "Where is \(self.currentSpot!.user.name)'s bicycle?"
        self.guessSpotButtonView.hidden = false
        self.mySpotView.hidden = true
      }
    }
    if( self.currentSpot == nil && self.guessSpotButtonView != nil) {
      self.title = "Where is YOUR bicycle?"
      self.guessSpotButtonView.hidden = true
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    if (segue.identifier == "showNewGuessScene") {
      let guessSpotViewController = segue.destinationViewController as! GuessSpotViewController
      guessSpotViewController.currentSpot = self.currentSpot
    }
  }

  func spotViewHeight() -> CGFloat {
    // FIXME: I was expecting to use gameListView.frame.height here, but the gameListView is only
    // something like 300X125 pixels in 'viewDidLoad'.
    // By the time subsequent spot refreshes have happened it is full size.
    //return self.gameListView.frame.height
    return self.view.frame.height
  }

  // MARK: UIScrollViewDelegate
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // Snap SpotView to fill frame - we don't want to stop scrolling between two SpotViews.
    let cellIndex = Int(round(targetContentOffset.memory.y / self.spotViewHeight()))
    targetContentOffset.memory.y = CGFloat(cellIndex) * self.spotViewHeight()

    if (cellIndex == self.currentSpots.count()) {
      //not looking at spot, looking at last cell
      self.currentSpot = nil
    } else {
      self.currentSpot = self.currentSpots[cellIndex]
    }
  }

  // MARK: UITableViewDataSource
  // MARK: UITableViewDelegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard section == 0  else {
      Logger.error("Unknown section: \(section)")
      return 0
    }

    let spotCount = self.currentSpots.count()

    if (spotCount == 0) {
      // Display nothing
      // We don't want to display the "Don't know these spots?" message before spots have loaded.
      return 0
    } else {
      // Display spots plus a final cell
      return spotCount + 1
    }
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return self.spotViewHeight()
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = UITableViewCell()
    if indexPath.row == self.currentSpots.count() {
      // Not looking at spot, looking at last cell
      cell.contentView.addSubview(self.lastCellInSpotsTableView)
    } else {
      // Spot Cell
      let spot = self.currentSpots[indexPath.row]

      var spotView:SpotView? = spotViewCache.objectForKey(spot) as! SpotView?
      if spotView == nil {
        spotView = SpotView(frame: self.view.frame, spot: spot)
        spotViewCache.setObject(spotView!, forKey: spot)
      }
      cell.contentView.addSubview(spotView!)
    }

    return cell
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refreshIfStale()
  }

  func applicationWillEnterForeground(notification: NSNotification) {
    refreshIfStale()
  }

  func refreshIfStale() {
    let secondsElapsed = Int(NSDate().timeIntervalSinceDate(self.timeOfLastReload))
    if ( secondsElapsed > 60 * 30 ) {
      refresh()
    }
  }

}
