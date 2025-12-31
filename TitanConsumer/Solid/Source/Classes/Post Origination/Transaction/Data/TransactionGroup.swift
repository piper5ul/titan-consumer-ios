//
//  TransactionGroup.swift
//  Solid
//
//  Created by Solid iOS Team on 15/03/21.
//

import Foundation

class TransactionsGroup {
    enum GroupType {
        case today
        case last30Days
        case older
    }

    var type: GroupType = .today
    var transactions = [TransactionModel]()
    var groupTitle: String = ""

    func getTitleString() -> String {
       var strTitle = ""

        switch type {
        case .today:
            strTitle = Utility.localizedString(forKey: "today").uppercased()
        case .last30Days:
            strTitle = Utility.localizedString(forKey: "last_30days").uppercased()
        case .older:
            strTitle = Utility.localizedString(forKey: "older").uppercased()
        }

        return strTitle
    }
}

class AccountsGroup {
    var accounts = [AccountDataModel]()
    var initialAccounts = [AccountDataModel]()
    var groupTitle: String = ""
    var accountType: AccountType = .personalChecking
}
