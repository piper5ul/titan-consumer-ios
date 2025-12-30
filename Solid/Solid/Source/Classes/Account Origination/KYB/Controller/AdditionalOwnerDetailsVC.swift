//
//  AdditionalOwnerDetailsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 24/02/21.
//

import UIKit

class AdditionalOwnerDetailsVC: BaseVC, FormDataCellDelegate {

    var arrTitles = [String]()
    var arrFieldTypes = [String]()
    var arrOwnerData = [String]()

    var detailsModel = KYCPersonDetailsModel()

    @IBOutlet weak var tblOwnerDetails: UITableView!
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    var selectedCountryCode = AppGlobalData.shared().personData.phone?.countryCode() ?? AppGlobalData.shared().selectedCountryCode
    var maxPhoneNumberLength: Int = AppGlobalData.shared().personData.phone?.phoneNumberLimit() ?? AppGlobalData.shared().maxPhoneNumberLength

    var codeTextField: UITextField?
    let codePickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblOwnerDetails.backgroundColor = .clear

        self.setNavigationBar()
        self.setData()
        self.setOwnerData()
        registerCellsAndHeaders()
        self.tblOwnerDetails.reloadData()

        self.setFooterUI()

        validateData()
    }

    func setData(forType: String = TaxType.ssn.rawValue) {
        if forType == TaxType.passport.rawValue {
            arrTitles = ["fName", "lName", "phone", "email", "dob", "docType", "passport"]
            arrFieldTypes = ["fName", "lName", "phone", "email", "dob", "stringPicker", "passport"]
        } else {
            arrTitles = ["fName", "lName", "phone", "email", "dob", "docType", "ssnumber"]
            arrFieldTypes = ["fName", "lName", "phone", "email", "dob", "stringPicker", "ssnumber"]
        }
    }

    func setOwnerData() {
        let firstName = detailsModel.firstName ?? ""
        let lastName = detailsModel.lastName ?? ""
        let phone = detailsModel.phone ?? ""
        let email = detailsModel.email ?? ""
        var dateOfBirth = detailsModel.dob ?? ""
        let ssn = detailsModel.ssn ?? ""
        let idType = detailsModel.idType
        let strIdType = TaxType.title(for: idType?.rawValue ?? "")
        
        if !dateOfBirth.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let dob = dateFormatter.date(from: dateOfBirth) {
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let birthDate = dateFormatter.string(from: dob)
                dateOfBirth = birthDate
            }
        }

        let idNumber = (idType == .passport) ? ssn : ssn.ssnFormat()
        arrOwnerData = [firstName, lastName, phone, email, dateOfBirth, strIdType, idNumber]
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(gotoAddressScreen), for: .touchUpInside)
    }

    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        var footerFrame = footerView.frame
        var footerY: CGFloat = footerView.frame.origin.y
        let navigationBarHeight = self.getNavigationbarHeight()
        UIView.animate(withDuration: 0.2) {
			footerY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navigationBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navigationBarHeight
			footerFrame.origin.y = footerY
            self.footerView.frame = footerFrame
            self.view.layoutIfNeeded()

            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
            self.tblOwnerDetails.contentInset = contentInsets
            self.tblOwnerDetails.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblOwnerDetails.scrollIndicatorInsets = self.tblOwnerDetails.contentInset
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let lblPhoneColor = self.tblOwnerDetails.viewWithTag(Constants.tagForCountryCodeLabel) as? UILabel {
                lblPhoneColor.textColor = .primaryColor
        }
    }
}

// MARK: - Navigationbar
extension AdditionalOwnerDetailsVC {

    func setNavigationBar() {
        self.title = Utility.localizedString(forKey: "kyc_NavTitle")
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        addBackNavigationbarButton()
    }

    func validateData() {
        if let firstName = detailsModel.firstName, !firstName.isEmpty && !firstName.isInvalidInput(),
           let lastName = detailsModel.lastName, !lastName.isEmpty && !lastName.isInvalidInput(),
           let phoneNo = detailsModel.phone?.phoneStringWithoutCode(countryCode: selectedCountryCode), !phoneNo.isEmpty, phoneNo.count == maxPhoneNumberLength,
           let emailVal = detailsModel.email, !emailVal.isEmpty, emailVal.isValidEmail,
           let dobVal = detailsModel.dob, !dobVal.isEmpty,
           let idTypeVal = detailsModel.idType, !idTypeVal.rawValue.isEmpty,
           let ownerSSNVal = detailsModel.ssn, !ownerSSNVal.isEmpty {
            if idTypeVal == TaxType.ssn && ownerSSNVal.plainNumberString.count == Constants.ssnCodeLimit {
                self.footerView.btnApply.isEnabled = true
            } else if idTypeVal == TaxType.passport && ownerSSNVal.isValidPassportNumber() {
                self.footerView.btnApply.isEnabled = true
            } else {
                self.footerView.btnApply.isEnabled = false
            }
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }

    @objc func gotoAddressScreen() {

        self.performSegue(withIdentifier: "GoToAdditionalOwnerAddressVC", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AdditionalOwnerAddressVC {
            if let phone = detailsModel.phone?.phoneStringWithoutCode(countryCode: selectedCountryCode) {
                let mobileNumber = selectedCountryCode + phone
                detailsModel.phone = mobileNumber
            }
            destinationVC.detailsModel = self.detailsModel
        }
    }
}

// MARK: - UITableView
extension AdditionalOwnerDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {

        guard let indexPath = self.tblOwnerDetails.indexPath(for: cell) else {return}

        self.scrollToIndexPath = indexPath
    }

    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

        guard let indexPath = self.tblOwnerDetails.indexPath(for: cell), let text = data as? String else {return}

        switch indexPath.row {
        case 0: // First name
            detailsModel.firstName = text.trim
            cell.validateEnteredText(enteredText: text.trim)
            
        case 1:// Last name
            detailsModel.lastName = text.trim
            cell.validateEnteredText(enteredText: text.trim)
            
        case 2:// phone
            let mobileNumber = text.phoneStringWithoutCode(countryCode: selectedCountryCode)
            detailsModel.phone = mobileNumber
            
        case 3:// Email
            detailsModel.email = text.trim
            
        case 4:// DOB
            detailsModel.dob = text.trim
            
        case 5:// doc type
            let idType = TaxType(rawValue: TaxType.entityId(for: text.trim))
            detailsModel.idType = idType
            setData(forType: idType?.rawValue ?? "")
            arrOwnerData[indexPath.row + 1] = ""
            detailsModel.ssn = ""
            arrOwnerData[indexPath.row] = text.trim
            tblOwnerDetails.reloadRows(at: [indexPath], with: .none)
            tblOwnerDetails.reloadRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: .none)
            
        case 6:// SSN/Passport
            detailsModel.ssn = text.trim
            
        default:break
        }

        arrOwnerData[indexPath.row] = text.trim

        validateData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func cell(shouldCelar cell: CustomTableViewCell) -> Bool {
        return false
    }
}

// MARK: - FormDataCellDelegate
extension AdditionalOwnerDetailsVC {

    func registerCellsAndHeaders() {
        self.tblOwnerDetails.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cellheight: CGFloat
		cellheight	= Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
		return cellheight
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        let strTitle = arrTitles[indexPath.row]
        cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
        cell.arrPickerData = TaxType.dataNodes
        cell.inputTextField?.text = arrOwnerData[indexPath.row]
        cell.fieldType = arrFieldTypes[indexPath.row]
        cell.inputTextField?.tag = indexPath.row

        cell.delegate = self
        
        if let codeLabel = cell.inputTextField?.viewWithTag(Constants.tagForCountryCodeLabel) {
            codeLabel.removeFromSuperview()
        }
        
        if cell.fieldType  == "phone" {
            let codeLabel = UILabel()
            codeLabel.frame = CGRect(x: Constants.countryCodeLableXConst, y: Constants.countryCodeLableYConst, width: Constants.countryCodeLableWidthConst, height: Constants.countryCodeLableHeightConst)
            codeLabel.text = Constants.countryCodeUS
            
            let strCountryCode = selectedCountryCode + " "
            codeLabel.attributedText = strCountryCode.getAttributedStringWithImage(withImage: "down", withImageSize: CGRect(x: 0, y: -3, width: 15, height: 15))
            codeLabel.layer.cornerRadius = Constants.cornerRadiusThroughApp
            codeLabel.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
            
            codeLabel.isUserInteractionEnabled = true
            let gestureReco = UITapGestureRecognizer(target: self, action: #selector(showCountryCodePicker))
            gestureReco.numberOfTapsRequired = 1
            codeLabel.addGestureRecognizer(gestureReco)

            codeLabel.font = Constants.regularFontSize14
            codeLabel.backgroundColor = UIColor.grayBackgroundColor
            codeLabel.textColor = .primaryColor
            codeLabel.textAlignment = .center
            codeLabel.tag = Constants.tagForCountryCodeLabel            
            cell.strSelectedCountryCode = self.selectedCountryCode
            cell.maxPhoneNumberLength = self.maxPhoneNumberLength
            cell.inputTextField?.addSubview(codeLabel)
        }
        
        return cell
    }
}

// MARK: - country code
extension AdditionalOwnerDetailsVC: UIPickerViewDelegate, UIPickerViewDataSource {

    @objc func showCountryCodePicker() {
        let navBarHeight = self.getNavigationbarHeight()
        codePickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 150 - navBarHeight, width: view.frame.size.width, height: 150)
        codePickerView.backgroundColor = .background
        codePickerView.setValue(UIColor.primaryColor, forKey: "textColor")
        codePickerView.delegate = self
        codePickerView.dataSource = self

        if #available(iOS 13.4, *), codePickerView.subviews.count > 0 {
            codePickerView.subviews[0].subviews[0].backgroundColor = .background
        }

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelPicker))
        cancelButton.tintColor = .primaryColor
        
        let doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = .primaryColor
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)

        codeTextField?.removeFromSuperview()
        codeTextField = UITextField(frame: .zero)
        codeTextField?.text = selectedCountryCode
        view.addSubview(codeTextField!)

        codeTextField!.inputView = codePickerView
        codeTextField!.inputAccessoryView = toolbar
        codeTextField!.becomeFirstResponder()
    }

    @objc func cancelPicker() {
        codeTextField?.resignFirstResponder()
    }
    
    @objc func donePicker() {
        codeTextField?.resignFirstResponder()
        selectedCountryCode =  AppMetaDataHelper.shared.config?.supportedCountries?[codePickerView.selectedRow(inComponent: 0)].dialCode ?? "+1"
        if let allowedLength = AppMetaDataHelper.shared.config?.supportedCountries?[codePickerView.selectedRow(inComponent: 0)].maxLength {
            maxPhoneNumberLength = allowedLength
        }
        
        detailsModel.phone = ""
        tblOwnerDetails.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        validateData()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppMetaDataHelper.shared.config?.supportedCountries?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let codeVal = AppMetaDataHelper.shared.config?.supportedCountries?[row].dialCode ?? "+1"
        let flagVal = AppMetaDataHelper.shared.config?.supportedCountries?[row].code ?? "US"
        let selectedValue = self.countryFlag(countryCode: flagVal) + " " + codeVal
        return NSAttributedString(string: selectedValue, attributes: nil)
    }
    
    func countryFlag(countryCode: String) -> String {
        return String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap({UnicodeScalar(127397 + $0.value)})))
    }
}
