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
        titleLabel!.font = .bt_primary_button
        titleLabel!.clipsToBounds = false
        setTitleColor(.gray, for: .disabled)
        setTitleColor(.red, for: .normal)
    }
}
