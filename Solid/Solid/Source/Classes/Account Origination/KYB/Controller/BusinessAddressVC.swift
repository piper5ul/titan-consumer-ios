//
//  BusinessAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 12/02/21.
//

import UIKit

class BusinessAddressVC: BaseAddressVC {
    var businessData = BusinessDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.filter.country = Utility.getGooglePlacesFilterCountry()
        super.setAddressData(address: businessData.address ?? Address())
        
        self.title = Utility.localizedString(forKey: "kyb_address_NavTitle")
        
        self.setFooterUI()
        addProgressbar(percentage: 70)
        super.validate()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(callUpdateBusinessAPI), for: .touchUpInside)
    }
}

// MARK: - Data Methods
extension BusinessAddressVC {
    @objc func callUpdateBusinessAPI() {
        self.view.endEditing(true)
        
        if let bisunessID = self.businessData.id {
            self.updateBusiness(bId: bisunessID)
        }
    }
    
    func goToAddOwnershipPercentageVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddOwnershipPercentageVC") as? AddOwnershipPercentageVC {
            vc.ownerFlow = .mainOwner
            self.show(vc, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    func goToOwnersListVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OwnersListVC") as? OwnersListVC {
            self.show(vc, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
}

// MARK: - API
extension BusinessAddressVC {
    //Update Business
    func updateBusiness(bId: String) {
        var postBody = CreateBusinessPostBody()
        
        if let phone = AppGlobalData.shared().personData.phone, let email = AppGlobalData.shared().personData.email {
            postBody.phone = phone
            postBody.email = email
            postBody.idNumber = businessData.idNumber
            postBody.idType = TaxType.ein.rawValue
            postBody.address = super.getPostAddressData()
            
            self.activityIndicatorBegin()
            
            KYBViewModel.shared.updateBusiness(businessId: bId, businessData: postBody) { (response, errorMessage) in
                
                self.activityIndicatorEnd()
                
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let businessResponse = response, let _ = businessResponse.id {
                        if businessResponse.entityType?.isSoleSingleEntitiy ?? false {
                            self.goToOwnersListVC()
                        } else {
                            self.goToAddOwnershipPercentageVC()
                        }
                    }
                }
            }
        }
    }
}
