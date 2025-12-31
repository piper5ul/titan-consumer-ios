//
//  TransactionDataHandler.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import Foundation

class TransactionDataHandler {
    var dataSource = [[TransactionRowData]]()
    var transaction: TransactionModel!
    var transactionAction: AccountActionDataModel!
}

extension TransactionDataHandler {
    func createDataSource(_ transactionData: TransactionModel) {
        transaction = transactionData

        // TRANSACTION SUMMARY
        let section1 = createTransactionSummary()
        dataSource.append(section1)

        // DETAILS
        let section2 = createTransactionData(transactionData)
        dataSource.append(section2)

        // ACTIONS
        let section3 = createTransactionActionData()
        dataSource.append(section3)

        // ADDRESS
        if(transactionData.transferType == TransferType.card), let _ = transaction.card?.merchant {
            let section4 = createAddressLocationData()
            dataSource.append(section4)
        }
    }
}

extension TransactionDataHandler {
	// Summary
	func createTransactionSummary() -> [TransactionRowData] {
        return getEmptySection()
	}

	// Details
	func createTransactionData(_ transactionData: TransactionModel) -> [TransactionRowData] {
        var section = [TransactionRowData]()
        if transactionData.transferType == TransferType.card {
            section = transactionDataForCard()
        } else if transactionData.transferType == TransferType.intrabank {
            section = transactionDataForIntraBank()
        } else if transactionData.transferType == TransferType.ACH {
            section = transactionDataForACH()
        } else {
            section = transactionDataForCheck()
        }
        return section
    }

    func transactionDataForIntraBank() -> [TransactionRowData] {
        // FOR ACH AND INTRABANK
        // source
        var section = [TransactionRowData]()

        var row1 = TransactionRowData()
        row1.key = TransactionDetails.source.getTitleKey()
        if transaction.accountId != nil {
            row1.value = transaction.accountId
        }
        // section.append(row1)

        // Paid to
        var row2 = TransactionRowData()
        if transaction.txnType == TransactionType.debit {
            row2.key = TransactionDetails.paidTo.getTitleKey()
        } else { row2.key = TransactionDetails.receivedFrom.getTitleKey()
        }

        if transaction.intrabank?.name != nil {
            row2.value = transaction.intrabank?.name
        }
        //	section.append(row2)

        // Description
        var row3 = TransactionRowData()
        row3.key = TransactionDetails.description.getTitleKey()
        if let description = transaction.description {
            row3.value = description
        }
        section.append(row3)

        var row4 = TransactionRowData()
        row4.key = TransactionDetails.transactionId.getTitleKey()
        if let tid = transaction.id {
            row4.value = tid
        }
        // section.append(row4)
        return section
    }

    func transactionDataForCard() -> [TransactionRowData] {
        // source
        var section = [TransactionRowData]()
        var row1 = TransactionRowData()
        row1.key = TransactionDetails.source.getTitleKey()
        if let aCard = transaction.card, let label = aCard.label {
            row1.value = label
        }
        section.append(row1)

        // merchant
        var row2 = TransactionRowData()
        row2.key = TransactionDetails.merchant.getTitleKey()
        if let merchant  =  transaction.card?.merchant?.merchantName {
            row2.value = merchant
        }
        section.append(row2)

        // transactionId
        var row3 = TransactionRowData()
        row3.key = TransactionDetails.transactionId.getTitleKey()
        if let tid = transaction.id {
            row3.value = tid
        }
        section.append(row3)
        return section
    }

    func transactionDataForACH() -> [TransactionRowData] {
        // source
        var section = [TransactionRowData]()
        var row1 = TransactionRowData()
        row1.key = TransactionDetails.source.getTitleKey()
        if let aId = transaction.accountId {
            row1.value = aId
        }
        // section.append(row1)

        // Paid to
        var row2 = TransactionRowData()
        if transaction.txnType == TransactionType.debit {
            row2.key = TransactionDetails.paidTo.getTitleKey()
        } else { row2.key = TransactionDetails.receivedFrom.getTitleKey()
        }

        if let cname = transaction.ach?.name {
            row2.value = cname
        }
        // section.append(row2)

        // Description
        var row3 = TransactionRowData()
        row3.key = TransactionDetails.description.getTitleKey()
        if transaction.title != nil {
            row3.value = transaction.description
        }
        section.append(row3)

        var row4 = TransactionRowData()
        row4.key = TransactionDetails.transactionId.getTitleKey()
        if let tid = transaction.id {
            row4.value = tid
        }
        // section.append(row4)
        return section
    }

    func transactionDataForCheck() -> [TransactionRowData] {

        var section = [TransactionRowData]()

        // Description
        var row1 = TransactionRowData()
        row1.key = TransactionDetails.description.getTitleKey()
        if transaction.title != nil {
            row1.value = transaction.description
        }
        section.append(row1)

        return section
    }
    
    func getDescriptionData() -> TransactionRowData {
        var descriptionRow = TransactionRowData()
        descriptionRow.key = TransactionDetails.description.getTitleKey()
        if let description = transaction.description {
            descriptionRow.value = description
        }
       
        return descriptionRow
    }
    
	// Actions
    func createTransactionActionData() -> [TransactionRowData] {
		if Utility.isDeviceIpad() {
			return getEmptySectionWithIpad()
		} else {
			return getEmptySection()
		}
    }

	func getEmptySectionWithIpad() -> [TransactionRowData] {
		var section = [TransactionRowData]()
		// view PDF
		var row1 = TransactionRowData()
		row1.key = TransactionActionDetails.viewPDF.getTitleKey()
		section.append(row1)
		
		// report problem
		var row2 = TransactionRowData()
		row2.key = TransactionActionDetails.reportProblem.getTitleKey()
		section.append(row2)
		return section
	}
	
    func getEmptySection() -> [TransactionRowData] {
        var section = [TransactionRowData]()
        // view PDF, report problem
        let row1 = TransactionRowData()
        section.append(row1)
        return section
    }

	// Address Data
    func createAddressData() -> [TransactionRowData] {
        var section = [TransactionRowData]()

        var row2 = TransactionRowData()
        row2.key = TransactionAddressDetails.city.getTitleKey()
		if let locality = transaction.card?.merchant?.merchantCity {
            row2.value = locality
        }
		row2.cellType = .data
        section.append(row2)

        var row3 = TransactionRowData()
        row3.key = TransactionAddressDetails.country.getTitleKey()
        if let country = transaction.card?.merchant?.merchantCountry {
            row3.value = country
        }

		row3.cellType = .data
		section.append(row3)
        return section
    }

	// Address Location Data
	func createAddressLocationData() -> [TransactionRowData] {
		var section = [TransactionRowData]()
		var row = TransactionRowData()
		row.cellType = .location
		section.append(row)
		return section
	}
}
