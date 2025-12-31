//
//  UserBusinessAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 4/19/21.
//

import Foundation

import UIKit

class UserBusinessAddressVC: BaseAddressVC {

	var businessData = BusinessDataModel()

	override func viewDidLoad() {
		super.viewDidLoad()
        super.filter.country = Utility.getGooglePlacesFilterCountry()
		super.setAddressData(address: businessData.address ?? Address())

		self.title = Utility.localizedString(forKey: "kyb_address_NavTitle")

        setFooterUI()

        super.validate()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "Done"))
        footerView.btnApply.addTarget(self, action: #selector(updateBusinessAddress), for: .touchUpInside)
    }
    
    @objc func updateBusinessAddress() {
        if let bisunessID = self.businessData.id {
            self.updateBusiness(bId: bisunessID)
        }
    }
}

// MARK: - API
extension UserBusinessAddressVC {
	// Update Business
	func updateBusiness(bId: String) {
		var updateBusinessPostBody = CreateBusinessPostBody()
		if let phone = AppGlobalData.shared().personData.phone, let email = AppGlobalData.shared().personData.email {
            updateBusinessPostBody.phone = phone
            updateBusinessPostBody.email = email
            updateBusinessPostBody.idNumber = businessData.idNumber
            updateBusinessPostBody.idType = TaxType.ein.rawValue
            updateBusinessPostBody.address = super.getPostAddressData()
			
			self.activityIndicatorBegin()
			KYBViewModel.shared.updateBusiness(businessId: bId, businessData: updateBusinessPostBody) { (response, errorMessage) in
				self.activityIndicatorEnd()
				if let error = errorMessage {
					self.showAlertMessage(titleStr: error.title, messageStr: error.body )
				} else {
                    if let businessResponse = response, let _ = businessResponse.id {
						NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadbusiness), object: nil)
						self.popVC()
					}
				}
			}
		}
	}
}
