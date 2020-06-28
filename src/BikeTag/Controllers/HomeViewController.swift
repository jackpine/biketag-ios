import CoreLocation
import PureLayout
import UIKit

class HomeViewController: ApplicationViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var guessSpotButtonView: PrimaryButton!
    @IBOutlet var spotDateContainer: UIView!
    @IBOutlet var spotDateLabel: UILabel!

    // Last Cell / Add Spot Stuff
    @IBOutlet var lastCellInSpotsTableView: UIView!
    @IBOutlet var newSpotCostLabel: UILabel!
    @IBOutlet var newSpotButton: PrimaryButton!
    @IBAction func didTouchUpInsideAddSpotButton(sender _: AnyObject) {
        navigationController!.performSegue(withIdentifier: "pushNewSpotViewController", sender: nil)
    }

    @IBOutlet var mySpotView: UIView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var activityIndicatorImageView: UIImageView!

    let currentSpots: SpotsCollection
    let locationService: LocationService
    let spotViewCache: NSCache<Spot, SpotView> = NSCache()
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter
    }()

    var currentSpot: Spot? {
        didSet {
            updateSpotControls()
        }
    }

    var refreshControl: UIRefreshControl!

    @IBAction func unwindToHome(segue _: UIStoryboardSegue) {
        gameTableView.setContentOffset(.zero, animated: true)
        refresh()
    }

    @IBOutlet var gameTableView: UITableView!

    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        currentSpots = appDelegate.currentSession.currentSpots
        locationService = appDelegate.locationService
        super.init(coder: aDecoder)
    }

    var timeOfLastReload: NSDate = NSDate()

    override func renderScore() {
        super.renderScore()
        if newSpotCostLabel != nil {
            if currentUserScore >= Spot.newSpotCost {
                newSpotCostLabel.text = "This costs 💎\(Spot.newSpotCost) of your 💎\(currentUserScore)."
                newSpotButton.isEnabled = true
            } else {
                newSpotCostLabel.text = "You need at least 💎\(Spot.newSpotCost - currentUserScore) more to add a spot."
                newSpotButton.isEnabled = false
            }
        }
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        gameTableView.translatesAutoresizingMaskIntoConstraints = false

        lastCellInSpotsTableView = LastCellInSpotsTableView(frame: view.frame, owner: self)

        activityIndicatorImageView.image = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)!
        loadingView.layer.cornerRadius = 5
        loadingView.layer.masksToBounds = true

        guessSpotButtonView.setTitle("Fetching Spots...", for: .disabled)

        refreshControl = UIRefreshControl()
        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]

        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: titleAttributes)
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshControlPulled(sender:)), for: .valueChanged)
        gameTableView.addSubview(refreshControl)
        gameTableView.allowsSelection = false
        gameTableView.register(SpotViewCell.self, forCellReuseIdentifier: SpotViewCell.reuseIdentifier)

        spotDateContainer.clipsToBounds = false
        spotDateContainer.layer.shadowColor = UIColor.black.cgColor
        spotDateContainer.layer.shadowRadius = 2
        spotDateContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        spotDateContainer.layer.shadowOpacity = 0.5

        updateSpotControls()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)

        startTrackingLocation()
        refresh()

        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                               object: self,
                                               queue: .main) { [weak self] _ in
            self?.refreshIfStale()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshIfStale()
    }

    var prefersDateVisible = true
    @objc
    func didTapView(_: UITapGestureRecognizer) {
        prefersDateVisible = !prefersDateVisible
        ensureSpotDateVisibility()

        navigationController?.setNavigationBarHidden(!prefersDateVisible, animated: true)
    }

    func startTrackingLocation() {
        let showLocationServicesDisabledAlert = {
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to get spots near you, please open this app's settings and set location access to 'While Using the App'.",
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.startTrackingLocation()
            }

            alertController.addAction(retryAction)

            let openAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url) { success in
                        guard success else {
                            Logger.error("unable to open settings.")
                            return
                        }
                    }
                }
            }

            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        }

        locationService.startTrackingLocation(onDenied: showLocationServicesDisabledAlert)
    }

    func refresh() {
        // Getting current spots requires the ApiKey *and* Location.
        // *Order is important*. We get the APIKey first, meanwhile
        // the Location manager fetches the location in the background (started previously)
        // minimizing the overall wait time.
        startLoadingAnimation()
        ensureApiKey {
            self.fetchCurrentUser()
            self.ensureLocation(onSuccess: self.fetchCurrentSpots)
        }
    }

    @objc func refreshControlPulled(sender _: AnyObject) {
        refresh()
    }

    func ensureApiKey(success: @escaping () -> Void) {
        let displayAuthenticationErrorAlert = { (error: Error) -> Void in
            let alertController = UIAlertController(
                title: "Unable to authenticate you.",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.ensureApiKey(success: success)
            }
            alertController.addAction(retryAction)

            self.present(alertController, animated: true, completion: nil)
        }

        ApiKey.ensureApiKey(successCallback: {
            success()
        }, errorCallback: displayAuthenticationErrorAlert)
    }

    func ensureLocation(onSuccess successCallback: @escaping (CLLocation) -> Void) {
        let displayRetryAlert = {
            let alertController = UIAlertController(
                title: "Hang on a second.",
                message: "We're having trouble pinpointing your location",
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.ensureLocation(onSuccess: successCallback)
            }
            alertController.addAction(retryAction)

            self.present(alertController, animated: true, completion: nil)
        }

        locationService.waitForLocation(onSuccess: successCallback,
                                        onTimeout: displayRetryAlert)
    }

    func fetchCurrentSpots(near: CLLocation) {
        Logger.info("refreshing spots list near \(near)")
        timeOfLastReload = NSDate()
        let setCurrentSpots = { (newSpots: [Spot]) -> Void in
            self.currentSpots.replaceSpots(spots: newSpots)
            self.currentSpot = self.currentSpots[0]
            self.gameTableView.reloadData()
            self.gameTableView.layoutIfNeeded()
            self.gameTableView.setContentOffset(.zero, animated: true)

            self.guessSpotButtonView.isEnabled = true
            self.stopLoadingAnimation()
            self.refreshControl.endRefreshing()
        }

        let displayErrorAlert = { (error: Error) -> Void in
            let alertController = UIAlertController(
                title: "Darn. Can't fetch spots right now.",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.fetchCurrentSpots(near: near)
            }
            alertController.addAction(retryAction)

            self.present(alertController, animated: true, completion: nil)
        }

        Spot.fetchCurrentSpots(spotsService: spotsService, location: near, callback: setCurrentSpots, errorCallback: displayErrorAlert)
    }

    func fetchCurrentUser() {
        Logger.debug("fetching current user")

        let displayErrorAlert = { (error: Error) -> Void in
            let alertController = UIAlertController(
                title: "Hrm. Trouble fetching your user data right now.",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.fetchCurrentUser()
            }
            alertController.addAction(retryAction)

            self.present(alertController, animated: true, completion: nil)
        }

        let updateCurrentUser = { (user: User) -> Void in
            User.setCurrentUser(user: user)
            self.currentUserScore = user.score
        }

        usersService.fetchUser(userId: Config.currentUserId, successCallback: updateCurrentUser, errorCallback: displayErrorAlert)
    }

    func stopLoadingAnimation() {
        loadingView.isHidden = true
    }

    func startLoadingAnimation() {
        loadingView.isHidden = false
    }

    func updateSpotControls() {
        if let currentSpot = self.currentSpot {
            if currentSpot.isCurrentUserOwner {
                title = "This is YOUR Spot!"
                guessSpotButtonView.isHidden = true
                mySpotView.isHidden = false
            } else {
                title = "Where is \(self.currentSpot!.user.name)'s bicycle?"
                guessSpotButtonView.isHidden = false
                mySpotView.isHidden = true
            }

            ensureSpotDateVisibility()
            spotDateLabel.text = dateFormatter.string(for: currentSpot.createdAt)
        } else {
            spotDateLabel.text = nil
            ensureSpotDateVisibility()
            title = "Where is YOUR bicycle?"
            guessSpotButtonView.isHidden = true
        }
    }

    var spotDateContainerLeadingConstraint: NSLayoutConstraint?

    func ensureSpotDateVisibility() {
        if let existingConstraint = spotDateContainerLeadingConstraint {
            NSLayoutConstraint.deactivate([existingConstraint])
        }

        if currentSpot == nil || !prefersDateVisible {
            spotDateContainerLeadingConstraint = spotDateContainer.autoPinEdge(.leading, to: .trailing, of: view)
        }

        UIView.animate(withDuration: 0.2) {
            self.spotDateContainer.superview!.layoutIfNeeded()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showNewGuessScene" {
            let guessSpotViewController = segue.destination as! GuessSpotViewController
            guessSpotViewController.currentSpot = currentSpot
        }
    }

    var spotViewHeight: CGFloat {
        // FIXME: I was expecting to use gameListView.frame.height here, but the gameListView is only
        // something like 300X125 pixels in 'viewDidLoad'.
        // By the time subsequent spot refreshes have happened it is full size.
        // return self.gameListView.frame.height
        return view.frame.height
    }

    // MARK: UIScrollViewDelegate

    func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Snap SpotView to fill frame - we don't want to stop scrolling between two SpotViews.
        let cellIndex = Int(round(targetContentOffset.pointee.y / spotViewHeight))
        targetContentOffset.pointee.y = CGFloat(cellIndex) * spotViewHeight

        if cellIndex == currentSpots.count() {
            // not looking at spot, looking at last cell
            currentSpot = nil
        } else {
            currentSpot = currentSpots[cellIndex]
        }
    }

    // MARK: UITableViewDataSource

    // MARK: UITableViewDelegate

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            Logger.error("Unknown section: \(section)")
            return 0
        }

        let spotCount = currentSpots.count()

        if spotCount == 0 {
            // Display nothing
            // We don't want to display the "Don't know these spots?" message before spots have loaded.
            return 0
        } else {
            // Display spots plus a final cell
            return spotCount + 1
        }
    }

    class SpotViewCell: UITableViewCell {
        static let reuseIdentifier = "SpotViewCell"

        let spotView: SpotView

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            spotView = SpotView()

            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(spotView)
            spotView.autoPinEdgesToSuperviewEdges()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(spot: Spot) {
            spotView.spot = spot
        }

        override func prepareForReuse() {
            spotView.spot = nil
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return spotViewHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < currentSpots.count() else {
            // Not looking at spot, looking at last cell
            let cell = UITableViewCell()
            cell.contentView.addSubview(lastCellInSpotsTableView)

            return cell
        }

        // Spot Cell
        let spot = currentSpots[indexPath.row]
        guard let cell: SpotViewCell = tableView.dequeueReusableCell(withIdentifier: SpotViewCell.reuseIdentifier) as? SpotViewCell else {
            fatalError("unknown cell")
        }

        cell.configure(spot: spot)

        return cell
    }

    func refreshIfStale() {
        let secondsElapsed = Int(NSDate().timeIntervalSince(timeOfLastReload as Date))
        if secondsElapsed > 60 * 30 {
            refresh()
        }
    }
}
