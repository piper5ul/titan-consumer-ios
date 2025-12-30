//
//  SSNVC.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit

class SSNVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var txtSSNCode: BaseTextField!

    var code: String = ""
    var mobileNumber: String = ""

    var auth0RefreshToken: String = ""
    var auth0IdToken: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()
        self.setData()
        self.setupInitialUI()
        txtSSNCode.fieldType = .alphaNumeric
        txtSSNCode.delegate = self
		addProgressbar(percentage: 20)
        validate(text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = txtSSNCode.becomeFirstResponder()
        txtSSNCode.addDoneButtonOnKeyboard()
    }

    func setupInitialUI() {
        txtSSNCode.placeholderString = ""
        self.setFooterUI()
    }

    func setFooterUI() {
        self.shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(callRegisterUserAPI), for: .touchUpInside)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.secondaryColor
        lblDesc.textColor = UIColor.secondaryColor
    }
}

// MARK: - Navigationbar
extension SSNVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        self.title = Utility.localizedString(forKey: "ssn_NavTitle")

        addBackNavigationbarButton()
    }

    func setData() {
		
		let lblTitleFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
		let lblDescFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
		
        lblTitle.font = lblTitleFont
        lblTitle.textColor = UIColor.secondaryColor

        lblDesc.font = lblDescFont
        lblDesc.textColor = UIColor.secondaryColor

        lblTitle.text = Utility.localizedString(forKey: "ssn_Title")
        lblDesc.text = Utility.localizedString(forKey: "ssn_Desc")
    }
}

// MARK: - Textfield delegate method
extension SSNVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let theString = textField.text! as NSString
        let theNewString = theString.replacingCharacters(in: range, with: string).trim
         
        if theNewString.isAlphaNumeric {
          textField.text = theNewString.ssnLast4String()
          validate(text: textField.text ?? "")
        } else if theNewString.count == 0 {
          textField.text = ""
        }

        return false
    }

    func validate(text: String) {
        if text.count == Constants.ssnLast4Limit {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
}

//MARK:- API calls
extension SSNVC {
    @objc func callRegisterUserAPI() {
        self.view.endEditing(true)

        var postBody = RegisterPostBody()
        postBody.clientId = Client.clientId
        postBody.idNumberLast4 = txtSSNCode.text

        self.activityIndicatorBegin()
        
        AuthViewModel.shared.registerUser(userData: postBody) { (registerResponse, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                _ = self.txtSSNCode.becomeFirstResponder()
            } else {
                if let response = registerResponse {
                    //call Auth0 to refresh tokens...
                    if response.refreshRequired ?? false {
                        self.refreshAuth0Token(refreshToken: self.auth0RefreshToken)
                    } else {
                        //TO REMOVE TEMP FILE
                        FileManager.default.clearTmpDirectory()
                        
                        AppGlobalData.personPhone = self.mobileNumber
                       
                        //store new tokens..
                        AppData.updateSession(idToken: self.auth0IdToken as String, accessToken: response.accessToken ?? "" as String, refreshToken: self.auth0RefreshToken as String)
                        AppGlobalData.shared().storeSessionData()
                        
                        self.getPersonDetail(showAutoLockWithVC: self)
                    }
                }
            }
        }
    }
    
    func refreshAuth0Token(refreshToken: String) {
        self.activityIndicatorBegin()
        
        AuthViewModel.shared.refreshAuth0Tokens(refreshToken: refreshToken) { response, status, error in
            DispatchQueue.main.async {
                self.activityIndicatorEnd()

                if status == true {
                    AppGlobalData.shared().authAccessToken = response.accessToken ?? ""
                    self.auth0IdToken = response.idToken ?? ""
                    self.auth0RefreshToken = response.refreshToken ?? ""
                    self.callRegisterUserAPI()
                } else {
                    self.showAlertMessage(titleStr: "", messageStr: error?.localizedDescription ?? "")
                }
            }
        }
    }
}
