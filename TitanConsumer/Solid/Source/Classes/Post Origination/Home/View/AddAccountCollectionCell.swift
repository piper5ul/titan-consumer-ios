//
//  DashboardCardCollectionCell.swift
//  Solid
//

import UIKit

class AddAccountCollectionCell: UICollectionViewCell {

	@IBOutlet weak var imgUsername: UIImageView!
	@IBOutlet weak var imgselection: UIImageView!

	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblAmount: UILabel!
	@IBOutlet weak var lblInitial: UILabel!
	@IBOutlet weak var btnAccount: UIButton!

    var isHeightCalculated: Bool = false

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

    var setCellSelected: Bool = false {
        didSet {
            if setCellSelected {
                self.imgselection.backgroundColor = UIColor.brandColor
                self.lblInitial.backgroundColor = UIColor.brandColor
                self.lblTitle.textColor = UIColor.primaryColor
                self.lblAmount.textColor = UIColor.primaryColor
            } else {
                self.imgselection.backgroundColor = UIColor.clear
                self.lblInitial.backgroundColor = UIColor.primaryColor
                self.lblTitle.textColor = UIColor.secondaryColor
                self.lblAmount.textColor = UIColor.secondaryColor
            }
        }
    }

    func configureAccountCell(with account: AccountDataModel) {
		self.lblTitle.text = account.label
		self.lblTitle.letterSpace = 0.24
		let currency = Utility.localizedString(forKey: "currency")
		self.lblAmount.text = "\(currency)\(account.availableBalance ?? "")"
		self.lblTitle.letterSpace = 0.24

		self.lblInitial.text = account.iconImageLetter?.uppercased()
		self.lblInitial.textColor = .white
		self.lblInitial.layer.cornerRadius = self.lblInitial.frame.height/2
		self.lblInitial.layer.masksToBounds = self.lblInitial.frame.height/2 > 0
		let titleFont = Utility.isDeviceIpad() ? Constants.mediumFontSize14: Constants.mediumFontSize12
		lblInitial.font = titleFont
		lblAmount.font = titleFont
		lblTitle.font = titleFont
        setCellSelected = false
	}

}
