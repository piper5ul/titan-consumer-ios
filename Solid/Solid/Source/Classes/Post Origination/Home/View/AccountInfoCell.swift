//
//  AccountInfoCell.swift
//  Solid
//
//  Created by Solid iOS Team on 06/05/21.
//

import UIKit

class AccountInfoCell: UITableViewCell {

    @IBOutlet weak var lblTitleBalance: UILabel!
    @IBOutlet weak var lblValueBalance: UILabel!

    @IBOutlet weak var lblTitleAccNo: UILabel!
    @IBOutlet weak var lblValueAccNo: UILabel!

    @IBOutlet weak var lblTitleRoutingNo: UILabel!
    @IBOutlet weak var lblValueRoutingNo: UILabel!

    @IBOutlet weak var imgVwAccNoCopy: BaseImageView!
    @IBOutlet weak var imgVwRoutingNoCopy: BaseImageView!

    var strAccountNo: String? = ""
    var strRoutingNo: String? = ""

    override func awakeFromNib() {

        // BALANCE...
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblTitleBalance.font = labelFont
        lblTitleBalance.textColor = UIColor.primaryColor
        lblTitleBalance.textAlignment = .left
        lblValueBalance.font = labelFont
        lblValueBalance.textColor = UIColor.greenMain
        lblValueBalance.textAlignment = .right

		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        // ACCOUNTING NUMBER..
        lblTitleAccNo.font = titleFont
        lblTitleAccNo.textColor = UIColor.secondaryColor
        lblTitleAccNo.textAlignment = .left
        lblValueAccNo.font = labelFont
        lblValueAccNo.textColor = UIColor.primaryColor
        lblValueAccNo.textAlignment = .left

        // ROUTING NUMBER..
        lblTitleRoutingNo.font = titleFont
        lblTitleRoutingNo.textColor = UIColor.secondaryColor
        lblTitleRoutingNo.textAlignment = .left
        lblValueRoutingNo.font = labelFont
        lblValueRoutingNo.textColor = UIColor.primaryColor
        lblValueRoutingNo.textAlignment = .left
        
        imgVwAccNoCopy.image = UIImage(named: "copy_black")
        imgVwAccNoCopy.isUserInteractionEnabled = true
        let gestureRecoAccNo = UITapGestureRecognizer(target: self, action: #selector(copyAccNumberClick))
        imgVwAccNoCopy.addGestureRecognizer(gestureRecoAccNo)
        imgVwAccNoCopy.customTintColor = .primaryColor
        
        imgVwRoutingNoCopy.image = UIImage(named: "copy_black")
        imgVwRoutingNoCopy.isUserInteractionEnabled = true
        let gestureRecoRout = UITapGestureRecognizer(target: self, action: #selector(copyRoutingNumberClick))
        imgVwRoutingNoCopy.addGestureRecognizer(gestureRecoRout)
        imgVwRoutingNoCopy.customTintColor = .primaryColor
        
        self.backgroundColor = .background
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitleBalance.textColor = UIColor.primaryColor
        lblTitleAccNo.textColor = UIColor.secondaryColor
        lblValueAccNo.textColor = UIColor.primaryColor
        lblTitleRoutingNo.textColor = UIColor.secondaryColor
        lblValueRoutingNo.textColor = UIColor.primaryColor
        imgVwAccNoCopy.customTintColor = .primaryColor
        imgVwRoutingNoCopy.customTintColor = .primaryColor
    }

    @objc func copyAccNumberClick() {
        if let accNumber = AppGlobalData.shared().accountData?.accountNumber {
            let pasteboard = UIPasteboard.general
            pasteboard.string = accNumber

            self.makeToast(Utility.localizedString(forKey: "cardNumber_copied"), duration: 1.3)
        }
    }

    @objc func copyRoutingNumberClick() {
        if let routeNumber = AppGlobalData.shared().accountData?.routingNumber {
            let pasteboard = UIPasteboard.general
            pasteboard.string = routeNumber

            self.makeToast(Utility.localizedString(forKey: "cardNumber_copied"), duration: 1.3)
        }
    }

    func configureAccountInfoCell(forRow rowData: AccountDataModel, hideSeparator: Bool = false) {
        showAccountData(forRow: rowData, hideSeparator: hideSeparator)
    }

    func showAccountData(forRow rowData: AccountDataModel, hideSeparator: Bool = false) {
        // Available balance
        lblTitleBalance.text = AccountDetails.availableBalance.getTitleKey()
        if let aBalance = rowData.availableBalance {
            lblValueBalance.text = Utility.getFormattedAmount(amount: aBalance)
        }

        // Account Number
        lblTitleAccNo.text = AccountDetails.accountNumber.getTitleKey()
        if rowData.accountNumber != nil {
            lblValueAccNo.text = rowData.accountNumber
            strAccountNo = rowData.accountNumber
        }

        // Routing Number
        lblTitleRoutingNo.text = AccountDetails.routingNumber.getTitleKey()
        if rowData.routingNumber != nil {
            lblValueRoutingNo.text = rowData.routingNumber
            strRoutingNo = rowData.routingNumber
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
