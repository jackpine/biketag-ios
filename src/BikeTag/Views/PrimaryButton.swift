import UIKit

class PrimaryButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            applyStyle()
        }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyle()
    }

    func applyStyle() {
        self.backgroundColor = UIColor.clear
        self.titleLabel?.font = Font.titleFont
        self.setTitleColor(.gray, for: .disabled)
        self.setTitleColor(.red, for: .normal)
    }

}
