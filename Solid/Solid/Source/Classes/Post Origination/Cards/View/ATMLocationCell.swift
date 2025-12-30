//
//  ATMLocationCell.swift
//  Solid
//
//  Created by Solid iOS Team on 17/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit

class ATMLocationCell: UITableViewCell {
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameInital: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgSeperator: UIImageView!
    
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInitialWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        innerView.backgroundColor = .background
        outerView.backgroundColor = .clear
        self.backgroundColor = .clear

        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        let descFont = Utility.isDeviceIpad() ? Constants.mediumFontSize14: Constants.mediumFontSize12

        self.lblName.font = labelFont
        self.lblName.textColor = UIColor.primaryColor
        self.lblAddress.font = descFont
        self.lblAddress.textColor = UIColor.secondaryColor

        self.lblNameInital.font = labelFont
        self.lblNameInital.textColor = .brandColor

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblNameInital.textColor = .brandColor
        self.lblName.textColor = UIColor.primaryColor
        self.lblAddress.textColor = UIColor.secondaryColor
    }

    func configureCard(frontData: ATMLocationsAddress) {
        lblName.text = frontData.name
        lblNameInital.text = frontData.iconImageLetter?.uppercased()
        lblNameInital.layer.cornerRadius = Constants.cornerRadiusThroughApp
        lblNameInital.layer.masksToBounds = true
        lblNameInital.backgroundColor = UIColor.grayBackgroundColor
        lblNameInital.textColor = .brandColor
        lblAddress.text = frontData.description
        innerView.backgroundColor = .background
        self.backgroundColor = .clear
        
     }
}
