//
//  CardData.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation

struct CardRowData {
    var key: String?
    var value: Any?
    var iconName: String?
    var cellType = CardCellType.data
}

public enum CardCellType {
    case data
    case detail
    case switched
    case btn
    case location
}

enum CardDetails: Int {
    case  label = 0,
          amountLimit,
          cardStatus,
          cardLast4,
          cardExp

    func getTitleKey() -> String {
        switch self {
            case .label:
                return Utility.localizedString(forKey: "card_label")
            case .amountLimit:
                return Utility.localizedString(forKey: "card_spendLimit")
            case .cardStatus:
                return Utility.localizedString(forKey: "card_status")
            case .cardLast4:
                return Utility.localizedString(forKey: "cardInfo_row_title_CardNo")
            case .cardExp:
                return Utility.localizedString(forKey: "cardInfo_detail_expDate")
        }
    }

    func getImageIconScreen() -> String {
        switch self {
            case .label:
                return "CardLabel"
            case .amountLimit:
                return "SpendLimits"
            default:
                return "Card"
        }
    }
}
