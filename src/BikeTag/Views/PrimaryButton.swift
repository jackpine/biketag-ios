import UIKit

class PrimaryButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            applyStyle()
        }
    }

    override required init(frame: CGRect) {
        super.init(frame: frame)
        applyStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyStyle()
    }

    func applyStyle() {
        backgroundColor = UIColor.clear
        titleLabel?.font = .bt_title
        setTitleColor(.gray, for: .disabled)
        setTitleColor(.red, for: .normal)
    }
}
