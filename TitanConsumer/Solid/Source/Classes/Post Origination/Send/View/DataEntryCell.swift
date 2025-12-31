//
//  DataEntryCell.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation
import UIKit

class DataEntryCell: CustomTableViewCell {

    override func awakeFromNib() {

		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        titleLabel?.font = labelFont
        titleLabel?.textColor = UIColor.secondaryColor
        titleLabel?.textAlignment = .left

        inputTextField?.font = UIFont.sfProDisplayRegular(fontSize: 14.0)
        inputTextField?.textAlignment = .left
        inputTextField?.textColor = .primaryColor

        inputTextField?.borderWidth = 0.5
        inputTextField?.borderColor = .secondaryColorWithOpacity
        inputTextField?.layer.cornerRadius = Constants.cornerRadiusThroughApp
        inputTextField?.layer.masksToBounds = true
    }

    func configureCellForIntrabankPay(dataModel: ContactRowData) {
        titleLabel?.text = dataModel.key

        inputTextField?.text = (dataModel.value as? String) ?? ""
        inputTextField?.placeholderString = dataModel.placeholder
    }
}
