//
//  PinCodeHelper.swift
//  Solid
//
//  Created by Solid iOS Team on 14/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

protocol PINOTPViewDelegate: AnyObject {
    /// Called whenever the textfield has to become first responder. Called for the first field when loading
    ///
    /// - Parameter index: the index of the field. Index starts from 0.
    /// - Returns: return true to show keyboard and vice versa
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool
    
    /// Called whenever all the OTP fields have been entered. It'll be called immediately after `hasEnteredAllOTP` delegate method is called.
    ///
    /// - Parameter otpString: The entered otp characters
    func enteredOTP(otpString: String, otpViewType: UIView)
    
    /// Called whenever an OTP is entered.
    ///
    /// - Parameter hasEntered: `hasEntered` will be `true` if all the OTP fields have been filled.
    /// - Returns: return if OTP entered is valid or not. If false and all otp has been entered, then error
    func hasEnteredAllOTP(hasEntered: Bool, otpViewType: UIView) -> Bool
}

class PINOTPView: UIView {
    /// Different display type for text fields.
    enum DisplayType {
        case circular
        case square
        case diamond
        case underlinedBottom
    }
    
    /// Different input type for OTP fields.
    enum KeyboardType: Int {
        case numeric
        case alphabet
        case alphaNumeric
    }
    
    /// Define the display type for OTP fields. Defaults to `circular`.
    var otpFieldDisplayType: DisplayType = .circular
    
    /// Defines the number of OTP field needed. Defaults to 4.
    var otpFieldsCount: Int = 4
    
    /// Defines the type of the data that can be entered into OTP fields. Defaults to `numeric`.
    var otpFieldInputType: KeyboardType = .numeric
    
    /// Define the font to be used to OTP field. Defaults tp `systemFont` with size `20`.
    var otpFieldFont: UIFont = UIFont.systemFont(ofSize: 20)
    
    /// If set to `true`, then the content inside OTP field will be displayed in asterisk (*) format. Defaults to `false`.
    var otpFieldEntrySecureType: Bool = false
    
    /// If set to `true`, then the content inside OTP field will not be displayed. Instead whatever was set in `otpFieldEnteredBorderColor` will be used to mask the passcode.
    ///
    ///  If `otpFieldEntrySecureType` is set to `true`, then it'll be ignored. This acts similar to Apple's lock code. Defaults to `false`.
    
    var otpFilledEntryDisplay: Bool = false
    
    /// If set to `false`, the blinking cursor for OTP field will not be visible. Defaults to `true`.
    var shouldRequireCursor: Bool = true
    
    /// If `shouldRequireCursor` is set to `false`, then this property will not have any effect. If `true`, then the color of cursor can be changed using this property. Defaults to `blue` color.
    var cursorColor: UIColor = UIColor.primaryColor
    
    /// Defines the size of OTP field. Defaults to `60`.
    var otpFieldSize: CGFloat = 60
    
    /// Space between 2 OTP field. Defaults to `16`.
    var otpFieldSeparatorSpace: CGFloat = 16
    
    /// Border width to be used, if border is needed. Defaults to `2`.
    var otpFieldBorderWidth: CGFloat = 1
    
    /// If set, then editing can be done to intermediate fields even though previous fields are empty. Else editing will take place from last filled text field only. Defaults to `true`.
    var shouldAllowIntermediateEditing: Bool = true
    
    /// Set this value if a background color is needed when a text is not enetered in the OTP field. Defaults to `clear` color.
    var otpFieldDefaultBackgroundColor: UIColor = UIColor.clear
    
    /// Set this value if a background color is needed when a text is enetered in the OTP field. Defaults to `clear` color.
    var otpFieldEnteredBackgroundColor: UIColor = UIColor.clear
    
    /// Set this value if a border color is needed when a text is not enetered in the OTP field. Defaults to `black` color.
    var otpFieldDefaultBorderColor: UIColor = UIColor(red: 0.93, green: 0.938, blue: 0.946, alpha: 1)
    
    /// Set this value if a border color is needed when a text is enetered in the OTP field. Defaults to `black` color.
    var otpFieldEnteredBorderColor: UIColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    
    /// Optional value if a border color is needed when the otp entered is invalid/incorrect.
    var otpFieldErrorBorderColor: UIColor?
    
    weak var delegate: PINOTPViewDelegate?
    
    fileprivate var secureEntryData = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Public functions
    /// Call this method to create the OTP field view. This method should be called at the last after necessary customization needed. If any property is modified at a later stage is simply ignored.
    func initializeUI() {
        layer.masksToBounds = true
        layoutIfNeeded()
        
        initializeOTPFields()
        
        // Forcefully try to make first otp field as first responder
        (viewWithTag(1) as? PINOTPTextField)?.becomeFirstResponder()
    }
    
    //MARK: Private functions
    // Set up the fields
    fileprivate func initializeOTPFields() {
        secureEntryData.removeAll()
        
        for index in stride(from: 0, to: otpFieldsCount, by: 1) {
            let oldOtpField = viewWithTag(index + 1) as? PINOTPTextField
            oldOtpField?.removeFromSuperview()
            let otpField = getOTPField(forIndex: index)
            addSubview(otpField)
            secureEntryData.append("")
        }
    }
    
    func setOTPFrame (index: Int) -> CGRect {
        var fieldFrame = CGRect(x: 0, y: 0, width: otpFieldSize, height: otpFieldSize)

        fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(otpFieldsCount / 2 - index) * (otpFieldSize + otpFieldSeparatorSpace) + otpFieldSize / 2) + 10
        
        // If odd, then center of self will be center of middle field. If false, then center of self will be center of space between 2 middle fields
        
        fieldFrame.origin.y = (bounds.size.height - otpFieldSize) / 2
        
        return fieldFrame
    }
    
    // Initalize the required OTP fields
    func getOTPField(forIndex index: Int) -> PINOTPTextField {
        
        let fieldFrame = self.setOTPFrame(index: index)
        
        let otpField = PINOTPTextField(frame: fieldFrame)
        otpField.delegate = self
        otpField.tag = index + 1
        otpField.font = otpFieldFont
        
        // Set input type for OTP fields
        switch otpFieldInputType {
        case .numeric:
            otpField.keyboardType = .numberPad
        case .alphabet:
            otpField.keyboardType = .alphabet
        case .alphaNumeric:
            otpField.keyboardType = .namePhonePad
        }
        
        // Set the border values if needed
        otpField.borderColor = otpFieldDefaultBorderColor
        otpField.borderWidth = otpFieldBorderWidth
        
        if shouldRequireCursor {
            otpField.tintColor = cursorColor
        } else {
            otpField.tintColor = UIColor.clear
        }
        
        // Set the default background color when text not set
        otpField.backgroundColor = otpFieldDefaultBackgroundColor
        
        // Finally create the fields
        otpField.initalizeUI(forFieldType: otpFieldDisplayType)
        
        return otpField
    }
    
    // Check if previous text fields have been entered or not before textfield can edit the selected field. This will have effect only if
    fileprivate func isPreviousFieldsEntered(forTextField textField: UITextField) -> Bool {
        var isTextFilled = true
        var nextOTPField: UITextField?
        
        // If intermediate editing is not allowed, then check for last filled field in forward direction.
        if !shouldAllowIntermediateEditing {
            for index in stride(from: 1, to: otpFieldsCount + 1, by: 1) {
                let tempNextOTPField = viewWithTag(index) as? UITextField
                
                if let tempNextOTPFieldText = tempNextOTPField?.text, tempNextOTPFieldText.isEmpty {
                    nextOTPField = tempNextOTPField
                    
                    break
                }
            }
            
            if let nextOTPField = nextOTPField {
                isTextFilled = (nextOTPField == textField || (textField.tag) == (nextOTPField.tag - 1))
            }
        }
        
        return isTextFilled
    }
    
    func removeOtherText() {
        for textFeild in self.subviews {
          (textFeild as! UITextField).text = ""
          (textFeild as! UITextField).layer.borderColor = UIColor.secondaryColor.cgColor
        }
      }
    
    func removeSecureData() {
        self.removeOtherText()
        secureEntryData.removeAll()
        for _ in stride(from: 0, to: otpFieldsCount, by: 1) {
            secureEntryData.append("")
        }
    }
    
    func deletedBackClick() {
        _ = delegate?.hasEnteredAllOTP(hasEntered: false, otpViewType: self)
        
        // Set the default enteres state for otp entry
        for index in stride(from: 0, to: otpFieldsCount, by: 1) {
            var otpField = viewWithTag(index + 1) as? PINOTPTextField
            
            if otpField == nil {
                otpField = getOTPField(forIndex: index)
            }
            
            let fieldBackgroundColor = (otpField?.text ?? "").isEmpty ? otpFieldDefaultBackgroundColor : otpFieldEnteredBackgroundColor
            let fieldBorderColor = (otpField?.text ?? "").isEmpty ? otpFieldDefaultBorderColor : otpFieldEnteredBorderColor
            
            if otpFieldDisplayType == .diamond || otpFieldDisplayType == .underlinedBottom {
                otpField?.shapeLayer.fillColor = fieldBackgroundColor.cgColor
                otpField?.shapeLayer.strokeColor = fieldBorderColor.cgColor
            } else {
                otpField?.backgroundColor = fieldBackgroundColor
                otpField?.layer.borderColor = fieldBorderColor.cgColor
            }
        }
    }
    
    func deletedBackElseClick() {
        var enteredOTPString = ""
        // Check for entered OTP
        for index in stride(from: 0, to: secureEntryData.count, by: 1) where !secureEntryData[index].isEmpty {
            enteredOTPString.append(secureEntryData[index])
        }
        
        if enteredOTPString.count == otpFieldsCount {
            delegate?.enteredOTP(otpString: enteredOTPString, otpViewType: self)
            
            // Check if all OTP fields have been filled or not. Based on that call the 2 delegate methods.
            let isValid = delegate?.hasEnteredAllOTP(hasEntered: (enteredOTPString.count == otpFieldsCount), otpViewType: self) ?? false
            
            // Set the error state for invalid otp entry
            for index in stride(from: 0, to: otpFieldsCount, by: 1) {
                var otpField = viewWithTag(index + 1) as? PINOTPTextField
                
                if otpField == nil {
                    otpField = getOTPField(forIndex: index)
                }
                
                if !isValid {
                    // Set error border color if set, if not, set default border color
                    otpField?.layer.borderColor = (otpFieldErrorBorderColor ?? otpFieldEnteredBorderColor).cgColor
                } else {
                    otpField?.layer.borderColor = otpFieldEnteredBorderColor.cgColor
                }
            }
        } else {
            delegate?.enteredOTP(otpString: enteredOTPString, otpViewType: self)
        }
    }
    
    // Helper function to get the OTP String entered
    fileprivate func calculateEnteredOTPSTring(isDeleted: Bool) {
        if isDeleted {
            deletedBackClick()
        } else {
            deletedBackElseClick()
        }
    }
}

extension PINOTPView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = delegate?.shouldBecomeFirstResponderForOTP(otpFieldIndex: (textField.tag - 1)) ?? true
        if textField.tag == 1 {
            self.removeOtherText()
            }
        if shouldBeginEditing {
            return isPreviousFieldsEntered(forTextField: textField)
        }
        
        return shouldBeginEditing
    }
    
    func otpFiledEntry (textField: UITextField, addedText: String) {
        if otpFilledEntryDisplay {
            textField.text = " "
        } else {
            if otpFieldEntrySecureType {
                textField.text = "•"
            } else {
                textField.text = addedText
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        // Check since only alphabet keyboard is not available in iOS
        if !replacedText.isEmpty && otpFieldInputType == .alphabet && replacedText.rangeOfCharacter(from: .letters) == nil {
            return false
        }
        
        if replacedText.count >= 1 {
            // If field has a text already, then replace the text and move to next field if present
            secureEntryData[textField.tag - 1] = string
            self.otpFiledEntry(textField: textField, addedText: string)
            
            textField.backgroundColor = otpFieldEnteredBackgroundColor
            textField.layer.borderColor = otpFieldEnteredBorderColor.cgColor
            
            let nextOTPField = viewWithTag(textField.tag + 1)
            
            if let nextOTPField = nextOTPField {
                nextOTPField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            
            // Get the entered string
            calculateEnteredOTPSTring(isDeleted: false)
        } else {
            let currentText = textField.text ?? ""
            
            if textField.tag > 1 && currentText.isEmpty {
                if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                    deleteText(in: prevOTPField)
                }
            } else {
                deleteText(in: textField)
                
                if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField, textField.tag > 1 {
                    prevOTPField.becomeFirstResponder()
                }
            }
        }
        
        return false
    }
    
    private func deleteText(in textField: UITextField) {
        // If deleting the text, then move to previous text field if present
        secureEntryData[textField.tag - 1] = ""
        textField.text = ""
        
        if otpFieldDisplayType == .diamond || otpFieldDisplayType == .underlinedBottom {
            (textField as! PINOTPTextField).shapeLayer.fillColor = otpFieldDefaultBackgroundColor.cgColor
            (textField as! PINOTPTextField).shapeLayer.strokeColor = otpFieldDefaultBorderColor.cgColor
        } else {
            textField.backgroundColor = otpFieldDefaultBackgroundColor
            textField.layer.borderColor = otpFieldDefaultBorderColor.cgColor
        }
        
        textField.becomeFirstResponder()
        
        // Get the entered string
        calculateEnteredOTPSTring(isDeleted: true)
    }
}
