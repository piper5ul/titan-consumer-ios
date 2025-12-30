//
//  ContactModel.swift
//  Solid
//
//  Created by Solid iOS Team on 02/03/21.
//

import Foundation

// List all owners
public struct ContactListResponseBody: Codable {
	public var total: Int?
	public var data: [ContactDataModel]?
}

// Create Contact
public struct ContactDataModel: Codable {
    public var id: String?
    public var accountId: String?
    public var name: String?
    public var email: String?
    public var phone: String?
    public var status: ContactStatus?
    public var intrabank: IntrabankAccount?
	public var card: Contactaddress?
    public var ach: ACHAccount?
    public var createdAt: String?
    public var modifiedAt: String?
	public var selectedPaymentMode: ContactAccountType?
	public var check: Contactaddress?
	public var wire: WirePayment?
    public var debitCard: DebitCard?
	public var iconImageLetter: String? {
		var aIconImageLetter: String?
		var value = ""
		if let cName = name, cName.count > 1 {
			let formatter = PersonNameComponentsFormatter()
			if let components = formatter.personNameComponents(from: cName) {
				formatter.style = .abbreviated
				aIconImageLetter =  formatter.string(from: components)
			}
		} else {
			value = name ?? ""
			return value
		}
		return aIconImageLetter
	}
}

public struct DebitCard: Codable {
    public var cardNumber: String?
    public var last4: String?
    public var expiryMonth: String?
    public var expiryYear: String?
    public var address: Contactaddress?
}

public struct Contactaddress: Codable {
	public var address: Address?
}

// Intrabank
public struct IntrabankAccount: Codable {
    public var accountNumber: String?
	public var description: String?
	public var amount: String?
}

// ACH
public struct ACHAccount: Codable {
    public var accountNumber: String?
    public var routingNumber: String?
    public var accountType: AccountType?
    public var bankName: String?
	public var purpose: String?
	public var amount: String?
}

// WIRE
public struct WirePayment: Codable {
	public var domestic: DomesticWire?
    public var international: InternationalWire?
}

// Domestic
public struct DomesticWire: Codable {
	public var accountNumber: String?
	public var routingNumber: String?
	public var accountType: AccountType?
	public var bankName: String?
	public var purpose: String?
	public var amount: String?
	public var address: Address?
}

public struct InternationalWire: Codable {
    public var accountNumber: String?
    public var bankIdentifierType: String?
    public var bankIdentifierCode: String?
    public var accountType: InternationalWireAccountType?
    public var beneficiaryBank: String?
    public var purpose: String?
    public var amount: String?
    public var beneficiaryAddress: Address?
    public var beneficiaryBankAddress: Address?
}

public struct CheckAccount: Codable {
	public var accountNumber: String?
	public var description: String?
	public var amount: String?
}

public struct ContactDeleteResponseBody: Codable {
    public var id: String?
    public var status: ContactStatus?
}
