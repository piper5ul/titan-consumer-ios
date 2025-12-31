//
//  FundModel.swift
//  Solid
//
//  Created by Solid iOS Team on 05/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation

// THESE WILL BE USED TO GET TOKEN FROM SOLID SERVER TO USE TO LINK PLAID...
struct PlaidTempTokenReponseModel: Codable {
    var linkToken: String?
    var expiresIn: String?
}

struct PlaidTempTokenRequestModel: Codable {
    var packageName: String?
    var plaidUpdateMode: PlaidUpdateTokenRequestModel?
}

struct PlaidUpdateTokenRequestModel: Codable {
    var type: String?
    var contactId: String?
}

// THESE WILL BE USED TO SEND PLAID PUBLIC TOKEN TO SOLID SERVER...
struct PlaidPublicTokenRequestModel: Codable {
    var plaidToken: String?
    var plaidAccountId: String?
}
