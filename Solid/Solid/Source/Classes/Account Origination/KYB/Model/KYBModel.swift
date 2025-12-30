//
//  KYBModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/12/21.
//

import Foundation

// For submit KYB
public struct SubmitBusinessPostBody: Codable {
	public var phone: String?
	public var address: Address?
	public var email: String?
	public var idType: String?
	public var idNumber: String?
}

// submit business
public struct SubmitBusinessResponseBody: Codable {
	public var id: String?
	public var businessId: String?
	public var status: String?
	public var reviewMessage: String?
	public var results: Results?
	public var createdAt: String?
	public var modifiedAt: String?
}

// kyc status
public struct KYBStatusResponseBody: Codable {
	public var id: String?
	public var businessId: String?
	public var status: KYBStatus?
	public var reviewMessage: String?
	public var results: Results?
	public var createdAt: String?
	public var modifiedAt: String?
}

// create business
public struct CreateBusinessPostBody: Codable {
	public var legalName: String?
    public var naicsCode: String?
	public var entityType: BusinessEntityType?
	public var dba: String?
	public var email: String?
	public var idNumber: String?
	public var idType: String?
	public var phone: String?
	public var dateOfIncorporation: String?
	public var website: String?
	public var purpose: String?
	public var industry: String?
	public var address: Address?
}

public struct BusinessListResponseBody: Codable {
	public var total: Int?
	public var data: [BusinessDataModel]?
}

public struct BusinessDataModel: Codable {
	public var id: String?
	public var legalName: String?
    public var naicsCode: String?
	public var entityType: BusinessEntityType?
	public var dba: String?
	public var email: String?
	public var idNumber: String?
	public var idType: String?
	public var phone: String?
	public var dateOfIncorporation: String?
	public var website: String?
	public var purpose: String?
	public var industry: String?
	public var address: Address?
	public var kyb: KYBModel?
	public var disclosureStatus: DisclosureStatus?
    public var reviewCode: String?
	public var createdAt: String?
	public var modifiedAt: String?
}

public struct KYBModel: Codable {
	public var id: String?
	public var businessId: String?
	public var status: KYBStatus?
	public var reviewMessage: String?
	public var results: Results?
    public var reviewCode: String?
	public var createdAt: String?
	public var modifiedAt: String?
}

//FOR PROJECTION/ETV..
public struct ProjectionModel: Codable {
    public var transactions: ProjectionTransactionsModel?
}

public struct ProjectionTransactionsModel: Codable {
    public var annual: ProjectionAnnualModel?
}

public struct ProjectionAnnualModel: Codable {
    public var send: ProjectionSendModel?
    public var receive: ProjectionReceiveModel?
    public var incoming: ProjectionIncomingModel?
}

public struct ProjectionSendModel: Codable {
    public var ach: ProjectionDataModel?
    public var internationalAch: ProjectionDataModel?
    public var domesticWire: ProjectionDataModel?
    public var internationalWire: ProjectionDataModel?
    public var physicalCheck: ProjectionDataModel?
}

public struct ProjectionReceiveModel: Codable {
    public var ach: ProjectionDataModel?
    public var physicalCheck: ProjectionDataModel?
}

public struct ProjectionIncomingModel: Codable {
    public var achPush: ProjectionDataModel?
    public var achPull: ProjectionDataModel?
    public var internationalAch: ProjectionDataModel?
    public var domesticWire: ProjectionDataModel?
    public var internationalWire: ProjectionDataModel?
}

public struct ProjectionDataModel: Codable {
    public var count: String?
    public var amount: String?
}

//For NAICS...
public struct NAICSCodesListResponseBody: Codable {
    public var total: Int?
    public var data: [BusinessSectorType]?
}

public struct BusinessSectorType: Codable {
    public var code: Int?
    public var name: String?
    public var total: Int?
    public var industries: [IndustryGroupType]?
}

public struct IndustryGroupType: Codable {
    public var code: Int?
    public var name: String?
    public var total: Int?
    public var nationalIndustries: [IndustryType]?
}

public struct IndustryType: Codable {
    public var code: Int?
    public var name: String?
}

//FOR PROJECTION/ETV ROW DATA..
public struct ETVRowData {
    var type: String
    var valuePickerData : [ListItems]
    var countPickerData : [ListItems]
}

public struct BusinessProjectionValues: Codable {
    var type: String?
    var projectionData : [BusinessProjectionValue]?
}

public struct BusinessProjectionValue: Codable  {
    public var amountRange: String?
    public var countRange: String?
    public var amount: String?
    public var count: String?
}
