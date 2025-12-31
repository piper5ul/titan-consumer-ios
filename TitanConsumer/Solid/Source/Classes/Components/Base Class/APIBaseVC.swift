//
//  APIBaseVC.swift
//  Solid
//
//  Created by Solid iOS Team on 23/06/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit

class APIBaseVC: UIBaseVC {

}

// MARK: - API Calls
extension APIBaseVC {

    func getPersonDetails(completion: @escaping (_ personResponse: PersonResponseBody?, AlertMessage?) -> Void) {

        PersonViewModel.shared.getPersonDetail { (personseResponseBody, errorMessage) in
            if let error = errorMessage {
                completion(nil, error)
                return
            } else {
                if let personData = personseResponseBody, let persondId = personData.id {

                    AppGlobalData.shared().personId = persondId
                    AppGlobalData.shared().personData = personData

                    self.identifyUser()

                    completion(personData, nil)
                    return
                }
            }
            completion(nil, nil)
        }
    }

    func getProgramDetails(programId: String, completion: @escaping (_ programRes: ProgramModel?, AlertMessage?) -> Void) {

        ProgramViewModel.shared.getProgramDetails(programId: programId) { (progRes, errorMessage) in
            if let error = errorMessage {
                completion(nil, error)
            } else {
                if let _ = progRes {
                    completion(progRes, nil)
                    return
                } else {
                    completion(nil, nil)
                }
            }
        }
    }

    func checkKYBStatus(businessId: String?, completion: @escaping (_ kybResponse: KYBStatusResponseBody?) -> Void) {

        KYBViewModel.shared.getKybstatus(businessId: businessId ?? "") { (response, errorMessage) in
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                completion(nil)
                return
            } else {
                if let businessData = response, let _ = businessData.status {
                    completion(businessData)
                    return
                }
            }
            completion(nil)
        }
    }

    func getBusinessFromList(_ completion: @escaping (BusinessDataModel?, AlertMessage?) -> Void) {

        KYBViewModel.shared.getbusinessList { (businessList, errorMessage) in
            if let error = errorMessage {
                completion(nil, error)
            } else {
                if let businessList = businessList?.data, businessList.count > 0 {
                    let businessData = businessList.first
                    // AppGlobalData.shared().businessId = businessData?.id
                    AppGlobalData.shared().businessData = businessData
                    AppGlobalData.shared().allBusiness = businessList
                    completion(businessData, nil)
                    return
                } else {
                    completion(nil, nil)
                    return
                }
            }
        }
    }

    func getAccountFromList(_ completion: @escaping (AccountDataModel?, AlertMessage?) -> Void) {

        let businessId = AppGlobalData.shared().businessData?.id ?? ""
        AccountViewModel.shared.getAccountList(businessId: businessId) { (accountList, errorMessage) in
            if let error = errorMessage {
                //                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                completion(nil, error)
            } else {
                if let accountList = accountList?.data, accountList.count > 0 {

                    AppGlobalData.shared().accountList = accountList

                    let accountData = accountList.first
                    if let aData = accountData {
                        AppGlobalData.shared().accountData = aData
                    }
                    completion(accountData, nil)
                    return
                } else {
                    completion(nil, nil)
                    return
                }
            }
        }
        // }
    }

    func getCardsList(limit: String, offset: String, _ completion: @escaping (CardsListResponseBody?, AlertMessage?) -> Void) {
        if let accountId = AppGlobalData.shared().accountData?.id {
            CardViewModel.shared.getcardList(accountId: accountId, limit: limit, offset: offset) { (cardlist, errorMessage) in
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                    completion(nil, error)
                } else {
                    if let cardsList = cardlist?.data, cardsList.count > 0 {
                        completion(cardlist, nil)
                        return
                    } else {
                        completion(nil, nil)
                        return
                    }
                }
            }
        }
    }

    func getDashboardCardsList(_ completion: @escaping (CardsListResponseBody?, AlertMessage?) -> Void) {
        if let accountId = AppGlobalData.shared().accountData?.id {
            CardViewModel.shared.getcardList(accountId: accountId, limit: "25", offset: "0") { (cardlist, errorMessage) in
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                    completion(nil, error)
                } else {
                    if let cardsList = cardlist?.data, cardsList.count > 0 {
                        AppGlobalData.shared().cardList = cardsList
                        completion(nil, nil)
                        return
                    } else {
                        AppGlobalData.shared().cardList = [CardModel]()
                        completion(nil, nil)
                        return
                    }
                }
            }
        }
    }
    
    func getContactList(type: String, limit: String, offset: String, _ completion: @escaping (ContactListResponseBody?, AlertMessage?) -> Void) {
        if let accountId = AppGlobalData.shared().accountData?.id {
        ContactViewModel.shared.getContactList(accountId: accountId, type: type, limit: limit, offset: offset) { (response, errorMessage) in
            
            if let error = errorMessage {
                completion(nil, error)
            } else {
                completion(response, nil)
            }
        }
      }
    }
    
    func getDashboardContactsList(_ completion: @escaping (ContactListResponseBody?, AlertMessage?) -> Void) {
        if let accountId = AppGlobalData.shared().accountData?.id {
        ContactViewModel.shared.getContactList(accountId: accountId, type: "others", limit: "\(Constants.fetchLimit)", offset: "0") { (response, errorMessage) in
            
            if let error = errorMessage {
                completion(nil, error)
            } else {
                if let contactsList = response?.data, contactsList.count > 0 {
                    AppGlobalData.shared().contactList =  contactsList.sorted(by: { $0.name?.lowercased() ?? ""  < $1.name?.lowercased()  ?? ""})
                    completion(nil, nil)
                } else {
                    AppGlobalData.shared().contactList = [ContactDataModel]()
                    completion(nil, nil)
                }
            }
        }
      }
    }

    func getPersonDetail(showAutoLockWithVC: UIViewController) {
        self.activityIndicatorBegin()

        self.getPersonDetails { (personData, _) in
            if let personData = personData, let kyc = personData.kyc, let kycStatus = kyc.status {

                AppGlobalData.shared().personData = personData
                if let programId = personData.programId/*, false*/ {

                    self.getProgramDetails(programId: programId) { (prgModel, _) in
                        if let programModel = prgModel {
                            AppMetaDataHelper.shared.updateProgramData(programData: programModel)
                            AppGlobalData.shared().programData = programModel
                            self.kycStatusCheck(kycStatus: kycStatus, showAutoLockWithVC: showAutoLockWithVC)
                        } else {
                            // Not valid program
                        }
                    }
                } else {
                    self.kycStatusCheck(kycStatus: kycStatus, showAutoLockWithVC: showAutoLockWithVC)
                }
            }
        }
    }

    func kycStatusCheck(kycStatus: KYCStatus, showAutoLockWithVC: UIViewController) {

        let prgModel = AppGlobalData.shared().programData

        if let bank = prgModel.bank, let accountType = bank.accountType, let personChecking = accountType.personalChecking, let businessChecking = accountType.businessChecking, let bothBusinessAndPersonalChecking = accountType.bothBusinessAndPersonalChecking {
            // AOTO LOGIN CODE
            switch kycStatus {
            case .approved:
                self.getAccountFromList { (_, _) in
                    self.activityIndicatorEnd()
                    if AppGlobalData.shared().accountList?.count ?? 0 > 0 {
                        self.gotoHomeScreen()
                    } else if bothBusinessAndPersonalChecking || personChecking {
                        self.createAutoLockPINforKYC(showAutoLockWithVC: showAutoLockWithVC, with: kycStatus)
                    } else if businessChecking {
                        self.getBusinessDetails(with: kycStatus, showAutoLockWithVC: showAutoLockWithVC)
                    }
                }
            case .notStarted:
                self.activityIndicatorEnd()
                self.gotoLoginCreatedScreen()
            default:
                self.activityIndicatorEnd()
                self.createAutoLockPINforKYC(showAutoLockWithVC: showAutoLockWithVC, with: kycStatus)
            }
        }
    }

    func getBusinessDetails(with kycStatus: KYCStatus, showAutoLockWithVC: UIViewController) {
        self.activityIndicatorBegin()
        self.getBusinessFromList { (businessData, _) in
            self.activityIndicatorEnd()
            if let aBusinessData = businessData, let kyb = aBusinessData.kyb, let kybStatus = kyb.status {
                if kybStatus == .approved {
                    self.getAccountDetails(showAutoLockWithVC: showAutoLockWithVC, aBusinessData: aBusinessData, kybStatus: kybStatus)
                } else {
                    self.createAutoLockPINforKYB(showAutoLockWithVC: showAutoLockWithVC, aKybStatus: kybStatus, aBusinessData: aBusinessData)
                }
            } else {
                self.createAutoLockPINforKYC(showAutoLockWithVC: showAutoLockWithVC, with: kycStatus)
            }
        }
    }

    func getAccountDetails(showAutoLockWithVC: UIViewController, aBusinessData: BusinessDataModel, kybStatus: KYBStatus) {

        self.activityIndicatorBegin()

        self.getAccountFromList { (accountData, _) in

            self.activityIndicatorEnd()

            if let accData = accountData, let _ = accData.id {
                AppGlobalData.shared().appFlow = .PO
                self.gotoHomeScreen()
            } else {
                self.createAutoLockPINforAccount(showAutoLockWithVC: showAutoLockWithVC, aKybStatus: kybStatus, aBusinessData: aBusinessData)
            }
        }
    }

    // Get Business Details
    func getBusinessDetails(_ completion: @escaping (BusinessDataModel?, AlertMessage?) -> Void) {
        if let businessId = AppGlobalData.shared().businessData?.id { // AppGlobalData.shared().businessId {

            KYBViewModel.shared.getBusinessDetails(businessId: businessId) { (response, errorMessage) in
                if let error = errorMessage {
                    completion(nil, error)
                } else {
                    if let businessData = response {
                        completion(businessData, nil)
                        return
                    } else {
                        completion(nil, nil)
                        return
                    }
                }
            }
        }
    }

    func fetchAccountList() {
        var businessId = ""
        if AppGlobalData.shared().selectedAccountType == AccountType.businessChecking {
            businessId = AppGlobalData.shared().businessData?.id ?? ""
        }
        AccountViewModel.shared.getAccountList(businessId: businessId) { (accountList, _) in
            if let accList = accountList, let accListData = accList.data, accListData.count > 0 {
                AppGlobalData.shared().accountList = accListData
            }
        }
    }
    
    func getAccountDetails(for accId: String, _ completion: @escaping (AccountDataModel?, AlertMessage?) -> Void) {
        self.activityIndicatorBegin()
        AccountViewModel.shared.getaccountDetail(accountId: accId) { (accountDataModel, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                //                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                completion(nil, error)
                return
            } else {
                AppGlobalData.shared().accountData = accountDataModel
                completion(accountDataModel, nil)
                return
            }
        }
    }

    func getOwners(_ completion: @escaping (OwnerListResponseBody?, AlertMessage?) -> Void) {
        if let businessId = AppGlobalData.shared().businessData?.id { // AppGlobalData.shared().businessId {
            OwnerViewModel.shared.getOwnerList(businessId: businessId) { (ownerList, errorMessage) in
                if let error = errorMessage {
                    completion(nil, error)
                } else {
                    if let  ownerL = ownerList?.data, ownerL.count > 0 {
                        AppGlobalData.shared().ownerList = ownerL
                        for (_, owner) in ownerL.enumerated() {
                            if owner.person?.id == AppGlobalData.shared().personId {
                                AppGlobalData.shared().ownerData = owner
                                completion(ownerList, nil)
                                return
                            }
                        }
                        _ = ownerList?.data?.first
                        completion(ownerList, nil)
                        return
                    } else {
                        completion(nil, nil)
                        return
                    }
                }
            }
        }
    }
}

// MARK: - AUTO LOCK - CREATE PASSCODE
extension APIBaseVC {

    func createAutoLockPINforKYC(showAutoLockWithVC: UIViewController, with kycStatus: KYCStatus) {

        // CREATE CUSTOM PASSCODE IF SYSTEM PASSCODE IS NOT SUPPORTED OR DISABLED...
        if !BiometricHelper.devicePasscodeEnabled() {
            let storedPin = Security.fetchPin()
            if storedPin == nil {
                let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                let autolockVC = storyboard.instantiateViewController(withIdentifier: "PinVC") as? PinVC
                let navController = UINavigationController(rootViewController: autolockVC!)
                if !Security.hasPin() {
                    autolockVC?.context = .creatPin
                    showAutoLockWithVC.present(navController, animated: true, completion: nil)
                    autolockVC?.onPinSuccess = {
                        AppGlobalData.shared().storeSessionData()
                        self.gotoKYCStatusScreen(aKycStatus: kycStatus)
                    }
                }
            } else {
                self.gotoKYCStatusScreen(aKycStatus: kycStatus)
            }
        } else {
            AppGlobalData.shared().storeSessionData()
            self.gotoKYCStatusScreen(aKycStatus: kycStatus)
        }
    }

    func createAutoLockPINforKYB(showAutoLockWithVC: UIViewController, aKybStatus: KYBStatus, aBusinessData: BusinessDataModel) {

        var shouldMoveAhead = false

        // CREATE CUSTOM PASSCODE IF SYSTEM PASSCODE IS NOT SUPPORTED OR DISABLED...
        if !BiometricHelper.devicePasscodeEnabled() {
            let storedPin = Security.fetchPin()
            if storedPin == nil {
                let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                let autolockVC = storyboard.instantiateViewController(withIdentifier: "PinVC") as? PinVC
                let navController = UINavigationController(rootViewController: autolockVC!)
                if !Security.hasPin() {
                    autolockVC?.context = .creatPin
                    showAutoLockWithVC.present(navController, animated: true, completion: nil)
                    autolockVC?.onPinSuccess = {
                        shouldMoveAhead = true
                    }
                }
            } else {
                shouldMoveAhead = true
            }
        } else {
            shouldMoveAhead = true
        }

        if shouldMoveAhead {

            AppGlobalData.shared().storeSessionData()

            switch aKybStatus {
                case .notStarted:
                    // Go to business detail screen
                    // self.gotoKYCStatusScreen(aKycStatus: kycStatus)
                    let businessData = aBusinessData
                    self.gotoBusinessDetailScreen(businessData: businessData)
                default:
                    // move to kyb status screen
                    self.gotoKYBStatusScreen(aKybStatus: aKybStatus, aBusinessData: aBusinessData)
            }
        }
    }

    func createAutoLockPINforAccount(showAutoLockWithVC: UIViewController, aKybStatus: KYBStatus, aBusinessData: BusinessDataModel) {

        var shouldMoveAhead = false

        // CREATE CUSTOM PASSCODE IF SYSTEM PASSCODE IS NOT SUPPORTED OR DISABLED...
        if !BiometricHelper.devicePasscodeEnabled() {
            let storedPin = Security.fetchPin()
            if storedPin == nil {
                let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                let autolockVC = storyboard.instantiateViewController(withIdentifier: "PinVC") as? PinVC
                let navController = UINavigationController(rootViewController: autolockVC!)
                if !Security.hasPin() {
                    autolockVC?.context = .creatPin
                    showAutoLockWithVC.present(navController, animated: true, completion: nil)
                    autolockVC?.onPinSuccess = {
                        shouldMoveAhead = true
                        AppGlobalData.shared().storeSessionData()
                    }
                }
            } else {
                shouldMoveAhead = true
            }
        } else {
            shouldMoveAhead = true
            AppGlobalData.shared().storeSessionData()
        }

        if shouldMoveAhead {
            self.gotoAccountSetupScreen()
        }
    }
}

// MARK: - TRANSACTION API METHODS
extension APIBaseVC {
    
    func getDashboardTransactionList(strId: String, queryString: String, _ completion: @escaping (TransactionListResponseBody?, AlertMessage?) -> Void) {
        TransactionViewModel.shared.getTransactionList(strId: strId, queryString: queryString) { (response, errorMessage) in
            if let error = errorMessage {
                completion(nil, error)
                } else {
                AppGlobalData.shared().transactionList = response?.data ?? [TransactionModel]()
                completion(response, nil)
            }
        }
    }
}
