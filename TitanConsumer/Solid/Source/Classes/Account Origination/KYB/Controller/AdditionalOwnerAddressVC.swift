//
//  AdditionalOwnerAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 24/02/21.
//

import UIKit

class AdditionalOwnerAddressVC: BaseAddressVC {

    var detailsModel = KYCPersonDetailsModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        let strCountryCode = detailsModel.phone?.countryCode() ??  AppGlobalData.shared().selectedCountryCode
        let strCountry = Utility.getCountry(forCountryCode: strCountryCode)
        super.filter.country = strCountry
        
        self.title = Utility.localizedString(forKey: "kyc_address_NavTitle")

        self.setFooterUI()

        super.strPhoneNumber = detailsModel.phone ?? ""
        super.validate()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(goToAddOwnershipPercentageVC), for: .touchUpInside)
    }
}

// MARK: - Data Methods
extension AdditionalOwnerAddressVC {

    @objc func goToAddOwnershipPercentageVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddOwnershipPercentageVC") as? AddOwnershipPercentageVC {
            vc.ownerFlow = .additionalOwner
            vc.addressData = super.getPostAddressData()
			vc.detailsModel = self.detailsModel
            self.show(vc, sender: self)
			self.modalPresentationStyle = .fullScreen
        }
    }
}
