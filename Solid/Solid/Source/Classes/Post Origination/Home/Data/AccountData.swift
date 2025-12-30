//
//  AccountData.swift
//  Solid
//
//  Created by Solid iOS Team on 3/2/21.
//

import Foundation
struct AccountRowData {
	var key: String?
	var value: Any?
	var iconName: String?
	var rightValue: String?
	var cellType = AccountCellType.data
}

public enum AccountCellType {
	case data
	case detail
	case switched
	case btn
	case location
}

enum AccountDetails: Int {
	case  accountNumber = 0,
		  routingNumber,
		  label,
		  atype,
		  dateOpened,
		  sponsorBank,
		  interest,
		  fees,
		  availableBalance

	func getTitleKey() -> String {
		switch self {
			case .accountNumber:
				return Utility.localizedString(forKey: "acc_detail_num_title") // "Account number"
			case .routingNumber:
				return Utility.localizedString(forKey: "acc_detail_rout_title") // "Routing number"
			case .label:
				return Utility.localizedString(forKey: "acc_detail_acc_name") // "Account name"
			case .availableBalance:
				return Utility.localizedString(forKey: "acc_detail_acc_balance") // "Balance"
			case .atype:
				return Utility.localizedString(forKey: "fund_type_row") // "Type"
			case .dateOpened:
				return Utility.localizedString(forKey: "acc_detail_date_opened") // "Date opened"
			case.sponsorBank:
				return Utility.localizedString(forKey: "fund_row_sponsorbank") // "Sponsor Bank"
			case .interest:
				return Utility.localizedString(forKey: "acc_detail_interest") // "Interest"
			case .fees:
				return Utility.localizedString(forKey: "acc_detail_fees") // "Fees"
		}
	}
}

enum AccountActionDetails: Int {
	case  statement = 0,
		  lockACH,
		  limits,
		  disclosures

	func getTitleKey() -> String {
		switch self {
			case .statement:
                return Utility.localizedString(forKey: "statements") // "Statements"
			case .lockACH:
				return "Lock ACH Withdrawals"
			case .limits:
				return "Limits"
			case .disclosures:
				return Utility.localizedString(forKey: "profile_disclosures") // "Disclosures"

		}
	}

	func getDescriptionValue() -> String {
		switch self {
			case .statement:
				return "You can view all your statements"
			case .lockACH:
				return "You can lock ACH Withdrawals"
			case .limits:
				return "View your current limits"
			case .disclosures:
				return "View account disclosures"
		}
	}

	func getImageIconScreen() -> String {
		switch self {
			case .statement:
				return "statement"
			case .lockACH:
				return "lock"
			case .limits:
				return "bell"
			case .disclosures:
				return "disclosures"
		}
	}

}
