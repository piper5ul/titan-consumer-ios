//
//  CurrencyTextField.swift
//  Solid
//
//  Created by Solid iOS Team on 9/20/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

protocol CurrencyDelegate {
    func current(amount: Double)
}

class CurrencyTextField: UITextField {

    var delegateCurreny: CurrencyDelegate?
    var tfTextAlignment: NSTextAlignment = .left {
        didSet {
            self.textAlignment = tfTextAlignment
        }
    }
    var tfTextColor: UIColor = .black {
        didSet {
            self.textColor = tfTextColor
        }
    }

    var tfDecimalLimit: Decimal = 999_999_999.99 {
        didSet {
            self.maximum = tfDecimalLimit
        }
    }

    var tfXInsets: CGFloat = 15.0 {
        didSet {
            self.obXInset = tfXInsets
        }
    }

    var obXInset = CGFloat(15)

    var string: String { return text ?? "0.0" }
    var decimal: Decimal {
        return string.decimal / pow(10, Formatter.currency.maximumFractionDigits)
    }
    var decimalNumber: NSDecimalNumber { return decimal.number }
    var doubleValue: Double { return decimalNumber.doubleValue }
    var integerValue: Int { return decimalNumber.intValue   }
    var maximum: Decimal = 999_999_999.99
    private var lastValue: String?
    override func willMove(toSuperview newSuperview: UIView?) {
        // you can make it a fixed locale currency if needed
        // Formatter.currency.locale = Locale(identifier: "pt_BR") // or "en_US", "fr_FR", etc
        Formatter.currency.locale = Locale(identifier: "en_US")
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        editingChanged()
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
        textAlignment = .left
        tfTextColor = UIColor.primaryColor
		font = Utility.isDeviceIpad() ? Constants.regularFontSize18: Constants.regularFontSize14
        self.cornerRadius = Constants.cornerRadiusThroughApp
        //self.borderColor = .customSeparatorColor
        //self.borderWidth = 1
        self.layer.masksToBounds = true
        self.backgroundColor = .background

        keyboardType = .numberPad
        addDoneButtonOnKeyboard()
		
		var tHeight: CGFloat = Constants.textfieldheightIphone
		if Utility.isDeviceIpad() {
			tHeight = 64
		}
        self.addConstraint(self.heightAnchor.constraint(equalToConstant: tHeight))
    }

    override func deleteBackward() {
        text = string.digits.dropLast().string
        editingChanged()
    }
    @objc func editingChanged() {
        guard decimal <= maximum else {
            text = lastValue
            return
        }
        text = Formatter.currency.string(for: decimal)
        lastValue = text
        amountStateUI()
        let amountRounded = self.doubleValue.rounded(toPlaces: 2)
        self.delegateCurreny?.current(amount: amountRounded)
    }

    func setDefault(value: String) {
        if let amt = Double(value) {
            self.text = Formatter.currency.string(for: amt) // "\(amt)"
            self.textColor = tfTextColor // UIColor.primaryColor
        } else {
            self.text = Formatter.currency.string(for: 0.0) // "0"
            self.textColor = UIColor.secondaryColorWithOpacity
        }
//        self.editingChanged()
    }

    private func amountStateUI() {
        if self.doubleValue == 0.00 {
            self.attributedPlaceholder =  NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.font: self.font ?? UIFont.sfProDisplayMedium(fontSize: 15), NSAttributedString.Key.foregroundColor: UIColor.secondaryColor])
            self.textColor = UIColor.secondaryColorWithOpacity
        } else {
            self.textColor = tfTextColor // UIColor.primaryColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tfTextColor = UIColor.primaryColor
    }
}

extension CurrencyTextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let xValue: CGFloat = obXInset
        return bounds.insetBy(dx: xValue, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let xValue: CGFloat = obXInset
        return bounds.insetBy(dx: xValue, dy: 0)
    }
}

extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
    }
}

extension Formatter {
    static let currency = NumberFormatter(numberStyle: .currency)
}

extension Decimal {
    var number: NSDecimalNumber { return NSDecimalNumber(decimal: self) }
}

extension LosslessStringConvertible {
    var string: String { return .init(self) }
}
