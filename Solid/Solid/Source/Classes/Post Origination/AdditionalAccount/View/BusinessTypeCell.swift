import UIKit

class BusinessTypeCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionImageView: BaseImageView!
    @IBOutlet weak var imgVWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgVHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionImageView.image = UIImage(named: "Chevron-right")
        imgVWidthConstraint.constant = 20
        imgVHeightConstraint.constant = 20
        selectionImageView.customTintColor = .primaryColor
        self.backgroundColor = .background
        titleLabel.textColor = .primaryColor
    }

    func configureCell(business: BusinessDataModel, isBusinessSelected: Bool) {
        titleLabel.text = business.legalName
        titleLabel.font = UIFont.sfProDisplayRegular(fontSize: 17.0)
    }

}
