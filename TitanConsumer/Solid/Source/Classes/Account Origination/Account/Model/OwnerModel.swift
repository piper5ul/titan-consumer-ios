//
//  OwnerModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/22/21.
//

import Foundation

// List all owners
public struct OwnerListResponseBody: Codable {
	public var total: Int?
	public var data: [OwnerDataModel]?
}

public struct OwnerDataModel: Codable {
	public var id: String?
	public var businessId: String?
	public var isControlPerson: Bool?
	public var ownership: String?
	public var designation: OwnerDesignationType?
    public var title: String?
	public var availableBalance: String?
	public var status: AccountStatus?
	public var createdAt: String?
	public var modifiedAt: String?
	public var person: PersonResponseBody?
}

// Create Ownwer
public struct CreateOwnerRequestbody: Codable {
	public var businessId: String?
	public var person: PersonResponseBody?
	public var ownership: String?
}

// update Owner
public struct UpdateOwnerRequestbody: Codable {
	public var businessId: String?
	public var ownership: String?
    public var designation: OwnerDesignationType?
    public var title: String?
    public var isControlPerson: Bool?
}

// submitOwner kyc
public struct KYCOwnerRequestbody: Codable {
	public var dateOfBirth: String?
	public var address: Address?
	public var email: String?
}

// KYC owner
public struct KYCOwnerResponsetbody: Codable {
	public var id: String?
	public var personId: String?
	public var status: KYCStatus?
	public var reviewMessage: String?
	public var results: Results?
	public var createdAt: String?
	public var modifiedAt: String?
}

// Control Person Data
public struct ControlPersonData: Codable {
    public var ownerId: String?
    public var isControlPerson: Bool?
    public var designation: OwnerDesignationType?
    public var title: String?
}

// Generate Ownership Disclosure
public struct OwnershipDisclosureRequestBody: Codable {
    public var action: String?
    public var redirectUri: String?
    public var frameancestor: String?
}

// Ownership Disclosure
public struct OwnershipDisclosureResponseBody: Codable {
    public var url: String?
    public var status: DisclosureStatus?
    public var signedAt: String?
}
