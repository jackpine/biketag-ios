import UIKit

class HomeViewController: ApplicationViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource  {

  @IBOutlet var guessSpotButtonView: PrimaryButton! {
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
      self.gameListView.reloadData()
    }
  }

  var currentSpot: Spot? {
    didSet {
      updateSpotControls()
    }
  }

  var refreshControl:UIRefreshControl!

  @IBAction func unwindToHome(segue: UIStoryboardSegue) {
  }

  @IBOutlet var gameListView: UITableView!

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }

  var timeOfLastReload: NSDate = NSDate()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.guessSpotButtonView.setTitle("Fetching Spots...", forState: .Disabled)
    self.guessSpotButtonView.setTitleColor(UIColor.grayColor(), forState: .Disabled)

    self.refreshControl = UIRefreshControl()
    let titleAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: titleAttributes)
    self.refreshControl.tintColor = UIColor.whiteColor()
    self.refreshControl.addTarget(self, action: "refreshControlPulled:", forControlEvents: UIControlEvents.ValueChanged)
    self.gameListView.addSubview(refreshControl)
    self.gameListView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    self.refreshCurrentSpotsAfterGettingApiKey()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func refreshControlPulled(sender:AnyObject) {
    refreshCurrentSpotsAfterGettingApiKey()
  }

  func refreshCurrentSpotsAfterGettingApiKey() {
    self.startLoadingAnimation()
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
    Logger.info("refreshing spots list")
    self.timeOfLastReload = NSDate()
    let setCurrentSpots = { (currentSpots: [Spot]) -> () in
      for currentSpot in currentSpots {
        self.currentSpots[currentSpot.game.id] = currentSpot
      }
      self.gameListView.contentOffset = CGPoint(x:0, y:0)
      self.currentSpot = self.currentSpotsArray()[0]
      self.guessSpotButtonView.enabled = true;
      self.stopLoadingAnimation()
      self.refreshControl.endRefreshing()
    }

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Darn. Can't fetch spots right now.",
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
        self.title = "Where is \(self.currentSpot!.user.name)'s bicycle?"
        self.guessSpotButtonView.hidden = false
        self.mySpotView.hidden = true
      }
    }
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

  // MARK UIScrollViewDelegate
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    // Snap SpotView to fill frame - we don't want to stop scrolling between two SpotViews.
    let cellIndex = Int(round(targetContentOffset.memory.y / self.spotViewHeight()))
    self.currentSpot = self.currentSpotsArray()[cellIndex]
    targetContentOffset.memory.y = CGFloat(cellIndex) * self.spotViewHeight()
  }

  // MARK UITableViewDataSource
  // MARK UITableViewDelegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.currentSpotsArray().count;
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return self.spotViewHeight()
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // TODO some way to reuse cells that haven't changed?
    let cell = UITableViewCell()
    let spot = self.currentSpotsArray()[indexPath.row]
    let spotView = SpotView(frame: self.view.frame, spot: spot)
    cell.insertSubview(spotView, atIndex: 0)
    return cell
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refreshCurrentSpotsIfStale()
  }

  func applicationWillEnterForeground(notification: NSNotification) {
    refreshCurrentSpotsIfStale()
  }

  func refreshCurrentSpotsIfStale() {
    let secondsElapsed = Int(NSDate().timeIntervalSinceDate(self.timeOfLastReload))
    if ( secondsElapsed > 60 * 30 ) {
      refreshCurrentSpotsAfterGettingApiKey()
    }
  }

}
