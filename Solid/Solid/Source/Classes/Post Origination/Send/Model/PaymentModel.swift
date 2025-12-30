//
//  PaymentModel.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation

struct PaymentModel: Codable {
    var id: String?
    var accountId: String?
    var contactId: String?
    var amount: String?
    var description: String?
    var status: PaymentStatus?
    var createdAt: String?
    var modifiedAt: String?
	var type: String?
	var address: Address?
	var card: CardModel?
}
