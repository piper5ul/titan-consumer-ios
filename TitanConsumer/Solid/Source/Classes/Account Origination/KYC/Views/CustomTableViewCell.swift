//
//  CustomTableViewCell.swift
//  TableV
//
//  Created by Solid iOS Team on 2/2/21.
//

import UIKit

enum RequiredData {
    case DOB
}

// MARK: - CELL
@objc protocol FormDataCellDelegate {
    @objc optional	func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?)
    @objc optional func cell (_ cell: CustomTableViewCell, editing: Any?, ended data: Any?)
    @objc optional func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?)
    @objc optional func cell (shouldCelar cell: CustomTableViewCell) -> Bool
    
    //FOR NAICS & ETV VALUE PICKER
    @objc optional func cellWithListItem(_ cell: CustomTableViewCell, selected data: ListItems?)
    
    //FOR ETV COUNT PICKER
    @objc optional func cellETVCount(_ cell: CustomTableViewCell, selected data: ListItems?)
}

class CustomTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet var inputTextField: BaseTextField?
    @IBOutlet var pickerTextField2: BaseTextField?
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var subTitleLabel: UILabel?
    @IBOutlet var descLabel: UILabel?
    
    @IBOutlet var indicatorView: UIActivityIndicatorView?
    @IBOutlet var imgV: UIImageView?
    
    @IBOutlet var cellView2: UIView?
    
    @IBOutlet weak var bottomConstlblDesc: NSLayoutConstraint!
    @IBOutlet weak var leadingConstCellView2: NSLayoutConstraint!
    @IBOutlet weak var widthConstCellView2: NSLayoutConstraint!
    @IBOutlet weak var heightConstlblTitle: NSLayoutConstraint!
    
    weak var delegate: FormDataCellDelegate?
    
    var requiredField: RequiredData!
    
    var arrPickerData: [ListItems] = []
    var arrPickerData2: [ListItems] = []
    
    let dobDatePicker = UIDatePicker()
    
    var pickerView = UIPickerView()
    var pickerView2 = UIPickerView()
    
    var strSelectedCountryCode: String? = Constants.countryCodeUS
    var maxPhoneNumberLength: Int = Constants.phoneNumberLimit
    
    var indexPath: IndexPath?
    
    var fieldType: String? = "" {
        didSet {
            if let tfType = fieldType, !tfType.isEmpty {
                inputTextField?.fieldType = (inputTextField?.getTextFieldType(fieldType: tfType))!
                
                if inputTextField?.fieldType == .picker {
                    self.imgV?.isHidden = false
                    self.imgV?.image = UIImage(named: "down")
                } else {
                    self.imgV?.isHidden = true
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let titlefont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        
        self.titleLabel?.font = titlefont
        self.titleLabel?.textColor = UIColor.secondaryColor
        
        self.subTitleLabel?.font = titlefont
        self.subTitleLabel?.textColor = UIColor.secondaryColor
        self.subTitleLabel?.isHidden = true
        
        self.leadingConstCellView2.constant = 0
        self.widthConstCellView2.constant = 0
        self.cellView2?.isHidden = true
        
        self.descLabel?.font = titlefont
        self.descLabel?.textColor = UIColor.secondaryColor
        
        self.indicatorView?.isHidden = true
        self.imgV?.isHidden = true
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView2.dataSource = self
        pickerView2.delegate = self
        
        self.backgroundColor =  .clear
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.titleLabel?.textColor = UIColor.secondaryColor
        self.descLabel?.textColor = UIColor.secondaryColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        delegate?.cell?(self, editing: textField, begin: nil)
        
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder?
        if nextResponder != nil {
            // Found next responder, so set it
            textField.returnKeyType = .next
        } else {
            // Not found, so remove keyboard
            textField.returnKeyType = .done
        }
        let type = inputTextField?.fieldType
        
        if type == .dob {
            setDatePicker()
        } else if textField == inputTextField && type == .picker {
            setPicker()
        } else if textField == pickerTextField2 {
            setPicker2()
        } else {
            self.inputTextField?.inputView = nil
            self.inputTextField?.inputAccessoryView = nil
            self.inputTextField?.updateTextFieldType()
            
            if type == .email {
                self.inputTextField?.autocorrectionType = .no
            } else {
                self.inputTextField?.autocapitalizationType = .words
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let theString = textField.text! as NSString
        let theNewString = theString.replacingCharacters(in: range, with: string).trim
        
        let type = inputTextField?.fieldType
        if type == .ssn || type == .ssnumber {
            textField.text = theNewString.ssnFormat()
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        } else if type == .zipCode {
            textField.text = theNewString.zipCodeFormat()
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        } else if type == .ein {
            textField.text = theNewString.einFormat()
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        } else if type == .alphabet {
            if theNewString.shouldAllowEntry() {
                delegate?.cell?(self, editing: textField, changed: theNewString)
            }
            return theNewString.shouldAllowEntry()
        } else if type == .phone {
            textField.text = Utility.getFormattedPhoneNumber(forCountryCode: strSelectedCountryCode ?? "", phoneNumber: theNewString, withMaxLimit: maxPhoneNumberLength)
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        } else if type == .accountNumber {
            textField.text = theNewString.accountNumberString()
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        } else if type == .routingNumber {
            textField.text = theNewString.routingNumberString()
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        } else if type == .passport {
            let passString = theString.replacingCharacters(in: range, with: string)
            if passString.isPassportString() {
                textField.text = passString.passportString()
                delegate?.cell?(self, editing: textField, changed: textField.text)
            }
            return false
        } else if type == .embossingPerson {
            let strPersonName = theString.replacingCharacters(in: range, with: string)
            textField.text = strPersonName.embossingPersonNameString()
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        } else if type == .embossingBusiness {
            let strBusinessName = theString.replacingCharacters(in: range, with: string)
            textField.text = strBusinessName.embossingBusinessNameString()
            delegate?.cell?(self, editing: textField, changed: textField.text)
            return false
        }
        
        delegate?.cell?(self, editing: textField, changed: theNewString)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.cell?(self, editing: textField, ended: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder?
        
        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        _ = delegate?.cell?(shouldCelar: self)
        return true
    }
    
    func validateEnteredText(enteredText: String) {
        if enteredText.isInvalidInput() {
            self.inputTextField?.status = .error
            self.inputTextField?.linkedErrorLabel?.text = Utility.localizedString(forKey: "invalid_input")
        } else {
            self.inputTextField?.status = .normal
        }
    }
    
    func validateEnteredAddressText(enteredText: String) {
        if enteredText.isInvalidAddress() {
            self.inputTextField?.status = .error
            self.inputTextField?.linkedErrorLabel?.text = Utility.localizedString(forKey: "invalid_input")
        } else {
            self.inputTextField?.status = .normal
        }
    }
}

// MARK: - Set Picker
extension CustomTableViewCell {
    func setDatePicker() {
        let toolbar = UIToolbar()
        
        // Format Date
        dobDatePicker.datePickerMode = .date
        dobDatePicker.backgroundColor = .white
        dobDatePicker.setValue(UIColor.primaryColor, forKey: "textColor")
        
        if #available(iOS 13.4, *) {
            dobDatePicker.preferredDatePickerStyle = .wheels
            
            if dobDatePicker.subviews.count > 0 {
                dobDatePicker.subviews[0].subviews[0].backgroundColor = .background
            }
        }
        
        let calendar = Calendar(identifier: .gregorian)
        
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = -18 // must be of 18+ age
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        dobDatePicker.maximumDate = maxDate
        
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(doneDatePicker))
        doneButton.tintColor = .primaryColor
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelDatePicker))
        cancelButton.tintColor = .primaryColor
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        self.inputTextField?.inputAccessoryView = toolbar
        self.inputTextField?.inputView = dobDatePicker
    }
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy" // "MMMM dd, yyyy"
        self.inputTextField!.text = formatter.string(from: dobDatePicker.date)
        self.endEditing(true)
        
        delegate?.cell?(self, editing: textField, changed: self.inputTextField!.text)
    }
    
    func setPicker() {
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let toolbar = UIToolbar()
        
        pickerView.backgroundColor = .background
        pickerView.setValue(UIColor.primaryColor, forKey: "textColor")
        
        if #available(iOS 13.4, *) {
            if pickerView.subviews.count > 0 {
                pickerView.subviews[0].subviews[0].backgroundColor = .background
            }
        }
        
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = .primaryColor
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelDatePicker))
        cancelButton.tintColor = .primaryColor
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        self.inputTextField?.inputAccessoryView = toolbar
        self.inputTextField?.inputView = pickerView
    }
    
    @objc func donePicker() {
        let pickerLabel: UILabel? = (self.pickerView.view(forRow: self.pickerView.selectedRow(inComponent: 0), forComponent: 0) as? UILabel)
        
        self.inputTextField!.text = pickerLabel?.text
        
        self.endEditing(true)
        
        delegate?.cell?(self, editing: textField, changed: self.inputTextField!.text)
        
        //FOR NAICS CODE.
        if arrPickerData.count > 0 {
            delegate?.cellWithListItem?(self, selected: arrPickerData[self.pickerView.selectedRow(inComponent: 0)])
        }
    }
    
    func setPicker2() {
        pickerView2 = UIPickerView()
        pickerView2.dataSource = self
        pickerView2.delegate = self
        
        let toolbar = UIToolbar()
        
        pickerView2.backgroundColor = .background
        pickerView2.setValue(UIColor.primaryColor, forKey: "textColor")
        
        if #available(iOS 13.4, *) {
            if pickerView2.subviews.count > 0 {
                pickerView2.subviews[0].subviews[0].backgroundColor = .background
            }
        }
        
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(donePicker2))
        doneButton.tintColor = .primaryColor
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelDatePicker))
        cancelButton.tintColor = .primaryColor
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        self.pickerTextField2?.inputAccessoryView = toolbar
        self.pickerTextField2?.inputView = pickerView2
    }
    
    @objc func donePicker2() {
        let pickerLabel: UILabel? = (self.pickerView2.view(forRow: self.pickerView2.selectedRow(inComponent: 0), forComponent: 0) as? UILabel)
        
        self.pickerTextField2!.text = pickerLabel?.text
        self.endEditing(true)
        
        //FOR ETV.
        delegate?.cellETVCount?(self, selected: arrPickerData2[self.pickerView2.selectedRow(inComponent: 0)])
    }
    
    @objc func cancelDatePicker() {
        self.endEditing(true)
    }
}

// MARK: - UIPickerViewDelegate
extension CustomTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == pickerView2 ? arrPickerData2.count : arrPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This is a required method.
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label : UILabel
        if view == nil {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: UIFont.systemFont(ofSize: 20).lineHeight * UIScreen.main.scale))
            label.textAlignment = .center
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.autoresizingMask = .flexibleWidth
            label.font = UIFont.systemFont(ofSize: 20)
        } else {
            label = view as! UILabel
        }
        
        if pickerView == pickerView2 {
            if row < arrPickerData2.count {
                if let strText = arrPickerData2[row].title, !strText.isEmpty {
                    label.text = strText
                }
            }
        } else {
            if row < arrPickerData.count {
                if let strText = arrPickerData[row].title, !strText.isEmpty {
                    label.text = strText
                }
            }
        }
        return label;
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return UIFont.systemFont(ofSize: 20).lineHeight * UIScreen.main.scale
    }
}
