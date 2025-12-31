//
//  TransactionData.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import Foundation

struct TransactionRowData {
    var key: String?
    var value: Any?
    var title: String?
	var rightValue: String?
    var placeholder: String?
    var iconName: String?
    var isSwitchOn: Bool? = false
    var textfieldType: TextFieldType?
    var cellType = AccountCellType.data
}

public enum TransactionCellType {
    case data
    case detail
    case switched
    case location
    case btn
}

enum TransactioSummaryDetails: Int {
	case  viewPDF = 0,
		  viewPDFDesc,
		  reportProblem,
		  reportProblemDesc

    func getTitleKey() -> String {
        switch self {
            case .viewPDF: return Utility.localizedString(forKey: "viewPDF")
            case .viewPDFDesc:
                return Utility.localizedString(forKey: "viewPDFDesc")
            case .reportProblem:
                return Utility.localizedString(forKey: "reportProblem")
            case .reportProblemDesc:
                return Utility.localizedString(forKey: "reportProblemDesc")
        }
    }

	func getImageIconScreen() -> String {
		switch self {
			case .viewPDF:
				return "Card"
			case .reportProblem:
				return "Card"
			default:
				return ""
		}
	}
}

enum TransactionDetails: Int {
    case  title = 0,
    source,
    merchant,
    transactionId,
	paidTo,
	description,
	receivedFrom
    
    func getTitleKey() -> String {
        switch self {
            case .title:
                return Utility.localizedString(forKey: "title")
            case .source:
                return Utility.localizedString(forKey: "source")
            case .merchant:
                return Utility.localizedString(forKey: "merchant")
            case .transactionId:
                return Utility.localizedString(forKey: "transactionId")
			case .paidTo :
				return Utility.localizedString(forKey: "paidTo")
			case .description :
				return Utility.localizedString(forKey: "description")
			case .receivedFrom :
				return Utility.localizedString(forKey: "receivedFrom")
		}
    }
}

enum TransactionActionDetails: Int {
    case  viewPDF = 0,
          viewPDFDesc,
          reportProblem,
          reportProblemDesc

    func getTitleKey() -> String {
        switch self {
            case .viewPDF:
                return Utility.localizedString(forKey: "viewPDF")
            case .viewPDFDesc:
                return Utility.localizedString(forKey: "viewPDFDesc")
            case .reportProblem:
                return Utility.localizedString(forKey: "reportProblem")
            case .reportProblemDesc:
                return Utility.localizedString(forKey: "reportProblemDesc")
        }
    }

    func getImageIconScreen() -> String {
        switch self {
            case .viewPDF:
                return "Card"
            case .reportProblem:
                return "Card"
            default:
                return ""
        }
    }
}

enum TransactionAttachmentDetails: Int {
    case  invoice = 0,
          receipt,
          attachments,
          notes

    func getTitleKey() -> String {
        switch self {
            case .invoice:
                return Utility.localizedString(forKey: "invoice")
            case .receipt:
                return Utility.localizedString(forKey: "receipt")
            case .attachments:
                return Utility.localizedString(forKey: "attachments")
            case .notes:
                return Utility.localizedString(forKey: "notes")
        }
    }
}

enum TransactionAddressDetails: Int {
    case  streetName = 0,
          city,
          country

    func getTitleKey() -> String {
        switch self {
            case.streetName:
                return Utility.localizedString(forKey: "contact_street_title")
            case .city:
                return Utility.localizedString(forKey: "contact_city_title")
            case .country:
                return Utility.localizedString(forKey: "contact_country_title")
        }
    }
}
