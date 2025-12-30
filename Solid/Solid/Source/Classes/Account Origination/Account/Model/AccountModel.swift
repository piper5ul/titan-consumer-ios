//
//  AccountModel.swift
//  Solid
//
//  Created by Solid iOS Team on 15/02/21.
//

import Foundation

// MARK: - ACCOUNTS
public struct AccountRequestBody: Codable {
    public var businessId: String?
    public var label: String?
    public var acceptedTerms: Bool?
    public var createPhysicalCard: Bool?
    public var currency: String?
    public var type: String?
}

public struct AccountListResponseBody: Codable {
	public var total: Int?
	public var data: [AccountDataModel]?
}

public struct AccountDataModel: Codable {
	public var id: String?
	public var businessId: String?
	public var label: String?
	public var status: AccountStatus?

    //bank account
    public var accountNumber: String?
    public var routingNumber: String?
    public var availableBalance: String?

    public var currency: String?
    public var usdBalance: String?
    public var config: AccountConfigModel?

	// Extra
	public var dateOpened: String?
	public var interest: String?
	public var type: AccountType?
	public var sponsorBankName: String?
	public var fees: String?
    
    public var createdAt: String?

    public var iconImageLetter: String? {
        var iconLetter: String?
        var value = ""
        if let firstName = label {
            value = firstName.substring(start: 0, end: 1)
        }
        if !value.isEmpty {
            iconLetter = value
        }
        return iconLetter
    }
}
public struct AccountActionDataModel: Codable {
	public var id: String?
	public var title: String?
	public var detail: String?
	public var isDetail: Bool?
	public var isSwitch: Bool?
}

public struct AccountConfigModel: Codable {
    public var card: CardConfigModel?
    
    enum CodingKeys: String, CodingKey {
        case card = "card"
    }
}

public struct CardConfigModel: Codable {
    public var virtualCardSettings: VirtualCardSettings?
    public var physicalCardSettings: PhysicalCardSettings?
    
    enum CodingKeys: String, CodingKey {
        case virtualCardSettings = "virtual"
        case physicalCardSettings = "physical"
    }
}

public struct VirtualCardSettings: Codable {
    public var enabled: Bool?
    public var count: String?
}

public struct PhysicalCardSettings: Codable {
    public var enabled: Bool?
    public var count: String?
}

// MARK: - STATEMENTS
public struct AccountStmtListRespBody: Codable {
	public var total: Int?
	public var data: [StatementDataModel]?
}

public struct StatementDataModel: Codable {
	public var month: Int?
	public var year: Int?
	public var createdAt: String?
}
