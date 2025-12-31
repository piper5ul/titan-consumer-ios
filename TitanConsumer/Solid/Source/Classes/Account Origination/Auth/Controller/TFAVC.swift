//
//  TFAVC.swift
//  Solid
//
//  Created by Solid iOS Team on 05/02/21.
//

import UIKit

class TFAVC: BaseVC {
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblDesc: UILabel!
	@IBOutlet weak var txtTFACode: BaseTextField!

	var codeResentRecently = false
	var mobileNumber: String?

    var auth0RefreshToken: String?
    var auth0IdToken: String?
    
	override func viewDidLoad() {
		super.viewDidLoad()

		self.setNavigationBar()
		self.setData()
		self.setupInitialUI()
		addProgressbar(percentage: 15)

		txtTFACode.fieldType = .mfa
		txtTFACode.delegate = self

        validate(text: "")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

        _ = txtTFACode.becomeFirstResponder()
        txtTFACode.addDoneButtonOnKeyboard()
    }

	func setupInitialUI() {
        self.setFooterUI()
	}

    func setFooterUI() {
        self.shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(startVerifyingCode), for: .touchUpInside)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setData()
    }
    
    @objc func startVerifyingCode() {
        self.view.endEditing(true)
        callVerifyOTPAPI()
    }

    func resendCode() {
        if codeResentRecently {
            self.alert(src: self, "forgot_pass.reset.resendAlertTitle_v2", "forgot_pass.reset.resendAlertMessage_v2")
        } else {
            self.callResendCodeAPI()
        }
    }
}

// MARK: - Navigationbar
extension TFAVC {
	func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

		self.title = Utility.localizedString(forKey: "tfa_NavTitle")

        addBackNavigationbarButton()
	}

	func setData() {
		let lblDescFont = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize12
		
		lblTitle.font = lblDescFont
		lblTitle.textColor = UIColor.secondaryColor

		lblDesc.font = lblDescFont
		lblDesc.textColor = UIColor.secondaryColor

		lblTitle.text = Utility.localizedString(forKey: "tfa_Title")
        let description = Utility.localizedString(forKey: "tfa_Desc") + " " + Utility.localizedString(forKey: "tfa_Resend")
		lblDesc.text = description
		
		let colorText = Utility.localizedString(forKey: "tfa_Resend")
		let colorAttriString = description.getThemeColorText(themeColorText: colorText)

		lblDesc.attributedText = colorAttriString
		lblDesc.isUserInteractionEnabled = true
		lblDesc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendCode(gesture:))))
	}

	@objc func resendCode(gesture: UITapGestureRecognizer) {
		guard let textT = self.lblDesc.text else { return }

		let resendText = Utility.localizedString(forKey: "tfa_Resend")
		let resendTxtRange = (textT as NSString).range(of: resendText)
		
        let resendRange = Utility.isDeviceIpad() ? NSRange.init(location: resendTxtRange.location - 25, length: resendTxtRange.length + 7) :  NSRange.init(location: resendTxtRange.location - 16, length: resendTxtRange.length + 3)

		if gesture.didTapAttributedTextInLabel(label: self.lblDesc, inRange: resendRange) {
			print("Tapped resend")
			resendCode()
		} else {
			print("Tapped none")
		}
	}
}

// MARK: Navigation
extension TFAVC {
    func navigateToSSN() {
        self.performSegue(withIdentifier: "GoToSSN", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ssnDestinationVC = segue.destination as? SSNVC {
            ssnDestinationVC.mobileNumber = self.mobileNumber ?? ""
            ssnDestinationVC.auth0IdToken = self.auth0IdToken ?? ""
            ssnDestinationVC.auth0RefreshToken = self.auth0RefreshToken ?? ""
        } else if let logindestinationVC = segue.destination as? LoginCreatedVC {
            logindestinationVC.mobileNumber = self.mobileNumber
        }
    }
}

// MARK: - Textfield delegate method
extension TFAVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let theString = textField.text! as NSString
        let theNewString = theString.replacingCharacters(in: range, with: string).trim

        if let pasteString = UIPasteboard.general.string, string == pasteString {
            if pasteString.count >= 6 {
                if !pasteString.isNumber() {
                    return false
                }
                textField.text = pasteString
                validate(text: textField.text ?? "")

                return false
            } else {
                return false
            }
        } else {
            textField.text = theNewString.mfaString()
            validate(text: textField.text ?? "")
        }

        return false
    }

	func validate(text: String) {
		if text.count == Constants.mfaCodeLimit {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.footerView.btnApply.isEnabled = true
			}
		} else {
            self.footerView.btnApply.isEnabled = false
        }
	}
}

// MARK: - API calls
extension TFAVC {
    func callVerifyOTPAPI() {
        let phoneNo = mobileNumber ?? ""
        let verificationCode = self.txtTFACode.text ?? ""

        self.activityIndicatorBegin()

        AuthViewModel.shared.verifyOTP(mobileNo: phoneNo, otp: verificationCode) { response, status, error in
            DispatchQueue.main.async {
                self.activityIndicatorEnd()

                if status == true {
                    AppGlobalData.shared().authAccessToken = response.accessToken ?? ""
                    self.callRegisterUserAPI(idToken: response.idToken ?? "", refreshToken: response.refreshToken ?? "")
                } else {
                    self.showAlertMessage(titleStr: "", messageStr: error?.localizedDescription ?? "")
                    _ = self.txtTFACode.becomeFirstResponder()
                }
            }
        }
    }
    
    func callResendCodeAPI() {
        self.activityIndicatorBegin()
   
        AuthViewModel.shared.sendOTP(mobileNo: self.mobileNumber ?? "") { message, status in
            DispatchQueue.main.async {
                self.activityIndicatorEnd()
                
                if status == true {
                    self.txtTFACode.text = ""
                    
                    let formatedNumber = Utility.getFormattedPhoneNumber(forCountryCode: AppGlobalData.shared().selectedCountryCode, phoneNumber: self.mobileNumber ?? "", withMaxLimit: AppGlobalData.shared().maxPhoneNumberLength)
                    let mobNumber = AppGlobalData.shared().selectedCountryCode + " "  + formatedNumber
                    let msg = "\(Utility.localizedString(forKey: "tfa_ResentTo")) \(mobNumber)"
                    self.showAlertMessage(titleStr: "", messageStr: msg)
                } else {
                    self.showAlertMessage(titleStr: "", messageStr: message)
                }
            }
        }
    }
    
    func callRegisterUserAPI(idToken: String, refreshToken: String) {
        var postBody = RegisterPostBody()
        postBody.clientId = Client.clientId

        self.activityIndicatorBegin()
        
        AuthViewModel.shared.registerUser(userData: postBody) { (registerResponse, errorMessage) in
            self.activityIndicatorEnd()
            
            if let error = errorMessage {
                if error.errorCode == "EC_NEW_DEVICE_LOGIN" {//open SSN screen...
                    self.auth0IdToken = idToken
                    self.auth0RefreshToken = refreshToken
                    self.navigateToSSN()
                } else {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                }
            } else {
                if let response = registerResponse {
                    //call Auth0 to refresh tokens...
                    if response.refreshRequired ?? false {
                        self.refreshAuth0Token(refreshToken: refreshToken)
                    } else {
                        //TO REMOVE TEMP FILE
                        FileManager.default.clearTmpDirectory()
                        
                        AppGlobalData.personPhone = self.mobileNumber ?? ""

                        //store new tokens..
                        AppData.updateSession(idToken: idToken as String, accessToken: response.accessToken ?? "" as String, refreshToken: refreshToken as String)

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
                    self.callRegisterUserAPI(idToken: response.idToken ?? "", refreshToken: response.refreshToken ?? "")
                } else {
                    self.showAlertMessage(titleStr: "", messageStr: error?.localizedDescription ?? "")
                    _ = self.txtTFACode.becomeFirstResponder()
                }
            }
        }
    }
}
