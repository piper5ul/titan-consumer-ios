//
//  CardDataHandler.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation

class CardDataHandler {
    var dataSource = [[CardRowData]]()
    var card: CardModel!
}

extension CardDataHandler {
    func createCardSuccessDataSource(_ cardData: CardModel) {
        card = cardData
        let section1 = createCardSuccessData()
        dataSource.append(section1)
    }

    func createCardDetailsDataSource(_ cardData: CardModel) {
        card = cardData
        let section2 = createCardDetailsActionData()
        dataSource.append(section2)
    }
}

extension CardDataHandler {
    func createCardSuccessData() -> [CardRowData] {
        var section = [CardRowData]()

        var row1 = CardRowData()
        row1.key = CardDetails.label.getTitleKey()
        if card.label != nil {
            row1.value = card.label
        }
        section.append(row1)

        var row2 = CardRowData()
        row2.key = CardDetails.amountLimit.getTitleKey()
        if card.limitAmount != nil {
            row2.value = card.limitAmount
            let strAmount = Utility.localizedString(forKey: "currency") + (card.limitAmount ?? "0") + " " + (card.limitInterval?.localizeDescription() ?? "")
            row2.value = strAmount.lowercased()
        }
        section.append(row2)

        var row3 = CardRowData()
        row3.key = CardDetails.cardStatus.getTitleKey()
        if card.cardStatus != nil {
            row3.value = card.cardStatus?.localizeDescription()
            let strStatus = card.cardStatus?.localizeDescription()
            row3.value = strStatus?.replacingOccurrences(of: "•", with: "")
        }
        section.append(row3)

        if card.cardType == .physical {
            var row4 = CardRowData()
            row4.key = CardDetails.cardLast4.getTitleKey()
            if let last4 = card.last4 {
                row4.value = "**** **** **** \(last4)"
            }
            section.append(row4)
            
            var row5 = CardRowData()
            row5.key = CardDetails.cardExp.getTitleKey()
            if let aMonth = card.expiryMonth, let aYear = card.expiryYear {
                let dtStr = aYear.count > 2 ? String(aYear.suffix(2)) : aYear
                row5.value = "\(aMonth)/\(dtStr)"
            }
            
            section.append(row5)
        }
        
        return section
    }

    func createCardDetailsData() -> [CardRowData] {
        var section = [CardRowData]()

        var row1 = CardRowData()
        row1.key = "VISA *" + (card.last4 ?? "")
        if let aMonth = card.expiryMonth, let aYear = card.expiryYear {
            let dateFormat = "\(aMonth)/\(aYear)".toCardValidityDate()
            row1.value = "Debit card valid until " + dateFormat
        }
        row1.iconName = "Card"

        section.append(row1)
        return section
    }

    func createCardDetailsActionData() -> [CardRowData] {
        var section = [CardRowData]()

        var row1 = CardRowData()
        var strRow1Key = Utility.localizedString(forKey: "card")
        if card.label != nil {
            strRow1Key += " : " + (card.label ?? "")
        }
        row1.key = strRow1Key
        row1.cellType = .btn
        section.append(row1)

        var row2 = CardRowData()
        var strRow2Key = CardDetails.amountLimit.getTitleKey()
        if card.limitAmount != nil {
            strRow2Key += " : " + Utility.localizedString(forKey: "currency") + (card.limitAmount ?? "0")
        }
        row2.key = strRow2Key
        row2.cellType = .btn
        section.append(row2)

        return section
    }
}
