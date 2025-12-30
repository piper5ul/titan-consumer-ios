//
//  PinVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/23/21.
//

import Foundation
import LocalAuthentication
import UIKit

enum AutolockContext {
	case creatPin
	case confirmPin
	case lock
}

class PinVC: BaseVC {
	var context: AutolockContext?
	var registeredPin: String?
	var lockTimer: Timer?
	var fields = [AuthTextField]()
	var forceLogout:(() -> Void)?
	var onDismiss:(() -> Void)?
	var type: BiometricType = .none
	var onPinSuccess:(() -> Void)?

	var isFromSetting = false

    var shouldLogout: Bool? = true

	@IBOutlet weak var txtpin: BaseTextField!
	@IBOutlet weak var lblTitle: UILabel!
	@IBOutlet weak var lblSeconds: UILabel!

	@IBOutlet weak var blockView: UIView!
	@IBOutlet weak var blockTimerLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var overlayButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}

        _ = txtpin.becomeFirstResponder()

		// PASSCODE
		self.type = Biometric.type()
		switch context {
			case .creatPin:
				lblTitle.text = Utility.localizedString(forKey: "enter_passcode")
				self.title = Utility.localizedString(forKey: "passcode_title_create")
			case .confirmPin:
				lblTitle.text =  Utility.localizedString(forKey: "confirm_passcode")
                self.title = Utility.localizedString(forKey: "passcode_title_create")
            case .lock:
                lblTitle.text =  Utility.localizedString(forKey: "confirm_passcode")
                self.title = Utility.localizedString(forKey: "passcode_title_confirm")
			default:
				break
		}
		setNavigationBar()

}
	@objc func dismissAutoLock() {
		self.view.endEditing(true)
		self.dismiss(animated: true, completion: nil)
		self.onDismiss?()
	}
	func setNavigationBar() {

		infoLabel.font = UIFont.sfProDisplayRegular(fontSize: 13)
		lblSeconds.font = UIFont.sfProDisplayRegular(fontSize: 13)
		let lblTimerFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize17
		blockTimerLabel.font = lblTimerFont

		lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 13)
		lblTitle.textColor = UIColor.secondaryColorWithOpacity

		isNavigationBarHidden = false

        var righButtonTitle = ""

        switch context {
            case .creatPin:
                righButtonTitle = Utility.localizedString(forKey: "next")

            case .confirmPin, .lock:
                righButtonTitle = Utility.localizedString(forKey: "confirm")

            default:
                break
        }

        addNavigationbarButton(buttonTitle: Utility.localizedString(forKey: "cancel"), buttonTextColor: UIColor.secondaryColor, addSide: NavigationButton.leftButton)
		addNavigationbarButton(buttonTitle: righButtonTitle, buttonTextColor: UIColor.primaryColor, addSide: NavigationButton.rightButton)
	}

	override func rightButtonAction() {
		self.processPin()
	}

	override func leftButtonAction() {

        if self.shouldLogout ?? true {
            logoutUser(showAlert: false)
        } else {
            self.dismissController()
        }
	}

    func logoutUser(showAlert: Bool) {

        if showAlert {
            self.showAlertMessage(titleStr: "Error", messageStr: Utility.localizedString(forKey: "logout_on_invalid") )
        }

        self.logoutUser()
    }
}

extension PinVC: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let theString = textField.text! as NSString
		let theNewString = theString.replacingCharacters(in: range, with: string)
		textField.text = theNewString.mfaString().trim
		validate(text: textField.text ?? "")
		return false
	}

	func validate(text: String) {
        self.enableRightBarButton(shouldEnable: false)
		let strText = text.numberString
        let rules: [ValidationRule] = [ NoConsecutiveDigitsRule(), NonRepeatRule()]
		if strText.count == Constants.mfaCodeLimit {
            if !(strText.isValid(rules: rules)) {
                self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "pincombination_error"))
                txtpin.text = ""
            } else {
                self.enableRightBarButton(shouldEnable: true)
            }
		}
	}

	func pinString() -> String {
		let otp = txtpin.text
		return otp!
	}

	func processPin() {
		let pin = pinString()
		switch context! {
			case .creatPin:
                self.context = .confirmPin
                self.registeredPin = pin
                self.txtpin.text = ""
                lblTitle.text =  Utility.localizedString(forKey: "confirm_passcode")
                self.title = Utility.localizedString(forKey: "passcode_title_create")
                addNavigationbarButton(buttonTitle: Utility.localizedString(forKey: "confirm"), buttonTextColor: UIColor.primaryColor, addSide: NavigationButton.rightButton)

			case .confirmPin:
				if pin != registeredPin {
					self.showAlertMessage(titleStr: "Error", messageStr: Utility.localizedString(forKey: "invalid_ConfirmPin") )
					self.enableRightBarButton(shouldEnable: false)
				} else {
					Security.storePin(pin: pin)
					AppGlobalData.isPinEnabled = true
					self.handlePinSuccess()
					self.dismiss(animated: true, completion: nil)

				}
			case .lock:
				let storedPin = Security.fetchPin()
				if pin == storedPin {
					Security.updateChecksum(reset: true)
					self.handlePinSuccess()
				} else {
					Security.updateChecksum(reset: false)
					checkForLimitExceed()
				}
		}
	}

	func checkForLimitExceed() {
		let cs = Security.getChecksum()
		let timeinterval = (cs.0?.timeIntervalSinceNow) ?? 0

		if timeinterval > 0 {
            self.logoutUser(showAlert: true)
		} else {
            self.showAlertMessage(titleStr: "Error", messageStr: Utility.localizedString(forKey: "invalid_pin") )
        }
	}

	func showBlockScreen(show: Bool) {
		if show {
			blockView.isHidden = false
			self.enableRightBarButton(shouldEnable: true)

			txtpin.isUserInteractionEnabled = false
			txtpin.text = ""

			self.updateBlockTimer()
			if lockTimer == nil {
				if #available(iOS 10.0, *) {
					lockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
						self.updateBlockTimer()
					})
				} else {
					blockView.isHidden = true
					txtpin.isUserInteractionEnabled = true
					// Fallback on earlier versions
				}
			}
		} else {
			blockView.isHidden = true
			txtpin.isUserInteractionEnabled = true
		}
	}

	func updateBlockTimer() {
		let cs = Security.getChecksum()
		let timeinterval = (cs.0?.timeIntervalSinceNow)!
		blockTimerLabel.text = "\(Int(timeinterval))"
		if timeinterval <= 0 {
			lockTimer?.invalidate()
			lockTimer = nil
			self.showBlockScreen(show: false)
		}
	}

	func handlePinSuccess() {
		self.onPinSuccess?()
	}
}
