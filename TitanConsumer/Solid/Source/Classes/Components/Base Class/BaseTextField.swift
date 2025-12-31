//
//  BaseTextField.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import Foundation
import UIKit

enum TextFieldType {
    case phone
    case email
    case alphaNumeric
    case ssn
    case ssnumber
    case mfa
    case ein
    case password
    case alphabet
    case dob
    case picker
    case zipCode
    case numeric
    case accountNumber
    case routingNumber
	case currency
    case search
    case passport
    case embossingPerson
    case embossingBusiness
}

class BaseTextField: AuthTextField {

    let defaultUnderlineColor: UIColor = UIColor.customSeparatorColor
    let onFocusUnderlineColor: UIColor = UIColor.primaryColor
    var obXInset = CGFloat(15)
    var obTextAlignment: NSTextAlignment = .left

    var fieldType: TextFieldType = .alphaNumeric {
        didSet {
            updateTextFieldType()
        }
    }

    var placeholderString: String? {
        didSet {

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = obTextAlignment
			let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
            self.attributedPlaceholder =  NSAttributedString(string: self.placeholderString ?? "", attributes: [NSAttributedString.Key.font: self.font ?? titleFont, NSAttributedString.Key.foregroundColor: UIColor.secondaryColor.withAlphaComponent(0.24),
                NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialise()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }

    func initialise() {
		self.font = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        self.textColor = UIColor.primaryColor
        
		var tHeight: CGFloat = Constants.textfieldheightIphone
		if Utility.isDeviceIpad() {
			tHeight = Constants.textfieldheightIpad
		}
		self.addConstraint(self.heightAnchor.constraint(equalToConstant: tHeight))

        self.setCornerRadius(corner: Constants.cornerRadiusThroughApp)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.textColor = UIColor.primaryColor
    }

    func setCornerRadius(corner: CGFloat) {
        self.layer.cornerRadius = corner
        self.layer.masksToBounds = corner > 0
    }
}

extension BaseTextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var xValue: CGFloat = obXInset
        let insetValue = Utility.isDeviceIpad() ?  obXInset + 75.0 : obXInset + 65.0
        if fieldType == .phone {
            xValue = insetValue
        } else if fieldType == .search {
            xValue = obXInset + 30.0
        }

        let textPadding = UIEdgeInsets(
                top: 0,
                left: xValue,
                bottom: 0,
                right: fieldType == .picker ? 40 : 15
            )
        return bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var xValue: CGFloat = obXInset
        let insetValue = Utility.isDeviceIpad() ?  obXInset + 75.0 : obXInset + 65.0
        if fieldType == .phone {
            xValue = insetValue
        } else  if fieldType == .search {
            xValue = obXInset + 30.0
        } else if fieldType == .currency {
            xValue = obXInset + 25.0
        }
        let textPadding = UIEdgeInsets(
                top: 0,
                left: xValue,
                bottom: 0,
                right: fieldType == .picker ? 40 : 15
            )
        
        return bounds.inset(by: textPadding)
    }
    
    func getTextFieldType(fieldType: String) -> TextFieldType {
        let keyboardType: TextFieldType

        switch fieldType {
            case "fName", "lName", "alphabet":
                keyboardType = .alphabet
            case "email":
                keyboardType = .email
            case "dob":
                keyboardType = .dob
            case "stringPicker":
                keyboardType = .picker
            case "ssn", "ssnumber":
                keyboardType = .ssn
            case "ein":
                keyboardType = .ein
            case "address_Zipcode":
                keyboardType = .zipCode
            case "phone":
                keyboardType = .phone
            case "accountNumber":
                keyboardType = .accountNumber
            case "routingNumber":
                keyboardType = .routingNumber
            case "passport":
                keyboardType = .passport
            case "embossingPerson":
                keyboardType = .embossingPerson
            case "embossingBusiness":
                keyboardType = .embossingBusiness
            default:
                keyboardType = .alphaNumeric
        }

        return keyboardType
    }
}

extension BaseTextField {

    func updateTextFieldType() {
        switch fieldType {
        case .phone:
            self.keyboardType = .phonePad
        case .password:
            self.keyboardType = .alphabet
        case .email:
            self.keyboardType = .emailAddress
        case .ssn, .mfa, .zipCode, .ein, .numeric, .accountNumber, .routingNumber, .currency:
            self.keyboardType = .numberPad
            addDoneButtonOnKeyboard()
        default:
            self.keyboardType = .alphabet
        }
    }
}

extension BaseTextField {

    override func becomeFirstResponder() -> Bool {
        _ = super.becomeFirstResponder()
        return true
    }

    override func resignFirstResponder() -> Bool {
        _ = super.resignFirstResponder()
        return true
    }
}
