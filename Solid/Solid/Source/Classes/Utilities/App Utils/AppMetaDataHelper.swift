//
//  AppMetaDataHelper.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import Foundation

struct AppConfig: Codable {
    let appName: String?
    var appBrandColor: String?
    var darkPrimaryColor: String?
    var primaryTextColor: String? = "#000000"
    var darkPrimaryTextColor: String? = "FFFFFF"
    let secondaryTextColor: String?
    let darkSecondaryTextColor: String?
    var ctaColor: String?
    var darkCtaColor: String?
    var ctaTextColor: String? = "FFFFFF"
    var darkCtaTextColor: String?
    var physicalCardTextColor: String? = "#FFFFFF"
    var virtualCardTextColor: String? = "#FFFFFF"
    let validateFlag: ValidateFlag?
    var allEnvConfig: AppEnvConfigurations?
    var supportedCountries: [AppCountryData]?
    let getInTouchEmail: String?
    var lcbBankTermsLink: String?
    var platformTerms: String?
    var solidWalletTermsLink: String?
    var auth0Terms: String?
    var auth0Privacy: String?
    let helpCenterLink: String?
    let disclosuresLink: String?
    var appUrl: String?
        
    private enum CodingKeys: String, CodingKey {
        case appName = "name"
        case appBrandColor = "primaryColor"
        case darkPrimaryColor = "darkPrimaryColor"
        case primaryTextColor = "primaryTextColor"
        case darkPrimaryTextColor = "darkPrimaryTextColor"
        case secondaryTextColor = "secondaryColor"
        case darkSecondaryTextColor = "darkSecondaryColor"
        case ctaColor = "ctaColor"
        case darkCtaColor = "darkCtaColor"
        case ctaTextColor = "ctaTextColor"
        case darkCtaTextColor = "darkCtaTextColor"
        case physicalCardTextColor = "physicalCardTextColor"
        case virtualCardTextColor = "virtualCardTextColor"
        case validateFlag = "ui"
        case allEnvConfig = "env"
        case supportedCountries = "supportedCountries"
        case getInTouchEmail = "supportMail"
        case lcbBankTermsLink = "lcbTerms"
        case platformTerms = "platformTerms"
        case solidWalletTermsLink = "walletTerms"
        case helpCenterLink = "helpCenter"
        case auth0Terms = "auth0Terms"
        case auth0Privacy = "auth0Privacy"
        case disclosuresLink = "disclosures"
        case appUrl = "appUrl"
    }
}

struct ValidateFlag: Codable {
    var isTestModeEnabled: Bool?
    var isSendCardByMailVisible: Bool?
    var isPullFundsEnabled: Bool?
    var isIntrabankTransferEnabled: Bool?
    var isToAnotherBankEnabled: Bool?
    var isDepositCheckEnabled: Bool?
    var isSendMoneyIntraBankEnabled: Bool?
    var isSendMoneyACHEnabled: Bool?
    var isSendMoneyCheckEnabled: Bool?
    var isSendMoneyDomesticwireEnabled: Bool?
    var isSendMoneyInternationalwireEnabled: Bool?
    var isSendMoneyVisaCardEnabled: Bool?
    var isContactMakePaymentEnabled: Bool?
    var isAddToWalletEnabled: Bool?

    private enum CodingKeys: String, CodingKey {
        case isTestModeEnabled = "isTestModeEnabled"
        case isSendCardByMailVisible = "isSendCardByMailVisible"
        case isPullFundsEnabled = "isPullFundsEnabled"
        case isIntrabankTransferEnabled = "isIntrabankTransferEnabled"
        case isToAnotherBankEnabled = "isToAnotherBankEnabled"
        case isDepositCheckEnabled = "isDepositCheckEnabled"
        case isSendMoneyIntraBankEnabled = "isSendMoneyIntraBankEnabled"
        case isSendMoneyACHEnabled = "isSendMoneyACHEnabled"
        case isSendMoneyCheckEnabled = "isSendMoneyCheckEnabled"
        case isSendMoneyDomesticwireEnabled = "isSendMoneyDomesticwireEnabled"
        case isSendMoneyInternationalwireEnabled = "isSendMoneyInternationalwireEnabled"
        case isSendMoneyVisaCardEnabled = "isSendMoneyVisaCardEnabled"
        case isContactMakePaymentEnabled = "isContactMakePaymentEnabled"
        case isAddToWalletEnabled = "isAddToWalletEnabled"
    }
}

struct AppCountryData: Codable {
    let name: String?
    let dialCode: String?
    let code: String?
    let maxLength: Int?
        
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case dialCode = "dial_code"
        case code = "code"
        case maxLength = "maxLength"
    }

    init(name: String?, dialCode: String?, code: String?, maxLength: Int?) {
        self.name = name
        self.dialCode = dialCode
        self.code = code
        self.maxLength = maxLength
    }
}

struct AppEnvConfigurations: Codable {
    let productionLive: AppConfigurationsKeys?
    let productionTest: AppConfigurationsKeys?
    
    private enum CodingKeys: String, CodingKey {
        case productionLive = "prod"
        case productionTest = "prodtest"
    }

    init(productionLive: AppConfigurationsKeys, productionTest: AppConfigurationsKeys) {
        self.productionLive = productionLive
        self.productionTest = productionTest
    }
}

struct AppConfigurationsKeys: Codable {
    let auth0ClientId: String?
    let auth0Audience: String?
    let auth0Domain: String?
    let segmentKey: String?
    
    private enum CodingKeys: String, CodingKey {
        case segmentKey = "segmentKey"
        case auth0ClientId = "auth0ClientId"
        case auth0Audience = "auth0Audience"
        case auth0Domain = "auth0Domain"
    }

    init(segmentKey: String, auth0ClientId: String, auth0Audience: String, auth0Domain: String) {
        self.segmentKey = segmentKey
        self.auth0ClientId = auth0ClientId
        self.auth0Audience = auth0Audience
        self.auth0Domain = auth0Domain
    }
}

struct AppMetaDataHelper {

    static var shared = AppMetaDataHelper()
    var config: AppConfig?
    var personaCallback = "https://personacallback"
    
    init () {
        debugPrint("AppMetaDataHelper")
    }

    var getAppName: String {
        if let strAppName = AppMetaDataHelper.shared.config?.appName {
            return strAppName
        } else {
            return "Solid"
        }
    }

    var getPersonaCallback: String {
        return AppMetaDataHelper.shared.personaCallback
    }
    
    var currentEnvKeys: AppConfigurationsKeys {
        switch APIManager.networkEnviroment {
            case .productionTest:
            return (AppMetaDataHelper.shared.config?.allEnvConfig?.productionTest)!
            case .productionLive:
                return (AppMetaDataHelper.shared.config?.allEnvConfig!.productionLive)!
        }
    }
    
    var naicsReadMoreLink: String {
        return "https://www.census.gov/naics/"
    }
    
    mutating func updateProgramData(programData: ProgramModel) {
        
        //UPDATE COLORS..
        if let brand = programData.brand {
            if let brandColor = brand.primaryColor, !brandColor.isEmpty {
                self.config?.appBrandColor = brandColor
            }
            
            if let darkBrandColor = brand.darkPrimaryColor, !darkBrandColor.isEmpty {
                self.config?.darkPrimaryColor = darkBrandColor
            }
            
            if let primaryTextColor = brand.primaryTextColor, !primaryTextColor.isEmpty {
                self.config?.primaryTextColor = primaryTextColor
            }
            
            if let darkPrimaryTextColor = brand.darkPrimaryTextColor, !darkPrimaryTextColor.isEmpty {
                self.config?.darkPrimaryTextColor = darkPrimaryTextColor
            }
            
            if let ctaColor = brand.ctaColor, !ctaColor.isEmpty {
                self.config?.ctaColor = ctaColor
            }
            
            if let darkCtaColor = brand.darkCtaColor, !darkCtaColor.isEmpty {
                self.config?.darkCtaColor = darkCtaColor
            }
            
            if let ctaTextColor = brand.ctaTextColor, !ctaTextColor.isEmpty {
                self.config?.ctaTextColor = ctaTextColor
            }
            
            if let darkCtaTextColor = brand.darkCtaTextColor, !darkCtaTextColor.isEmpty {
                self.config?.darkCtaTextColor = darkCtaTextColor
            }
            
            if let physicalcardTcolor = brand.physicalCardTextColor, !physicalcardTcolor.isEmpty {
                self.config?.physicalCardTextColor = physicalcardTcolor
            }
            
            if let virtualCardTColor = brand.virtualCardTextColor, !virtualCardTColor.isEmpty {
                self.config?.virtualCardTextColor = virtualCardTColor
            }
        }
        
        //UPDATE lcbBankTermsLink
        if let legal = programData.legal, let lcbBankTermsLink = legal.bank, !lcbBankTermsLink.isEmpty {
            self.config?.lcbBankTermsLink = lcbBankTermsLink
        }
        
        //UPDATE solidBankTermsLink
        if let legal = programData.legal, let solidBankTermsLink = legal.solid, !solidBankTermsLink.isEmpty {
            self.config?.platformTerms = solidBankTermsLink
        }
        
        //UPDATE solidWalletTermsLink
        if let legal = programData.legal, let solidWalletTermsLink = legal.program, !solidWalletTermsLink.isEmpty {
            self.config?.solidWalletTermsLink = solidWalletTermsLink
        }
    }
}
