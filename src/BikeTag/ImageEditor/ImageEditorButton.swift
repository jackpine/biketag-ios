import UIKit

@objc
public class ImageEditorButton: UIButton {
    @objc
    var block: () -> Void = {}

    // MARK: -

    @objc
    public init(block: @escaping () -> Void = {}) {
        super.init(frame: .zero)

        self.block = block
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @objc
    public init(title: String, block: @escaping () -> Void = {}) {
        super.init(frame: .zero)

        self.block = block
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        setTitle(title, for: .normal)
    }

    @objc
    public init(imageName: String,
                tintColor: UIColor?,
                block: @escaping () -> Void = {}) {
        super.init(frame: .zero)

        self.block = block
        addTarget(self, action: #selector(didTap), for: .touchUpInside)

        setImage(imageName: imageName)
        self.tintColor = tintColor
    }

    @objc
    public func setImage(imageName: String) {
        if let image = UIImage(named: imageName) {
            setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            assertionFailure("Missing asset: \(imageName)")
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Common Style Reuse

    @objc
    public class func sendButton(imageName: String, block: @escaping () -> Void) -> ImageEditorButton {
        let button = ImageEditorButton(imageName: imageName, tintColor: .white, block: block)

        let buttonWidth: CGFloat = 40
        button.layer.cornerRadius = buttonWidth / 2
        button.autoSetDimensions(to: CGSize(square: buttonWidth))

        button.backgroundColor = .blue

        return button
    }

    /// Mimics a UIBarButtonItem of type .cancel, but with a shadow.
    @objc
    public class func shadowedCancelButton(block: @escaping () -> Void) -> ImageEditorButton {
        let cancelButton = ImageEditorButton(title: NSLocalizedString("Cancel", comment: "button text"), block: block)
        cancelButton.setTitleColor(.white, for: .normal)
        if let titleLabel = cancelButton.titleLabel {
            titleLabel.font = UIFont.systemFont(ofSize: 18.0)
            titleLabel.layer.shadowColor = UIColor.black.cgColor
            titleLabel.addDropShadow()
        } else {
            assertionFailure("Missing titleLabel.")
        }
        cancelButton.sizeToFit()
        return cancelButton
    }

    @objc
    public class func navigationBarButton(imageName: String, block: @escaping () -> Void) -> ImageEditorButton {
        let button = ImageEditorButton(imageName: imageName, tintColor: .white, block: block)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.66
        button.layer.shadowOffset = .zero
        return button
    }

    // MARK: -

    @objc
    func didTap() {
        block()
    }
}
