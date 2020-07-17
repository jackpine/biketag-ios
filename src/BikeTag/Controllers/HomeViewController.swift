import CoreLocation
import PureLayout
import UIKit

class HomeViewController: BaseViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Dependencies

    var currentSpots: SpotsCollection {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.currentSession.currentSpots
    }

    var locationService: LocationService {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.locationService
    }

    // MARK: - Subviews

    lazy var postButton: UIView = {
        let view = UIView()

        let diameter: CGFloat = 60
        view.autoSetDimensions(to: CGSize(width: diameter, height: diameter))
        view.layer.cornerRadius = diameter / 2
        view.backgroundColor = .white
        view.addDropShadow()

        let button = UIButton()
        let image = #imageLiteral(resourceName: "bike-flag")
        button.setImage(image, for: .normal)
        view.addSubview(button)
        button.autoPinEdgesToSuperviewMargins()
        button.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        return view
    }()

    // Last Cell / Add Spot Stuff
    lazy var postYourOwnView: PostYourOwnView = {
        let view = PostYourOwnView()
        view.delegate = self
        return view
    }()

    @IBOutlet var newSpotCostLabel: UILabel!
    @IBOutlet var newSpotButton: PrimaryButton!
    @IBAction func didTouchUpInsideAddSpotButton(sender _: AnyObject) {
        presentNewSpotVC()
    }

    lazy var loadingView: LoadingActivityView = LoadingActivityView()

    let spotViewCache: NSCache<Spot, SpotView> = NSCache()

    var refreshControl: UIRefreshControl!

    @IBAction func unwindToHome(segue _: UIStoryboardSegue) {
        gameTableView.setContentOffset(.zero, animated: true)
        refresh()
    }

    @IBOutlet var gameTableView: UITableView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var timeOfLastReload: NSDate = NSDate()

    func renderScore() {
        scoreButton.setTitle("\(User.currencyUnit)\(currentUserScore)", for: .normal)
        if let newSpotCostLabel = newSpotCostLabel {
            if currentUserScore >= Spot.newSpotCost {
                newSpotCostLabel.text = "This costs \(User.currencyUnit)\(Spot.newSpotCost) of your \(User.currencyUnit)\(currentUserScore)."
                newSpotButton.isEnabled = true
            } else {
                newSpotCostLabel.text = "You need at least \(User.currencyUnit)\(Spot.newSpotCost - currentUserScore) more to add a spot."
                newSpotButton.isEnabled = false
            }
        }
    }

    // MARK: Score Button

    lazy var scoreButtonContainer: UIView = {
        let container = PillView()
        container.layer.cornerRadius = 16
        container.backgroundColor = .white
        container.addDropShadow()
        container.clipsToBounds = false
        container.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        container.addSubview(scoreButton)
        scoreButton.autoPinEdgesToSuperviewMargins()

        return container
    }()

    lazy var scoreButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapScoreButton), for: .touchUpInside)
        button.setTitleColor(.bt_blackText, for: .normal)
        button.titleLabel?.font = UIFont.bt_bold_label.withSize(12)
        return button
    }()

    var currentUserScore = User.getCurrentUser().score {
        didSet {
            renderScore()
        }
    }

    @objc
    func didTapScoreButton() {
        Logger.debug("score button touched")

        let alertController = UIAlertController(
            title: "\(User.currencyUnit)\(currentUserScore) in the bank",
            message: nil,
            preferredStyle: .alert
        )

        let dismissAction = UIAlertAction(title: "No Thanks", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)

        let newSpotAction = UIAlertAction(title: "\(User.currencyUnit)\(Spot.newSpotCost) to post your own spot", style: .default) { [weak self] _ in
            self?.presentNewSpotVC()
        }
        newSpotAction.isEnabled = currentUserScore >= Spot.newSpotCost
        alertController.addAction(newSpotAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: View Life Cycle

    var loadingViewCenterXConstraint: NSLayoutConstraint?
    func setupSubviews() {
        view.addSubview(loadingView)
        loadingViewCenterXConstraint = loadingView.autoAlignAxis(toSuperviewAxis: .vertical)
        loadingView.autoAlignAxis(toSuperviewAxis: .horizontal)

        view.addSubview(postButton)
        if #available(iOS 11.0, *) {
            postButton.autoPinEdge(toSuperviewMargin: .top, withInset: 12)
        } else {
            // on iOS10 we're clobbering the status bar. This probably doesn't work
            // right when there's a call baner, but 🤷‍♂️
            postButton.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
        }
        postButton.autoPinEdge(toSuperviewMargin: .trailing)

        view.addSubview(scoreButtonContainer)
        scoreButtonContainer.autoPinEdge(.top, to: .bottom, of: postButton, withOffset: 8)
        scoreButtonContainer.autoAlignAxis(.vertical, toSameAxisOf: postButton)
    }

    override func viewDidLoad() {
        addShadowBehindStatusBar()

        super.viewDidLoad()
        setupSubviews()

        navigationItem.title = NSLocalizedString("Nearby Tags", comment: "navigation title")

        renderScore()

        if #available(iOS 11.0, *) {
            self.gameTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        gameTableView.translatesAutoresizingMaskIntoConstraints = false

        refreshControl = UIRefreshControl()
        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]

        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: titleAttributes)
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshControlPulled(sender:)), for: .valueChanged)
        gameTableView.addSubview(refreshControl)
        gameTableView.allowsSelection = false
        gameTableView.register(SpotViewCell.self, forCellReuseIdentifier: SpotViewCell.reuseIdentifier)

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

    var hideControls = false
    @objc
    func didTapView(_: UITapGestureRecognizer) {
        let newValue = !hideControls
        hideControls = newValue
        UIView.animate(withDuration: 0.3) {
            for cell in self.gameTableView.visibleCells {
                guard let spotCell = cell as? SpotViewCell else {
                    Logger.info("unexpected cell: \(cell)")
                    continue
                }
                spotCell.spotView.hideControls = newValue
                spotCell.layoutIfNeeded()
            }
        }
    }

    func addShadowBehindStatusBar() {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            assertionFailure("missing key window... cannot add shadow behind status")
            return
        }

        let topShadow = GradientView(from: UIColor.black.withAlphaComponent(0.3),
                                     to: .clear)
        keyWindow.addSubview(topShadow)
        topShadow.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        topShadow.autoSetDimension(.height, toSize: 30)
        topShadow.layer.zPosition = 100
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

    func snapToCell(animated: Bool) {
        guard let path = gameTableView.indexPathForRow(at: gameTableView.bounds.center) else {
            return
        }
        gameTableView.scrollToRow(at: path, at: .middle, animated: animated)
    }

    func fetchCurrentSpots(near: CLLocation) {
        Logger.info("refreshing spots list near \(near)")
        timeOfLastReload = NSDate()
        let setCurrentSpots = { [weak self] (newSpots: [Spot]) -> Void in
            guard let self = self else { return }
            self.currentSpots.replaceSpots(spots: newSpots)
            self.gameTableView.reloadData()
            self.gameTableView.layoutIfNeeded()
            self.snapToCell(animated: true)
            self.completeLoadingAnimation()
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

        Spot.fetchCurrentSpots(location: near, callback: setCurrentSpots, errorCallback: displayErrorAlert)
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

        Config.usersService.fetchUser(userId: Config.currentUserId, successCallback: updateCurrentUser, errorCallback: displayErrorAlert)
    }

    func completeLoadingAnimation() {
        guard let loadingViewCenterXConstraint = loadingViewCenterXConstraint else {
            assertionFailure("loadingViewCenterXConstraint was unexpectedly nil")
            return
        }

        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                           loadingViewCenterXConstraint.constant = self.view.frame.width
                           self.loadingView.superview?.layoutIfNeeded()
                       },
                       completion: { _ in
                           self.loadingView.isHidden = true
        })
    }

    func startLoadingAnimation() {
        loadingView.isHidden = false

        guard let loadingViewCenterXConstraint = loadingViewCenterXConstraint else {
            assertionFailure("loadingViewCenterXConstraint was unexpectedly nil")
            return
        }

        loadingViewCenterXConstraint.constant = -view.frame.width
        loadingView.superview?.layoutIfNeeded()

        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                           loadingViewCenterXConstraint.constant = 0
                           self.loadingView.superview?.layoutIfNeeded()
                       },
                       completion: { _ in

        })
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

        func configure(spot: Spot, delegate: SpotViewDelegate) {
            spotView.spot = spot
            spotView.delegate = delegate
        }

        override func prepareForReuse() {
            spotView.spot = nil
            spotView.delegate = nil
            spotView.hideControls = false
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return spotViewHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < currentSpots.count() else {
            // Not looking at spot, looking at last cell
            let cell = UITableViewCell()
            cell.contentView.addSubview(postYourOwnView)
            postYourOwnView.autoPinEdgesToSuperviewEdges()
            return cell
        }

        // Spot Cell
        let spot = currentSpots[indexPath.row]
        guard let cell: SpotViewCell = tableView.dequeueReusableCell(withIdentifier: SpotViewCell.reuseIdentifier) as? SpotViewCell else {
            fatalError("unknown cell")
        }

        cell.configure(spot: spot, delegate: self)

        return cell
    }

    func refreshIfStale() {
        let secondsElapsed = Int(NSDate().timeIntervalSince(timeOfLastReload as Date))
        if secondsElapsed > 60 * 30 {
            refresh()
        }
    }

    func presentNewSpotVC() {
        let vc = NewSpotViewController.fromStoryboard()
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                              target: self,
                                                              action: #selector(didTapDismissNewSpot))

        let modal = NewSpotNavController(rootViewController: vc)
        vc.spotCreationDelegate = modal
        modal.newSpotDelegate = self

        present(modal, animated: true)
    }

    @objc
    func didTapDismissNewSpot() {
        dismiss(animated: true)
    }

    @objc
    func didTapDismissNewGuess() {
        dismiss(animated: true)
    }

    @objc
    func didTapPostButton() {
        presentNewSpotVC()
    }
}

extension HomeViewController: SpotViewDelegate {
    func spotViewDidTapGuessSpot(_ spot: Spot) {
        let guessSpotVC = GuessSpotViewController.fromStoryboard(spot: spot)

        guessSpotVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                                       target: self,
                                                                       action: #selector(didTapDismissNewGuess))

        let modal = GuessNavController(rootViewController: guessSpotVC)
        modal.guessNavDelegate = self
        modal.existingSpot = spot
        guessSpotVC.guessCreationDelegate = modal

        present(modal, animated: true)
    }
}

extension HomeViewController: GuessNavDelegate {
    func guessNav(_: GuessNavController, didPostNewSpot newSpot: Spot) {
        fetchCurrentUser()
        currentSpots.addNewSpot(newSpot: newSpot)
        gameTableView.reloadData()
        gameTableView.setContentOffset(.zero, animated: true)
        dismiss(animated: true)
    }

    func guessNavRequestedStop(_: GuessNavController) {
        dismiss(animated: true)
    }
}

extension HomeViewController: PostYourOwnViewDelegate {
    func didTapPostYourOwn(_: PostYourOwnView) {
        presentNewSpotVC()
    }
}

extension HomeViewController: NewSpotNavDelegate {
    func newSpotNav(_: NewSpotNavController, didFinishCreatingSpot newSpot: Spot) {
        fetchCurrentUser()
        currentSpots.addNewSpot(newSpot: newSpot)
        gameTableView.reloadData()
        gameTableView.setContentOffset(.zero, animated: true)
        if UserDefaults.hasPreviouslyCreatedSpot() {
            dismiss(animated: true)
        } else {
            showFirstSpotCreated()
        }
    }

    func showFirstSpotCreated() {
        dismiss(animated: true)
        // TODO: - Instead, show first spot created / APN request screen
        // once we have APN set up.
        // UserDefaults.setHasPreviouslyCreatedSpot(val: true)
    }
}
