//
//  CurrencyEntryCell.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation
import UIKit

protocol CurrencyEntryCellDelegate: AnyObject {

    func amountEntered(amount: Double)
}

class CurrencyEntryCell: UITableViewCell, CurrencyDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtFieldAmount: CurrencyTextField!

    weak var delegate: CurrencyEntryCellDelegate?

    override func awakeFromNib() {
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        lblTitle.font = labelFont
        lblTitle.textColor = UIColor.secondaryColor
        lblTitle.textAlignment = .left

        txtFieldAmount.delegateCurreny = self
        
        self.backgroundColor = .clear
    }

    func configureCellForIntrabankPay(dataModel: ContactRowData) {
        lblTitle.text = dataModel.key
        txtFieldAmount.font =  Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        txtFieldAmount.setDefault(value: (dataModel.value as? String) ?? "")
//        txtFieldAmount.text = (dataModel.value as? String) ?? ""
        txtFieldAmount.placeholder = dataModel.placeholder
        if dataModel.textfieldType == TextFieldType.currency {
            txtFieldAmount.addDoneButtonOnKeyboard()
        }

        //txtFieldAmount.borderWidth = 0.5
        //txtFieldAmount.borderColor = .secondaryColorWithOpacity
        txtFieldAmount.layer.cornerRadius = Constants.cornerRadiusThroughApp
        txtFieldAmount.layer.masksToBounds = true
    }

    func current(amount: Double) {
        delegate?.amountEntered(amount: amount)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.secondaryColor
        
        //txtFieldAmount.textColor = ui
    }
}
