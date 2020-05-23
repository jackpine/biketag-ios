import UIKit

class LastCellInSpotsTableView: UIView {
    required init(frame: CGRect, owner: UIViewController) {
        super.init(frame: frame)
        let subview = Bundle.main.loadNibNamed("LastCellInSpotsTableView", owner: owner, options: nil)?.first as! UIView
        subview.frame = self.frame
        addSubview(subview)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
