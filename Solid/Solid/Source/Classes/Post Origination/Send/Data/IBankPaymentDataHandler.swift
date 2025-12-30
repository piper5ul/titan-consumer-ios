//
//  IBankPaymentDataHandler.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation

class IBankPaymentDataHandler {
    var dataSource = [[ContactRowData]]()
    var contactModel: ContactDataModel?
    var paymentModel: PaymentModel?
}

extension IBankPaymentDataHandler {

    func createTableData(_ contactData: ContactDataModel, _ paymentData: PaymentModel) {
		contactModel = contactData
		paymentModel = paymentData

		let section1 = createAmountData()
		dataSource.append(section1)

		let section2 = createSourceData()
		dataSource.append(section2)

		if contactData.selectedPaymentMode == ContactAccountType.ach {
			let section3 = createDestinationDataForACH()
			dataSource.append(section3)
		} else {
			let section3 = createDestinationData()
			dataSource.append(section3)
		}
	}

    func createAmountData() -> [ContactRowData] {
        var section = [ContactRowData]()

        // Amount
        var row1 = ContactRowData()
        row1.placeholder = Utility.localizedString(forKey: "currency")
        row1.textfieldType = .currency
        row1.key = Utility.localizedString(forKey: "pay_row_amount")
        if let paymentModel = paymentModel, let amount = paymentModel.amount {
            let currency = Utility.localizedString(forKey: "currency")
            row1.value = "\(currency)\(amount)"
        }
        section.append(row1)

        // Purpose
        var row2 = ContactRowData()
        row2.placeholder = Utility.localizedString(forKey: "pay_row_purpose_placeholder")
        row2.textfieldType = .alphaNumeric
        row2.key = Utility.localizedString(forKey: "pay_row_purpose")
        if let paymentModel = paymentModel, let desc = paymentModel.description {
            row2.value = desc
        }
        section.append(row2)

        return section
    }

    func createSourceData() -> [ContactRowData] {
        var section = [ContactRowData]()

        // FROM
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "pay_row_from")
		if AppGlobalData.shared().accTypePersonalChecking {
			if let name = AppGlobalData.shared().personData.name {
				row1.value = name
			}
		} else {
			if let selectedBusiness = AppGlobalData.shared().businessData, let name = selectedBusiness.legalName {
				row1.value = name
			}
		}
		section.append(row1)

        // ACCOUNT
		var row2 = ContactRowData()
		row2.key = Utility.localizedString(forKey: "pay_row_account")
		if let selectedAcc = AppGlobalData.shared().accountData, let name = selectedAcc.label, let num = selectedAcc.accountNumber {
			row2.value = "\(name) \(num)"
		}

        section.append(row2)
        return section
    }
	
	func createCardData() -> [ContactRowData] {
		var section = [ContactRowData]()
		
		// FROM
		var source = ContactRowData()
		source.key = Utility.localizedString(forKey: "pay_section_source")
		if let accountName = AppGlobalData.shared().accountData?.label {
			source.value = accountName
			section.append(source)
		}
		
		var destination = ContactRowData()
		destination.key = Utility.localizedString(forKey: "pay_section_destination")
		if let contact = contactModel, let accName = contact.name {
			destination.value = accName
			section.append(destination)
		}
		
		// Account Name
		var email = ContactRowData()
		if let contact = contactModel, let accEmail = contact.email, !accEmail.isEmpty {
			email.key = Utility.localizedString(forKey: "email")
			email.value = accEmail
			section.append(email)
		}
		
		var phone = ContactRowData()
		phone.key = Utility.localizedString(forKey: "phone")
		if let contact = contactModel, let phoneNo = contact.phone {
            let formatedNumber = Utility.getFormattedPhoneNumber(forCountryCode: Constants.countryCodeUS, phoneNumber: phoneNo, withMaxLimit: Constants.phoneNumberLimit)
			phone.value = Constants.countryCodeUS + " " + formatedNumber
			section.append(phone)
		}
		
		// Purpose
		var purpose = ContactRowData()
		purpose.placeholder = Utility.localizedString(forKey: "pay_row_purpose")
		purpose.textfieldType = .alphaNumeric
		purpose.key = Utility.localizedString(forKey: "pay_row_purpose")
		if let paymentModel = paymentModel, let desc = paymentModel.description {
			purpose.value = desc
			section.append(purpose)
		}
		return section
	}

    func createDestinationData() -> [ContactRowData] {
        var section = [ContactRowData]()

        // Account Name
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "pay_row_accName")
        if let contact = contactModel, let accName = contact.name {
            row1.value = accName
        }
        section.append(row1)

        // Account Number
        var row2 = ContactRowData()
        row2.key = Utility.localizedString(forKey: "contact_AccountNumber_title")
        if let contact = contactModel, let bankAcc = contact.intrabank, let accNum = bankAcc.accountNumber {
            row2.value = accNum
        }
        section.append(row2)
        return section

    }

	func createDestinationDataForACH() -> [ContactRowData] {
		var section = [ContactRowData]()

		// Account Name
		var row1 = ContactRowData()
		row1.key = Utility.localizedString(forKey: "pay_row_accName")
		if let contact = contactModel, let accName = contact.name {
			row1.value = accName
		}
		section.append(row1)

		// Account Number
		var row2 = ContactRowData()
		row2.key = Utility.localizedString(forKey: "contact_AccountNumber_title")
		if let contact = contactModel, let bankAcc = contact.ach, let accNum = bankAcc.accountNumber {
			row2.value = accNum
		}
		section.append(row2)

		// Routing Number
		var row3 = ContactRowData()
		row3.key = Utility.localizedString(forKey: "contact_RoutingNumber_title")
		if let contact = contactModel, let bankAcc = contact.ach, let routingNum = bankAcc.routingNumber {
			row3.value = routingNum
		}
		section.append(row3)

		// Bank
		var row4 = ContactRowData()
		row4.key = Utility.localizedString(forKey: "contact_Bank_title")
		if let contact = contactModel, let bankAcc = contact.ach, let bankName = bankAcc.bankName {
			row4.value = bankName
		}
		section.append(row4)

		// Account Type
		var row5 = ContactRowData()
		row5.key = Utility.localizedString(forKey: "contact_AccountType_title")
		if let contact = contactModel, let bankAcc = contact.ach, let type = bankAcc.accountType {
			row5.value = AccountType.title(for: type.rawValue) // type.rawValue
		}
		section.append(row5)

		return section

	}
}

extension IBankPaymentDataHandler {

    func createSuccessTableData(_ contactData: ContactDataModel, _ paymentData: PaymentModel) {
        contactModel = contactData
        paymentModel = paymentData
        let paymentMode = contactData.selectedPaymentMode
        switch paymentMode {
        case .ach:
            let section2 = createSuccessDataForAch()
            dataSource.append(section2)
        case .intrabank:
            let section = createSuccessDataForIntrabank()
            dataSource.append(section)
        case .check:
            let section = createSuccessDataForCheck()
            dataSource.append(section)
        case .domesticWire:
            let section = createSuccessDataForDomesticWire()
            dataSource.append(section)
        case .internationalWire:
            let section = createSuccessDataForInternatioanlWire()
            dataSource.append(section)
        case .sendVisaCard:
            let section = createCardData()
            dataSource.append(section)
        default:
            break
        }
    }

	func createSuccessDataForCheck() -> [ContactRowData] {
		var section = [ContactRowData]()
		
		// FROM
		var row1 = ContactRowData()
		row1.key = Utility.localizedString(forKey: "pay_section_source")
		if let accountName = AppGlobalData.shared().accountData?.label {
			row1.value = accountName
		}
		
		var row2 = ContactRowData()
		row2.key = Utility.localizedString(forKey: "pay_section_destination")
		if let contact = contactModel, let accName = contact.name {
			row2.value = accName
		}
		
		// Address
		var row3 = ContactRowData()
		row3.key = Utility.localizedString(forKey: "address")
		if let paymentData = paymentModel {
			row3.value = paymentData.address?.addressStringWithPostalCode()
		}
		
		// Purpose
		var row4 = ContactRowData()
		row4.placeholder = Utility.localizedString(forKey: "pay_row_purpose")
		row4.textfieldType = .alphaNumeric
		row4.key = Utility.localizedString(forKey: "pay_row_purpose")
		if let paymentModel = paymentModel, let desc = paymentModel.description {
			row4.value = desc
		}
		
		section.append(row1)
		section.append(row2)
		section.append(row3)
		section.append(row4)
		
		return section
	}
	
    func createSuccessDataForIntrabank() -> [ContactRowData] {
        var section = [ContactRowData]()

        // FROM
        var source = ContactRowData()
		source.key = Utility.localizedString(forKey: "pay_section_source")
		if let accountName = AppGlobalData.shared().accountData?.label {
			source.value = accountName
		}
        section.append(source)

		var destination = ContactRowData()
		destination.key = Utility.localizedString(forKey: "pay_section_destination")
		if let contact = contactModel, let accName = contact.name {
			destination.value = accName
		}
		section.append(destination)

        // Purpose
        var row3 = ContactRowData()
         row3.placeholder = Utility.localizedString(forKey: "description")
        row3.textfieldType = .alphaNumeric
        row3.key = Utility.localizedString(forKey: "description")
        if let paymentModel = paymentModel, let desc = paymentModel.description {
            row3.value = desc
        }
        section.append(row3)

        return section
    }
	
	func createSuccessDataForAch() -> [ContactRowData] {
		var section = [ContactRowData]()

		// FROM
		var achrow1 = ContactRowData()
		achrow1.key = Utility.localizedString(forKey: "pay_section_source")
		if let accountName = AppGlobalData.shared().accountData?.label {
			achrow1.value = accountName
		}
		section.append(achrow1)

		var achrow2 = ContactRowData()
		achrow2.key = Utility.localizedString(forKey: "pay_section_destination")
		if let contact = contactModel, let accName = contact.name {
			achrow2.value = accName
		}
		section.append(achrow2)

		// Account Number
		var row3 = ContactRowData()
		row3.key = Utility.localizedString(forKey: "contact_AccountNumber_title")
		if let contact = contactModel, let bankAcc = contact.ach, let accNum = bankAcc.accountNumber {
			row3.value = accNum
		}
		section.append(row3)

		// Routing Number
		var row4 = ContactRowData()
		row4.key = Utility.localizedString(forKey: "contact_RoutingNumber_title")
		if let contact = contactModel, let bankAcc = contact.ach, let routingNum = bankAcc.routingNumber {
			row4.value = routingNum
		}
		section.append(row4)

		// Bank
		var row5 = ContactRowData()
		row5.key = Utility.localizedString(forKey: "payment_sucess_bankname")
		if let contact = contactModel, let bankAcc = contact.ach, let bankName = bankAcc.bankName {
			row5.value = bankName
		}
		section.append(row5)

		// Account Type
		var row6 = ContactRowData()
		row6.key = Utility.localizedString(forKey: "contact_AccountType_title")
		if let contact = contactModel, let bankAcc = contact.ach, let type = bankAcc.accountType {
			row6.value = AccountType.title(for: type.rawValue) // type.rawValue
		}
		section.append(row6)

		// Purpose
		var row7 = ContactRowData()
		row7.placeholder = Utility.localizedString(forKey: "pay_row_purpose_placeholder")
		row7.textfieldType = .alphaNumeric
		row7.key = Utility.localizedString(forKey: "pay_row_purpose")
		if let paymentModel = paymentModel, let desc = paymentModel.description {
			row7.value = desc
		}
		section.append(row7)

		return section
	}

	func createSuccessDataForDomesticWire() -> [ContactRowData] {
		var section = [ContactRowData]()

		// FROM
		var row1 = ContactRowData()
		row1.key = Utility.localizedString(forKey: "pay_section_source")
		if let accountName = AppGlobalData.shared().accountData?.label {
			row1.value = accountName
		}
		section.append(row1)

		var row2 = ContactRowData()
		row2.key = Utility.localizedString(forKey: "pay_section_destination")
		if let contact = contactModel, let accName = contact.name {
			row2.value = accName
		}
		section.append(row2)

		// Account Number
		var row3 = ContactRowData()
		row3.key = Utility.localizedString(forKey: "contact_AccountNumber_title")
		if let contact = contactModel, let bankAcc = contact.wire?.domestic, let accNum = bankAcc.accountNumber {
			row3.value = accNum
		}
		section.append(row3)

		// Routing Number
		var row4 = ContactRowData()
		row4.key = Utility.localizedString(forKey: "contact_RoutingNumber_title")
		if let contact = contactModel, let bankAcc = contact.wire?.domestic, let routingNum = bankAcc.routingNumber {
			row4.value = routingNum
		}
		section.append(row4)

		// Bank
		var row5 = ContactRowData()
		row5.key = Utility.localizedString(forKey: "payment_sucess_bankname")
		if let contact = contactModel, let bankAcc = contact.wire?.domestic, let bankName = bankAcc.bankName {
			row5.value = bankName
		}
		section.append(row5)

		// Account Type
		var row6 = ContactRowData()
		row6.key = Utility.localizedString(forKey: "contact_AccountType_title")
		if let contact = contactModel, let bankAcc = contact.wire?.domestic, let type = bankAcc.accountType {
			row6.value = AccountType.title(for: type.rawValue)
		}
		section.append(row6)

		// Purpose
		var row7 = ContactRowData()
		row7.placeholder = Utility.localizedString(forKey: "pay_row_purpose_placeholder")
		row7.textfieldType = .alphaNumeric
		row7.key = Utility.localizedString(forKey: "pay_row_purpose")
		if let paymentModel = contactModel?.wire?.domestic, let desc = paymentModel.purpose {
			row7.value = desc
		}
		section.append(row7)

		return section
	}
    
    func createSuccessDataForInternatioanlWire() -> [ContactRowData] {
        var section = [ContactRowData]()

        // SOURCE
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "pay_section_source")
        if let accountName = AppGlobalData.shared().accountData?.label {
            row1.value = accountName
        }
        section.append(row1)

        // DESTINATION
        var row2 = ContactRowData()
        row2.key = Utility.localizedString(forKey: "pay_section_destination")
        if let contact = contactModel, let accName = contact.name {
            row2.value = accName
        }
        section.append(row2)

        // SWIFT CODE
        var row3 = ContactRowData()
        row3.key = Utility.localizedString(forKey: "payment_success_swiftCode")
        if let contact = contactModel, let internationalWire = contact.wire?.international, let swiftCode = internationalWire.bankIdentifierCode {
            row3.value = swiftCode
        }
        section.append(row3)
        
        // BANK NAME
        var row4 = ContactRowData()
        row4.key = Utility.localizedString(forKey: "payment_sucess_bankname")
        if let contact = contactModel, let internationalWire = contact.wire?.international, let bankName = internationalWire.beneficiaryBank {
            row4.value = bankName
        }
        section.append(row4)
        
        // ACCOUNT NUMBER
        var row5 = ContactRowData()
        row5.key = Utility.localizedString(forKey: "contact_AccountNumber_title")
        if let contact = contactModel, let internationalWire = contact.wire?.international, let accNum = internationalWire.accountNumber {
            row5.value = accNum
        }
        section.append(row5)

        // COUNTRY
        var row6 = ContactRowData()
        row6.key = Utility.localizedString(forKey: "contact_country_title")
        if let contact = contactModel, let internationalWire = contact.wire?.international, let country = internationalWire.beneficiaryAddress?.country {
            row6.value = country
        }
        section.append(row6)
        
        // PURPOSE
        var row7 = ContactRowData()
        row7.placeholder = Utility.localizedString(forKey: "pay_row_purpose_placeholder")
        row7.textfieldType = .alphaNumeric
        row7.key = Utility.localizedString(forKey: "pay_row_purpose")
        if let paymentModel = contactModel?.wire?.international, let desc = paymentModel.purpose {
            row7.value = desc
        }
        section.append(row7)

        return section
    }
}

// FOR PULL FUNDS
extension IBankPaymentDataHandler {

    func createPullFundsSuccessTableData(_ contactData: ContactDataModel, _ paymentData: PaymentModel, _ pullFundsFlow: PullFundsFlow ) {
        contactModel = contactData
        paymentModel = paymentData

        var section = [ContactRowData]()

        var accNo = ""
        var accName = ""
        
        // Souce
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "source")
        if let accountData = contactModel?.ach {
            let strBankName = accountData.bankName ?? ""
            let strAccNo = accountData.accountNumber?.last4() ?? ""
            let strSource = strBankName + " XXXXXX" + strAccNo

            accNo = strSource
        } else if let accountData = contactModel?.debitCard {
            let strDebitCardNo = accountData.last4 ?? ""
            let strSource = "XXXX XXXX XXXX " + strDebitCardNo

            accNo = strSource
        }

        // Destination
        var row2 = ContactRowData()
        row2.key = Utility.localizedString(forKey: "pay_section_destination")
        if let accountName = AppGlobalData.shared().accountData?.label {
            accName = accountName
        }

        // Description
        var row3 = ContactRowData()
        row3.key = Utility.localizedString(forKey: "description")
        if let paymentModel = paymentModel, let desc = paymentModel.description {
            row3.value = desc
        }

        if pullFundsFlow == .pullFundsOut {
            row1.value = accName
            row2.value = accNo
        } else {
            row1.value = accNo
            row2.value = accName
        }

        section.append(row1)
        section.append(row2)
        section.append(row3)

        dataSource.append(section)
    }
}
