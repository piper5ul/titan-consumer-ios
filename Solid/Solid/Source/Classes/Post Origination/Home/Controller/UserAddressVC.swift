//
//  UserAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 4/19/21.
//

import Foundation
import UIKit

class UserAddressVC: BaseAddressVC {

	var detailsModel = KYCPersonDetailsModel()

	override func viewDidLoad() {
		super.viewDidLoad()
        super.filter.country = Utility.getGooglePlacesFilterCountry()
		super.setAddressData(address: AppGlobalData.shared().personData.address ?? Address())
        
		self.title = Utility.localizedString(forKey: "kyc_address_NavTitle")

        setFooterUI()

        super.validate()
	}

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "Done"))
        footerView.btnApply.addTarget(self, action: #selector(updatePerson), for: .touchUpInside)
    }
}

//MARK:- API
extension UserAddressVC {

    @objc func updatePerson() {
		let personID = AppGlobalData.shared().personData.id!
        var updateUserPostBody = UpdatePersonPostBody()
        updateUserPostBody.address = self.getPostAddressData()
        
		self.activityIndicatorBegin()
		UpdatePersonViewModel.shared.updatePersonDetail(personId: personID, userData: updateUserPostBody) { (response, errorMessage) in
			self.activityIndicatorEnd()
			if (response) != nil {
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloaduserProfile), object: nil)
				self.popVC()
            } else {
				if let error = errorMessage {
					self.showAlertMessage(titleStr: error.title, messageStr: error.body )
				}
			}
		}
	}
}
