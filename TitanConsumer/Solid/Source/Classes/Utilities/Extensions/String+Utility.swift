//
//  String+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit
import RNCryptor

extension String {

    static var strSelfMatch = "SELF MATCHES %@"
    
    var serverDateFormat: String {
        return "yyyy-MM-dd'T'HH:mm:ss'Z'"
    }

    var isAlphaNumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var alphanumString: String {
        let pattern = "[^A-Za-z0-9 ]+"
        let result = self.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
        return result
    }

    var numberString: String {
        let okayChars = Set("1234567890")
        return self.filter {okayChars.contains($0) }
    }

	var zipcodewithHyphenString: String {
		let okayChars = Set("1234567890-")
		return self.filter {okayChars.contains($0) }
	}

    var decimalString: String {
        let okayChars = Set("1234567890.")
        return self.filter {okayChars.contains($0) }
    }

    var trim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

    func substring(from: Int) -> String {
        let start = from
        let end = self.count

        if start < 0 || end > self.count || start > end {
            return ""
        }
        let startIndex = index(self.startIndex, offsetBy: start)
        let endIndex = index(self.startIndex, offsetBy: end)
        let range = startIndex..<endIndex
        return String(self[range])
    }

    func substring(start: Int, end: Int) -> String {
        if start < 0 || end > self.count {
            return ""
        }
        let start = index(self.startIndex, offsetBy: start)
        let end = index(self.startIndex, offsetBy: end)
        let range = start..<end
        return String(self[range])
    }

    func atIndex(index: Int) -> String {
        return substring(start: index, end: index + 1)
    }

    func isNumber() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")// Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: self)
        let hasValidChars = allowedCharacters.isSuperset(of: characterSet)
        return hasValidChars
    }

    // to check having only alphabet entry..
    func shouldAllowEntry() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
            if regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil {
                return false
            }
        } catch {

        }
        return true
    }

    func last4() -> String! {
        if self.count > 4 {
            return substring(from: self.count - 4)
        }
        return self
    }

    func till(_ delimeter: String) -> String? {
        let split = self.components(separatedBy: delimeter)
        return split[0]
    }

    // FORMATTING
    func formattedUSPhoneNumber() -> String {
        let trimmed = self.replacingOccurrences(of: Constants.countryCodeUS, with: "")
        var str = trimmed.numberString
        str = str.count > Constants.phoneNumberLimit ? str.substring(start: 0, end: Constants.phoneNumberLimit) : str

        if str.count > 6 {
            let s1 = str.substring(start: 0, end: 3)
            let s2 = str.substring(start: 3, end: 6)
            let s3 = str.substring(start: 6, end: str.count)
            let num =  "(\(s1)) \(s2)-\(s3)"
            return num
        }
        return str
    }
    
    func formattedNonUSPhoneNumber(strCode: String, maxLength: Int) -> String {
        let trimmed = self.replacingOccurrences(of: strCode, with: "")
        var str = trimmed.numberString
        str = str.count > maxLength ? str.substring(start: 0, end: maxLength) : str
        return str
    }
    
    // Phone Country Code
    func countryCode() -> String {
        for dictCodes in AppMetaDataHelper.shared.config?.supportedCountries ?? [] {
            let countryCode = dictCodes.dialCode ?? "+1"
            if self.contains(countryCode) {
                return countryCode
            }
        }
        
        return ""
    }
    
    // Phone number limit
    func phoneNumberLimit() -> Int {
        for dictCodes in AppMetaDataHelper.shared.config?.supportedCountries ?? [] {
            let countryCode = dictCodes.dialCode ?? "+1"
            if self.contains(countryCode) {
                if let allowedLength = dictCodes.maxLength {
                    return allowedLength
                }
                return Constants.phoneNumberLimit
            }
        }
        
        return Constants.phoneNumberLimit
    }
    
    func ssnString() -> String {
        var str = self.numberString
        str = str.count > Constants.ssnCodeLimit ? str.substring(start: 0, end: Constants.ssnCodeLimit) : str
        return str
    }

    func ssnLast4String() -> String {
        var str = self
        str = str.count > Constants.ssnLast4Limit ? str.substring(start: 0, end: Constants.ssnLast4Limit) : str
        return str
    }
    
    func cardLast4String() -> String {
        var str = self
        str = str.count > Constants.last4Limit ? str.substring(start: 0, end: Constants.last4Limit) : str
        return str
    }

    func zipcodeString() -> String {
        var str = self.numberString
        str = str.count > Constants.zipCodeLimit ? str.substring(start: 0, end: Constants.zipCodeLimit) : str
        return str
    }

    func mfaString() -> String {
        var str = self.numberString
        str = str.count > Constants.mfaCodeLimit ? str.substring(start: 0, end: Constants.mfaCodeLimit) : str
        return str
    }
    
    func ownerPercentageString() -> String {
        var str = self.numberString
        str = str.count > 3 ? str.substring(start: 0, end: 3) : str
        return str
    }

    func accountNumberString() -> String { // For account number limit
        var str = self.numberString
        str = str.count > Constants.accountNumberMaxLimit ? str.substring(start: 0, end: Constants.accountNumberMaxLimit) : str
        return str
    }

    func routingNumberString() -> String { // For routing number limit
        var str = self.numberString
        str = str.count > Constants.routingNumber ? str.substring(start: 0, end: Constants.routingNumber) : str
        return str
    }

    func embossingPersonNameString() -> String { // For card embossing person name limit
        let str = self.count > Constants.embossingPersonName ? self.substring(start: 0, end: Constants.embossingPersonName) : self
        return str
    }
    
    func embossingBusinessNameString() -> String { // For card embossing business name limit
        let str = self.count > Constants.embossingBusinessName ? self.substring(start: 0, end: Constants.embossingBusinessName) : self
        return str
    }
    
    func isAccountNumberInLimit() -> Bool { // For account number limit
        let str = self.numberString

        if str.count < Constants.accountNumberMinLimit {
            return false
        } else if str.count > Constants.accountNumberMaxLimit {
            return false
        } else {
            return true
        }
    }

    func formatCardNumber() -> String {
        var startIndex = 0
        var endIndex = 4
        let cardNumber = self
        var formattedCardNumber = ""

        for _ in 0..<cardNumber.count {

            var subString = cardNumber.substring(start: startIndex, end: endIndex)
            formattedCardNumber = formattedCardNumber.count > 0 ? "\(formattedCardNumber) \(subString)" : subString

            if endIndex == cardNumber.count {
                break
            }

            if (endIndex + 4) > cardNumber.count {
                subString = cardNumber.substring(start: endIndex, end: cardNumber.count)
                formattedCardNumber = "\(formattedCardNumber) \(subString)"
                break
            } else {
                startIndex = endIndex
                endIndex += 4
            }
        }

        return formattedCardNumber

    }

    var plainNumberString: String {
        let numbersOnly = CharacterSet(charactersIn: "0123456789")
        let filteredPhone = self.filter { (aChar) -> Bool in
            return aChar.unicodeScalars.contains(where: { numbersOnly.contains($0)})
        }

        return filteredPhone
    }

    func phoneStringWithoutCode(countryCode: String) -> String {
        let withoutCode = self.replacingOccurrences(of: countryCode, with: "")
        return withoutCode.numberString
    }

    func ssnFormat() -> String {
        let str = self.numberString
        if str.count > 5 {
            let count = str.count < 9 ? str.count : 9
            let s1 = str.substring(start: 0, end: 3)
            let s2 = str.substring(start: 3, end: 5)
            let s3 = str.substring(start: 5, end: count)
            let num = "\(s1)-\(s2)-\(s3)"
            return num
        }
        return str
    }

    func passportString() -> String {
        var str = self
        str = str.count > Constants.passportNumberMaxLimit ? str.substring(start: 0, end: Constants.passportNumberMaxLimit) : str
        return str
    }
    
    func isPassportString() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: [])
            if regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil {
                return false
            }
        } catch {

        }
        return true
    }

    func isValidPassportNumber() -> Bool {
        return self.trim.count >= Constants.passportNumberMinLimit && self.trim.count <= Constants.passportNumberMaxLimit
    }
    
    func maskedSSN() -> String {
        let s1 = self.substring(start: count - 4, end: count)
        return "XXX-XX-\(s1)"

    }

    func programCodeString() -> String {
        var str = self.numberString
        str = str.count > Constants.programCodeLimit ? str.substring(start: 0, end: Constants.programCodeLimit) : str
        return str
    }

    func einFormat() -> String {
        let str = self.numberString
        if str.count > 2 {
            let count = str.count < Constants.einCodeLimit ? str.count : Constants.einCodeLimit
            let s1 = str.substring(start: 0, end: 2)
            let s2 = str.substring(start: 2, end: count)
            let num = "\(s1)-\(s2)"
            return num
        }
        return str
    }

	func zipCodeFormat() -> String {
		let str = self.numberString
		if str.count > 5 {
			let count = str.count < Constants.zipCodeLimit ? str.count : Constants.zipCodeLimit
			let s1 = str.substring(start: 0, end: 5)
			let s2 = str.substring(start: 5, end: count)
            let num = Utility.isNonUS() ? "\(s1)\(s2)" :  "\(s1)-\(s2)"
			return num
		}
		return str
	}

    func maskedEin() -> String {
        let s1 = self.substring(start: count - 5, end: count)
        return "XX-XXX\(s1)"
    }

    func maskedDebitCard() -> String {
        if self.count > 0 {
            let number = self.numberString
            let last4Digits = number.substring(from: number.count - 4)
            let maskedNumber = "**** **** **** \(last4Digits)"
            return maskedNumber
        }
        return self
    }

    func maskedAccountNumber() -> String {
        if self.count > 0 {
            let last4Digits = self.substring(from: self.count - 4)
            let maskedNumber = "••• \(last4Digits)"
            return maskedNumber
        }
        return self
    }

    func accountNumberLast3() -> String {
        if self.count > 0 {
            let last3Digits = self.substring(from: self.count - 3)
            let maskedNumber = "****\(last3Digits)"
            return maskedNumber
        }
        return self
    }

    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: String.strSelfMatch, emailRegEx)
        return emailTest.evaluate(with: self)
    }

	var isValidUSZipcode: Bool {
        let pincodeRegEx = "^\\d{5}(?:[-\\s]?\\d{4})?$"
        let pincodeString = NSPredicate(format: String.strSelfMatch, pincodeRegEx)
        return pincodeString.evaluate(with: self)
	}
    
    var isValidNonUSZipcode: Bool {
        let pincodeRegEx = "^\\d{5,9}"
        let pincodeString = NSPredicate(format: String.strSelfMatch, pincodeRegEx)
        return pincodeString.evaluate(with: self)
    }

    func isInvalidInput() -> Bool {
        return (isHavingSpecialChars() || isHavingSQLKeywords())
    }

    func isInvalidAddress() -> Bool {
        return (isHavingSpecialCharsForAddress() || isHavingSQLKeywords())
    }

    func isHavingSpecialCharsForAddress() -> Bool {
        return self.range(of: "[!\"#$%()_*+/:;<=>?\\[\\\\\\]^`{|}~]+", options: .regularExpression) != nil
    }

    func isHavingSpecialChars() -> Bool {
        return self.range(of: "[!\"#$%'()_*+.,-/:;<=>?\\[\\\\\\]^`{|}~]+", options: .regularExpression) != nil
    }

    func isHavingSQLKeywords() -> Bool {
        let enterdString = self
        let keywordsMainArray: [String] = ["select", "drop", "update", "alter", "truncate", "delete", "insert", "create"]
        let keywordsSupportArray: [String] = ["from", "table", "*", "database", "join", "where", "like"]

        for item in keywordsMainArray {
            if enterdString.lowercased().contains(item.lowercased()) {
                for data in keywordsSupportArray {
                    if enterdString.lowercased().contains(data.lowercased()) {
                        return true
                    }
                }
            }
        }

        return  false
    }

    var digits: String { return filter { $0.isWholeNumber } }

    var decimal: Decimal { return Decimal(string: digits) ?? 0 }

    func getAttributedString(forLineSpacing lineSpacing: CGFloat) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributedDesc = NSMutableAttributedString(string: self)

        attributedDesc.addAttribute(NSAttributedString.Key.font, value: UIFont.sfProDisplayRegular(fontSize: 14.0), range: NSRange(location: 0, length: attributedDesc.length))
        attributedDesc.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedDesc.length))
        attributedDesc.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryColor, range: NSRange(location: 0, length: attributedDesc.length))

        return attributedDesc
    }

    func getAttributedColorString(usingString uString: String, coloredString cString: String) -> NSMutableAttributedString {
        let range = (uString as NSString).range(of: cString)
        let attributedString = NSMutableAttributedString(string: uString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range)

        return attributedString
    }

    func getAttributedAddContactString() -> NSMutableAttributedString {
        let range1 = (description as NSString).range(of: "+")
        let range2 = (description as NSString).range(of: description)

        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.sfProDisplayRegular(fontSize: 14.0), range: range2)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.sfProDisplayRegular(fontSize: 20), range: range1)

        return attributedString
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }

    var decimleNumber: NSNumber? {
        let aDeciNum = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.number(from: aDeciNum)
    }

    var doubleValue: Double? {
        return self.decimleNumber?.doubleValue ?? 0
    }

    var floatValue: Float! {
        return self.decimleNumber?.floatValue ?? 0
    }

    func convertJsonStringToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            let resultDic = Utility.convertToJsonDictionary(responseData: data)
            return resultDic
        }
        return nil

    }
    
    func convertJsonStringToArryOfDictionary() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension String {

    func getUnderlinedString(underline underLineText: String) -> NSMutableAttributedString {

        let underlineAttriString = NSMutableAttributedString(string: self)
        let range1 = (description as NSString).range(of: underLineText)

        let range2 = (description as NSString).range(of: description)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.7

        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryColor, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.sfProDisplayRegular(fontSize: 14.0), range: range2)

        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.sfProDisplayRegular(fontSize: 14.0), range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: underlineAttriString.length))

        return underlineAttriString
    }

    func getThemeColorText(themeColorText colorText: String) -> NSMutableAttributedString {
        let colorAttriString = NSMutableAttributedString(string: self)
        let range1 = (description as NSString).range(of: colorText)
        let range2 = (description as NSString).range(of: description)
		let font = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize12
        colorAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryColor, range: range2)
        colorAttriString.addAttribute(NSAttributedString.Key.font, value: font, range: range1)
        colorAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range1)
        return colorAttriString
    }

    func getColoredText(forText: String, withColor: UIColor) -> NSMutableAttributedString {

        let colorAttriString = NSMutableAttributedString(string: self)
        let range1 = (description as NSString).range(of: forText)
        let range2 = (description as NSString).range(of: description)

        colorAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range2)
		let font = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.regularFontSize14
        colorAttriString.addAttribute(NSAttributedString.Key.font, value: font, range: range1)
        colorAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: withColor, range: range1)

        return colorAttriString
    }

    func getBoldString(bold boldText: String, withColor: UIColor) -> NSMutableAttributedString {

        let boldAttriString = NSMutableAttributedString(string: self)
        let range1 = (description as NSString).range(of: boldText)
        let range2 = (description as NSString).range(of: description)

        boldAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryColor, range: range2)
        boldAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.sfProDisplayRegular(fontSize: 14.0), range: range2)

        boldAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.sfProDisplayMedium(fontSize: 14.0), range: range1)
        boldAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: withColor, range: range1)

        return boldAttriString
    }
    
    func getUnderlinedBoldString(underLineText1: String, underLineText2: String) -> NSMutableAttributedString {
        let underlineAttriString = NSMutableAttributedString(string: self)
        let range1 = (description as NSString).range(of: underLineText1)
        let range2 = (description as NSString).range(of: underLineText2)

        let range3 = (description as NSString).range(of: description)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.7

        let lblRegularFont = Utility.isDeviceIpad() ? Constants.regularFontSize17 : Constants.regularFontSize14
        let lblMediumFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16 : Constants.mediumFontSize14

        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryColor, range: range3)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: lblRegularFont, range: range3)

        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: lblMediumFont, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: underlineAttriString.length))

        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: lblMediumFont, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: underlineAttriString.length))
        
        return underlineAttriString
    }
    
    func getAttributedStringWithImage(withImage: String, withImageSize: CGRect) -> NSMutableAttributedString {
        let attachImage = UIImage(named: withImage)
        let attributedString = NSMutableAttributedString(string: self)
        let imgAttachment = NSTextAttachment()
        imgAttachment.image = attachImage
        let iconsSize = withImageSize
        imgAttachment.bounds = iconsSize
        attributedString.append(NSAttributedString(attachment: imgAttachment))
        
        return attributedString
    }
    
    func getNAICSString(withDescText: String, withLinkText: String) -> NSMutableAttributedString {
        let naicsString = NSMutableAttributedString(string: self)
        let naicsRange = (description as NSString).range(of: description)
        let descRange = (description as NSString).range(of: withDescText)
        let linkRange = (description as NSString).range(of: withLinkText)
                
        let titlefont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        let descfont = Utility.isDeviceIpad() ? Constants.regularFontSize14 : Constants.regularFontSize10
        let linkfont = Utility.isDeviceIpad() ? Constants.mediumFontSize14 : Constants.mediumFontSize10

        naicsString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryColor, range: naicsRange)
        naicsString.addAttribute(NSAttributedString.Key.font, value: titlefont, range: naicsRange)
        naicsString.addAttribute(NSAttributedString.Key.font, value: descfont, range: descRange)
        
        naicsString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: linkRange)
        naicsString.addAttribute(NSAttributedString.Key.font, value: linkfont, range: linkRange)
        naicsString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.primaryColor, range: linkRange)
        return naicsString
    }
}

extension String {

    //    ENCRYPTION
    static let cryptokey   = "KbvQEAPPTeFkCvFX12ep7hJQOK9Yxy"

    func encrypt() -> String {
        let data: Data       = self.data(using: String.Encoding.utf8)!
        let ciphertext      = RNCryptor.encrypt(data: data, withPassword: String.cryptokey)
        let latinString     = String(data: ciphertext, encoding: String.Encoding.isoLatin1)!
        return latinString
    }

    func decrypt() -> String? {
        do {
            let thePinData      = self.data(using: String.Encoding.isoLatin1)!
            let originalData    = try RNCryptor.decrypt(data: thePinData, withPassword: String.cryptokey)
            let string          = String(data: originalData, encoding: String.Encoding.utf8)
            return string

        } catch {
            debugPrint(error)
            return nil
        }
    }
}

extension String {

    func utcDateToLocal() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.string(from: dt!)
    }

    func utcDateTo(formate: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = formate

        if let convertedDate = dt {
            return dateFormatter.string(from: convertedDate)
        }

        return nil
    }

    func toMonthYearFormat() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM yyyy"

        if let finalDate = dt {
            return dateFormatter.string(from: finalDate)
        } else {
            return nil
        }
    }

    func dateTo(formate: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = formate

        if let convertedDate = dt {
            return dateFormatter.string(from: convertedDate)
        }

        return nil
    }

    func getDate(format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)!
        return date
    }

    func getStatementDate(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        if let dat = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM_yyyy"
            let sDate = dateFormatter.string(from: dat)
            return sDate
        }
        return ""
    }

    func toCardValidityDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        if let dat = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "MMM yyyy"
            let sDate = dateFormatter.string(from: dat)
            return sDate
        }
        return ""
    }
}
extension String {

    func isValid(rules: [ValidationRule]) -> Bool {
        guard let number = Int(self) else {
            return false
        }
        for rule in rules {
            if !rule.isValid(for: number) {
                return false
            }
        }
        return true
    }
    
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter) // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

        if zeroDiff == 0 { // <3>
            // Same format, compare normally
            return self.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) // <5>
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }
    
    var currency: String {
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
    
    var removeCurrency: String {
        // removing all characters from string before formatting
        let stringWithoutSymbol = self.replacingOccurrences(of: "$", with: "")
        let stringWithoutComma = stringWithoutSymbol.replacingOccurrences(of: ",", with: "")
        return stringWithoutComma
    }
    
    func isDecimalNumber() -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")// Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: self)
        let hasValidChars = allowedCharacters.isSuperset(of: characterSet)
        return hasValidChars
    }
}
