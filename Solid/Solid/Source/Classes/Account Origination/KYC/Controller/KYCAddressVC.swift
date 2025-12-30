//
//  KYCAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 09/02/21.
//

import UIKit

class KYCAddressVC: BaseAddressVC {

    var detailsModel = KYCPersonDetailsModel()
    var kycStatus: KYCStatus?
    var hostedURL: String = ""
    var fromIDV = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.filter.country = Utility.getGooglePlacesFilterCountry()
        super.setAddressData(address: AppGlobalData.shared().personData.address ?? Address())
        
        self.tblAddress.reloadData()
        self.tblAddress.backgroundColor = .clear

        self.title = Utility.localizedString(forKey: "kyc_address_NavTitle")

        setFooterUI()
        addProgressbar(percentage: 40)
        super.validate()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(updatePerson), for: .touchUpInside)
    }
    
    func gotoPersonaVerificationScreen() {
        self.performSegue(withIdentifier: "GoToVerifyPersonaVC", sender: self)
    }
    
    func gotoKYCStatusScreen() {
        self.performSegue(withIdentifier: "GotoKYCStatusScreen", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoKYCStatusScreen", let kycStatusVC = segue.destination as? KYCStatusVC {
            kycStatusVC.kycStatus = kycStatus
            kycStatusVC.isIDVCheck = fromIDV
        } else if segue.identifier == "GoToVerifyPersonaVC", let verifyPersonaVC = segue.destination as? VerifyPersonaVC {
            verifyPersonaVC.hostedURL = hostedURL
        }
    }
}

// MARK: - API
extension KYCAddressVC {

    @objc func updatePerson() {
        self.view.endEditing(true)
        
        let personID = AppGlobalData.shared().personData.id!
        
        let updateKYCPostBody = super.getUpdatePersonPostBody(detailsModel: detailsModel)
        
        self.activityIndicatorBegin()
        
        UpdatePersonViewModel.shared.updatePersonDetail(personId: personID, userData: updateKYCPostBody) { (response, errorMessage) in
            
            self.activityIndicatorEnd()
            
            if let _ = response {
                self.callAPIToGetHostedURL()
            } else {
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                }
            }
        }
    }
    
    func callAPIToGetHostedURL() {
        if let _ = AppGlobalData.shared().personId {
            self.activityIndicatorBegin()
            
            KYCViewModel.shared.getPersonaHostedURL { (response, errorMessage) in
                self.activityIndicatorEnd()

                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let data = response, let idvStatus = data.status {
                        if idvStatus == "approved" {
                           self.callSubmitKYCAPI()
                        } else if idvStatus != "notStarted" {
                            self.fromIDV = true
                            self.kycStatus = idvStatus == "declined" ? .declined : .inReview
                            self.gotoKYCStatusScreen()
                        } else if let hostedUrl = data.url, !hostedUrl.isEmpty {
                            self.hostedURL = hostedUrl
                            self.gotoPersonaVerificationScreen()
                        }
                    }
                }
            }
        }
    }
    
    func callSubmitKYCAPI() {
        if let _ = AppGlobalData.shared().personId {
            self.activityIndicatorBegin()
            self.activityIndicator.color = .black

            KYCViewModel.shared.submitKYCCall { (kycResponse, errorMessage) in

                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let response = kycResponse {
                        self.kycStatus = response.status
                        self.gotoKYCStatusScreen()
                    }
                }
            }
        }
    }
}
