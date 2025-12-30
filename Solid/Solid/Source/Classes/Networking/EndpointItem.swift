//
//  EndpointItem.swift
//  Solid
//
//  Created by Solid iOS Team on 2/8/21.
//

import Foundation
import UIKit
import Alamofire

enum EndpointItem {
	// MARK: User actions
	case getAll
    case registerUser
	case logout
    case getPersonaHostedUrl(String)
    case submitKYC(String)
	case getPerson
	case updatePerson(String)
	case submitKyb(String)
	case getKybStatus(String)

    case listAllNAICSCodes
    case getProjection(String)
    case updateProjection(String)
	case listAllBusiness
	case createBusiness
	case getBusiness(String)
	case getOwnershipDisclosure(String)
    case generateOwnershipDisclosure(String)
	case updateBusiness(String)

	case createAccount
	case listAllAccount(String, String, String)
	case getAccount(String)
	case listStatementForAccount(String)
	case getStatementForAccount(String, String)

	case listAllOwner(String)
	case createOwner
	case getOwnerDetails(String)
	case updateOwner(String)
	case submitOwnerKyc(String)
	case getOwnerKyc(String)

    // CONTACT
    case createContact
    case updateContact(String)
	case listAllContacts(String, String, String, String)
	case getContactDetails(String)
    case deleteContact(String)

    // PAY
    case paymentMethod(String)

    // CARD
    case createCard
    case updateCard(String)
    case getCards(String, String, String)
    case getCardDetails(String)
    case getCardUnredacted(String)
	case activateCard(String)
    case deleteCard(String)
    case getVGSShowToken(String)
    case getCardPinToken(String)
    case getAddDebitCardToken(String)
    case getATMLocation(String, String, String, String, String, String)
    case enrollWallet(String)

    // TRANSACTION
    case listAllTransaction(String, String)
    case getTransactionDetail(String, String)
    case transactionDetailExport(String, String)

    // PROGRAM
    case getProgramDetail(String)

	// CHECK
	case receiveCheck
	case receiveCheckFiles(String)
	case receiveCheckStatus
	case listAllChecks(String)
	case updateReceiveCheck

    // FUNDS
    case getPlaidTempToken(String)
    case submitPlaidPublicToken(String)
    case pullFundsIn
    case pullFundsOut
    case debitPull
}

// MARK: - EndPointType
extension EndpointItem: EndPointType {
    
    var baseURL: String {
        switch APIManager.networkEnviroment {
        case .productionTest: return "https://test-api.solidfi.com/v1"
        case .productionLive: return "https://api.solidfi.com/v1"
        }
    }
    
    var path: String {
        switch self {

        case .getAll:
            return ""
       
        // AUTH
        case .registerUser:
            return "/auth/register"
        case .logout:
            return "/auth/logout"
            
            // PERSONA and KYC
        case .getPersonaHostedUrl(let personId):
            return EndPoint.Person.getPersonaHostedUrl(personId).raw()
        case .submitKYC(let personId):
            return EndPoint.Person.submitKYC(personId).raw()
        case .getPerson:
            return "/person"
        case .updatePerson(let personId):
            return "/person" + "/\(personId)"
            
            //  KYB
        case .listAllNAICSCodes:
            return Endpoint.Business.listAllNAICSCodes.raw()
        case.getProjection(let businessId):
            return Endpoint.Business.getProjection(businessId).raw()
        case.updateProjection(let businessId):
            return Endpoint.Business.updateProjection(businessId).raw()
        case .submitKyb(let businessId):
            return Endpoint.Business.submitKyb(businessId).raw()
        case .getKybStatus(let businessId):
            return Endpoint.Business.getKybStatus(businessId).raw()
        case .listAllBusiness:
            return Endpoint.Business.listAllBusiness.raw()
        case .createBusiness:
            return Endpoint.Business.createBusiness.raw()
        case.getBusiness(let businessId):
            return Endpoint.Business.getBusiness(businessId).raw()
        case.getOwnershipDisclosure(let businessId):
            return Endpoint.Business.getOwnershipDisclosure(businessId).raw()
        case.generateOwnershipDisclosure(let businessId):
            return Endpoint.Business.generateOwnershipDisclosure(businessId).raw()
        case.updateBusiness(let businessId):
            return Endpoint.Business.updateBusiness(businessId).raw()
            
            // Account
        case .listAllAccount(let accountId, let limit, let offset):
            return Endpoint.Account.listAllAccount(accountId, limit, offset).raw()
        case .createAccount:
            return Endpoint.Account.createAccount.raw()
        case .getAccount(let accountId):
            return Endpoint.Account.getAccount(accountId).raw()
        case .listStatementForAccount(let accountId):
            return Endpoint.Account.listStatementForAccount(accountId).raw()
        case .getStatementForAccount(let accountId, let queryString):
            return Endpoint.Account.getStatementForAccount(accountId, queryString).raw()
            
            // Owner
        case .listAllOwner(let businessId):
            return Endpoint.Owner.listAllOwner(businessId).raw()
        case .createOwner:
            return Endpoint.Owner.createOwner.raw()
        case.getOwnerDetails(let ownerId):
            return Endpoint.Owner.getOwnerDetails(ownerId).raw()
        case .updateOwner(let ownerId):
            return Endpoint.Owner.updateOwner(ownerId).raw()
        case .submitOwnerKyc(let ownerId):
            return Endpoint.Owner.submitOwnerKyc(ownerId).raw()
        case .getOwnerKyc(let ownerId):
            return Endpoint.Owner.getOwnerKyc(ownerId).raw()
            
            // CONTACT
        case .createContact:
            return ContactEndpoint.Contact.createContact.raw()
        case .updateContact(let contactId):
            return ContactEndpoint.Contact.updateContact(contactId).raw()
        case .listAllContacts(let accountId, let type, let limit, let offset):
            return ContactEndpoint.Contact.listAllContacts(accountId, type, limit, offset).raw()
        case .getContactDetails(let contactId):
            return ContactEndpoint.Contact.getContactDetails(contactId).raw()
        case .deleteContact(let contactId):
            return ContactEndpoint.Contact.deleteContact(contactId).raw()
            
            // SEND PAYMENT
        case .paymentMethod(let endpoint):
            return PaymentEndpoint.Payment.paymentMethod(endpoint).raw()
            
            // CARD
        case .createCard:
            return CardEndpoint.createCard.raw()
        case .updateCard(let cardId):
            return CardEndpoint.updateCard(cardId).raw()
        case .getCards(let accountId, let limit, let offset):
            return CardEndpoint.getCards(accountId, limit, offset).raw()
        case .getCardDetails(let cardId):
            return CardEndpoint.getCardDetails(cardId).raw()
        case .getCardUnredacted(let cardId):
            return CardEndpoint.getCardUnredacted(cardId).raw()
        case .activateCard(let cardId):
            return CardEndpoint.activateCard(cardId).raw()
        case .deleteCard(let cardId):
            return CardEndpoint.deleteCard(cardId).raw()
        case .getVGSShowToken(let cardId):
            return CardEndpoint.getVGSShowToken(cardId).raw()
        case .getCardPinToken(let cardId):
            return CardEndpoint.getCardPinToken(cardId).raw()
        case .getAddDebitCardToken(let contactId):
            return CardEndpoint.getAddDebitCardToken(contactId).raw()
        case .getATMLocation(let cardId, let limit, let offSet, let latitude, let longitude, let radius):
            return CardEndpoint.getATMLocationsNearBy(cardId, limit, offSet, latitude, longitude, radius).raw()
        case .enrollWallet(let cardId):
            return CardEndpoint.enrollWallet(cardId).raw()
            
            // TRANSACTION
        case .listAllTransaction(let strID, let queryString):
            return TransactionEndpoint.Transaction.listAllTransaction(strID, queryString).raw()
        case .getTransactionDetail(let strID, let transactionId):
            return TransactionEndpoint.Transaction.getTransactionDetail(strID, transactionId).raw()
        case .transactionDetailExport(let strID, let transactionId):
            return TransactionEndpoint.Transaction.transactionDetailExport(strID, transactionId).raw()
            
            // PROGRAM
        case .getProgramDetail(let programId):
            return ProgramEndPoint.Program.getProgramDetail(programId).raw()
            
            // CHECK
        case .receiveCheck:
            return RCDEndpoint.RCDCheck.receiveCheck.raw()
        case .receiveCheckFiles(let transferId):
            return RCDEndpoint.RCDCheck.receiveCheckFiles(transferId).raw()
        case .receiveCheckStatus:
            return RCDEndpoint.RCDCheck.receiveCheckStatus.raw()
        case .listAllChecks(let accountId):
            return RCDEndpoint.RCDCheck.listllChecks(accountId).raw()
        case .updateReceiveCheck:
            return RCDEndpoint.RCDCheck.updateReceiveCheck.raw()
            
            // FUNDS
        case .getPlaidTempToken(let accountId):
            return FundEndpoint.getPlaidTempToken(accountId).raw()
        case .submitPlaidPublicToken(let accountId):
            return FundEndpoint.submitPlaidPublicToken(accountId).raw()
        case .pullFundsIn:
            return FundEndpoint.pullFundsIn.raw()
        case .pullFundsOut:
            return FundEndpoint.pullFundsOut.raw()
        case .debitPull:
            return FundEndpoint.debitPull.raw()
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .registerUser, .logout, .getPersonaHostedUrl(_),
                .submitKYC(_), .submitKyb(_),
                .createBusiness, .createAccount, .createOwner, .submitOwnerKyc,
                .createContact, .createCard,
                .paymentMethod(_), .receiveCheck,
                .getPlaidTempToken(_), .submitPlaidPublicToken(_),
                .pullFundsIn, .pullFundsOut, .debitPull, .getVGSShowToken(_), .getCardPinToken(_), .getAddDebitCardToken(_), .enrollWallet(_), .generateOwnershipDisclosure(_) :
            return .post
        case .getAll, .getPerson, .getKybStatus(_), .listAllBusiness, .getBusiness(_), .getOwnershipDisclosure(_), .getCardDetails(_), .getCardUnredacted(_), .getProgramDetail(_), .listAllChecks(_), .listAllNAICSCodes, .getProjection(_):
            return .get
        case .updatePerson(_), .updateBusiness(_), .updateOwner(_), .updateContact(_), .updateCard(_), .activateCard(_), .updateReceiveCheck, .receiveCheckFiles, .updateProjection(_):
            return .patch
        case .deleteContact(_), .deleteCard(_):
            return .delete
        default:
            return .get
        }
    }
    
    var headers: HTTPHeaders? {
        let accessToken = (AppData.session.accessToken ?? "") as String
        //	let deviceId = UUID().uuidString
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        AppData.session.deviceId = deviceId
        
        var strSdLanguage = ""
        if let prefLocalization = Bundle.main.preferredLocalizations.first, let regionCode = Locale.current.regionCode {
            strSdLanguage = prefLocalization + "-" + regionCode
        }
        
        //let strIPAddress: String = self.getIPAddress()
        let sdDeviceId = "SD-Device-ID"
        let sdLanguage = "sd-language"
        let cachecontrol = "Cache-Control"
        let cachecontrolValue = "no-cache, no-store"
        let contentTypeKey = "Content-Type"
        let contentTypeValue = "application/json"
        
        switch self {
        case .registerUser:
            let accToken = AppGlobalData.shared().authAccessToken
            return [sdDeviceId: deviceId, "Authorization": "Bearer \(accToken)", sdLanguage: strSdLanguage, cachecontrol: cachecontrolValue]
        case .logout:
            return [sdDeviceId: deviceId, "Authorization": "Bearer \(accessToken)", sdLanguage: strSdLanguage, cachecontrol: cachecontrolValue]
        case .enrollWallet(_):
            return [sdDeviceId: deviceId, "Authorization": "Bearer \(accessToken)", contentTypeKey: contentTypeValue, sdLanguage: strSdLanguage, cachecontrol: cachecontrolValue]
        default:
            return ["Authorization": "Bearer \(accessToken)", contentTypeKey: contentTypeValue, sdLanguage: strSdLanguage, cachecontrol: cachecontrolValue]
        }
    }
    
    var url: URL {
        return URL(string: self.baseURL + self.path)!
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                    
                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
}
