//
//  ProgramModel.swift
//  Solid
//
//  Created by Solid iOS Team on 5/15/21.
//

import Foundation

// MARK: - Welcome
public struct ProgramModel: Codable {
    var id: String?
    var productName: String?
    var accountNumberPrefix: String?
    var status: String?
    var programDescription: String?
    var programType: String?
    var company: Company?
    var brand: Brand?
    var bank: Bank?
    var legal: Legal?

    enum CodingKeys: String, CodingKey {
        case id, productName, accountNumberPrefix, status
        case programDescription = "description"
        case programType, company, brand, bank, legal
    }
}

// MARK: - Company
public struct Company: Codable {
    var name: String?
    var domain: String?
    var companyDescription: String?
    var tin: String?
    var entityType: String?
    var address: Address?
    var contact: CompanyContact?

    enum CodingKeys: String, CodingKey {
        case name, domain
        case companyDescription = "description"
        case tin, entityType, address, contact
    }
}

// MARK: - Contact
public struct CompanyContact: Codable {
    var name: String?
    var email: String?
    var phoneNumber: String?
}

// MARK: - Brand
public struct Brand: Codable {
	var id: String?
	var	primaryColor: String?
    var darkPrimaryColor: String?
    var primaryTextColor: String?
    var darkPrimaryTextColor: String?
    var ctaColor: String?
    var darkCtaColor: String?
    var ctaTextColor: String?
    var darkCtaTextColor: String?
	var	squareLogo: String?
	var	landscapeLogo: String?
	var	cardArtPhysical: String?
	var	cardArtVirtual: String?
	var	cardArtVirtualBack: String?
	var	cardArtPhysicalBack: String?
	var fontName: String?
	var fontURL: String?
    var physicalCardTextColor: String? = "#FFFFFF"
    var virtualCardTextColor: String? = "#FFFFFF"
    var darkSquareLogo: String?
    var darkLandscapeLogo: String?
}

// MARK: - Bank
public struct Bank: Codable {
    var sponsor: String?
    var fdicInsurance: Bool?
    var maxAccounts: MaxAccounts?
    var accountType: AccountTypePermission?
    var accountSubType: AccountSubType?
}

// MARK: - AccountSubType
public struct AccountSubType: Codable {
    var dda: Bool?
    var interest: Bool?
    var clearing: Bool?
    var reserve: Bool?
    var accrue: Bool?
}

// MARK: - AccountType
public struct AccountTypePermission: Codable {
    var personalChecking: Bool?
    var personalSavings: Bool?
    var businessChecking: Bool?
    var businessSavings: Bool?
    var cardAccount: Bool?
    
    public var bothBusinessAndPersonalChecking: Bool? {
        if let pchecking = personalChecking, let bChecking = businessChecking {
            if pchecking && bChecking {
                return true
            } else {
                return false
            }
        }
        return false
    }
}

// MARK: - MaxAccounts
public struct MaxAccounts: Codable {
    var personal: String?
    var business: String?
}

// MARK: - Legal
public struct Legal: Codable {
    var bank: String?
    var program: String?
    var solid: String?
}
