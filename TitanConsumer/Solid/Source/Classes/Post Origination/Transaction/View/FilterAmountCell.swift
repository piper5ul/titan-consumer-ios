//
//  FilterAmountCell.swift
//  Solid
//
//  Created by Solid iOS Team on 16/03/21.
//

import UIKit

protocol AmountCellDelegate: AnyObject {
    func fromAmount(amount: String)
    func toAmount(amount: String)
}

class FilterAmountCell: UITableViewCell, CurrencyDelegate {

    @IBOutlet var txtFrom: CurrencyTextField!
    @IBOutlet var txtTo: CurrencyTextField!

    @IBOutlet var lblFrom: UILabel!
    @IBOutlet var lblTo: UILabel!

    weak var amountCellDelegate: AmountCellDelegate?
    var currentFieldType: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.backgroundColor = .clear
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12

        self.lblFrom?.font = labelFont
        self.lblFrom?.textColor = UIColor.secondaryColor

        self.lblTo?.font = labelFont
        self.lblTo?.textColor = UIColor.secondaryColor

        self.lblFrom?.text = Utility.localizedString(forKey: "from")
        self.lblTo?.text = Utility.localizedString(forKey: "to")

        txtFrom.delegateCurreny = self
        txtTo.delegateCurreny = self

        self.txtFrom.tfDecimalLimit = Constants.cardSpendDigitsLimit
        self.txtTo.tfDecimalLimit = Constants.cardSpendDigitsLimit

        txtFrom.addDoneButtonOnKeyboard()
        txtTo.addDoneButtonOnKeyboard()

		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        self.txtFrom?.font = titleFont
        self.txtTo?.font = titleFont

        self.txtFrom.delegate = self
        self.txtTo.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func current(amount: Double) {

        if currentFieldType == "from"{
            amountCellDelegate?.fromAmount(amount: amount.toString())
        } else {
            amountCellDelegate?.toAmount(amount: amount.toString())
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.lblFrom?.textColor = UIColor.secondaryColor
        self.lblTo?.textColor = UIColor.secondaryColor
    }
}

// MARK: - UITextField
extension FilterAmountCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == txtFrom {
            currentFieldType = "from"
        } else {
            currentFieldType = "to"
        }

        return true
    }
}
