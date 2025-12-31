//
//  CardModel.swift
//  Solid
//
//  Created by Solid iOS Team on 08/03/21.
//

import Foundation

public struct CardsListResponseBody: Codable {
	public var total: Int?
	public var data: [CardModel]?
}

public struct CardStatusModel: Codable {
	public var cardStatus: String?
	enum CodingKeys: String, CodingKey {
		case cardStatus
	}
}

public struct Merchant: Codable {
	public var merchantName: String?
	public var merchantCity: String?
	public var merchantState: String?
	public var merchantCountry: String?
	public var postalCode: String?
	public var merchantCategory: String?
	enum CodingKeys: String, CodingKey {
		case merchantName
		case merchantCity
		case merchantState
		case merchantCountry
		case postalCode
		case merchantCategory
	}
}

public struct CardModel: Codable {
    public var id: String?
    public var accountId: String?
    public var businessId: String?
    public var programId: String?
    public var label: String?
    public var limitAmount: String?
    public var embossingPerson: String?
    public var embossingBusiness: String?
    public var cardStatus: CardStatus?
    public var limitInterval: CardSpendLimitTypes?
    public var cardType: CardType?
    public var cardholder: CardHolderModel?
    public var shipping: ShippingAddressModel?
	public var billingAddress: BillingAddressModel?
	public var merchant: Merchant?
    public var currency: String = Utility.localizedString(forKey: "currency_name") // "USD"
    public var expiryMonth: String?
    public var expiryYear: String?
    public var last4: String?
    public var activatedAt: String?
    public var createdAt: String?
    public var modifiedAt: String?
    public var bin: String?

    public var cardTypeLabel: String? {
        var value = ""
        if let _ = businessId, let binText = bin {
            value = Utility.localizedString(forKey: "cardtype_business") + " " + binText
            value = value.uppercased()
        } else if let binText = bin {
            value = Utility.localizedString(forKey: "cardtype_personal") + " " + binText
            value = value.uppercased()
        }
        return value
    }
	private enum CodingKeys: String, CodingKey {
		case id
		case accountId
		case businessId
		case programId
		case last4
		case label
		case limitAmount
        case embossingPerson
        case embossingBusiness
		case cardStatus
		case limitInterval
		case cardType
		case cardholder
		case shipping
		case currency
        case expiryMonth
        case expiryYear
		case activatedAt
		case createdAt
		case modifiedAt
        case bin
	}
}

public struct CardHolderModel: Codable {
	public var id: String?
	public var personId: String?
	public var billingAddress: Address?
	public var createdAt: String?
	public var modifiedAt: String?
	public var name: String?
}

public struct ShippingModel: Codable {
    public var id: String?
    public var shippingAddress: Address?
    public var eta: Address?
    public var deliveryStatus: CardDeliveryStatus?
    public var createdAt: String?
    public var modifiedAt: String?
}

public struct ShippingAddressModel: Codable {
    public var shippingAddress: Address?
}

public struct BillingAddressModel: Codable {
	public var billingAddress: Address?
}

public struct CardCreateRequestBody: Codable {
    public var accountId: String?
    public var label: String?
    public var embossingPerson: String?
    public var embossingBusiness: String?
    public var limitAmount: String?
    public var limitInterval: CardSpendLimitTypes?
    public var cardType: CardType?
    public var billingAddress: Address?
    public var shipping: ShippingAddressModel?
    public var currency: String? = "USD"
}

public struct CardUpdateRequestBody: Codable {
    public var id: String?
    public var label: String?
    public var limitAmount: String?
    public var limitInterval: CardSpendLimitTypes?
    public var cardStatus: CardStatus?
}

// CARD ACTIVATION
public struct CardActivateRequestBody: Codable {
	public var last4: String?
	public var expirationDate: String?
    public var expiryMonth: String?
    public var expiryYear: String?
}

public struct CardActivationResponseBody: Codable {
	public var id: String
	public var cardStatus: CardStatus?
}

struct CardDetailsModel: Codable {
    var id: String?
    var cardNumber: String?
    var cvv: String?
    var expiryMonth: String?
    var expiryYear: String?
    var contactName: String?
}

struct CardVGSShowTokenModel: Codable {
    var id: String?
    var showToken: String?
}

struct CardPinTokenModel: Codable {
    var id: String?
    var pinToken: String?
}

struct DebitCardTokenModel: Codable {
    var id: String?
    var debitCardToken: String?
}

// For Update Card Pin using for VGS and Pin Update
public struct UpdateCardPinPostBody: Codable {
    public var pin: String?
    public var expiryMonth: String?
    public var expiryYear: String?
    public var last4: String?
}

struct ATMLocations: Codable {
    var total: Int?
    var data: [ATMLocationsAddress]?

    private enum CodingKeys: String, CodingKey {
        case total
        case data
    }
}

struct Coordinates: Codable {
    var latitude: Double?
    var longitude: Double?
    
    private enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
        
    }
}
struct ATMLocationsAddress: Codable {
    var name: String?
    var description: String?
    var coordinates: Coordinates?
    
    var iconImageLetter: String? {
        var iconLetter: String?
        var value = ""
        if let firstName = name {
            value = firstName.substring(start: 0, end: 1)
        }
        if !value.isEmpty {
            iconLetter = value
        }
        return iconLetter
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case coordinates
    }
}

struct CardWalletRequestBody: Codable {
    var wallet: String?
    var applePay: Applepay?
  
    private enum CodingKeys: String, CodingKey {
        case wallet
        case applePay
    }
}

struct CardWalletResponseBody: Codable {
    var wallet: String?
    var applePay: ApplepayResponse?
  
    private enum CodingKeys: String, CodingKey {
        case wallet
        case applePay
    }
}

struct ApplepayResponse: Codable {
    var paymentAccountReference: String?
//    var activationData: Data?
//    var encryptedPassData: Data?
//    var ephemeralPublicKey: Data?
    
    var activationData: String?
    var encryptedPassData: String?
    var ephemeralPublicKey: String?
   
    private enum CodingKeys: String, CodingKey {
        case paymentAccountReference
        case activationData
        case encryptedPassData
        case ephemeralPublicKey
    }
}

struct Applepay: Codable {
    var deviceCert: String?
    var nonceSignature: String?
    var nonce: String?
    
    private enum CodingKeys: String, CodingKey {
        case deviceCert
        case nonceSignature
        case nonce
    }
}

public struct VGSDebitCardModel: Codable {
    public var debitCard: VGSDebitCardData?

    enum CodingKeys: String, CodingKey {
        case debitCard = "debitCard"
    }
}

public struct VGSDebitCardData: Codable {
    public var expiryMonth: String?
    public var expiryYear: String?
    public var cardNumber: String?
    public var address: Address?
    
    enum CodingKeys: String, CodingKey {
        case expiryMonth = "expiryMonth"
        case expiryYear = "expiryYear"
        case cardNumber = "cardNumber"
        case address = "address"
    }
}
