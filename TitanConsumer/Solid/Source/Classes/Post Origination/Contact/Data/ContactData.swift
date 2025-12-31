//
//  AccountData.swift
//  Solid
//
//  Created by Solid iOS Team on 3/2/21.
//

import Foundation

struct ContactRowData {
	var key: String?
	var value: Any?
    var title: String?
    var placeholder: String?
	var iconName: String?
    var isSwitchOn: Bool? = false
    var textfieldType: TextFieldType?
	var cellType = AccountCellType.data
}

public enum ContactCellType {
	case data
	case detail
	case switched
	case location
	case btn
}

enum CantactAccountDetail: Int {
	case  accountNumber = 0,
	routingNumber,
	bank,
	accountType

	func getTitleKey() -> String {
		switch self {
			case .accountNumber:
				return Utility.localizedString(forKey: "contact_AccountNumber_title")
			case .routingNumber:
				return Utility.localizedString(forKey: "contact_RoutingNumber_title")
			case .bank:
				return Utility.localizedString(forKey: "contact_Bank_title")
			case .accountType:
				return Utility.localizedString(forKey: "contact_AccountType_title")
		}
	}
}

enum CantactAddressDetail: Int {
	case  streetName = 0,
		  city,
		  country

	func getTitleKey() -> String {
		switch self {

	case.streetName:
	return Utility.localizedString(forKey: "contact_street_title")
	case .city:
	return Utility.localizedString(forKey: "contact_city_title")
	case .country:
	return Utility.localizedString(forKey: "contact_country_title")
	}
}
}

enum ContactPersonalDetails: Int {
	case  phone = 0,
		  email,
		address

	func getTitleKey() -> String {
		switch self {
			case .phone:
				return Utility.localizedString(forKey: "contact_phone_title")
			case .email:
				return Utility.localizedString(forKey: "contact_Email_title")
			case .address:
				return Utility.localizedString(forKey: "address")
		}
	}
}

enum ContactActionDetails: Int {
	case  makePayment = 0,
		  paymentHistory,
		  editContact,
		  deleteContact

	func getTitleKey() -> String {
		switch self {
			case .makePayment:
				return Utility.localizedString(forKey: "contact_makepayment_title")
			case .paymentHistory:
				return Utility.localizedString(forKey: "contact_paymenthistory_title")
			case .editContact:
				return Utility.localizedString(forKey: "contact_details_EditTitle")
			case .deleteContact:
				return Utility.localizedString(forKey: "contact_row_DeleteContact")
		}
	}

	func getImageIconScreen() -> String {
		switch self {
			case .makePayment:
				return "makepayment"
			case .paymentHistory:
				return "makepayment"
			case .editContact:
				return "card"
			case .deleteContact:
				return "card"
		}
	}
}

public enum ContactAccountType: String, Codable {
    case intrabank
    case ach
    case check
    case domesticWire
    case internationalWire
    case sendVisaCard
    case unknown
    
    func getTitleKey() -> String {
        switch self {
        case .intrabank:
            return Utility.localizedString(forKey: "accountType_intrabank")
        case .ach:
            return Utility.localizedString(forKey: "accountType_ach")
        case .check:
            return Utility.localizedString(forKey: "accountType_check")
        case .domesticWire:
            return Utility.localizedString(forKey: "accountType_domesticWire")
        case .internationalWire:
            return Utility.localizedString(forKey: "accountType_internationalWire")
        case .sendVisaCard:
            return Utility.localizedString(forKey: "accountType_card")
        default:
            return ""
        }
    }
    
    public init(from decoder: Decoder) throws {
        self = try ContactAccountType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
