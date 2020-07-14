import UIKit

protocol SpotViewDelegate: AnyObject {
    func spotViewDidTapGuessSpot(_ spot: Spot)
}

class SpotView: UIView {
    static let loadingImage = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)
    weak var delegate: SpotViewDelegate?

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter
    }()

    lazy var rewardFormatter = NumberFormatter()

    var spot: Spot? {
        didSet {
            updateSpotViewImage()
            if let spot = spot {
                let nameFormat = NSLocalizedString("posted by %1@ on %2@", comment: "label affixed to a spot image. Embeds (1) the name of the user who posted the spot and (2) the date/time they posted.")
                let timeString = dateFormatter.string(for: spot.createdAt) ?? "?"

                let nameText = spot.isCurrentUserOwner ? NSLocalizedString("you", comment: "embedded in place of username for your own spots") : spot.user.name
                nameLabel.text = String(format: nameFormat, nameText, timeString)

                let numberString = rewardFormatter.string(for: spot.reward) ?? "?"
                let rewardformat = NSLocalizedString("💎%@ reward", comment: "label affixed to a spot image. Embeds the reward amount earned if captured.")

                rewardLabel.text = String(format: rewardformat, numberString)

                if spot.isCurrentUserOwner {
                    let title = NSLocalizedString("Your Spot! ", comment: "primary button text overlaying spot")
                    guessSpotButtonView.setTitle(title, for: .normal)
                    guessSpotButtonView.isEnabled = false
                } else {
                    let title = NSLocalizedString("Find it! ", comment: "primary button text overlaying spot")
                    guessSpotButtonView.setTitle(title, for: .normal)
                    guessSpotButtonView.isEnabled = true
                }
            } else {
                nameLabel.text = nil
                rewardLabel.text = nil
            }
        }
    }

    let loadingView: UIImageView
    let imageView: UIImageView

    required init() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = 1234
        imageView.translatesAutoresizingMaskIntoConstraints = false

        loadingView = UIImageView(image: SpotView.loadingImage)
        loadingView.tag = 6666
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(nameView)
        addSubview(rewardView)
        addSubview(loadingView)

        // Layout

        loadingView.autoSetDimensions(to: CGSize(width: 50, height: 50))
        loadingView.autoCenterInSuperview()
        loadingView.alpha = 0.5
        imageView.autoPinEdgesToSuperviewEdges()

        nameViewHEdgeConstraint = nameView.autoPinEdge(toSuperviewEdge: .leading)

        rewardView.autoPinEdge(.top, to: .bottom, of: nameView, withOffset: 8)
        rewardViewHEdgeConstraint = rewardView.autoPinEdge(toSuperviewEdge: .trailing)
        rewardView.autoPinEdge(toSuperviewMargin: .bottom, withInset: 8)

        guessSpotButtonViewVCenterConstraint = guessSpotButtonView.autoAlignAxis(.vertical, toSameAxisOf: self)

        NotificationCenter.default.addObserver(self, selector: #selector(SpotView.updateSpotViewImage), name: Spot.didSetImageNotification, object: spot)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("unimplemented")
    }

    @objc
    func updateSpotViewImage() {
        if let image = spot?.image {
            loadingView.isHidden = true
            imageView.image = image
        } else {
            loadingView.isHidden = false
            imageView.image = nil
        }
    }

    var nameViewHEdgeConstraint: NSLayoutConstraint!
    var rewardViewHEdgeConstraint: NSLayoutConstraint!
    var guessSpotButtonViewVCenterConstraint: NSLayoutConstraint!
    var hideControls: Bool = false {
        didSet {
            if hideControls {
                nameViewHEdgeConstraint.constant = -nameView.frame.width
                rewardViewHEdgeConstraint.constant = nameView.frame.width
                guessSpotButtonViewVCenterConstraint.isActive = false
            } else {
                nameViewHEdgeConstraint.constant = 0
                rewardViewHEdgeConstraint.constant = 0
                guessSpotButtonViewVCenterConstraint.isActive = true
            }
        }
    }

    // MARK: - Subviews

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bt_bold_label
        label.textColor = .black

        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            label.autoSetContentCompressionResistancePriority(for: .horizontal)
            label.autoSetContentCompressionResistancePriority(for: .vertical)
        }

        return label
    }()

    lazy var rewardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bt_bold_label.withSize(16)
        label.textColor = .black

        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            label.autoSetContentCompressionResistancePriority(for: .horizontal)
            label.autoSetContentCompressionResistancePriority(for: .vertical)
        }

        return label
    }()

    lazy var nameView: UIView = {
        let container = UIView()

        container.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 8)
        container.backgroundColor = .white
        container.setDropShadow()

        container.addSubview(nameLabel)
        nameLabel.autoPinEdgesToSuperviewMargins()

        return container
    }()

    lazy var rewardView: UIView = {
        let container = UIView()
        container.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        container.backgroundColor = .bt_background
        container.setDropShadow()

        let spacer = UIView.hStretchingSpacer()
        let stack = UIStackView(arrangedSubviews: [guessSpotButtonView, spacer, rewardLabel])
        stack.axis = .horizontal

        container.addSubview(stack)
        stack.autoPinEdgesToSuperviewMargins()

        return container
    }()

    lazy var guessSpotButtonView: PrimaryButton = {
        let button = PrimaryButton()
        button.addTarget(self, action: #selector(didTapGuessSpot), for: .touchUpInside)
        return button
    }()

    @objc
    func didTapGuessSpot() {
        Logger.debug("")
        guard let spot = spot else {
            assertionFailure("spot was unexpectedly nil")
            return
        }
        delegate?.spotViewDidTapGuessSpot(spot)
    }
}
