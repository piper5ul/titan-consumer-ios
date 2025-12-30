//
//  AccountsListSectionHeader.swift
//  Solid
//
//  Created by Solid iOS Team on 12/01/22.
//

import Foundation
import UIKit

class AccountsListSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAccountTotal: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var imgViewAll: BaseImageView!
    @IBOutlet weak var lblViewAll: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!

    override func awakeFromNib() {
        lblTitle.font = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblTitle.textColor = UIColor.primaryColor
        lblTitle.textAlignment = .left
        lblTitle.letterSpace = 0.28

        lblBalance.font = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblBalance.textColor = UIColor.primaryColor
        lblBalance.textAlignment = .right
        lblBalance.letterSpace = 0.28

        lblAccountTotal.font = Utility.isDeviceIpad() ? Constants.regularFontSize14: Constants.regularFontSize12
        lblAccountTotal.textColor = UIColor.secondaryColor
        lblAccountTotal.textAlignment = .left
        
        lblViewAll.font = Utility.isDeviceIpad() ? Constants.regularFontSize16: Constants.regularFontSize14
        lblViewAll.textColor = UIColor.secondaryColor
        lblViewAll.textAlignment = .right        
        btnViewAll.setTitle("", for: .normal)
        
        lblViewAll.text = Utility.localizedString(forKey: "dashboard_section_viewAll")
        imgViewAll.image = UIImage(named: "Chevron-right")
        imgViewAll.customTintColor = UIColor.secondaryColorWithOpacity
        
        self.contentView.backgroundColor = .grayBackgroundColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblBalance.textColor = UIColor.primaryColor
        lblViewAll.textColor = UIColor.secondaryColor
        lblAccountTotal.textColor = UIColor.secondaryColor
        imgViewAll.customTintColor = .secondaryColor
    }
}
