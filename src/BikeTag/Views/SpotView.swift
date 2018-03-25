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
        self.imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = 1234
        imageView.translatesAutoresizingMaskIntoConstraints = false

        self.loadingView = UIImageView(image: SpotView.loadingImage)
        loadingView.tag = 6666
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(imageView)
        self.addSubview(loadingView)

        // Layout

        loadingView.autoSetDimensions(to: CGSize(width: 100, height: 100))
        loadingView.autoCenterInSuperview()
        imageView.autoPinEdgesToSuperviewEdges()

        NotificationCenter.default.addObserver(self, selector: #selector(SpotView.updateSpotViewImage), name: Spot.didSetImageNotification, object: spot)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("unimplemented")
    }

    @objc
    func updateSpotViewImage() {
        if let image = self.spot?.image {
            self.loadingView.isHidden = true
            self.imageView.image = image
        } else {
            self.loadingView.isHidden = false
            self.imageView.image = nil
        }
    }
}
