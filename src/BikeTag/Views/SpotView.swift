import UIKit

class SpotView: UIView {
    static let loadingImage = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)

    var spot: Spot? {
        didSet {
            updateSpotViewImage()
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
        addSubview(loadingView)

        // Layout

        loadingView.autoSetDimensions(to: CGSize(width: 50, height: 50))
        loadingView.autoCenterInSuperview()
        loadingView.alpha = 0.5
        imageView.autoPinEdgesToSuperviewEdges()

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
}
