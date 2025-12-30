//
//  ContactDetailsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 02/03/21.
//

import UIKit

class ContactDetailsVC: BaseVC, FormDataCellDelegate {
    var arrTitles = [String]()
    var arrFieldTypes = [String]()
    
    var arrContactData = [String]()
    
    var contactData: ContactDataModel? = ContactDataModel()
    var originalData: ContactDataModel? = ContactDataModel()
    
    var contactFlow: ContactFlow? = .create
    var checkStatusType: FundType? = .unknown
    @IBOutlet weak var topConstEditContact: NSLayoutConstraint!
    
    var selectedCountryCode = AppGlobalData.shared().personData.phone?.countryCode() ?? AppGlobalData.shared().selectedCountryCode
    var maxPhoneNumberLength: Int = AppGlobalData.shared().personData.phone?.phoneNumberLimit() ?? AppGlobalData.shared().maxPhoneNumberLength
    
    var dummyTextField: UITextField?
    let pickerView = UIPickerView()
    
    @IBOutlet weak var tblContactDetails: UITableView!
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setData()
        
        if let _ = self.contactData?.id {
            self.originalData = self.contactData
            self.setContactData()
        } else {
            originalData = ContactDataModel()
            contactData = ContactDataModel()
            arrContactData = ["", "", ""]
        }
        
        registerCellsAndHeaders()
        self.tblContactDetails.reloadData()
        self.tblContactDetails.backgroundColor = .clear
        
        if contactFlow == .edit {
            topConstEditContact.constant = 0
        }
        
        self.setFooterUI()
        validate()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
        if let contact = contactData, let conId = contact.id, !conId.isEmpty {
            footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "done"))
        }
    }
    
    func setData() {
        arrTitles = ["contact_Details_Name", "contact_Details_Phone", "contact_Details_Email"]
        arrFieldTypes = ["alphaNumeric", "phone", "email"]
    }
    
    func setContactData() {
        let name = contactData?.name ?? ""
        var phone = ""
        if let phoneNo = contactData?.phone, !phoneNo.isEmpty {
            selectedCountryCode = phoneNo.countryCode()
            let phoneLimit = phoneNo.phoneNumberLimit()
            maxPhoneNumberLength = Int(phoneLimit)
            let formatedNumber = Utility.getFormattedPhoneNumber(forCountryCode: selectedCountryCode, phoneNumber: phoneNo, withMaxLimit: phoneLimit)
            phone = formatedNumber
        }
        
        let email = contactData?.email ?? ""
        arrContactData = [name, phone, email]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let tblCell = self.tblContactDetails, let lblPhoneColor = tblCell.viewWithTag(Constants.tagForCountryCodeLabel) as? UILabel {
            lblPhoneColor.textColor = .primaryColor
        }
    }
    
    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        var bdcFrame = footerView.frame
        var bdcY: CGFloat = footerView.frame.origin.y
        let navBarHeight = self.getNavigationbarHeight()
        UIView.animate(withDuration: 0.2) {
            bdcY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
            bdcFrame.origin.y = bdcY
            self.footerView.frame = bdcFrame
            self.view.layoutIfNeeded()
            
            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/1.5), right: 0.0)
            self.tblContactDetails.contentInset = contentInsets
            self.tblContactDetails.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblContactDetails.scrollIndicatorInsets = self.tblContactDetails.contentInset
        }
    }
}

// MARK: - Navigationbar
extension ContactDetailsVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        
        addBackNavigationbarButton()
        
        self.title = contactFlow == .edit ? Utility.localizedString(forKey: "contact_details_EditTitle") : Utility.localizedString(forKey: "contact_Details_NavTitle")
    }
    
    @objc func handleNavigation() {
        if let contactID = self.contactData?.id {
            if isUpdated() {
                self.updateContact(contactID: contactID)
            } else {
                self.popVC()
            }
        } else {
            self.view.endEditing(true)
            createContact()
        }
    }
    
    func navigateToRCD() {
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CaptureCheckViewController") as? CaptureCheckViewController {
            vc.paymentModel = RCModel()
            vc.contactId =  self.contactData?.id
            vc.contactName =  self.contactData?.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func validate() {
        var isValid = true
        
        // for email validation
        if let email = contactData?.email, !email.isEmpty {
            debugPrint(email)
            if email.isValidEmail {
                self.footerView.btnApply.isEnabled = true
            } else {
                self.footerView.btnApply.isEnabled = false
                isValid = false
            }
        }
        
        // for phome number
        if let contactPhone = contactData?.phone, !contactPhone.isEmpty, contactPhone != selectedCountryCode {
            let phone = contactPhone.phoneStringWithoutCode(countryCode: selectedCountryCode)
            if !phone.isEmpty, phone.count == maxPhoneNumberLength {
                self.footerView.btnApply.isEnabled = true
            } else {
                self.footerView.btnApply.isEnabled = false
                isValid = false
            }
        }
        
        // for name and number
        if let name = contactData?.name, !name.isEmpty && !name.isInvalidInput() && isValid {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
    
    func isUpdated() -> Bool {
        var isUpdated = false
        
        if originalData?.name != contactData?.name {
            isUpdated = true
        }
        
        if originalData?.email != contactData?.email {
            isUpdated = true
        }
        
        let originalContactCountryCode = originalData?.phone?.countryCode()
        let originalContactPhone =  originalData?.phone?.phoneStringWithoutCode(countryCode: originalContactCountryCode!)
        
        let updatedContactCountryCode = contactData?.phone?.countryCode()
        let updatedContactPhone =  contactData?.phone?.phoneStringWithoutCode(countryCode: updatedContactCountryCode!)
        
        if originalContactPhone != updatedContactPhone {
            isUpdated = true
        }
        
        return isUpdated
    }
}

// MARK: - FormDataCellDelegate
extension ContactDetailsVC {
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
        guard let indexPath = self.tblContactDetails.indexPath(for: cell) else {return}
        
        self.scrollToIndexPath = indexPath
    }
    
    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {
        guard let indexPath = self.tblContactDetails.indexPath(for: cell), let text = data as? String else {return}
        
        switch indexPath.row {
        case 0: // Name
            contactData?.name = text.trim
            cell.validateEnteredText(enteredText: text.trim)
            
        case 1:// Phone
            let mobileNumber = selectedCountryCode + text.numberString
            contactData?.phone = mobileNumber
            
        case 2:// Email
            contactData?.email = text.trim
            
        default:break
        }
        
        validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func cell(shouldCelar cell: CustomTableViewCell) -> Bool {
        return false
    }
}

// MARK: - UITableView
extension ContactDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblContactDetails.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        self.tblContactDetails.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        let strTitle = arrTitles[indexPath.row]
        cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
        cell.inputTextField?.text = arrContactData[indexPath.row]
        cell.fieldType = arrFieldTypes[indexPath.row]
        cell.inputTextField?.tag = indexPath.row
        cell.delegate = self
        
        if let lblCode = cell.inputTextField?.viewWithTag(Constants.tagForCountryCodeLabel) {
            lblCode.removeFromSuperview()
        }
        
        if cell.fieldType  == "phone" {
            var lblCode = UILabel()
            lblCode = UILabel(frame: CGRect(x: Constants.countryCodeLableXConst, y: Constants.countryCodeLableYConst, width: Constants.countryCodeLableWidthConst, height: Constants.countryCodeLableHeightConst))
            
            let strCountryCode = selectedCountryCode + " "
            lblCode.attributedText = strCountryCode.getAttributedStringWithImage(withImage: "down", withImageSize: CGRect(x: 0, y: -3, width: 15, height: 15))
            lblCode.layer.cornerRadius = Constants.cornerRadiusThroughApp
            lblCode.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
            
            lblCode.isUserInteractionEnabled = true
            let gestureReco = UITapGestureRecognizer(target: self, action: #selector(showCountryCodePicker))
            gestureReco.numberOfTapsRequired = 1
            lblCode.addGestureRecognizer(gestureReco)
            
            lblCode.textAlignment = .center
            lblCode.textColor = .primaryColor
            lblCode.tag = Constants.tagForCountryCodeLabel
            lblCode.backgroundColor = UIColor.grayBackgroundColor
            let codeFont = Constants.regularFontSize14
            lblCode.font = codeFont
            cell.inputTextField?.addSubview(lblCode)
            cell.strSelectedCountryCode = self.selectedCountryCode
            cell.maxPhoneNumberLength = self.maxPhoneNumberLength
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return contactFlow == .edit ? 50 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cheight: CGFloat
        cheight	= Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
        return cheight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        headerCell.lblSectionHeader.text = Utility.localizedString(forKey: "contact_Details_Title")
        headerCell.lblSectionHeader.font = Constants.commonFont
        return headerCell
    }
}

// MARK: - country code
extension ContactDetailsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    @objc func showCountryCodePicker() {
        let navBarHeight = self.getNavigationbarHeight()
        pickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 150 - navBarHeight, width: view.frame.size.width, height: 150)
        pickerView.backgroundColor = .background
        pickerView.setValue(UIColor.primaryColor, forKey: "textColor")
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if #available(iOS 13.4, *), pickerView.subviews.count > 0 {
            pickerView.subviews[0].subviews[0].backgroundColor = .background
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelPicker))
        cancelButton.tintColor = .primaryColor
        
        let doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = .primaryColor
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        dummyTextField?.removeFromSuperview()
        dummyTextField = UITextField(frame: .zero)
        dummyTextField?.text = selectedCountryCode
        view.addSubview(dummyTextField!)
        
        dummyTextField!.inputView = pickerView
        dummyTextField!.inputAccessoryView = toolbar
        dummyTextField!.becomeFirstResponder()
    }
    
    @objc func cancelPicker() {
        dummyTextField?.resignFirstResponder()
    }
    
    @objc func donePicker() {
        dummyTextField?.resignFirstResponder()
        selectedCountryCode = AppMetaDataHelper.shared.config?.supportedCountries?[pickerView.selectedRow(inComponent: 0)].dialCode ?? "+1"
        if let allowedLength = AppMetaDataHelper.shared.config?.supportedCountries?[pickerView.selectedRow(inComponent: 0)].maxLength {
            maxPhoneNumberLength = allowedLength
        }
        
        arrContactData[1] = ""
        tblContactDetails.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        validate()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppMetaDataHelper.shared.config?.supportedCountries?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let codeValue = AppMetaDataHelper.shared.config?.supportedCountries?[row].dialCode ?? "+1"
        let flagValue = AppMetaDataHelper.shared.config?.supportedCountries?[row].code ?? "US"
        let selectedValue = self.countryFlag(countryCode: flagValue) + " " + codeValue
        return NSAttributedString(string: selectedValue, attributes: nil)
    }
    
    func countryFlag(countryCode: String) -> String {
        return String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap({UnicodeScalar(127397 + $0.value)})))
    }
}

// MARK: - API CALLS
extension ContactDetailsVC {
    func updateContact(contactID: String) {
        if let data = contactData {
            var postBody = data
            postBody.accountId = AppGlobalData.shared().accountData?.id
            postBody.id = nil
            postBody.createdAt = nil
            postBody.modifiedAt = nil
            postBody.status = nil
            postBody.intrabank = nil
            postBody.ach = nil
            postBody.wire = nil
            postBody.check = nil
            
            self.activityIndicatorBegin()
            ContactViewModel.shared.updateContact(contactId: contactID, contactData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil, userInfo: nil)
                        self.popVC()
                    }
                }
            }
        }
    }
    
    func createContact() {
        var postBody = contactData
        postBody?.accountId = AppGlobalData.shared().accountData?.id
        postBody?.name = contactData?.name
        self.activityIndicatorBegin()
        ContactViewModel.shared.createNewContact(contactData: postBody!) { (response, errorMessage) in
            self.activityIndicatorEnd()
            
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let _ = response {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil, userInfo: nil)
                    self.contactData = response
                    if self.checkStatusType == .checkDeposit {
                        self.navigateToRCD()
                    } else {
                        self.gotoSuccessScreen()
                    }
                }
            }
        }
    }
    
    func gotoSuccessScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
        if let successVC = storyboard.instantiateViewController(withIdentifier: "ContactCreationVC") as? SuccessContactCreationVC {
            successVC.contactData = self.contactData
            self.navigationController?.pushViewController(successVC, animated: true)
        }
    }
}
