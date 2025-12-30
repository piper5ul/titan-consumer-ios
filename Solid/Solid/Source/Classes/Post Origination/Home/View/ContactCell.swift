//ContactCell
//  Solid
//  Created by Solid iOS Team on 01/03/21.
//

import Foundation
import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblContactInitial: UILabel!
	@IBOutlet weak var btnAccesory: BaseButton!

    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInitialWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!

    @IBOutlet weak var imgSeperator: UIImageView!

    override func awakeFromNib() {
        innerView.backgroundColor = .background
        outerView.backgroundColor = .clear
        self.backgroundColor = .clear
    }

	func showData(forRow rowData: AccountRowData, hideSeparator: Bool = false) {
		lblTitle.text = rowData.key
        titleBottomConstraint.constant = -10
        titleLeadingConstraint.constant = 15
	}

	func configureContactListCell(forRow rowData: ContactDataModel, hideSeparator: Bool = false) {
        lblTitle.text = rowData.name
        lblContactInitial.text = rowData.iconImageLetter?.uppercased()
        lblContactInitial.layer.cornerRadius = Constants.cornerRadiusThroughApp
        lblContactInitial.layer.masksToBounds = true
		lblContactInitial.backgroundColor = UIColor.grayBackgroundColor
        lblContactInitial.textColor = .brandColor
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblContactInitial.font = labelFont
        lblContactInitial.textAlignment = .center
        innerView.backgroundColor = .clear
       // btnAccesory.isHidden = false
        self.backgroundColor = .background
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblContactInitial.textColor = .brandColor
    }
    
	func configureContactCell(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
		showContactData(forRow: rowData, hideSeparator: hideSeparator)
	}
	func showContactData(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
		lblTitle.text = rowData.key
        lblTitle.isHidden = true
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblTitle.font = labelFont
        lblTitle.textColor = .primaryColor
	}
}
