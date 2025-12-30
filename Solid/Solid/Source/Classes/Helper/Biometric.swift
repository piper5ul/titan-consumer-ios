//
//  Biodmetric.swift
//  Solid
//
//  Created by Solid iOS Team on 29/07/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import LocalAuthentication

enum BiometricType {
    case none
    case touch
    case face
//    case locked
}

class Biometric {
    static func type() -> BiometricType {

        var error: NSError?
        let authContext = LAContext()
        if #available(iOS 11, *) {
            if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                switch authContext.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touch
                case .faceID:
                    return .face
                @unknown default:
                    debugPrint("Scope for any new case in future")
                    return .none
                }
            } else {
                /*
                if let err = error, err.code == -8
                {
                    return .locked
                }
 */
                return .none
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
    }
}
