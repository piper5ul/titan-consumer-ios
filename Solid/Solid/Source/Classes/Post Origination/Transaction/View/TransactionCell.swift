//
//  TransactionCell.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var lblTransferType: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblContactInitial: UILabel!
    @IBOutlet weak var lblAmount: UILabel!

    @IBOutlet weak var dataView: UIView!

    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var lblNoData: UILabel!

    @IBOutlet weak var imgVwSeparator: UIImageView!

    @IBOutlet weak var transferTypeColoredBgView: UIView!
    @IBOutlet weak var transferTypeWhiteBgView: UIView!

    override func awakeFromNib() {
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize14 : Constants.regularFontSize12
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize16

        lblTitle.font = titleFont
		lblTitle.letterSpace = 0.32
        lblValue.textColor = UIColor.primaryColor
        lblTitle.textAlignment = .left

        lblValue.font = labelFont
        lblValue.textColor = UIColor.secondaryColorWithOpacity
		lblValue.letterSpace = 0.24
        lblValue.textAlignment = .left

        lblAmount.font = labelFont
        lblAmount.textColor = UIColor.secondaryColor
        lblAmount.textAlignment = .right

        lblContactInitial.font = UIFont.sfProDisplayRegular(fontSize: 24)

        noDataView.isHidden = true
		let noDataFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        lblNoData.font = noDataFont
        lblNoData.textColor = UIColor.secondaryColor
        lblNoData.textAlignment = .center
        lblNoData.text = Utility.localizedString(forKey: "noTransactions")

        lblTransferType.font = Utility.isDeviceIpad() ? Constants.mediumFontSize14 : Constants.mediumFontSize12
        lblTransferType.textAlignment = .center
        lblTransferType.layer.cornerRadius = Constants.cornerRadiusThroughApp
        lblTransferType.layer.masksToBounds = true

        imgVwSeparator.backgroundColor = UIColor.customSeparatorColor
        
        self.backgroundColor = .background
        
        transferTypeWhiteBgView.backgroundColor = .white
        transferTypeWhiteBgView.alpha = 0.60
        transferTypeWhiteBgView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        transferTypeWhiteBgView.layer.masksToBounds = true
        
        transferTypeColoredBgView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        transferTypeColoredBgView.layer.masksToBounds = true
    }

    func configureTransactionCell(forRow rowData: TransactionModel, hideSeparator: Bool = false) {
        imgVwSeparator.isHidden = hideSeparator
        lblValue.textColor = .secondaryColor
		
        if let _ = rowData.id { // MEANS HAVING DATA
            lblTitle.text = rowData.title
            lblValue.text = rowData.txnDate?.utcDateTo(formate: "MMM dd, yyyy 'at' hh:mm a")

            lblAmount.text = rowData.formattedAmount
            
            if let transferType = rowData.transferType, transferType != .unknown {
                lblTransferType.text = transferType.localizedDescription()
                transferTypeColoredBgView.backgroundColor = transferType.colorForType().withAlphaComponent(0.2)
                lblTransferType.textColor = transferType.colorForType()
            } else {
                lblTransferType.isHidden = true
            }

            if rowData.isPositiveAmount {
                lblAmount.textColor = UIColor.greenMain
            } else {
                lblAmount.textColor = UIColor.redMain
            }

            if rowData.status == .pending {
                lblValue.text = Utility.localizedString(forKey: "RCD_pending")
                lblAmount.textColor = rowData.status?.colorForType()
            }

            noDataView.isHidden = true
            dataView.isHidden = false
        } else {
            noDataView.isHidden = false
            dataView.isHidden = true
        }
    }

    func configureRCDStatusCell(forRow rowData: ReceiveCheckResponseBody) {
        showRCDStatusData(forRow: rowData)
    }

    func showRCDStatusData(forRow rowData: ReceiveCheckResponseBody) {
		let titleFont = Utility.isDeviceIpad() ? Constants.mediumFontSize18: Constants.mediumFontSize16
		let amountFont = Utility.isDeviceIpad() ? Constants.mediumFontSize14: Constants.mediumFontSize12
		
        lblTitle.font = titleFont
        lblValue.textColor = UIColor.secondaryColor
        lblAmount.font = amountFont

        lblTitle.text = rowData.name
        lblValue.text = rowData.transferredAt?.utcDateTo(formate: "MMM dd, yyyy 'at' hh:mm a")
        lblAmount.text = rowData.formattedAmount

        if let status = rowData.status {
            lblTransferType.text = status.localizeDescription()
            transferTypeColoredBgView.backgroundColor =  status.colorForType().withAlphaComponent(0.3)
            lblTransferType.textColor = status.colorForType()
        } else {
            lblTransferType.isHidden = true
        }

        if rowData.isPositiveAmount {
            lblAmount.textColor = .greenMain
        } else {
            lblAmount.textColor = .redMain
        }

        noDataView.isHidden = true
        dataView.isHidden = false
    }
	
	func configureEmptyContactCell(forRow rowData: TransactionModel, hideSeparator: Bool = false) {
		noDataView.isHidden = false
		lblNoData.text  = Utility.localizedString(forKey: "no_contact")
		lblNoData.numberOfLines = 2
		dataView.isHidden = true
		imgVwSeparator.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblValue.textColor = UIColor.primaryColor
        lblValue.textColor = UIColor.secondaryColorWithOpacity
        lblAmount.textColor = UIColor.secondaryColor
        lblNoData.textColor = UIColor.secondaryColor
        imgVwSeparator.backgroundColor = UIColor.customSeparatorColor
    }
}
