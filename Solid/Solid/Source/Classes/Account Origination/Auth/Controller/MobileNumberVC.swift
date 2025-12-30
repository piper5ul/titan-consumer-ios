//
//  MobileNumberVC.swift
//  Solid
//
//  Created by Solid iOS Team on 05/02/21.
//

import UIKit

class MobileNumberVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var countryCodeWidthConst: NSLayoutConstraint!
    @IBOutlet weak var otpConsentViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var otpConsentViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var lblOTPConsent: UILabel!
    @IBOutlet weak var lblOTPTerms: UILabel!
    @IBOutlet weak var checkboxTerms: UIButton!
    @IBOutlet weak var txtMobileNumber: BaseTextField!
        
    var initialViewModal = InitialViewModal()
    
    var selectedCountryCode: String = Constants.countryCodeUS
    var maxPhoneNumberLength: Int = Constants.phoneNumberLimit
    
    var countyCodeTextField: UITextField?
    let countyCodePickerView = UIPickerView()
    
    var isTermsAgreed: Bool = false
    
    var mobileNumber: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setNavigationBar()
        self.setData()
        self.setFooterUI()
        
        AppGlobalData.shared().selectedCountryCode = Constants.countryCodeUS
        
        countryCodeWidthConst.constant = CGFloat(Constants.countryCodeLableWidthConst)
        lblCountryCode.layer.cornerRadius = Constants.cornerRadiusThroughApp
        lblCountryCode.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
        
        let strCountryCode = selectedCountryCode + " "
        lblCountryCode.attributedText = strCountryCode.getAttributedStringWithImage(withImage: "down", withImageSize: CGRect(x: 0, y: -3, width: 15, height: 15))
        lblCountryCode.textAlignment = .center
        self.addTapGestureToCountyLabel()
        
        txtMobileNumber.fieldType = .phone
        txtMobileNumber.delegate = self
        
        validate(text: "")
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            otpConsentViewBottomConst.constant = bottomPadding == 0 ? 110 : 75
            otpConsentViewHeightConst.constant = bottomPadding == 0 ? 100.0 : 95.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //_ = txtMobileNumber.becomeFirstResponder()
        
        isNavigationBarHidden = false
        txtMobileNumber.addDoneButtonOnKeyboard()
    }
    
    func setFooterUI() {
        self.shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(sendOTP), for: .touchUpInside)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.secondaryColor
        lblCountryCode.textColor = UIColor.primaryColor
    }
}

// MARK: - Navigationbar
extension MobileNumberVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        
        self.title = Utility.localizedString(forKey: "mobileNo_NavTitle")
        
        addBackNavigationbarButton()
    }
    
    func setData() {
        let lblTitleFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        lblTitle.font = lblTitleFont
        lblCountryCode.font = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        lblTitle.textColor = UIColor.secondaryColor
        lblCountryCode.textColor = UIColor.primaryColor
        lblCountryCode.backgroundColor = UIColor.grayBackgroundColor
        lblTitle.text = Utility.localizedString(forKey: "mobileNo_Title")
        
        let otpMessageFont = Utility.isDeviceIpad() ? Constants.regularFontSize17 : Constants.regularFontSize14
        self.lblOTPConsent.font = otpMessageFont
        self.lblOTPConsent.textColor = .secondaryColor
        
        self.lblOTPTerms.font = otpMessageFont
        self.lblOTPTerms.textColor = .secondaryColor
        
        checkboxTerms.setBackgroundImage(UIImage(named: "checkbox_unSelected")?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkboxTerms.tintColor = .primaryColor
        
        let strOtpConsentMessage = Utility.localizedString(forKey: "otpConsent_message")
        lblOTPConsent.text = strOtpConsentMessage
        
        let strOTPTermsMessage = Utility.localizedString(forKey: "otpTerms_Privacy")
        let strOTPTerms = Utility.localizedString(forKey: "terms_service")
        let strOTPPrivacy = Utility.localizedString(forKey: "privacy_policy").lowercased()
        let strOTPAttributedTerms = strOTPTermsMessage.getUnderlinedBoldString(underLineText1: strOTPTerms, underLineText2: strOTPPrivacy)
        lblOTPTerms.attributedText = strOTPAttributedTerms
        lblOTPTerms.isUserInteractionEnabled = true
        lblOTPTerms.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(otpTermAndPrivacyClicked(gesture:))))
    }
    
    @objc func otpTermAndPrivacyClicked(gesture: UITapGestureRecognizer) {
        guard let textT = self.lblOTPTerms.text else { return }
        
        let strOTPTerms = Utility.localizedString(forKey: "terms_service")
        let termsTxtRange = (textT as NSString).range(of: strOTPTerms)
        
        let strOTPPrivacy = Utility.localizedString(forKey: "privacy_policy").lowercased()
        let privacyTxtRange = (textT as NSString).range(of: strOTPPrivacy)
        
        let termsRange = Utility.isDeviceIpad() ? NSRange.init(location: termsTxtRange.location - 25, length: termsTxtRange.length + 7) :  NSRange.init(location: termsTxtRange.location, length: termsTxtRange.length)
        
        let privacyRange = Utility.isDeviceIpad() ? NSRange.init(location: privacyTxtRange.location - 25, length: privacyTxtRange.length + 7) :  NSRange.init(location: privacyTxtRange.location, length: privacyTxtRange.length)
        
        if gesture.didTapAttributedTextInLabel(label: self.lblOTPTerms, inRange: termsRange) {
            self.showOTPTerms()
            
        } else if gesture.didTapAttributedTextInLabel(label: self.lblOTPTerms, inRange: privacyRange) {
            self.showOTPPrivacyPolicy()
        }
    }
    
    @IBAction func otpConsentTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setBackgroundImage(UIImage(named: "checkbox_selected")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "checkbox_unSelected")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        sender.tintColor = .primaryColor
        
        isTermsAgreed = sender.isSelected
        
        validate(text: txtMobileNumber.text ?? "")
    }
}

// MARK: - Textfield delegate method
extension MobileNumberVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let theString = textField.text! as NSString
        let theNewString = theString.replacingCharacters(in: range, with: string)
        
        textField.text = Utility.getFormattedPhoneNumber(forCountryCode: self.selectedCountryCode, phoneNumber: theNewString, withMaxLimit: self.maxPhoneNumberLength)
        
        validate(text: textField.text ?? "")
        
        return false
    }
    
    func validate(text: String) {
        let phoneNumber = text.plainNumberString
        if phoneNumber.count == maxPhoneNumberLength && isTermsAgreed {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
    
    func gotoOTPScreen() {
        self.performSegue(withIdentifier: "GoToTFA", sender: self)
    }
}

// MARK: - API call and Navigation
extension MobileNumberVC {
    @objc func sendOTP() {
        let mobileNumber = selectedCountryCode + txtMobileNumber.text!.plainNumberString
        
        self.activityIndicatorBegin()
        
        AuthViewModel.shared.sendOTP(mobileNo: mobileNumber) { message, status in
            DispatchQueue.main.async {
                self.activityIndicatorEnd()
                
                if status == true {
                    self.mobileNumber = mobileNumber
                    self.gotoOTPScreen()
                } else {
                    self.showAlertMessage(titleStr: "", messageStr: message )
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TFAVC {
            destinationVC.mobileNumber = self.mobileNumber
        }
    }
}

// MARK: - country code
extension MobileNumberVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func addTapGestureToCountyLabel() {
        lblCountryCode.isUserInteractionEnabled = true
        let gestureReco = UITapGestureRecognizer(target: self, action: #selector(showCountryCodePicker))
        gestureReco.numberOfTapsRequired = 1
        lblCountryCode.addGestureRecognizer(gestureReco)
    }
    
    @objc func showCountryCodePicker() {
        let navBarHeight = self.getNavigationbarHeight()
        countyCodePickerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 150 - navBarHeight, width: view.frame.size.width, height: 150)
        countyCodePickerView.backgroundColor = .background
        countyCodePickerView.setValue(UIColor.primaryColor, forKey: "textColor")
        countyCodePickerView.delegate = self
        countyCodePickerView.dataSource = self
        
        if #available(iOS 13.4, *), countyCodePickerView.subviews.count > 0 {
            countyCodePickerView.subviews[0].subviews[0].backgroundColor = .background
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Utility.localizedString(forKey: "cancel"), style: .plain, target: self, action: #selector(cancelPicker))
        cancelButton.tintColor = .primaryColor
        
        let doneButton = UIBarButtonItem(title: Utility.localizedString(forKey: "done"), style: .plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = .primaryColor
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        countyCodeTextField?.removeFromSuperview()
        countyCodeTextField = UITextField(frame: .zero)
        countyCodeTextField?.text = selectedCountryCode
        view.addSubview(countyCodeTextField!)
        
        countyCodeTextField!.inputView = countyCodePickerView
        countyCodeTextField!.inputAccessoryView = toolbar
        countyCodeTextField!.becomeFirstResponder()
    }
    
    @objc func cancelPicker() {
        countyCodeTextField?.resignFirstResponder()
    }
    
    @objc func donePicker() {
        countyCodeTextField?.resignFirstResponder()
        selectedCountryCode =  AppMetaDataHelper.shared.config?.supportedCountries?[countyCodePickerView.selectedRow(inComponent: 0)].dialCode ?? "+1"
        if let allowedLength = AppMetaDataHelper.shared.config?.supportedCountries?[countyCodePickerView.selectedRow(inComponent: 0)].maxLength {
            maxPhoneNumberLength = allowedLength
        }
        
        let strCountryCode = selectedCountryCode + " "
        lblCountryCode.attributedText = strCountryCode.getAttributedStringWithImage(withImage: "down", withImageSize: CGRect(x: 0, y: -3, width: 15, height: 15))
        AppGlobalData.shared().selectedCountryCode = selectedCountryCode
        AppGlobalData.shared().maxPhoneNumberLength = maxPhoneNumberLength
        
        txtMobileNumber.text = ""
        validate(text: "")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppMetaDataHelper.shared.config?.supportedCountries?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let codeV = AppMetaDataHelper.shared.config?.supportedCountries?[row].dialCode ?? "+1"
        let flagV = AppMetaDataHelper.shared.config?.supportedCountries?[row].code ?? "US"
        let selectedValue = self.countryFlag(countryCode: flagV) + " " + codeV
        return NSAttributedString(string: selectedValue, attributes: nil)
    }
    
    func countryFlag(countryCode: String) -> String {
        return String(String.UnicodeScalarView(countryCode.unicodeScalars.compactMap({UnicodeScalar(127397 + $0.value)})))
    }
}
