//
//  FundCell.swift
//  Solid
//
//  Created by Solid iOS Team on 19/05/21.
//

import UIKit
import Toast

class FundCell: UITableViewCell {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var imvVwDropdown: BaseImageView!

    @IBOutlet weak var lblAccNoTitle: UILabel!
    @IBOutlet weak var lblAccNoValue: UILabel!
    @IBOutlet weak var imgVwAccNoCopy: BaseImageView!

    @IBOutlet weak var lblRoutingNoTitle: UILabel!
    @IBOutlet weak var lblRoutingNoValue: UILabel!
    @IBOutlet weak var imgVwRoutingNoCopy: BaseImageView!

	@IBOutlet weak var imvVwseparatorCell1: UIImageView!
	@IBOutlet weak var imvVwseparatorCell2: UIImageView!
	@IBOutlet weak var imvVwseparatorCell3: UIImageView!

    @IBOutlet weak var lblAccTypeTitle: UILabel!
    @IBOutlet weak var lblAccTypeValue: UILabel!

    @IBOutlet weak var lblBankNameTitle: UILabel!
    @IBOutlet weak var lblBankNameValue: UILabel!
    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var imgSeperator: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

		self.backgroundColor = .clear
        dataView.backgroundColor = .background
        imgSeperator.backgroundColor = .customSeparatorColor
		let headerFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblHeader.font = headerFont
        lblHeader.textColor = UIColor.primaryColor
        lblHeader.textAlignment = .left

		let lblDescFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        lblDesc.font = lblDescFont
        lblDesc.textColor = UIColor.secondaryColor
        lblDesc.textAlignment = .left
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize14
		let valueFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14

        lblAccNoTitle.font = titleFont
        lblAccNoTitle.textColor = UIColor.secondaryColor
        lblAccNoTitle.textAlignment = .left
        lblAccNoValue.font = headerFont
        lblAccNoValue.textColor = UIColor.primaryColor
        lblAccNoValue.textAlignment = .left

        lblRoutingNoTitle.font = titleFont
        lblRoutingNoTitle.textColor = UIColor.secondaryColor
        lblRoutingNoTitle.textAlignment = .left
        lblRoutingNoValue.font = headerFont
        lblRoutingNoValue.textColor = UIColor.primaryColor
        lblRoutingNoValue.textAlignment = .left

        lblAccTypeTitle.font = titleFont
        lblAccTypeTitle.textColor = UIColor.secondaryColor
        lblAccTypeTitle.textAlignment = .left
        lblAccTypeValue.font = valueFont
        lblAccTypeValue.textColor = UIColor.primaryColor
        lblAccTypeValue.textAlignment = .left

        lblBankNameTitle.font = titleFont
        lblBankNameTitle.textColor = UIColor.secondaryColor
        lblBankNameTitle.textAlignment = .left
        lblBankNameValue.font = valueFont
        lblBankNameValue.textColor = UIColor.primaryColor
        lblBankNameValue.textAlignment = .left
		
		if Utility.isDeviceIpad() {
			imvVwseparatorCell1.backgroundColor = .customSeparatorColor
			imvVwseparatorCell2.backgroundColor = .customSeparatorColor
			imvVwseparatorCell3.backgroundColor = .customSeparatorColor
			imvVwseparatorCell1.isHidden = false
			imvVwseparatorCell2.isHidden = false
			imvVwseparatorCell3.isHidden = false
		}

        self.layer.cornerRadius = Constants.cornerRadiusThroughApp
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configurePushFundCell(forRow rowData: [ContactRowData]) {
        lblHeader.text = rowData[0].key
        let value = rowData[0].value as? String
        lblDesc.text = value
       // imvVwDropdown.image = UIImage(named: "up")

        lblAccNoTitle.text = rowData[1].key
        let accNoValue = rowData[1].value as? String
        lblAccNoValue.text = accNoValue
        imgVwAccNoCopy.image = UIImage(named: "copy_black")
        imgVwAccNoCopy.isUserInteractionEnabled = true
        let gestureReco = UITapGestureRecognizer(target: self, action: #selector(copyAccNoClick))
        imgVwAccNoCopy.addGestureRecognizer(gestureReco)
        imgVwAccNoCopy.customTintColor = .primaryColor

        lblRoutingNoTitle.text = rowData[2].key
        let routeNoValue = rowData[2].value as? String
        lblRoutingNoValue.text = routeNoValue
        imgVwRoutingNoCopy.image = UIImage(named: "copy_black")
        imgVwRoutingNoCopy.isUserInteractionEnabled = true
        let gestureRecoRoute = UITapGestureRecognizer(target: self, action: #selector(copyRoutingNoClick))
        imgVwRoutingNoCopy.addGestureRecognizer(gestureRecoRoute)
        imgVwRoutingNoCopy.customTintColor = .primaryColor

        lblAccTypeTitle.text = rowData[3].key
        let accType = rowData[3].value as? String
        lblAccTypeValue.text = accType

        lblBankNameTitle.text = rowData[4].key
        let bankName = rowData[4].value as? String
        lblBankNameValue.text = bankName
    }

    @objc func copyAccNoClick() {
        if let accNo = AppGlobalData.shared().accountData?.accountNumber {
            let pasteboard = UIPasteboard.general
            pasteboard.string = accNo

            self.makeToast(Utility.localizedString(forKey: "cardNumber_copied"), duration: 1.3)
        }
    }

    @objc func copyRoutingNoClick() {
        if let routeNo = AppGlobalData.shared().accountData?.routingNumber {
            let pasteboard = UIPasteboard.general
            pasteboard.string = routeNo

            self.makeToast(Utility.localizedString(forKey: "cardNumber_copied"), duration: 1.3)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imgSeperator.backgroundColor = .customSeparatorColor
        lblHeader.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
        lblAccNoTitle.textColor = UIColor.secondaryColor
        lblAccNoValue.textColor = UIColor.primaryColor
        lblRoutingNoTitle.textColor = UIColor.secondaryColor
        lblRoutingNoValue.textColor = UIColor.primaryColor
        lblAccTypeTitle.textColor = UIColor.secondaryColor
        lblAccTypeValue.textColor = UIColor.primaryColor
        lblBankNameTitle.textColor = UIColor.secondaryColor
        lblBankNameValue.textColor = UIColor.primaryColor
        imvVwseparatorCell1.backgroundColor = .customSeparatorColor
        imvVwseparatorCell2.backgroundColor = .customSeparatorColor
        imvVwseparatorCell3.backgroundColor = .customSeparatorColor
        imgVwAccNoCopy.customTintColor = .primaryColor
        imgVwRoutingNoCopy.customTintColor = .primaryColor
    }
}
