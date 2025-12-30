//
//  UserProfileData.swift
//  Solid
//
//  Created by Solid iOS Team on 3/19/21.
//

import Foundation

struct UserProfileRowData {
	var key: String?
	var value: Any?
	var iconName: String?
	var rightValue: String?
	var cellType = AccountCellType.data
}

public enum UserCellType {
	case data
	case detail
	case switched
	case btn
	case location
}

enum UserDetails: Int {
    case  name = 0,
          mobileNumber,
          email,
          streetname,
          city,
          country,
          legalname,
          dba,
          naics
    
    func getTitleKey() -> String {
        switch self {
        case .name:
            return Utility.localizedString(forKey: "profile_name")
        case .mobileNumber:
            return Utility.localizedString(forKey: "profile_number")
        case .email:
            return Utility.localizedString(forKey: "profile_email")
        case .streetname:
            return Utility.localizedString(forKey: "contact_street_title")
        case .city:
            return Utility.localizedString(forKey: "contact_city_title")
        case .country:
            return Utility.localizedString(forKey: "contact_country_title")
        case .legalname:
            return Utility.localizedString(forKey: "profile_legalname")
        case .dba:
            return Utility.localizedString(forKey: "profile_dba")
        case .naics:
            return Utility.localizedString(forKey: "naicsCode")
        }
    }
}

enum UserActionDetails: Int {
	case  helpcenter = 0,
		  getintouch,
		  limits,
		  disclosures

	func getTitleKey() -> String {
		switch self {
			case .helpcenter:
				return Utility.localizedString(forKey: "profile_helpcenter")
			case .getintouch:
				return Utility.localizedString(forKey: "profile_getintouch")
			case .limits:
				return Utility.localizedString(forKey: "profile_limits")
			case .disclosures:
				return Utility.localizedString(forKey: "profile_disclosures")
		}
	}

	func getDescriptionValue() -> String {
		switch self {
			case .helpcenter:
				return Utility.localizedString(forKey: "profile_helpcenter_description")
			case .getintouch:
				return Utility.localizedString(forKey: "profile_getintouch_description")
			case .limits:
				return Utility.localizedString(forKey: "profile_limits_description")
			case .disclosures:
				return Utility.localizedString(forKey: "profile_disclosures_description")
		}
	}

	func getImageIconScreen() -> String {
		switch self {
			case .helpcenter:
				return "statement"
			case .getintouch:
				return "lock"
			case .limits:
				return "bell"
			case .disclosures:
				return "disclosures"
		}
	}

}
