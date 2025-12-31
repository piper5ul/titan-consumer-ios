//
//  UserProfileDataHandler.swift
//  Solid
//
//  Created by Solid iOS Team on 3/19/21.
//

import Foundation
import UIKit

class BusinessDataHandler {
	var dataSource = [[UserProfileRowData]]()
	var profile: BusinessDataModel!
	var profileAction: AccountActionDataModel!
    
    var allIndustries: [BusinessSectorType]!
    var etvDataSource = [[ETVRowData]]()
}

extension BusinessDataHandler {
	func createDataSource(_ profileData: BusinessDataModel) {
        profile = profileData

        let section0 = createPersonalInfoData()
        dataSource.append(section0)

        //section with blank rows for ETV data
        let section1 = [UserProfileRowData]()
        dataSource.append(section1)
        
        //section with blank rows for Accounts list
        let section2 = [UserProfileRowData]()
        dataSource.append(section2)
        
        let section3 = createProfileActionData()
        dataSource.append(section3)

        let section4 = createAddressLocationData()
        dataSource.append(section4)

    }
}
extension BusinessDataHandler {
	// MARK: - Basic Account Details
	func createPersonalInfoData() -> [UserProfileRowData] {
		var section = [UserProfileRowData]()
		// name
		var row1 = UserProfileRowData()
		row1.key = UserDetails.legalname.getTitleKey()
		if let name = profile.legalName {
			row1.value = name
		}
		section.append(row1)

		// Phone number
		var row2 = UserProfileRowData()
		row2.key = UserDetails.dba.getTitleKey()
		if let dba = profile.dba {
			row2.value = dba
		}
		section.append(row2)
        
        // NAICS
        var row3 = UserProfileRowData()
        row3.key = UserDetails.naics.getTitleKey()
        if let _ = profile.naicsCode {
            row3.value = self.getIndustry()
        }
        section.append(row3)
        
		return section
	}

	// MARK: - Account Action Details
	func createProfileActionData() -> [UserProfileRowData] {
		var section = [UserProfileRowData]()
		// statement
		var row1 = UserProfileRowData()
		row1.key = UserActionDetails.helpcenter.getTitleKey()
		row1.value = UserActionDetails.helpcenter.getDescriptionValue()
		row1.iconName = UserActionDetails.helpcenter.getImageIconScreen()
		row1.cellType = .detail
		section.append(row1)

		var row2 = UserProfileRowData()
		row2.key = UserActionDetails.getintouch.getTitleKey()
		row2.value = UserActionDetails.getintouch.getDescriptionValue()
		row2.iconName = UserActionDetails.getintouch.getImageIconScreen()
		row2.cellType = .detail
        section.append(row2)
       
		var row3 = UserProfileRowData()
		row3.key = UserActionDetails.limits.getTitleKey()
		row3.value = UserActionDetails.limits.getDescriptionValue()
		row3.iconName = UserActionDetails.limits.getImageIconScreen()
		row3.cellType = .detail
//		section.append(row3)

		var row4 = UserProfileRowData()
		row4.key = UserActionDetails.disclosures.getTitleKey()
		row4.value = UserActionDetails.disclosures.getDescriptionValue()
		row4.iconName = UserActionDetails.disclosures.getImageIconScreen()
		row4.cellType = .detail
		//section.append(row4)

		return section
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
    
    func getIndustry() -> String {
        var strBusinessIndustry = ""
        for sector in allIndustries {
            for group in sector.industries ?? [IndustryGroupType]() {
                for industry in group.nationalIndustries ?? [IndustryType]() {
                    if let icode = industry.code, let iname = industry.name {
                        if String(icode) == profile.naicsCode {
                            let strIndustryCode = String(icode)
                            let strIndustryName = iname
                            strBusinessIndustry = strIndustryCode + "\n" + strIndustryName
                            return strBusinessIndustry
                        }
                    }
                }
            }
        }
        
        return strBusinessIndustry
    }
}

// MARK: - ETV..
extension BusinessDataHandler {
    func createETVDataSource() {
        let section1 = createSendData()
        etvDataSource.append(section1)

        let section2 = createReceiveData()
        etvDataSource.append(section2)

        let section3 = createIncomingData()
        etvDataSource.append(section3)
    }
    
    func createSendData() -> [ETVRowData] {
        var section = [ETVRowData]()
        
        //ACH
        let row1 = getACHListItems(withTitle: "ach")
        section.append(row1)

        //INTERNATIONAL ACH
        let row2 = getInternationalACHListItems()
        section.append(row2)
        
        //DOMESTIC WIRE
        let row3 = getDomesticWireListItems()
        section.append(row3)
        
        //INTERNATIONAL WIRE
        let row4 = getInternationalWireListItems()
        section.append(row4)
        
        //PHYSICAL CHECK
        let row5 = getCheckListItems()
        section.append(row5)
        
        return section
    }
    
    func createReceiveData() -> [ETVRowData] {
        var section = [ETVRowData]()
        
        //ACH
        let row1 = getACHListItems(withTitle: "ach")
        section.append(row1)
        
        //PHYSICAL CHECK
        let row2 = getCheckListItems()
        section.append(row2)
        
        return section
    }
    
    func createIncomingData() -> [ETVRowData] {
        var section = [ETVRowData]()
        
        //ACH PUSH
        let row1 = getACHListItems(withTitle: "achPush")
        section.append(row1)

        //ACH PULL
        let row2 = getACHListItems(withTitle: "achPull")
        section.append(row2)

        //INTERNATIONAL ACH
        let row3 = getInternationalACHListItems()
        section.append(row3)
        
        //DOMESTIC WIRE
        let row4 = getDomesticWireListItems()
        section.append(row4)
        
        //INTERNATIONAL WIRE
        let row5 = getInternationalWireListItems()
        section.append(row5)
        
        return section
    }
    
    func getACHListItems(withTitle: String) -> ETVRowData {
        //ACH DATA
        let values = AppGlobalData.shared().listETVACHValues["etvValues"] ?? [[:]]
        let counts = AppGlobalData.shared().listETVACHValues["etvCounts"] ?? [[:]]

        //ACH VALUES LIST ITEMS..
        var etvValuesList = [ListItems]()
        for etvValue in values {
            if let range = etvValue["valueRange"], let max = etvValue["maxValue"] {
                etvValuesList.append(ListItems(title: range, id: max))
            }
        }
        
        //ACH COUNTS LIST ITEMS..
        var etvCountsList = [ListItems]()
        for etvCount in counts {
            if let range = etvCount["countRange"], let max = etvCount["maxCount"] {
                etvCountsList.append(ListItems(title: range, id: max))
            }
        }
        
        let rowData = ETVRowData(type: Utility.localizedString(forKey: withTitle), valuePickerData: etvValuesList, countPickerData: etvCountsList)
        return rowData
    }
    
    func getInternationalACHListItems() -> ETVRowData {
        //International ACH DATA
        let values = AppGlobalData.shared().listETVIACHValues["etvValues"] ?? [[:]]
        let counts = AppGlobalData.shared().listETVIACHValues["etvCounts"] ?? [[:]]

        //International ACH VALUES LIST ITEMS..
        var etvValuesList = [ListItems]()
        for etvValue in values {
            if let range = etvValue["valueRange"], let max = etvValue["maxValue"] {
                etvValuesList.append(ListItems(title: range, id: max))
            }
        }
        
        //International ACH COUNTS LIST ITEMS..
        var etvCountsList = [ListItems]()
        for etvCount in counts {
            if let range = etvCount["countRange"], let max = etvCount["maxCount"] {
                etvCountsList.append(ListItems(title: range, id: max))
            }
        }
        
        let rowData = ETVRowData(type: Utility.localizedString(forKey: "internationalAch"), valuePickerData: etvValuesList, countPickerData: etvCountsList)
        return rowData
    }
    
    func getDomesticWireListItems() -> ETVRowData {
        //Domestic Wire DATA
        let values = AppGlobalData.shared().listETVDWireValues["etvValues"] ?? [[:]]
        let counts = AppGlobalData.shared().listETVDWireValues["etvCounts"] ?? [[:]]

        //Domestic Wire VALUES LIST ITEMS..
        var etvValuesList = [ListItems]()
        for etvValue in values {
            if let range = etvValue["valueRange"], let max = etvValue["maxValue"] {
                etvValuesList.append(ListItems(title: range, id: max))
            }
        }
        
        //Domestic Wire COUNTS LIST ITEMS..
        var etvCountsList = [ListItems]()
        for etvCount in counts {
            if let range = etvCount["countRange"], let max = etvCount["maxCount"] {
                etvCountsList.append(ListItems(title: range, id: max))
            }
        }
        
        let rowData = ETVRowData(type: Utility.localizedString(forKey: "domesticWire"), valuePickerData: etvValuesList, countPickerData: etvCountsList)
        return rowData
    }
    
    func getInternationalWireListItems() -> ETVRowData {
        //International Wire DATA
        let values = AppGlobalData.shared().listETVIWireValues["etvValues"] ?? [[:]]
        let counts = AppGlobalData.shared().listETVIWireValues["etvCounts"] ?? [[:]]

        //International Wire VALUES LIST ITEMS..
        var etvValuesList = [ListItems]()
        for etvValue in values {
            if let range = etvValue["valueRange"], let max = etvValue["maxValue"] {
                etvValuesList.append(ListItems(title: range, id: max))
            }
        }
        
        //International Wire COUNTS LIST ITEMS..
        var etvCountsList = [ListItems]()
        for etvCount in counts {
            if let range = etvCount["countRange"], let max = etvCount["maxCount"] {
                etvCountsList.append(ListItems(title: range, id: max))
            }
        }
        
        let rowData = ETVRowData(type: Utility.localizedString(forKey: "internationalWire"), valuePickerData: etvValuesList, countPickerData: etvCountsList)
        return rowData
    }
    
    func getCheckListItems() -> ETVRowData {
        //Check DATA
        let values = AppGlobalData.shared().listETVCheckValues["etvValues"] ?? [[:]]
        let counts = AppGlobalData.shared().listETVCheckValues["etvCounts"] ?? [[:]]

        //Check VALUES LIST ITEMS..
        var etvValuesList = [ListItems]()
        for etvValue in values {
            if let range = etvValue["valueRange"], let max = etvValue["maxValue"] {
                etvValuesList.append(ListItems(title: range, id: max))
            }
        }
        
        //Check COUNTS LIST ITEMS..
        var etvCountsList = [ListItems]()
        for etvCount in counts {
            if let range = etvCount["countRange"], let max = etvCount["maxCount"] {
                etvCountsList.append(ListItems(title: range, id: max))
            }
        }
        
        let rowData = ETVRowData(type: Utility.localizedString(forKey: "physicalCheck"), valuePickerData: etvValuesList, countPickerData: etvCountsList)
        return rowData
    }
    
    func getSelectedACHValues(selectedAmountRange: String, selectedCountRange: String) -> [String] {
        var strMaxCount = ""
        var strMaxValue = ""
        
        //ACH DATA
        let achValues = AppGlobalData.shared().listETVACHValues["etvValues"] ?? [[:]]
        let achCounts = AppGlobalData.shared().listETVACHValues["etvCounts"] ?? [[:]]
        
        for achData in achValues {
            if achData["valueRange"] == selectedAmountRange {
                strMaxValue = achData["maxValue"] ?? ""
            }
        }
        
        for achData in achCounts {
            if achData["countRange"] == selectedCountRange {
                strMaxCount = achData["maxCount"] ?? ""
            }
        }
        
        return [strMaxValue, strMaxCount]
    }
    
    func getSelectedIACHValues(selectedAmountRange: String, selectedCountRange: String) -> [String] {
        var strMaxCount = ""
        var strMaxValue = ""
        
        //INTERNATIONAL ACH DATA
        let iachValues = AppGlobalData.shared().listETVIACHValues["etvValues"] ?? [[:]]
        let iachCounts = AppGlobalData.shared().listETVIACHValues["etvCounts"] ?? [[:]]
        
        for iachData in iachValues {
            if iachData["valueRange"] == selectedAmountRange {
                strMaxValue = iachData["maxValue"] ?? ""
            }
        }
        
        for iachData in iachCounts {
            if iachData["countRange"] == selectedCountRange {
                strMaxCount = iachData["maxCount"] ?? ""
            }
        }
        
        return [strMaxValue, strMaxCount]
    }
    
    func getSelectedDWireValues(selectedAmountRange: String, selectedCountRange: String) -> [String] {
        var strMaxCount = ""
        var strMaxValue = ""
        
        //WIRE DATA
        let wireValues = AppGlobalData.shared().listETVDWireValues["etvValues"] ?? [[:]]
        let wireCounts = AppGlobalData.shared().listETVDWireValues["etvCounts"] ?? [[:]]
        
        for wireData in wireValues {
            if wireData["valueRange"] == selectedAmountRange {
                strMaxValue = wireData["maxValue"] ?? ""
            }
        }
        
        for wireData in wireCounts {
            if wireData["countRange"] == selectedCountRange {
                strMaxCount = wireData["maxCount"] ?? ""
            }
        }
        
        return [strMaxValue, strMaxCount]
    }
    
    func getSelectedIWireValues(selectedAmountRange: String, selectedCountRange: String) -> [String] {
        var strMaxCount = ""
        var strMaxValue = ""
        
        //INTERNATIONAL WIRE DATA
        let iwireValues = AppGlobalData.shared().listETVIWireValues["etvValues"] ?? [[:]]
        let iwireCounts = AppGlobalData.shared().listETVIWireValues["etvCounts"] ?? [[:]]
        
        for iwireData in iwireValues {
            if iwireData["valueRange"] == selectedAmountRange {
                strMaxValue = iwireData["maxValue"] ?? ""
            }
        }
        
        for iwireData in iwireCounts {
            if iwireData["countRange"] == selectedCountRange {
                strMaxCount = iwireData["maxCount"] ?? ""
            }
        }
        
        return [strMaxValue, strMaxCount]
    }
    
    func getSelectedCheckValues(selectedAmountRange: String, selectedCountRange: String) -> [String] {
        var strMaxCount = ""
        var strMaxValue = ""
        
        //CHECK DATA
        let checkValues = AppGlobalData.shared().listETVCheckValues["etvValues"] ?? [[:]]
        let checkCounts = AppGlobalData.shared().listETVCheckValues["etvCounts"] ?? [[:]]
        
        for chkData in checkValues {
            if chkData["valueRange"] == selectedAmountRange {
                strMaxValue = chkData["maxValue"] ?? ""
            }
        }
        
        for chkData in checkCounts {
            if chkData["countRange"] == selectedCountRange {
                strMaxCount = chkData["maxCount"] ?? ""
            }
        }
        
        return [strMaxValue, strMaxCount]
    }
    
    func getSelectedProjectionValues(selectedAmountRange: String, selectedCountRange: String, selectedProjectionData: [BusinessProjectionValues], forIndexPath: IndexPath) -> BusinessProjectionValue {
        let strValueRange = selectedAmountRange
        let strCountRange = selectedCountRange
        var strMaxCount = ""
        var strMaxValue = ""

        var selectedPData = selectedProjectionData[forIndexPath.section].projectionData?[forIndexPath.row] ?? BusinessProjectionValue()
        
        switch forIndexPath.section {
        case 0:
            switch forIndexPath.row {
            case 0:
                let selectedData = getSelectedACHValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 1:
                let selectedData = getSelectedIACHValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 2:
                let selectedData = getSelectedDWireValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 3:
                let selectedData = getSelectedIWireValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 4:
                let selectedData = getSelectedCheckValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            default:
                break
            }
           
        case 1:
            switch forIndexPath.row {
            case 0:
                let selectedData = getSelectedACHValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 1:
                let selectedData = getSelectedCheckValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            default:
                break
            }
        case 2:
            switch forIndexPath.row {
            case 0:
                let selectedData = getSelectedACHValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 1:
                let selectedData = getSelectedACHValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 2:
                let selectedData = getSelectedIACHValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 3:
                let selectedData = getSelectedDWireValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            case 4:
                let selectedData = getSelectedIWireValues(selectedAmountRange: selectedAmountRange, selectedCountRange: selectedCountRange)
                strMaxValue = selectedData[0]
                strMaxCount = selectedData[1]
            default:
                break
            }
        default:
            break
        }
        
        selectedPData.amount = strMaxValue
        selectedPData.count = strValueRange == "$0.00 - $0.00" ? "0" : strMaxCount
        selectedPData.countRange = strValueRange == "$0.00 - $0.00" ? "0 - 0" : strCountRange
        selectedPData.amountRange = strValueRange
        
        return selectedPData
    }
}
