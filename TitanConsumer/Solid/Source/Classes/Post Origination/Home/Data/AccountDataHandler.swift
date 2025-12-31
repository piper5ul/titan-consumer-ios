//
//  AccountDataHandler.swift
//  Solid
//
//  Created by Solid iOS Team on 3/2/21.
//

import Foundation
import UIKit

class AccountDataHandler {
	var dataSource = [[AccountRowData]]()
	var account: AccountDataModel!
	var accountAction: AccountActionDataModel!
//	typealias headerDataTouple = (String, String, String, UIColor)
}

extension AccountDataHandler {
	func createDataSource(_ accountData: AccountDataModel) {
		account = accountData
		let section1 = createBasicInfoData()
		dataSource.append(section1)

        let section2 = createOtherData()
        dataSource.append(section2)

		let section3 = createAccountActionData()
	    dataSource.append(section3)
	}
}
extension AccountDataHandler {
	// MARK: - Basic Account Details
	func createBasicInfoData() -> [AccountRowData] {
		let section = [AccountRowData]()
		return section
	}

    // MARK: - Other Account Details
    func createOtherData() -> [AccountRowData] {
        var section = [AccountRowData]()

        // type
        var row1 = AccountRowData()
        row1.key = AccountDetails.atype.getTitleKey()
        if account.type != nil {
            // row1.value = account.type
            var type = ""
            if let bType =  account.type {
                type = (bType == .cardAccount) ? "Card Account" : AccountType.title(for: bType.rawValue)
                row1.value  = type
            }
            section.append(row1)
        }

        // date opened
        var row2 = AccountRowData()
        row2.key = AccountDetails.dateOpened.getTitleKey()
        if account.createdAt != nil {
            row2.value = account.createdAt?.utcDateTo(formate: "MMM dd, yyyy 'at' hh:mm a")
        }
        section.append(row2)

        // sponsor bank
        var row3 = AccountRowData()
        row3.key = AccountDetails.sponsorBank.getTitleKey()
        if let sponBankname = account.sponsorBankName {
            row3.value = sponBankname
        }
        section.append(row3)

        // Interest
        var row4 = AccountRowData()
        row4.key = AccountDetails.interest.getTitleKey()
        if account.interest != nil {
            row4.value = (account.interest ?? "") + "% " + Utility.localizedString(forKey: "interest_apy")
        }
        section.append(row4)

        // fees
        var row5 = AccountRowData()
        row5.key = AccountDetails.fees.getTitleKey()
        if let fees = account.fees {
            row5.value =  Utility.getFormattedAmount(amount: fees)
        }
        section.append(row5)
        return section
    }

	// MARK: - Account Action Details
	func createAccountActionData() -> [AccountRowData] {
		var section = [AccountRowData]()
		// statement
		var row1 = AccountRowData()
		row1.key = AccountActionDetails.statement.getTitleKey()
		row1.value = ""
		row1.iconName = ""
		row1.cellType = .detail
		section.append(row1)

	   /* // Lock ACH
		var row2 = AccountRowData()
		row2.key = AccountActionDetails.lockACH.getTitleKey()
		row2.value = ""
		row2.iconName = ""
		row2.cellType = .detail
		section.append(row2)
		
		//Limits
		var row3 = AccountRowData()
		row3.key = AccountActionDetails.limits.getTitleKey()
		row3.value = ""
		row3.iconName = ""
		row3.cellType = .detail
		section.append(row3)*/

		// Disclosures
		var row4 = AccountRowData()
		row4.key = AccountActionDetails.disclosures.getTitleKey()
		row4.value = ""
		row4.iconName = ""
		row4.cellType = .detail
		//section.append(row4)
		return section
	}

}
