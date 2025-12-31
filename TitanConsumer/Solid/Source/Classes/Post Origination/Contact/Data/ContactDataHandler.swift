//
//  ContactDataHandler.swift
//  Solid
//
//  Created by Solid iOS Team on 3/2/21.
//

import Foundation
import UIKit

class ContactDataHandler {
	var dataSource = [[ContactRowData]]()
	var contact: ContactDataModel!
	var contactAction: AccountActionDataModel!
}

extension ContactDataHandler {
    func createDataSource(_ contactData: ContactDataModel) {
		contact = contactData

        let section1 = createPersonalInfoData()
		dataSource.append(section1)

		let section2 = createActionData()
		dataSource.append(section2)
	}
}
extension ContactDataHandler {
	// MARK: - Basic Account Details

	func createPersonalInfoData() -> [ContactRowData] {
		var section = [ContactRowData]()

        // Phone
		var row1 = ContactRowData()
		row1.key = ContactPersonalDetails.phone.getTitleKey()
		if let phone = contact.phone, !phone.isEmpty, phone != phone.countryCode() {
            let countryCode = phone.countryCode()
            let phoneLimit = phone.phoneNumberLimit()
            let formatedNumber = Utility.getFormattedPhoneNumber(forCountryCode: countryCode, phoneNumber: phone, withMaxLimit: phoneLimit)
            row1.value = countryCode + " " + formatedNumber
		} else {
			row1.value = Utility.localizedString(forKey: "contact_detail_AddPhone")
		}
		section.append(row1)

		// Email
		var row2 = ContactRowData()
		row2.key = ContactPersonalDetails.email.getTitleKey()
		if let email = contact.email, !email.isEmpty {
			row2.value = email
		} else {
			row2.value = Utility.localizedString(forKey: "contact_detail_AddEmail")
		}
		section.append(row2)

		// Email
		var row3 = ContactRowData()
		row3.key = ContactPersonalDetails.address.getTitleKey()
        var strAddress = ""
        if let checkAddress = contact.check?.address {
            strAddress = checkAddress.addressString()
		} else if let wireAddress = contact.wire?.domestic?.address {
            strAddress = wireAddress.addressString()
        } else if let cardAddress = contact.card?.address {
            strAddress = cardAddress.addressString()
        }
        
        row3.value = strAddress

        if !strAddress.isEmpty {
            section.append(row3)
        }
        
		return section
	}

	func createIntrabankAccountData() -> [ContactRowData] {
		var section = [ContactRowData]()

        // Account number
		var row1 = ContactRowData()
		row1.key = CantactAccountDetail.accountNumber.getTitleKey()
		if contact.intrabank?.accountNumber != nil {
			row1.value = contact.intrabank?.accountNumber
		}
		section.append(row1)

		return section
	}

    func createACHAccountData() -> [ContactRowData] {
        var section = [ContactRowData]()

        var row1 = ContactRowData()
        row1.key = CantactAccountDetail.accountNumber.getTitleKey()
        if contact.ach?.accountNumber != nil {
            row1.value = contact.ach?.accountNumber
        }
        section.append(row1)

        // Account Number
        var row2 = ContactRowData()
        row2.key = CantactAccountDetail.routingNumber.getTitleKey()
        if contact.ach?.routingNumber != nil {
            row2.value = contact.ach?.routingNumber
        }
        section.append(row2)

        // Account Number
        var row3 = ContactRowData()
        row3.key = CantactAccountDetail.bank.getTitleKey()
        if contact.ach?.bankName != nil {
            row3.value = contact.ach?.bankName
        }
        section.append(row3)

        // Account Number
        var row4 = ContactRowData()
        row4.key = CantactAccountDetail.accountType.getTitleKey()

        var type = ""
        if let bType =  contact?.ach?.accountType {
            type =  AccountType.title(for: bType.rawValue)
            row4.value  = type
        }
        section.append(row4)

        return section
    }

	// MARK: - Account Action Details

	func createActionData() -> [ContactRowData] {
		var section = [ContactRowData]()

        if let isContactMakePaymentEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isContactMakePaymentEnabled, isContactMakePaymentEnabled {
                var row1 = ContactRowData()
                row1.key = ContactActionDetails.makePayment.getTitleKey()
                row1.value = ContactActionDetails.makePayment.getTitleKey()
                row1.cellType = .detail
                section.append(row1)
        }

		var row2 = ContactRowData()
		row2.key = ContactActionDetails.paymentHistory.getTitleKey()
		row2.value = ContactActionDetails.paymentHistory.getTitleKey()
        row2.cellType = .detail
		section.append(row2)

		var row3 = ContactRowData()
		row3.key = ContactActionDetails.editContact.getTitleKey()
		row3.value = ContactActionDetails.editContact.getTitleKey()
        row3.cellType = .detail
		section.append(row3)

		var row4 = ContactRowData()
		row4.key = ContactActionDetails.deleteContact.getTitleKey()
		row4.value = ContactActionDetails.deleteContact.getTitleKey()
        row4.cellType = .detail
		section.append(row4)
		return section

	}
	func createAccountActionData() -> [ContactRowData] {
		var section = [ContactRowData]()
		// make payment and view history
        let row1 = ContactRowData()
		section.append(row1)

		return section
	}

    // MARK: - Delete Contact
    func createContactDeleteData() -> [ContactRowData] {
        var section = [ContactRowData]()

        // Delete contact
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "contact_row_DeleteContact")
        row1.value = ""
        row1.cellType = .detail
        section.append(row1)

        return section
    }
}
