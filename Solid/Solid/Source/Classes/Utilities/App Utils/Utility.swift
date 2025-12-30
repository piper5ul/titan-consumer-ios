//
//  Utility.swift
//
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit

class Utility {

    static func getCurrencyForAmount(amount: NSNumber, isDecimalRequired: Bool, withoutSpace: Bool = false) -> String {
        var formattedCurrency = ""
        let currency = Utility.localizedString(forKey: "currency")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if isDecimalRequired {
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            formatter.generatesDecimalNumbers = true

            let decimalAmountString = String(describing: formatter.string(from: amount)!)
            if withoutSpace {
                formattedCurrency = "\(currency)\(decimalAmountString)"
            } else {
                formattedCurrency = "\(currency) \(decimalAmountString)"
            }
        } else {
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
            formatter.generatesDecimalNumbers = false
            let decimalAmountString = String(describing: formatter.string(from: amount)!)

            if withoutSpace {
                formattedCurrency = "\(currency)\(decimalAmountString)"
            } else {
                formattedCurrency = "\(currency) \(decimalAmountString)"
            }
        }

        return formattedCurrency
    }

    static func isValidAmount(_ aString: String, _ completeText: String) -> Bool {
        var canChange = true
        let characterSet = CharacterSet(charactersIn: aString)

        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        canChange = allowedCharacters.isSuperset(of: characterSet)

        let dotSeparators = completeText.components(separatedBy: ".")
        let dotsCount = dotSeparators.count - 1
        canChange = dotsCount > 1 ? false : canChange

        if dotsCount == 1 {
            let decimals = dotSeparators[1]
            canChange = decimals.count <= 2 ? true : false
        }

        return canChange
    }

    static func convertAmountToValidFormat(_ aString: String, _ textFieldText: String, _ range: NSRange) -> String? {
        if (aString == "0" || aString == "") && (textFieldText as NSString).range(of: ".").location < range.location {
            return ""
        }

        // First check whether the replacement string's numeric...
        let cs = NSCharacterSet(charactersIn: "0123456789.").inverted
        let filtered = aString.components(separatedBy: cs)
        let component = filtered.joined(separator: "")
        let isNumeric = aString == component

        // Then if the replacement string's numeric, or if it's
        // a backspace, or if it's a decimal point and the text
        // field doesn't already contain a decimal point,
        // reformat the new complete number using
        if isNumeric {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.roundingMode = .down
            formatter.maximumFractionDigits = 2
            // Combine the new text with the old; then remove any
            // commas from the textField before formatting
            let newString = (textFieldText as NSString).replacingCharacters(in: range, with: aString)
            let numberWithOutCommas = newString.replacingOccurrences(of: ",", with: "")
            let number = formatter.number(from: numberWithOutCommas)
            if number != nil {
                var formattedString = formatter.string(from: number!)

                // If the last entry was a decimal or a zero after a decimal,
                // re-add it here because the formatter will naturally remove
                // it.
                if aString == "." && range.location == textFieldText.count {
                    formattedString = formattedString?.appending(".")
                }
                return formattedString
            } else {
                return nil
            }
        }

        return nil
    }

    static func isDeviceIpad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
    }

    static func convertToJsonDictionary(responseData: Data) -> [String: Any]? {

        do {
            let decoded = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any]
            if let dictFromJSON = decoded {
               return dictFromJSON
            }

        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    static func openSettigsApp() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }

    static func openURLInBrowser(url: String) {
        guard let browserURL = URL(string: url) else {
            return
        }

        if UIApplication.shared.canOpenURL(browserURL) {
            UIApplication.shared.open(browserURL, completionHandler: { (success) in
                print("url opened: \(browserURL) : \(success)")
            })
        }
    }

    static func parseLocal<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let data: Data
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {fatalError("Couldn't find \(filename) in main Bundle.")}

        do {
            data = try Data(contentsOf: file)
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
            }
        } catch {
            fatalError("Couldn't find \(filename) from main Bundle:\n\(error)")
        }
    }
    
    static func parseLocalJson<T: Decodable>(_ jsonData: Data) -> T {
        do {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: jsonData)
            } catch {
                fatalError("Couldn't parse  as \(T.self):\n\(error)")
            }
        }
    }

    static func localizedString(forKey: String) -> String {

        let result = NSLocalizedString(forKey, comment: "")
        return result
    }

    static var appTarget: String? {
        if let targetName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String {
            return targetName
        }
        return nil
    }

    // FOR TRANSACTION FILTER..
    static func getDateRange(dateOption: TransactionTimePeriod) -> ([Date]) {

        var startDate = Date()
        var endDate = Date()

        switch dateOption {
        case .week:
            startDate = Date().startOfWeek ?? Date()
            endDate = Date().endOfWeek ?? Date()
        case .month:
            startDate = Calendar.current.startOfMonth(for: Date())
            endDate = Calendar.current.endOfMonth(for: Date())
        case .lastMonth:
            if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) {
                startDate = Calendar.current.startOfMonth(for: previousMonth)
                endDate = Calendar.current.endOfMonth(for: previousMonth)
            }
        default:
            break
        }

        return [startDate, endDate]
    }
    
    static func getFormattedAmount(amount: String) -> String {
        let aBalance = Double(amount) ?? 0
        let balNumber = NSNumber(value: Double(aBalance))
        let formattedAmount = Utility.getCurrencyForAmount(amount: balNumber, isDecimalRequired: true, withoutSpace: true)
        
        return formattedAmount
    }

    static func getCountry(forCountryCode: String) -> String {
        var countryCode = String()
        if forCountryCode == "" {
            countryCode = "+1"
        } else {
            countryCode = forCountryCode
        }

        let filteredArray = AppMetaDataHelper.shared.config?.supportedCountries?.filter({ $0.dialCode! == countryCode})
        return filteredArray?[0].code ?? "US"
    }
    
    static func isNonUS(forPhoneNumber: String = "") -> Bool {
        if !forPhoneNumber.isEmpty && forPhoneNumber.countryCode() != Constants.countryCodeUS {
            return true
        } else if let userCountry = AppGlobalData.shared().personData.phone?.countryCode(), userCountry != Constants.countryCodeUS {
            return true
        } else {
            return false
        }
    }
    
    //TO GET TOP SPACING WHEN BUSINESS VIEW IS NOT AVAILABELE IN NAVIGATION
    static func getTopSpacing() -> CGFloat {
        var topSpace: CGFloat = 65
        
        if let accountsList = AppGlobalData.shared().accountList, accountsList.count > 0 {
            let businessAccountsList = accountsList.filter({ $0.type == .businessChecking})
            if businessAccountsList.count > 0 {
                topSpace = 130
            }
        }
        
        return topSpace
    }
    
    static func getFormattedPhoneNumber(forCountryCode: String, phoneNumber: String, withMaxLimit: Int) -> String {
        return (forCountryCode != Constants.countryCodeUS) ? phoneNumber.formattedNonUSPhoneNumber(strCode: forCountryCode, maxLength: withMaxLimit) : phoneNumber.formattedUSPhoneNumber()
    }
    
    static func getGooglePlacesFilterCountry() -> String {
        let strCountryCode = AppGlobalData.shared().personData.phone?.countryCode() ?? AppGlobalData.shared().selectedCountryCode
        let strCountry = Utility.getCountry(forCountryCode: strCountryCode)
        return strCountry
    }
}
