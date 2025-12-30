//
//  Constants.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import Foundation
import UIKit

public struct Constants {
    static let ssnCodeLimit                 = 9
    static let ssnLast4Limit                = 4
    static let mfaCodeLimit                 = 6
    static let phoneNumberLimit             = 10
    static let einCodeLimit                 = 9
    static let zipCodeLimit                 = 9
    static let accountNumberMinLimit        = 6     // For account number min limit
    static let accountNumberMaxLimit        = 17    // For account number max limit
    static let routingNumber                = 9     // routing number limit
    static let expiryCount					= 7
    static let expiryMonthCount             = 2
    static let expiryDateCount              = 4
    static let cardSpendDigitsLimit: Decimal = 999_99.99
    static let last4Limit                   = 4
    static let cardNumberLimit              = 16
    static let programCodeLimit             = 4
    static let passportNumberMinLimit       = 4
    static let passportNumberMaxLimit       = 20
    static let embossingPersonName          = 23  // card embossing person name limit
    static let embossingBusinessName        = 23  // card embossing business name limit
    
    static let defaultSectionHeight: CGFloat = 60.0
    
    //UI
    static let cornerRadiusThroughApp: CGFloat = 4
    static let solidTargetName              = "Solid"
    
    //Footer UI
    static let footerViewHeight: CGFloat = 120
    
    //RCD
    static let checkDepositMaxLimit: Double = 1000.00
    static let skeletonCellHeight: CGFloat = 82
    
    //Form cell height
    static let formCellHeightiphone: CGFloat = 106
    static let formCellHeightipad: CGFloat = 118
    static let textfieldheightIphone: CGFloat = 48
    static let textfieldheightIpad: CGFloat = 60
    static let keyboardUpSpace: CGFloat = 90
    static let placesTableViewCellHeight: CGFloat = 40
    static let formCellWithNoteHeightiphone: CGFloat = 126
    static let formCellWithNoteHeightipad: CGFloat = 120
    
    //For Google map
    static let googleMapAppUrl = "comgooglemaps://"
    static let googleMapUrl = "//maps.google.com"
    
    static let cashWallet = "Cash Wallet"
    static let steelCard = "Steel Card"
    
    static let countryCodeUS = "+1"
    
    static let tagForGreyView = 10001
    static let tagForNavRightCloseButton = 10002
    static let tagForTopCustomNavView = 10003
    static let tagForTopView = 10004
    static let tagForTopLogoImgView = 10005
    static let tagForProgressbarImgView = 10006
    static let tagForTopProfileButton = 10007
    static let tagForCustomBackButton = 10008
    static let tagForCustomSearchText = 10009
    static let tagForRegulatBackButton = 10010
    static let tagForSeachIconInSearchBar = 10011
    static let tagForSpendingLimit = 10012
    
    static let countryCodeLableWidthConst   = 60
    static let countryCodeLableHeightConst  = 30
    static let countryCodeLableXConst   = 7
    static let countryCodeLableYConst   = 7
    
    static let fetchLimit                   = 25
    static let accountsFetchLimit           = 150
    static let minimumSearchCharacter       = 2
    
    //Fonts with different size and type
    //Regular
    static let regularFontSize10: UIFont = UIFont.sfProDisplayRegular(fontSize: 10)
    static let regularFontSize12: UIFont = UIFont.sfProDisplayRegular(fontSize: 12)
    static let regularFontSize14: UIFont = UIFont.sfProDisplayRegular(fontSize: 14)
    static let regularFontSize24: UIFont = UIFont.sfProDisplayRegular(fontSize: 24)
    static let regularFontSize16: UIFont = UIFont.sfProDisplayRegular(fontSize: 16)
    static let regularFontSize17: UIFont = UIFont.sfProDisplayRegular(fontSize: 17)
    static let regularFontSize18: UIFont = UIFont.sfProDisplayRegular(fontSize: 18)
    static let regularFontSize20: UIFont = UIFont.sfProDisplayRegular(fontSize: 20)
    static let regularFontSize22: UIFont = UIFont.sfProDisplayRegular(fontSize: 22)
    static let regularFontSize48: UIFont = UIFont.sfProDisplayRegular(fontSize: 48)
    static let regularFontSize28: UIFont = UIFont.sfProDisplayRegular(fontSize: 28)
    
    //Medium
    static let mediumFontSize10: UIFont = UIFont.sfProDisplayMedium(fontSize: 10)
    static let mediumFontSize12: UIFont = UIFont.sfProDisplayMedium(fontSize: 12)
    static let mediumFontSize14: UIFont = UIFont.sfProDisplayMedium(fontSize: 14)
    static let mediumFontSize16: UIFont = UIFont.sfProDisplayMedium(fontSize: 16)
    static let mediumFontSize18: UIFont = UIFont.sfProDisplayMedium(fontSize: 18)
    static let mediumFontSize24: UIFont = UIFont.sfProDisplayMedium(fontSize: 24)
    static let mediumFontSize22: UIFont = UIFont.sfProDisplayMedium(fontSize: 22)
    static let mediumFontSize20: UIFont = UIFont.sfProDisplayMedium(fontSize: 20)
    //Bold
    static let boldFontSize14: UIFont = UIFont.sfProDisplayBold(fontSize: 14)
    static let boldFontSize16: UIFont = UIFont.sfProDisplayBold(fontSize: 16)
    static let boldFontSize22: UIFont = UIFont.sfProDisplayBold(fontSize: 22)
    static let boldFontSize24: UIFont = UIFont.sfProDisplayBold(fontSize: 24)
    static let boldFontSize28: UIFont = UIFont.sfProDisplayBold(fontSize: 28)
    
    static let commonFont: UIFont =  Utility.isDeviceIpad() ? Constants.mediumFontSize20: Constants.mediumFontSize18
    static let tagForCountryCodeLabel = 10007
}

public struct NotificationConstants {
    static let reloadAccountsAfterAdding = "ReloadAccountsAfterAdding"
    static let reloadContactsAfterAddEdit = "ReloadContactsAfterAddEdit"
    static let reloadAfterAccountSwitch = "ReloadAfterAccountSwitch"
    static let reloadContactsAfterDelete = "ReloadContactsAfterDelete"
    
    static let reloadCardAfterAdding = "reloadCardAfterAdding"
    static let reloadCardAfterStatusChange = "reloadCardAfterStatusChange"
    static let reloadCardAfterEdit = "reloadCardAfterEdit"
    static let selectCardFromDashboard = "selectCardFromDashboard"
    static let activateCardFromDashboard = "activateCardFromDashboard"
    static let selectContactFromDashboard = "selectContactFromDashboard"
    
    static let reloadCardTransaction = "reloadCardTransaction"
    static let reloaduserProfile = "reloaduserProfile"
    static let reloadbusiness = "reloadbusiness"
    
    // RCD..
    static let onRCDImageUploadSuccess   = "on_RCDImage_Upload_Success"
    static let selectedAccount = "selectedAccount"
}
