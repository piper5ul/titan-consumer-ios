//
//  DataCell.swift
//  Solid
//
//  Created by Solid iOS Team on 01/03/21.
//

import Foundation
import UIKit

class DataCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var imgVwAccessory: UIImageView!
	@IBOutlet weak var lblDescription: UILabel!

    @IBOutlet weak var imgSeperator: UIImageView!

    var fieldType: String? = ""
    var handler: ((Int) -> Void)?
    private var counter = 0 {
        didSet {
            DispatchQueue.main.async {
                self.lblValue.text = "0:\(self.counter)"
                self.lblValue.textColor = UIColor.redMain
                self.handler?(self.counter)
            }
        }
    }
    
    override func awakeFromNib() {
        imgVwAccessory.isHidden = true
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize14
        lblTitle.font = titleFont
        lblTitle.textColor = UIColor.secondaryColor
        lblTitle.textAlignment = .left
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblValue.font = labelFont
        lblValue.textColor = UIColor.primaryColor
        lblValue.textAlignment = .left
		lblDescription.font = titleFont
		lblDescription.textColor = UIColor.primaryColor
		lblDescription.textAlignment = .left
		lblDescription.isHidden = true
        
        self.backgroundColor = .background
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.secondaryColor
        lblValue.textColor = UIColor.primaryColor
        lblDescription.textColor = UIColor.primaryColor
        imgSeperator.backgroundColor = .customSeparatorColor
    }

	func configureCell(forRow rowData: AccountRowData, hideSeparator: Bool = false) {
		showData(forRow: rowData, hideSeparator: hideSeparator)
	}

	func showData(forRow rowData: AccountRowData, hideSeparator: Bool = false) {
		lblTitle.text = rowData.key
		let value = rowData.value as? String
		lblValue.text =  value
        lblTitle.textColor = UIColor.secondaryColor
	}

	func configureContactCell(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
		showContactData(forRow: rowData, hideSeparator: hideSeparator)
	}

	func showContactData(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        if rowData.key == Utility.localizedString(forKey: "pay_row_amount") {
            lblValue.textColor = UIColor.primaryColor
        }
		if Utility.isDeviceIpad() {
			imgSeperator.isHidden = false
			imgSeperator.backgroundColor = .customSeparatorColor
		}
		lblTitle.text = rowData.key
		let value = rowData.value as? String
		lblValue.text = value
	}

    // FOR CARD...
    func configureCardCell(forRow rowData: CardRowData, hideSeparator: Bool = false) {
        showCardData(forRow: rowData, hideSeparator: hideSeparator)
    }

    func showCardData(forRow rowData: CardRowData, hideSeparator: Bool = false) {
        lblTitle.text = rowData.key
        let value = rowData.value as? String
        lblValue.text =  value
        
        if Utility.isDeviceIpad() {
            imgSeperator.isHidden = false
            imgSeperator.backgroundColor = .customSeparatorColor
        }
    }

    // FOR TRANSACTION..
    func configureTransactionCell(forRow rowData: TransactionRowData, hideSeparator: Bool = false) {
        showTransactionData(forRow: rowData, hideSeparator: hideSeparator)
    }

    func showTransactionData(forRow rowData: TransactionRowData, hideSeparator: Bool = false) {
        if rowData.key == Utility.localizedString(forKey: "viewPDF") {
            lblValue.textColor = UIColor.primaryColor
        }
        lblTitle.text = rowData.key
        let value = rowData.value as? String
        lblValue.text = value
    }

	func configureProfileCell(forRow rowData: UserProfileRowData, hideSeparator: Bool = false) {
		showProfileData(forRow: rowData, hideSeparator: hideSeparator)
	}

	func showProfileData(forRow rowData: UserProfileRowData, hideSeparator: Bool = false) {
	    lblDescription.text = ""
		lblDescription.isHidden = true
		let value = rowData.value as? String
		lblValue.text =  value
		lblTitle.text = rowData.key
        lblValue.textAlignment = .left
        
        lblTitle.textColor = UIColor.secondaryColor
        lblValue.textColor = UIColor.primaryColor
        
        if Utility.isDeviceIpad() {
            imgSeperator.isHidden = false
            imgSeperator.backgroundColor = .customSeparatorColor
        }
	}

    // FUND..
    func configureFundCell(forRow rowData: ContactRowData) {
        showFundData(forRow: rowData)
    }

    func showFundData(forRow rowData: ContactRowData) {
        lblTitle.text = rowData.key
        let value = rowData.value as? String
        lblValue.text = value

        if rowData.key == Utility.localizedString(forKey: "acc_detail_num_title") || rowData.key == Utility.localizedString(forKey: "acc_detail_rout_title") {
            imgVwAccessory.isHidden =  false
            imgVwAccessory.image = UIImage(named: "copy_black")
            imgVwAccessory.isUserInteractionEnabled = true
            let gestureReco = UITapGestureRecognizer(target: self, action: #selector(copyClick))
            imgVwAccessory.addGestureRecognizer(gestureReco)
        }
    }

    @objc func copyClick() {
        self.makeToast(Utility.localizedString(forKey: "cardNumber_copied"), duration: 1.3)
    }

    func configurePullFundsSuccessCell(forRow rowData: ContactRowData) {
        lblTitle.text = rowData.key
        let value = rowData.value as? String
        lblValue.text = value
        
        if Utility.isDeviceIpad() {
            imgSeperator.isHidden = false
            imgSeperator.backgroundColor = .customSeparatorColor
        }
    }
}
