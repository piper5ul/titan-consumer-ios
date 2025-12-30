//
//  TransactionModel.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import Foundation

// *** Base Amount Protocol ***//

protocol CommonAmountFormatting {
    var amount: String? { get set }
}

extension CommonAmountFormatting {

    public var trnsAmount: Double {
        return Double(self.amount ?? "") ?? 0
    }

    public var formattedAmount: String {
        let number = NSNumber(value: abs(self.trnsAmount))
        var formatted = Utility.getCurrencyForAmount(amount: number, isDecimalRequired: true, withoutSpace: true)
        
        if self.trnsAmount != 0 {
            formatted = self.trnsAmount < 0 ? "- \(formatted)" : "+ \(formatted)"
        }
        
        return formatted
    }

    public var isPositiveAmount: Bool {
        return self.trnsAmount > 0
    }
}

// ******//

public struct TransactionListResponseBody: Codable {
	public var total: Int?
	public var data: [TransactionModel]?
}

public struct TransactionModel: Codable, CommonAmountFormatting {
    public var id: String?
    public var txnType: TransactionType?
    public var title: String?
    public var amount: String?
    public var transferType: TransferType?
    public var status: TransactionStatus?
    public var subType: String?
    public var description: String?
    public var accountId: String?
    public var businessId: String?
    public var programId: String?
	public var source: String?
    public var personId: String?
    public var balance: String?
    public var card: Card?
	public var merchant: String?
    public var createdAt: String?
    public var txnDate: String?
    public var intrabank: Intrabank?
    public var ach: ACH?
	public var physicalCheck: PhysicalCheck?
    public var address: Address?
    
    public var createdDate: Date? {
        var string = self.createdAt!.till(".")?.replacingOccurrences(of: "T", with: " ")
        string = string! + " +0000"
        return Date(string!, format: "yyyy-MM-dd HH:mm:ss Z")
    }

    public var transactionDateObject: Date? {
        if self.txnDate == nil {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        var finalDate: Date?

        if let theDate = formatter.date(from: self.txnDate!) {
             finalDate = theDate
        } else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            finalDate = formatter.date(from: self.txnDate!)
        }

        return finalDate
    }

    public var transactionDateInLocalZone: String {
        guard let transDate = self.txnDate else {
            return ""
        }
        return transDate.utcDateToLocal()
    }

    public var transactionTime: String {
        guard let transDate = self.transactionDateObject else {
            return ""
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: transDate)
    }

    public var imageName: String {

        var imgName = ""
        switch transferType {
        case .card:
            imgName = self.isPositiveAmount ? "cardCredit" : "cardDebit"
        default:
            imgName = self.isPositiveAmount ? "transferCredit" : "transDebit"
        }

        return imgName
    }
}

public struct Intrabank: Codable {
    public var transferId: String?
    public var contactId: String?
    public var name: String?
}

public struct ACH: Codable {
	public var transferId: String?
	public var contactId: String?
	public var name: String?
}

public struct PhysicalCheck: Codable {
    public var transferId: String?
    public var contactId: String?
    public var name: String?
}

public struct FilterData: Codable {
    public var arrOfSelectedIndex: [IndexPath]?
    public var startDate: String?
    public var endDate: String?
    public var minAmount: String?
    public var maxAmount: String?
    public var txnType: String?
    public var cardId: String?
    public var cardName: String?
    public var periodType: TransactionTimePeriod?
}

public struct QueryParams: Codable {
    public var startDate: String?
    public var endDate: String?
    public var minAmount: String?
    public var maxAmount: String?
    public var txnType: TransactionType?
    public var transferType: TransferType?
    public var subType: String?
    public var cardId: String?
    public var contactId: String?
    public var offset: String?
    public var limit: String?
}

public struct Card: Codable {
	public var id: String?
	public var transferId: String?
	public var label: String?
	public var merchant: Merchant?
	public var createdAt: String?
	public var modifiedAt: String?

	private enum CodingKeys: String, CodingKey {
		case id
		case transferId
		case label
		case merchant
		case createdAt
		case modifiedAt
	}
}
