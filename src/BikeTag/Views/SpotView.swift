import UIKit

class SpotView: UIImageView {

    var spot: Spot?
    //TODO make these singletons?
    let loadingImage = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)
    let loadingView = UIImageView()

    required init(frame: CGRect, spot: Spot) {
        super.init(frame: frame)
        if (spot.image == nil) {
            loadingView.frame = CGRect(x: 150, y: 300, width: 100, height: 100)
            loadingView.center = self.center
            loadingView.image = loadingImage
            self.addSubview(loadingView)
        } else {
            self.image = spot.image
        }
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.spot = spot

        NotificationCenter.default.addObserver(self, selector: #selector(SpotView.updateSpotViewImage), name: Spot.didSetImageNotification, object: spot)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
    }

    @objc func updateSpotViewImage() {
        if self.spot == nil {
            self.loadingView.isHidden = false
            self.image = nil
        } else {
            self.loadingView.isHidden = true
            self.image = self.spot!.image
        }
    }
}
