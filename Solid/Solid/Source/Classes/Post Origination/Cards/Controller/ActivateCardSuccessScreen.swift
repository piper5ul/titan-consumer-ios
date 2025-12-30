//
//  ActivateCardSuccessScreen.swift
//  Solid
//
//  Created by Solid iOS Team on 3/10/21.
//

import Foundation
import UIKit

class ActivateCardSuccessScreen: BaseVC {
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblDetails: UILabel!
	@IBOutlet weak var vwAnimationContainer: BaseAnimationView?

    var cardData: CardModel?

	override func viewDidLoad() {
		super.viewDidLoad()
		setUI()
        self.setFooterUI()
	}

	func setUI() {
        self.isNavigationBarHidden = true
		isScreenModallyPresented = true
		self.lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 24)
        self.lblTitle.textColor = UIColor.primaryColor
        lblTitle.text = Utility.localizedString(forKey: "card_activate_success_title")
		let lblDetailsFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
		self.lblDetails.font = lblDetailsFont
        self.lblDetails.textColor = UIColor.secondaryColorWithOpacity
        lblDetails.text = Utility.localizedString(forKey: "card_activate_success_desc")
		vwAnimationContainer?.animationFile = "success"
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "done"))
        footerView.btnApply.addTarget(self, action: #selector(btnDoneClicked(sender:)), for: .touchUpInside)
    }

	@IBAction func btnDoneClicked(sender: UIButton) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterStatusChange), object: nil)
        let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CardInfoVC") as? CardInfoVC {
            vc.cardModel = self.cardData
            self.show(vc, sender: self)
        }
	}
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.lblTitle.textColor = UIColor.primaryColor
        self.lblDetails.textColor = UIColor.secondaryColorWithOpacity
    }
}
