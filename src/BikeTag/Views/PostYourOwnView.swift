import UIKit

class PostYourOwnView: UIView {
    weak var delegate: PostYourOwnViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.autoAlignAxis(toSuperviewAxis: .vertical)

        addSubview(topLabel)
        topLabel.autoPinEdge(.bottom, to: .top, of: button, withOffset: -30)
        topLabel.autoCenterInSuperview()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Subviews

    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bt_bold_label.withSize(24)
        label.text = NSLocalizedString("Don't know these spots?", comment: "label text")
        label.textColor = UIColor.bt_blackText
        return label
    }()

    lazy var button: PrimaryButton = {
        let button = PrimaryButton()
        let title = NSLocalizedString("Post your own! ", comment: "button text which starts the 'post a spot' flow")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()

    @objc
    func didTapButton() {
        delegate?.didTapPostYourOwn(self)
    }
}

protocol PostYourOwnViewDelegate: AnyObject {
    func didTapPostYourOwn(_ postYourOwnView: PostYourOwnView)
}
