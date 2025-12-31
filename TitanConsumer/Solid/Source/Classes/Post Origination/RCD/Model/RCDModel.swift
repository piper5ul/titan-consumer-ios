//
//  RCDModel.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

public struct RCModel {
	public var amount: Double?
	public var checkFrontImage: UIImage?
	public var checkRearImage: UIImage?
	public var accountId: String?
}

public struct UploadCheckModel {
	public var checkFrontImage: UIImage?
	public var checkRearImage: UIImage?
	public var accountId: String?
}

public struct ReceiveCheckRequestBody: Codable {
	var accountId: String?
    var contactId: String?
    var amount: String?
    var description: String?

	enum CodingKeys: String, CodingKey {
		case accountId, contactId, amount, description
	}
}

public struct ReceiveCheckResponseBody: Codable, CommonAmountFormatting {
	var  id: String?
    var accountId: String?
    var contactId: String?
    var accountnumber: String?
    var routingNumber: String?
    var name: String?
    var amount: String?
    var description: String?
	public var status: CheckStatus?
	public var address: Address?
	public var txnType: TransactionType?
	public var transferType: TransferType?
	public var transferSubType: String?
	public var createdAt: String?
	public var modifiedAt: String?
	public var transferredAt: String?
	public var accountType: AccountType?
	public var iban: String?

	enum CodingKeys: String, CodingKey {
		case id, accountId, contactId, name, accountnumber, routingNumber, amount, status, description, address, txnType, transferType, transferSubType, createdAt, modifiedAt, transferredAt, accountType, iban
	}

    public var checkAmount: Double {
        return Double(self.amount ?? "") ?? 0
    }

    public var formattedCheckAmount: String {
        let number = NSNumber(value: abs(self.checkAmount))
        var formatted = Utility.getCurrencyForAmount(amount: number, isDecimalRequired: true, withoutSpace: true)
        
        if self.checkAmount != 0 {
            formatted = self.checkAmount < 0 ? "- \(formatted)" : "+ \(formatted)"
        }
        return formatted
    }

    public var isPositiveAmount: Bool {
		if self.checkAmount < 0 {
			return false
		}
		return true
    }
}

public struct ReceiveCheckListResponseBody: Codable {
	public var total: Int?
	public var data: [ReceiveCheckResponseBody]?

	enum CodingKeys: String, CodingKey {
		case total
		case data
	}
}
