//
//  FundLinkedAccountCell.swift
//  Solid
//
//  Created by Solid iOS Team on 05/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class FundLinkedAccountCell: UITableViewCell {

    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var radioButton: BaseButton!
    @IBOutlet weak var btnRemove: BaseButton!

    var isRadiobuttonSelected: Bool? {
        didSet {
            radioButton.isSelected = isRadiobuttonSelected ?? false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setThemeColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setThemeColor() {
        let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize14
        lblAccountName.font = labelFont
        lblAccountName.textAlignment = .left
        let attrs = [
            NSAttributedString.Key.font: labelFont,
            NSAttributedString.Key.foregroundColor: UIColor.primaryColor,
            NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]
        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitleStr = NSMutableAttributedString(string: Utility.localizedString(forKey: "pull_fund_removelinkAccount_btnTitle"), attributes: attrs)
        attributedString.append(buttonTitleStr)
        btnRemove.setAttributedTitle(attributedString, for: .normal)
        btnRemove.backgroundColor = .clear

        self.radioButton.setImage(UIImage(named: "radioButton_deselected"), for: .normal)
        self.radioButton.setImage(UIImage(named: "radioButton_selected"), for: .selected)
        self.radioButton.backgroundColor = .clear
        self.radioButton.imageView?.tintColor = .brandColor
        
        self.backgroundColor = .clear
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setThemeColor()
    }
}
