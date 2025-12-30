//
//  BiometricHelper.swift
//  Solid
//
//  Created by Solid iOS Team on 11/03/21.
//

import Foundation
import UIKit
import LocalAuthentication

class BiometricHelper {

    static let shared = BiometricHelper()
    var sourceViewcontroller: UIViewController?
	var type: BiometricType = .none

	var withScreen = false
	var sourceController: UIViewController?
	var completion: (Bool) -> Void = { (_) in }
	var autolockVC: PinVC?
    var shouldLogout: Bool? = true

	static func showAuth(sourceController: UIViewController, withScreen: Bool, shouldLogout: Bool = true, _ completion:@escaping (Bool) -> Void) {
		self.shared.sourceController    = sourceController
		self.shared.withScreen          = withScreen
		self.shared.completion          = completion
        self.shared.shouldLogout         = shouldLogout
		self.shared.showAuth()
	}

    func showAuth() {
        showBiometric { shouldMoveAhead in
            self.completion(shouldMoveAhead)
        }
    }

	func handleAuthSuccess() {
		self.autolockVC?.dismiss(animated: true, completion: nil)
		// self.completion(true)
	}

	func showPIN(from sourceVC: UIViewController, shouldLogout: Bool = true, _ completion:@escaping ((Bool) -> Void)) {
		self.sourceViewcontroller = sourceVC
		let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
		autolockVC = storyboard.instantiateViewController(withIdentifier: "PinVC") as? PinVC
		let navController = UINavigationController(rootViewController: autolockVC!)
        autolockVC?.shouldLogout = shouldLogout

		if (Biometric.type() == .none || AppGlobalData.isPinEnabled) && !Security.hasPin() {
			autolockVC?.context = .creatPin

            self.sourceViewcontroller?.present(navController, animated: true, completion: nil)
			autolockVC?.onPinSuccess = {
				self.handleAuthSuccess()
				completion(true)
            }
        } else {
            autolockVC?.context  = .lock
            autolockVC?.modalTransitionStyle = .crossDissolve
            self.sourceViewcontroller?.present(navController, animated: true, completion: nil)

            autolockVC?.onPinSuccess = {
                self.handleAuthSuccess()
                completion(true)
            }
        }

		autolockVC?.onDismiss = {
			debugPrint("autolock dismiss")
			completion(true)
		}
	}

    static func devicePasscodeEnabled() -> Bool {

        if #available(iOS 9.0, *) {
            let context = LAContext()
            return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        }

        return false
     }

    func showBiometric(_ completion:@escaping ((Bool) -> Void)) {

        if BiometricHelper.devicePasscodeEnabled() {
            // var maskedPhone = "Business Account"
            var maskedPhone  = Utility.localizedString(forKey: "masked_phone")

            if let currentPhone = AppGlobalData.shared().personData.phone {
                let phoneNumber = (currentPhone.substring(from: 2))
                let count       = phoneNumber.count
                if count > 6 {
                    let s3 = phoneNumber.substring(start: 6, end: count)
                    maskedPhone = "(•••) •••-\(s3)"
                }
            }

            Security.biometricAunthenticate(reasonString: maskedPhone) { (biometricStatus, _, _) in

                var shouldAllowMoveAhead: Bool = false

                if biometricStatus == .failure || biometricStatus == .cancel { // 3 wrong tries & //biometric cancel
                    shouldAllowMoveAhead = false
                    completion(shouldAllowMoveAhead)
                    self.logoutUser()
                } else if biometricStatus == .notAvailable || biometricStatus == .lockedOut || biometricStatus == .UIcancelBySystem {
                    // biometric locked due to too many wrong attempts
                    // UI canceled by system / Authentication was canceled by the system (i.e screen locked/put app in background)
                    shouldAllowMoveAhead = false
                } else if biometricStatus == .success { // biometric locked due to too many wrong attempts
                    shouldAllowMoveAhead = true
                }

                completion(shouldAllowMoveAhead)
            }
        } else { // SYSTEM PASSCODE IS NOT SUPPORTED OR NOT DISABLED...CREATE CUSTOM PASSCODE..
            self.showPIN(from: BiometricHelper.shared.sourceController!, shouldLogout: self.shouldLogout ?? true) { (shouldMoveAhead) in
                self.completion(shouldMoveAhead)
            }
        }
    }

    func logoutUser() {
        if self.shouldLogout ?? true {
            let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
            self.autolockVC = storyboard.instantiateViewController(withIdentifier: "PinVC") as? PinVC
            self.autolockVC?.logoutUser(showAlert: true)
        }
    }
}
