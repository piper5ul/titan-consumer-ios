//
//  AppGlobalData.swift
//  Solid
//
//  Created by Solid iOS Team on 11/02/21.
//

import Foundation
import LinkKit

class AppGlobalData {

    private static var privateShared: AppGlobalData?

    static func shared() -> AppGlobalData { // change class to final to prevent override
        guard let uwShared = privateShared else {
            privateShared = AppGlobalData()
            return privateShared!
        }
        return uwShared
    }

    static func destroy() {
        privateShared = nil
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "api_env")
        defaults.set(nil, forKey: "session_data")
        defaults.set(nil, forKey: "person_phone")
        defaults.synchronize()
    }

    private init() {
        print("init singleton AppGlobalData")
    }

    deinit {
        print("deinit singleton AppGlobalData")
    }

    public var personId: String?
	public var businessId: String?
    public var businessData: BusinessDataModel?
    public var allBusiness: [BusinessDataModel]?
    public var accountData: AccountDataModel?
	public var accountList: [AccountDataModel]?
    public var selectedAccountType: AccountType?

    public var plaidHandler: Handler? // for PLAID link handler..

	public var personData = PersonResponseBody()
	public var ownerData = OwnerDataModel()
	public var ownerList = [OwnerDataModel]()
	public var cardList = [CardModel]()
	public var contactList = [ContactDataModel]()
	public var selectedCardModel: CardModel?
	public var selectedContactModel: ContactDataModel?
    public var isSelectedCardAccount: Bool = false

    public var cardData = CardModel()
    public var transactionList = [TransactionModel]()
	public var selectedTransaction = TransactionModel()

    public var arrFilterIndex = [IndexPath]()

    public var appFlow: AppFlow? = .AO
    public var creationFlow: POFlow? = .addAccount

    public var accTypePersonalChecking: Bool = false
    public var accTypeBusinessChecking: Bool = false
    public var accTypeCardAccount: Bool = false
	public var bothPersonalAndBusinessChecking: Bool = false

    public var selectedCountryCode: String = Constants.countryCodeUS
    public var maxPhoneNumberLength: Int = Constants.phoneNumberLimit
    
    public var globalCountryList: [AppCountryData]?
    
    public var maxPersonalCheckingAccountsAllowed: Int = 0
    public var maxBusinessCheckingAccountsAllowed: Int = 0

    public var authAccessToken: String = ""

    //ETV..
    var listETVACHValues: [String : [[String : String]]] = ["etvValues": [["valueRange": "$0.00 - $0.00", "maxValue": "0.00"], ["valueRange": "$0.01 - $5,000.00", "maxValue": "5000.00"], ["valueRange": "$5,000.01 - $10,000.00", "maxValue": "10000.00"], ["valueRange": "$10,000.01 - $20,000.00", "maxValue": "20000.00"], ["valueRange": "$20,000.01 - $30,000.00", "maxValue": "30000.00"], ["valueRange": "$30,000.01 - $60,000.00", "maxValue": "60000.00"], ["valueRange": "$60,000.01 - $100,000.00", "maxValue": "100000.00"], ["valueRange": "$100,000.01 - $150,000.00", "maxValue": "150000.00"], ["valueRange": "$150,000.01 - $225,000.00", "maxValue": "225000.00"], ["valueRange": "$300,000.01 - $1,000,000.00", "maxValue": "1000000.00"], ["valueRange": "$1,000,000.01 - $2,000,000.00", "maxValue": "2000000.00"], ["valueRange": "$2,000,000.00+", "maxValue": "2000000.00"]], "etvCounts": [["countRange": "0 - 0", "maxCount": "0"], ["countRange": "1 - 10", "maxCount": "10"], ["countRange": "11 - 20", "maxCount": "20"], ["countRange": "21 - 30", "maxCount": "30"], [ "countRange": "31 - 40", "maxCount": "40"], ["countRange": "41 - 60", "maxCount": "60"], ["countRange": "61 - 100", "maxCount": "100"], ["countRange": "101 - 150", "maxCount": "150"], ["countRange": "151 - 250", "maxCount": "250"], ["countRange": "251 - 500", "maxCount": "500"], ["countRange": "501 - 1000", "maxCount": "1000"], ["countRange": "1000+", "maxCount": "1000"]]]

    var listETVIACHValues: [String : [[String : String]]] = ["etvValues": [["valueRange": "$0.00 - $0.00", "maxValue": "0.00"], ["valueRange": "$0.01 - $250.00", "maxValue": "250.00"], ["valueRange": "$250.01 - $500.00", "maxValue": "500.00"], ["valueRange": "$500.01 - $750.00", "maxValue": "750.00"], ["valueRange": "$750.01 - $1000.00", "maxValue": "1000.00"], ["valueRange": "$1000.01 - $2500.00", "maxValue": "2500.00"], ["valueRange": "$2500.01 - $5,000.00", "maxValue": "5000.00"], ["valueRange": "$5,000.01 - $10,000.00", "maxValue": "10000.00"], ["valueRange": "$10,000.01 - $20,000.0", "maxValue": "20000.00"], ["valueRange": "$20,000.01 - $30,000.00", "maxValue": "30000.00"], ["valueRange": "$30,000.01 - $60,000.00", "maxValue": "60000.00"], ["valueRange": "$60,000.01 - $100,000.00", "maxValue": "100000.00"], ["valueRange": "$100,000.01+", "maxValue": "100000.01"]], "etvCounts": [["countRange": "0 - 0", "maxCount": "0"], ["countRange": "1 - 2", "maxCount": "2"], ["countRange": "3 - 4", "maxCount": "4"], ["countRange": "5 - 6", "maxCount": "6"], ["countRange": "6 - 10", "maxCount": "10"], ["countRange": "11 - 20", "maxCount": "20"], ["countRange": "21 - 30", "maxCount": "30"], [ "countRange": "31 - 40", "maxCount": "40"], ["countRange": "41 - 60", "maxCount": "60"], ["countRange": "61 - 100", "maxCount": "100"], ["countRange": "101 - 150", "maxCount": "150"], ["countRange": "151 - 250", "maxCount": "250"], ["countRange": "251+", "maxCount": "251"]]]
    
    var listETVDWireValues: [String : [[String : String]]] = ["etvValues": [["valueRange": "$0.00 - $0.00", "maxValue": "0.00"], ["valueRange": "$0.01 - $5,000.00", "maxValue": "5000.00"], ["valueRange": "$5,000.01 - $10,000.00", "maxValue": "10000.00"], ["valueRange": "$10,000.01 - $15,000.00", "maxValue": "15000.00"], ["valueRange": "$15,000.01 - $20,000.00", "maxValue": "20000.00"], ["valueRange": "$20,000.01 - $30,000.00", "maxValue": "30000.00"], ["valueRange": "$30,000.01 - $40,0000.00", "maxValue": "40000.00"], ["valueRange": "$40,000.01 - $50,000.00", "maxValue": "50000.00"], ["valueRange": "$50,000.01 - $70,000.00", "maxValue": "70000.00"], ["valueRange": "$70,000.01 - $100,000.00", "maxValue": "100000.00"], ["valueRange": "$100,000.01 - $150,000.00", "maxValue": "150000.00"], ["valueRange": "$150,000.01 - $200,000.00", "maxValue": "200000.00"], ["valueRange": "$200,000.01 - $500,000.00", "maxValue": "500000.00"], ["valueRange": "$500,000.01 - $1,000,000.00", "maxValue": "1000000.00"], ["valueRange": "$1,000,000.01 - $1,500,000.00", "maxValue": "1500000.00"], ["valueRange": "$1,500,000.01 - $3,000,000.00", "maxValue": "3000000.00"], ["valueRange": "$3,000,000.01+", "maxValue": "3000000.01"]], "etvCounts": [["countRange": "0 - 0", "maxCount": "0"], ["countRange": "1 - 2", "maxCount": "2"], ["countRange": "3 - 4", "maxCount": "4"], ["countRange": "5 - 6", "maxCount": "6"], ["countRange": "6 - 10", "maxCount": "10"], ["countRange": "11 - 20", "maxCount": "20"], ["countRange": "21 - 30", "maxCount": "30"], ["countRange": "31 - 40", "maxCount": "40"], ["countRange": "41 - 60", "maxCount": "60"], ["countRange": "61 - 100", "maxCount": "100"], ["countRange": "101 - 150", "maxCount": "150"], ["countRange": "151 - 250", "maxCount": "250"], ["countRange": "251 - 500", "maxCount": "500"], ["countRange": "501 - 700", "maxCount": "700"], ["countRange": "701 - 800", "maxCount": "800"], ["countRange": "801 - 900", "maxCount": "900"], ["countRange": "901+", "maxCount": "901"]]]
    
    var listETVIWireValues: [String : [[String : String]]] = ["etvValues": [["valueRange": "$0.00 - $0.00", "maxValue": "0.00"], ["valueRange": "$0.01 - $250.00", "maxValue": "250.00"], ["valueRange": "$250.01 - $500.00", "maxValue": "500.00"], ["valueRange": "$500.01 - $750.00", "maxValue": "750.00"], ["valueRange": "$750.01 - $1000.00", "maxValue": "1000.00"], ["valueRange": "$1000.01 - $2500.00", "maxValue": "2500.00"], ["valueRange": "$2500.01 - $5,000.00", "maxValue": "5000.00"], ["valueRange": "$5,000.01 - $10,000.00", "maxValue": "10000.00"], ["valueRange": "$10,000.01 - $20,000.00", "maxValue": "20000.00"], ["valueRange": "$20,000.01 - $30,000.00", "maxValue": "30000.00"], ["valueRange": "$30,000.01 - $60,000.00", "maxValue": "60000.00"], ["valueRange": "$60,000.01 - $100,000.00", "maxValue": "100000.00"], ["valueRange": "$100,000.01 - $150,000.00", "maxValue": "150000.00"], ["valueRange": "$150,000.01 - $225,000.00", "maxValue": "225000.00"], ["valueRange": "$300,000.01 - $1,000,000.00", "maxValue": "1000000.00"], ["valueRange": "$1,000,000.01 - $2,000,000.00", "maxValue": "2000000.00"], ["valueRange": "$2,000,000.00+", "maxValue": "2000000.00"]], "etvCounts": [["countRange": "0 - 0", "maxCount": "0"], ["countRange": "1 - 2", "maxCount": "2"], ["countRange": "3 - 4", "maxCount": "4"], ["countRange": "5 - 6", "maxCount": "6"], ["countRange": "6 - 10", "maxCount": "10"], ["countRange": "11 - 20", "maxCount": "20"], ["countRange": "21 - 30", "maxCount": "30"], ["countRange": "31 - 40", "maxCount": "40"], ["countRange": "41 - 60", "maxCount": "60"], ["countRange": "61 - 100", "maxCount": "100"], ["countRange": "101 - 150", "maxCount": "150"], ["countRange": "151 - 250", "maxCount": "250"], ["countRange": "251 - 500", "maxCount": "500"], ["countRange": "501 - 700", "maxCount": "700"], ["countRange": "701 - 800", "maxCount": "800"], ["countRange": "801 - 900", "maxCount": "900"], ["countRange": "901+", "maxCount": "901"]]]
    
    var listETVCheckValues: [String : [[String : String]]] = ["etvValues": [["valueRange": "$0.00 - $0.00", "maxValue": "0.00"], ["valueRange": "$0.01 - $5,000.00", "maxValue": "5000.00"], ["valueRange": "$5,000.01 - $10,000.00", "maxValue": "10000.00"], ["valueRange": "$10,000.01 - $30,000.00", "maxValue": "30000.00"], ["valueRange": "$30,000.01 - $50,000.00", "maxValue": "50000.00"], ["valueRange": "$50,000.01 - $100,0000.00", "maxValue": "100000.00"], ["valueRange": "$100,000.01 - $180,000.00", "maxValue": "180000.00"], ["valueRange": "$180,000.01 - $300,000.00", "maxValue": "300000.00"], ["valueRange": "$300,000.01 - $600,000.00", "maxValue": "600000.00"], ["valueRange": "$600,000.01 - $1,000,000.00", "maxValue": "1000000.00"], ["valueRange": "$1,000,000.01 - $1500,000.00", "maxValue": "1500000.00"], ["valueRange": "$1,500,000.01 - $2,500,000.00", "maxValue": "2500000.00"], ["valueRange": "$2,500,000.01+", "maxValue": "2500000.01"]], "etvCounts": [["countRange": "0 - 0", "maxCount": "0"], ["countRange": "1 - 2", "maxCount": "2"], ["countRange": "3 - 5", "maxCount": "5"], ["countRange": "6 - 10", "maxCount": "10"], ["countRange": "11 - 15", "maxCount": "15"], ["countRange": "16 - 20", "maxCount": "20"], ["countRange": "21 - 30", "maxCount": "30"], ["countRange": "31 - 40", "maxCount": "40"], ["countRange": "41 - 50", "maxCount": "50"], ["countRange": "51 - 75", "maxCount": "75"], ["countRange": "76-90", "maxCount": "90"], ["countRange": "91 - 100", "maxCount": "100"], ["countRange": "101+", "maxCount": "101"]]]
    //...
    
    public var programData = ProgramModel() {
        didSet {
            if let aBank = programData.bank, let accType = aBank.accountType, let maxAccounts = aBank.maxAccounts {
                accTypePersonalChecking = accType.personalChecking ?? false
                accTypeBusinessChecking = accType.businessChecking ?? false
                accTypeCardAccount = accType.cardAccount ?? false
				bothPersonalAndBusinessChecking = (accTypePersonalChecking && accTypeBusinessChecking)
                maxPersonalCheckingAccountsAllowed = Int(maxAccounts.personal ?? "0") ?? 0
                maxBusinessCheckingAccountsAllowed = Int(maxAccounts.business ?? "0") ?? 0
            }
        }
    }

    public func setArrFilterIndex() {
        arrFilterIndex.insert(IndexPath(), at: 0)
        arrFilterIndex.insert(IndexPath(), at: 1)
        arrFilterIndex.insert(IndexPath(), at: 2)
    }

    public func resetArrFilterIndex() {
        arrFilterIndex[0] = IndexPath()
        arrFilterIndex[1] = IndexPath()
        arrFilterIndex[2] = IndexPath()
    }

	static var isPinEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "pin_enabled_status")
        }
		set {
			let defaults = UserDefaults.standard
			defaults.set(newValue, forKey: "pin_enabled_status")
			defaults.synchronize()
		}
	}

    static var apiEnv: String {
        get {
            return UserDefaults.standard.value(forKey: "api_env") as! String
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "api_env")
            defaults.synchronize()
        }
    }

    func storeSessionData() {
        AppGlobalData.apiEnv = APIManager.networkEnviroment.localizeDescription()
        //AppGlobalData.setSessionData(AppData.session)
        Security.storeSession(userSession: AppData.session)
    }

    static func setSessionData(_ value: SessionData!) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: "session_data")
    }

    static func getSessionData() -> SessionData! {
       var userData: SessionData!
     userData =    Security.fetchSession()
        return userData
    }

    static var personPhone: String {
        get {
            return Security.fetchPhone()!
        }
        set {
            Security.storePhone(phone: newValue)
        }
    }
    
    public func getVGSContentPath(cardId: String) -> String {
        return "/v1/card/\(cardId)/show"
    }
    
    public func accessPinVGSContentPath(cardId: String) -> String {
        return "/v1/card/\(cardId)/pin"
    }

    public func addDebitCardContentPath(contactID: String) -> String {
        return "/v1/contact/\(contactID)/debitcard"
        
    }
    
    public func isMaxCashAccontLimitReached() -> Bool {
        let createdAccountCount = self.accountList?.count ?? 0
        
        if createdAccountCount < self.maxPersonalCheckingAccountsAllowed || createdAccountCount < self.maxBusinessCheckingAccountsAllowed {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Maintenance
extension AppGlobalData {
    func showMaintenanceScreen() {
        let storyboard = UIStoryboard.init(name: "Auth", bundle: nil)
        if let maintenanceVC = (storyboard.instantiateViewController(withIdentifier: "MaintenanceVC") as? MaintenanceVC) {
            let navController = UINavigationController(rootViewController: maintenanceVC)
            if let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window {
                window.rootViewController = navController
            }
        }
    }
}
