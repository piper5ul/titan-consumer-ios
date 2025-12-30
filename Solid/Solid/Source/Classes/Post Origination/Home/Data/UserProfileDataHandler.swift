//
//  UserProfileDataHandler.swift
//  Solid
//
//  Created by Solid iOS Team on 3/19/21.
//

import Foundation
import UIKit

class UserProfileDataHandler {
	var dataSource = [[UserProfileRowData]]()
	var profile: PersonResponseBody!
	var profileAction: AccountActionDataModel!
}

extension UserProfileDataHandler {
	func createDataSource(_ profileData: PersonResponseBody) {
		profile = profileData

		let section1 = createPersonalInfoData()
		dataSource.append(section1)

		let section = createPersonalInfoData()
		dataSource.append(section)

		let section2 = createProfileActionData()
		dataSource.append(section2)

		// let section3 = createAddressData()
		// dataSource.append(section3)

		let section4 = createAddressLocationData()
		dataSource.append(section4)

	}
}
extension UserProfileDataHandler {
	// MARK: - Basic Account Details
	func createPersonalInfoData() -> [UserProfileRowData] {
		var section = [UserProfileRowData]()
		// name
		var row1 = UserProfileRowData()
		row1.key = UserDetails.name.getTitleKey()
		if let name = profile.name {
			row1.value = name
		}
		section.append(row1)

		// Phone number
		var row2 = UserProfileRowData()
		row2.key = UserDetails.mobileNumber.getTitleKey()
		if let phone = profile.phone {
            let countryCode = phone.countryCode()
            let phoneLimit = phone.phoneNumberLimit()
            let formatedNumber = Utility.getFormattedPhoneNumber(forCountryCode: countryCode, phoneNumber: phone, withMaxLimit: phoneLimit)
            row2.value =  countryCode + " " + formatedNumber
		}
		section.append(row2)

		// email
		var row3 = UserProfileRowData()
		row3.key = UserDetails.email.getTitleKey()
		if let email = profile.email {
			row3.value = email
		}
		section.append(row3)

		return section
	}

	// MARK: - Account Action Details
	func createProfileActionData() -> [UserProfileRowData] {
		var section2 = [UserProfileRowData]()
		// statement
		var actionRow1 = UserProfileRowData()
        actionRow1.key = UserActionDetails.helpcenter.getTitleKey()
        actionRow1.value = UserActionDetails.helpcenter.getDescriptionValue()
        actionRow1.iconName = UserActionDetails.helpcenter.getImageIconScreen()
        actionRow1.cellType = .detail
        section2.append(actionRow1)

		var actionRow2 = UserProfileRowData()
        actionRow2.key = UserActionDetails.getintouch.getTitleKey()
        actionRow2.value = UserActionDetails.getintouch.getDescriptionValue()
        actionRow2.iconName = UserActionDetails.getintouch.getImageIconScreen()
        actionRow2.cellType = .detail
        section2.append(actionRow2)

		var actionRow3 = UserProfileRowData()
        actionRow3.key = UserActionDetails.limits.getTitleKey()
        actionRow3.value = UserActionDetails.limits.getDescriptionValue()
        actionRow3.iconName = UserActionDetails.limits.getImageIconScreen()
        actionRow3.cellType = .detail
//		section2.append(actionRow3)

		var actionRow4 = UserProfileRowData()
        actionRow4.key = UserActionDetails.disclosures.getTitleKey()
        actionRow4.value = UserActionDetails.disclosures.getDescriptionValue()
        actionRow4.iconName = UserActionDetails.disclosures.getImageIconScreen()
        actionRow4.cellType = .detail
        //section2.append(actionRow4)

		return section2
	}

	// MARK: - Basic address Data
	func createAddressData() -> [UserProfileRowData] {
		var section = [UserProfileRowData]()

		// street
		var row1 = UserProfileRowData()
		row1.key = CantactAddressDetail.streetName.getTitleKey()
		if let streetName =  profile.address?.line1 {
			row1.value = streetName
		}
		section.append(row1)

		// city
		var row2 = UserProfileRowData()
		row2.key = CantactAddressDetail.city.getTitleKey()
		if let city = profile.address?.city {
			row2.value = city
		}
		section.append(row2)

		// country
		var row3 = UserProfileRowData()
		row3.key = CantactAddressDetail.country.getTitleKey()
		if let country = profile.address?.country {
			row3.value = country
		}
		section.append(row3)
		return section
	}

	// Address Location Data
	func createAddressLocationData() -> [UserProfileRowData] {
		var section = [UserProfileRowData]()
		var row = UserProfileRowData()
		row.cellType = .location
		section.append(row)
		return section
	}
}
