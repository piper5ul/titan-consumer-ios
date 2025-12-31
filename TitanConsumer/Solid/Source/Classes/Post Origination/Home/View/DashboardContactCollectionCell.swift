//
//  DashboardCardCollectionCell.swift
//  Solid
//

import UIKit

class DashboardContactCollectionCell: UICollectionViewCell {

	@IBOutlet weak var initialView: UIView!
	@IBOutlet weak var lblInitial: UILabel!
	@IBOutlet weak var lblContactName: UILabel!

    var isHeightCalculated: Bool = false

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

    func configureCell(with contact: ContactDataModel) {
		lblContactName.text = contact.name
		lblInitial.text = contact.iconImageLetter?.uppercased()
		initialView.layer.cornerRadius = Constants.cornerRadiusThroughApp
		self.layer.cornerRadius = Constants.cornerRadiusThroughApp

		initialView.backgroundColor = .white
		initialView.layer.masksToBounds = true
		initialView.backgroundColor = UIColor.grayBackgroundColor
        lblInitial.textColor = .brandColor
		let initialFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
		lblInitial.font = initialFont
		lblInitial.textAlignment = .center
		let contactnameFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
		lblContactName.font = contactnameFont
        lblContactName.textColor = .primaryColor
        self.backgroundColor = .background
	}
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblInitial.textColor = .brandColor
    }
}
