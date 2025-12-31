//
//  DashboardEmptyCard.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit

class DashboardEmptyCard: UICollectionViewCell {
	@IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dashContainerView: UIView!
    @IBOutlet weak var dashedView: UIView!
    @IBOutlet weak var btnCreateCard: BaseButton!
    @IBOutlet weak var lbltitle: UILabel!
	@IBOutlet weak var cellWidth: NSLayoutConstraint!

    func configureUI() {
//        self.backgroundColor = .clear

        containerView.backgroundColor = .background
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
		lbltitle.font = labelFont
        lbltitle.text = Utility.localizedString(forKey: "card_add_label")
        lbltitle.textColor = UIColor.primaryColor

        btnCreateCard.cornerRadius = btnCreateCard.frame.height/2
        btnCreateCard.borderColor = UIColor.brandColor
        btnCreateCard.borderWidth = 1.0
        btnCreateCard.setImage(UIImage(named: "AddIcon")?.maskWithColor(color: UIColor.brandColor), for: .normal)
        btnCreateCard.backgroundColor = UIColor.clear

        dashContainerView.layer.cornerRadius = Constants.cornerRadiusThroughApp + 2
		containerView.layer.cornerRadius = Constants.cornerRadiusThroughApp + 4
		containerView.layer.masksToBounds = true
        dashContainerView.layer.masksToBounds = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.dashedView.addDashedBorder()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        btnCreateCard.borderColor = .primaryColor
        lbltitle.textColor = UIColor.primaryColor
        btnCreateCard.setImage(UIImage(named: "AddIcon")?.maskWithColor(color: UIColor.brandColor), for: .normal)
        self.dashedView.addDashedBorder()
    }
}
