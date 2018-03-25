import UIKit

class SpotView: UIView {

    static let loadingImage = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)

    var spot: Spot
    let loadingView: UIImageView
    let imageView: UIImageView

    required init(frame: CGRect, spot: Spot) {
        self.spot = spot

        self.imageView = UIImageView(image: spot.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        self.loadingView = UIImageView(image: SpotView.loadingImage)
        loadingView.isHidden = spot.image != nil

        super.init(frame: frame)

        self.addSubview(loadingView)
        self.addSubview(imageView)

        // Layout

        loadingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(SpotView.updateSpotViewImage), name: Spot.didSetImageNotification, object: spot)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("unimplemented")
    }

    @objc func updateSpotViewImage() {
        if let image = self.spot.image {
            self.loadingView.isHidden = true
            self.imageView.image = image
        } else {
            self.loadingView.isHidden = false
            self.imageView.image = nil
        }
    }
}
