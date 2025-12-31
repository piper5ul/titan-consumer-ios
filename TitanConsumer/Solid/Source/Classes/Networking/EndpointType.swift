//
//  EndpointType.swift
//  Solid
//
//  Created by Solid iOS Team on 2/8/21.
//

import Foundation
import Alamofire

protocol EndPointType {

	// MARK: - Vars & Lets
	var baseURL: String { get }
	var path: String { get }
	var httpMethod: HTTPMethod { get }
	var headers: HTTPHeaders? { get }
	var url: URL { get }
	var encoding: ParameterEncoding { get }
}

protocol EndPointProtocol {
    func raw() -> String
}

enum EndPoint {
    enum Person: EndPointProtocol {
        case resource
        case getPersonaHostedUrl(String)
        case submitKYC(String)

        func raw() -> String {
            switch self {
                case .resource:
                    return "/person"
                case .getPersonaHostedUrl(let personId):
                    return Person.resource.raw() + "/\(personId)/idv"
                case .submitKYC(let personId):
                    return Person.resource.raw() + "/\(personId)" + "/kyc"
            }
        }

    }
}

enum Endpoint {
    enum Business: EndPointProtocol {
        case resource
        case submitKyb(String)
        case getKybStatus(String)
        case listAllBusiness
        case createBusiness
        case getBusiness(String)
        case getOwnershipDisclosure(String)
        case generateOwnershipDisclosure(String)
        case updateBusiness(String)
        case listAllNAICSCodes
        case getProjection(String)
        case updateProjection(String)
        
        func raw() -> String {
            switch self {
            case .resource:
                return "/business"
            case .listAllNAICSCodes:
                return Business.resource.raw() + "/naicscode"
            case.getProjection(let businessId):
                return Business.resource.raw() + "/\(businessId)" + "/projection"
            case.updateProjection(let businessId):
                return Business.resource.raw() + "/\(businessId)" + "/projection"
            case .submitKyb(let businessId):
                return Business.resource.raw() + "/\(businessId)/kyb"
            case .getKybStatus(let businessId):
                return Business.resource.raw() + "/\(businessId)/kyb"
            case .listAllBusiness:
                return Business.resource.raw()
            case .createBusiness:
                return Business.resource.raw()
            case.getBusiness(let businessId):
                return Business.resource.raw() + "/\(businessId)"
            case.getOwnershipDisclosure(let businessId):
                return Business.resource.raw() + "/\(businessId)" + "/ownershipDisclosure"
            case.generateOwnershipDisclosure(let businessId):
                return Business.resource.raw() + "/\(businessId)" + "/ownershipDisclosure"
            case.updateBusiness(let businessId):
                return Business.resource.raw() + "/\(businessId)"
            }
        }
    }

	enum Account: EndPointProtocol {
        case resource
        case createAccount
        case listAllAccount(String, String, String)
        case getAccount(String)
        case listStatementForAccount(String)
        case getStatementForAccount(String, String)

        func raw() -> String {
            switch self {
            case .resource:
                return "/account"
            case .createAccount:
                return Account.resource.raw()
            case .listAllAccount(let businessId, let limit, let offset):
                let listAccUrl = Account.resource.raw()
                if !businessId.isEmpty {
                    return  listAccUrl + "?businessId=\(businessId)"
                }
                return listAccUrl + "?limit=\(limit)&offset=\(offset)"
            case .getAccount(let accountId):
                return Account.resource.raw() + "/\(accountId)"
            case .listStatementForAccount(let accountId):
                return Account.resource.raw() + "/\(accountId)/statement"
            case .getStatementForAccount(let accountId, let queryString):
                return Account.resource.raw() + "/\(accountId)/statement/\(queryString)?export=pdf"
            }
        }
    }

	enum Owner: EndPointProtocol {
		case resource
		case listAllOwner(String)
		case createOwner
		case getOwnerDetails(String)
		case updateOwner(String)
		case submitOwnerKyc(String)
		case getOwnerKyc(String)

		func raw() -> String {
			switch self {
				case .resource:
					return "/owner"
				case .listAllOwner(let businessId):
					return Owner.resource.raw() + "?businessId=\(businessId)"
				case .createOwner:
					return Owner.resource.raw()
				case .getOwnerDetails(let ownerId):
					return Owner.resource.raw() + "/\(ownerId)"
				case .updateOwner(let ownerId):
					return Owner.resource.raw() + "/\(ownerId)"
				case .submitOwnerKyc(let ownerId):
					return Owner.resource.raw() +  "/\(ownerId)" + "/kyc"
				case .getOwnerKyc(let ownerId):
					return Owner.resource.raw() +  "/\(ownerId)" + "/kyc"
			}
		}
	}
}

enum ContactEndpoint {
    enum Contact: EndPointProtocol {
        case resource
        case createContact
        case updateContact(String)
		case listAllContacts(String, String, String, String)
		case getContactDetails(String)
        case deleteContact(String)
        func raw() -> String {
            switch self {
                case .resource:
                    return "/contact"
                case .createContact:
                    return Contact.resource.raw()
                case .updateContact(let contactId):
                    return Contact.resource.raw() + "/\(contactId)"
				case .listAllContacts(let accountId, let type, let limit, let offset):
					return Contact.resource.raw() + "?accountId=\(accountId)&type=\(type)&limit=\(limit)&offset=\(offset)"
				case .getContactDetails(let contactId):
					return Contact.resource.raw() + "/\(contactId)"
                case .deleteContact(let contactId):
                    return Contact.resource.raw() + "/\(contactId)"
            }
        }
    }
}

enum PaymentEndpoint {
    enum Payment: EndPointProtocol {
        case resource
        case paymentMethod(String)
        func raw() -> String {
            switch self {
                case .resource:
                    return "/send"
                case .paymentMethod(let endpoint):
                    return Payment.resource.raw() + "/\(endpoint)"
            }
        }
    }
}
enum CardEndpoint: EndPointProtocol {
    case resource
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
    case getATMLocationsNearBy(String, String, String, String, String, String)
    case enrollWallet(String)

    func raw() -> String {
        switch self {
        case .resource:
            return "/card"
        case .createCard:
            return CardEndpoint.resource.raw()
        case .updateCard(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)"
        case .getCards(let accountId, let limit, let offset):
            return CardEndpoint.resource.raw() + "?accountId=\(accountId)&limit=\(limit)&offset=\(offset)"
        case .getCardDetails(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)"
        case .getCardUnredacted(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)/unredact"
        case .activateCard(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)/activate"
        case .deleteCard(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)"
        case .getVGSShowToken(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)/show-token"
        case .getCardPinToken(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)/pintoken"
        case .getAddDebitCardToken(let contactId):
            return "/contact/\(contactId)/debitcard/token"
        case .getATMLocationsNearBy(let cardId, let limit, let offSet, let latitude, let longitude, let radius):
            return CardEndpoint.resource.raw() + "/atm?cardId=\(cardId)" + "&limit=\(limit)&offset=\(offSet)" + "&latitude=\(latitude)&longitude=\(longitude)" + "&radius=\(radius)"
        case .enrollWallet(let cardId):
            return CardEndpoint.resource.raw() + "/\(cardId)/provision"
        }
    }
}

enum TransactionEndpoint {
    enum Transaction: EndPointProtocol {
        case resource
        case listAllTransaction(String, String)
        case getTransactionDetail(String, String)
        case transactionDetailExport(String, String)

        func raw() -> String {
            switch self {
            case .resource:
                return "/account"
            case .listAllTransaction(let strId, let queryString):
                let qString = "/\(strId)" + "/transaction?\(queryString)"
                return Transaction.resource.raw() + qString
            case .getTransactionDetail(let strId, let transactiontId):
                let qString = "/\(strId)/transaction/\(transactiontId)?export=json"
                return Transaction.resource.raw() + qString
            case .transactionDetailExport( let strId, let transactiontId):
                let qString = "/\(strId)/transaction/\(transactiontId)?export=pdf"
                return Transaction.resource.raw() + qString
            }
        }
    }
}

enum ProgramEndPoint {
    enum Program: EndPointProtocol {
        case resource
        case getProgramDetail(String)
        func raw() -> String {
            switch self {
                case .resource:
                    return "/program"
                case .getProgramDetail(let programId):
                    return Program.resource.raw()+"/\(programId)"
            }
        }
    }

}

enum RCDEndpoint {
	enum RCDCheck: EndPointProtocol {
		case resource
		case receiveCheck
		case receiveCheckFiles(String)
		case receiveCheckStatus
		case listllChecks(String)
		case updateReceiveCheck

		func raw() -> String {
			switch self {
				case .resource:
					return "/receive/check"
				case .receiveCheck:
					return RCDCheck.resource.raw()
				case .receiveCheckFiles(let transferId):
					return RCDCheck.resource.raw()+"/" + "\(transferId)" + "/files"
				case .receiveCheckStatus:
					return RCDCheck.resource.raw()
				case .listllChecks(let accountId):
					return RCDCheck.resource.raw() + "?accountId=\(accountId)"
				case .updateReceiveCheck:
					return RCDCheck.resource.raw()
			}
		}
	}
}

enum FundEndpoint: EndPointProtocol {
    case resource
    case getPlaidTempToken(String)
    case submitPlaidPublicToken(String)
    case pullFundsIn
    case pullFundsOut
    case debitPull

    func raw() -> String {
        switch self {
            case .resource:
                return "/account"
            case .getPlaidTempToken(let accountId):
                return FundEndpoint.resource.raw() + "/\(accountId)" + "/plaid-token"
            case .submitPlaidPublicToken(let accountId):
                return FundEndpoint.resource.raw() + "/\(accountId)" + "/plaid-account"
            case .pullFundsIn:
                return  "/receive/ach"
            case .pullFundsOut:
                return  "/send/ach"
            case .debitPull:
                return  "/receive/debitpull"
        }
    }
}
