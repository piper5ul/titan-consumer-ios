//
//  Security.swift
//  Solid
//
//  Created by Solid iOS Team on 11/03/21.
//

import Foundation
import LocalAuthentication
import SwiftKeychainWrapper
import UIKit
import Alamofire

class Security {
	//    Keychain
	static let pinKey           = "autolock_pin"
	static let checksumKey      = "checksum"
	static let domainStateKey   = "domain_state"
    static let personphone =
    "person_phone"
    static let sessiondata = "session_data"
    
    static func storeSession(userSession: SessionData) {
        KeychainWrapper.standard.set(try! PropertyListEncoder().encode(userSession), forKey: sessiondata)
        updateChecksum(reset: true)
    }
    
    static func getSessionData() -> SessionData! {
        var userData: SessionData!
        if let data = UserDefaults.standard.value(forKey: sessiondata) as? Data {
            userData = try? PropertyListDecoder().decode(SessionData.self, from: data)
            return userData!
        } else {
            return userData
        }
    }

    static func fetchSession() -> SessionData? {
        var userData: SessionData!
        if let keychainSession = KeychainWrapper.standard.data(forKey: sessiondata) {
            userData = try? PropertyListDecoder().decode(SessionData.self, from: keychainSession)
            return userData
        }
       return userData
    }
  
    //STORE AND FetCh pHONe NUMBER
    static func storePhone(phone: String) {
        let encryptedPhonenumber = phone.encrypt()
        _ = KeychainWrapper.standard.set(encryptedPhonenumber, forKey: personphone)
        updateChecksum(reset: true)
    }
    
    static func fetchPhone() -> String? {
        guard let keychainPhoneString = KeychainWrapper.standard.string(forKey: personphone) else {
            return nil
        }
        let decryptedPhoneString = keychainPhoneString.decrypt()
        return decryptedPhoneString
    }
    
	//    STORE AND FETCH PIN
	static func storePin(pin: String) {
		let encryptedPin = pin.encrypt()
		// Save to keychain
		_ = KeychainWrapper.standard.set(encryptedPin, forKey: pinKey)

		updateChecksum(reset: true)
	}

	static func fetchPin() -> String? {
		guard let keychainString = KeychainWrapper.standard.string(forKey: pinKey) else {
			return nil
		}
		let decryptedString = keychainString.decrypt()
		return decryptedString
	}

	static func hasPin() -> Bool {
		return KeychainWrapper.standard.string(forKey: pinKey) != nil
	}

	//    STORE AND FETCH CHECKSUM
	static func updateChecksum(reset: Bool) {
		var dateStr = ""
		var countrStr = ""

		if reset {
			dateStr = "\(Date().timeIntervalSince1970)"
			countrStr = "0"
		} else {
			let cs = getChecksum()
			let countr = (cs.1) ?? 0
			if countr >= 2 {
				let newDate = Date().addingTimeInterval(60)
				dateStr = "\(newDate.timeIntervalSince1970)"
				countrStr = "0"
			} else {
				dateStr = "\(Date().timeIntervalSince1970)"
				countrStr = "\(countr + 1)"
			}
		}

		let newString = "\(dateStr),\(countrStr)"
		let encryptedString = newString.encrypt()
		_ = KeychainWrapper.standard.set(encryptedString, forKey: checksumKey)

	}

	//    RETURNS waitTillDate, Error Count
	static func getChecksum() -> (Date?, Int?) {
		guard let checksumString = KeychainWrapper.standard.string(forKey: checksumKey) else {
			return (nil, nil)
		}
		let decrypted = checksumString.decrypt()
		let array = decrypted?.components(separatedBy: ",")

		let timeInterval = Double(array![0])!
		let counter = Int(array![1])

		let date = Date(timeIntervalSince1970: timeInterval)
		return (date, counter)
	}
    
	static func clearKeychain() {
		KeychainWrapper.standard.removeObject(forKey: pinKey)
		KeychainWrapper.standard.removeObject(forKey: checksumKey)
        KeychainWrapper.standard.removeObject(forKey: personphone)
        KeychainWrapper.standard.removeObject(forKey: sessiondata)
	}

	static func handleAppOnFirstInstall() {
		let defaults = UserDefaults.standard
		let key = "hasRunBefore"
		if !defaults.bool(forKey: key) {
			clearKeychain()
			// AppData.logout()
		}
		defaults.set(true, forKey: key)
	}

	enum BiometricStatus {
		case success
		case failure
		case notAvailable
		case lockedOut
		case cancel
        case UIcancelBySystem
	}

    static func biometricAunthenticate(reasonString: String, completion:@escaping ((BiometricStatus, String, Int) -> Void)) {

        var authError: NSError?
        let myContext = LAContext()
        myContext.localizedFallbackTitle = ""

        let myLocalizedReasonString = reasonString
        if myContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {

            myContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { (success, evaluateError) in

                if success {
                    DispatchQueue.main.async { completion(.success, "", 0) }

                } else {

                    guard let error = evaluateError else {
                        return
                    }
                    let errorcode = error._code

                    let errorMessage = showBiometricFailure(errorCode: error._code)
                    let status: BiometricStatus = getBiometricStatus(errorCode: errorcode)
                    DispatchQueue.main.async { completion(status, errorMessage, errorcode ) }
                }
            }
        } else {
            completion(.notAvailable, "", 0)
        }
    }

    static func getBiometricStatus(errorCode: Int) -> BiometricStatus {

        if(errorCode == -8) // Locked out
        {
            return BiometricStatus.lockedOut
        } else if errorCode == -6 { // User denied access
            return BiometricStatus.notAvailable
        } else if errorCode == -2 { // User pressed Cancel
            return BiometricStatus.cancel
        } else if errorCode == -1 { // 3 wrong tries
            return BiometricStatus.failure
        } else if errorCode == -4 { // UI canceled by system / Authentication was canceled by the system (i.e screen locked/put app in background)
            return BiometricStatus.UIcancelBySystem
        }
        return BiometricStatus.failure
    }

    static func showBiometricFailure(errorCode: Int) -> String {

            if(errorCode == -8) // Locked out
            {
               return "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
            } else if errorCode == -6 { // User denied access
                return "Authentication could not start because the user has not enrolled in biometric authentication. Please go to settings and allow access."
            } else if errorCode == -2 { // User pressed Cancel
				return "Authentication could not continue because the user pressed cancel."
			} else if errorCode == -1 { // 3 wrong tries
                return "Application retry limit exceeded."
            }
            return ""
    }

    static func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
                case LAError.biometryNotAvailable.rawValue:
                    message = "Authentication could not start because the device does not support biometric authentication."

                case LAError.biometryLockout.rawValue:
                    message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."

                case LAError.biometryNotEnrolled.rawValue:
                    message = "Authentication could not start because the user has not enrolled in biometric authentication."

                default:
                    message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
                case LAError.touchIDLockout.rawValue:
                    message = "Too many failed attempts."

                case LAError.touchIDNotAvailable.rawValue:
                    message = "TouchID is not available on the device"

                case LAError.touchIDNotEnrolled.rawValue:
                    message = "TouchID is not enrolled on the device"

                default:
                    message = "Did not find error code on LAError object"
            }
        }

        return message
    }

    static func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {

        var message = ""

        switch errorCode {

            case LAError.authenticationFailed.rawValue:
                message = "The user failed to provide valid credentials"

            case LAError.appCancel.rawValue:
                message = "Authentication was canceled by application"

            case LAError.invalidContext.rawValue:
                message = "The context is invalid"

            case LAError.notInteractive.rawValue:
                message = "Not interactive"

            case LAError.passcodeNotSet.rawValue:
                message = "Passcode is not set on the device"

            case LAError.systemCancel.rawValue:
                message = "Authentication was canceled by the system"

            case LAError.userCancel.rawValue:
                message = "The user did cancel"

            case LAError.userFallback.rawValue:
                message = "The user chose to use the fallback"

            default:
                message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }

        return message
    }

}
