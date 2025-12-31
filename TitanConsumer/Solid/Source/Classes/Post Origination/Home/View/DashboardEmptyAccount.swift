//
//  DashboardEmptyAccount.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit

class DashboardEmptyAccount: UICollectionViewCell {

    @IBOutlet weak var dashContainerView: UIView!
    @IBOutlet weak var dashedView: UIView!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var imgAdd: BaseImageView!

    func configureUI() {
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
		lbltitle.font = labelFont
        lbltitle.text = Utility.localizedString(forKey: "create_Account")
        lbltitle.textColor = UIColor.secondaryColor
        imgAdd.image = UIImage(named: "add_filled")
        imgAdd.backgroundColor = .clear
    }
}
