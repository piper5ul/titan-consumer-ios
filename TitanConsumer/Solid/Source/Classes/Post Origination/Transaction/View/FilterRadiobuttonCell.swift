//
//  FilterRadiobuttonCell.swift
//  Solid
//
//  Created by Solid iOS Team on 16/03/21.
//

import UIKit

protocol RadiobuttonCellDelegate: AnyObject {
    func selectedRadioButton(cell: FilterRadiobuttonCell)
}

class FilterRadiobuttonCell: UITableViewCell {

    @IBOutlet var radioButton: UIButton!
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var radioButtonLeadingConstraint: NSLayoutConstraint!

    weak var radioDelegate: RadiobuttonCellDelegate?

    var isRadiobuttonSelected: Bool? {
        didSet {
            radioButton.isSelected = isRadiobuttonSelected ?? false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.backgroundColor = .clear
		let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        self.titleLabel?.font = titleFont
        self.titleLabel?.textColor = UIColor.primaryColor

        self.radioButton.setImage(UIImage(named: "radioButton_deselected"), for: .normal)
        self.radioButton.setImage(UIImage(named: "radioButton_selected"), for: .selected)
        self.radioButton.backgroundColor = .clear
        self.radioButton.imageView?.tintColor = .brandColor
    }

    @IBAction func radioButtonSelected(sender: UIButton) {

        if !sender.isSelected {
            sender.isSelected = true

            radioDelegate?.selectedRadioButton(cell: self)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.radioButton.imageView?.tintColor = .brandColor
        self.titleLabel?.textColor = UIColor.primaryColor
    }
}

// MARK: - Spend limit
extension FilterRadiobuttonCell {

    // SPEND LIMIT
    func configureForSpendLimit(spendLimit: CardSpendLimitTypes, isSelected: Bool) {
        titleLabel.text = spendLimit.localizeDescription()
        isRadiobuttonSelected = isSelected
        radioButtonLeadingConstraint.constant = 16
    }
    
    //ADD ACCOUNT
    func configureForAddAccount(title: String, isSelected: Bool) {
        titleLabel.text = title
        isRadiobuttonSelected = isSelected
        radioButtonLeadingConstraint.constant = 0
    }
}
