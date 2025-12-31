//
//  AuthLoginViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/8/21.
//

import Foundation
import Auth0

class AuthViewModel: BaseViewModel {
	static let shared = AuthViewModel()
    static var  response = AuthTokenModel()

	let apiManager = APIManager.shared()
    
    func registerUser(userData: RegisterPostBody, _ completion: @escaping(_ reigsterUserResponse: AuthTokenModel?, _ errorMessage: AlertMessage?) -> Void) {
        self.decode(modelType: userData)
        self.apiManager.call(type: EndpointItem.registerUser, params: postParams) { (registerResponse, errorMessage) in
            completion(registerResponse, errorMessage)
        }
    }
    
    func logout(tokenData: LogoutPostBody, _ completion: @escaping(_ response: AuthTokenModel?, _ errorMessage: AlertMessage?) -> Void) {
        self.decode(modelType: tokenData)
        self.apiManager.call(type: EndpointItem.logout, params: postParams) { (otpResponse, errorMessage) in
            completion(otpResponse, errorMessage)
        }
    }
}

//MARK:- Auth0 calls..
extension AuthViewModel {
    func sendOTP(mobileNo: String, completion: @escaping(String, Bool) -> Void) {
        Auth0
            .authentication(clientId: Client.clientId, domain: AppMetaDataHelper.shared.currentEnvKeys.auth0Domain ?? "")
            .startPasswordless(phoneNumber: mobileNo)
            .start { result in
                switch result {
                case .success(_):
                    completion("OTP Sent!", true)
                case .failure(let error):
                    completion(error.localizedDescription, false)
                }
            }
    }
    
    func verifyOTP(mobileNo: String, otp: String, completion: @escaping(Auth0TokenModel, Bool, Error?) -> Void) {
        Auth0
            .authentication(clientId: Client.clientId, domain: AppMetaDataHelper.shared.currentEnvKeys.auth0Domain ?? "")
            .login(
                phoneNumber: mobileNo,
                code: otp,
                audience: AppMetaDataHelper.shared.currentEnvKeys.auth0Audience,
                scope: "openid profile email offline_access")
            .start { result in
                switch result {
                case .success(let response):
                    var authData = Auth0TokenModel()
                    authData.accessToken = response.accessToken
                    authData.idToken = response.idToken
                    authData.refreshToken = response.refreshToken ?? ""
                    completion(authData, true, nil)
                case .failure(let error):
                    completion(Auth0TokenModel(), false, error)
                }
            }
    }
    
    func refreshAuth0Tokens(refreshToken: String, completion: @escaping(Auth0TokenModel, Bool, Error?) -> Void) {
        Auth0
            .authentication(clientId: Client.clientId, domain: AppMetaDataHelper.shared.currentEnvKeys.auth0Domain ?? "")
            .renew(withRefreshToken: refreshToken, scope: "openid profile email offline_access")
            .start { result in
                switch result {
                case .success(let response):
                    var authData = Auth0TokenModel()
                    authData.accessToken = response.accessToken
                    authData.idToken = response.idToken
                    authData.refreshToken = response.refreshToken ?? ""
                    completion(authData, true, nil)
                case .failure(let error):
                    completion(Auth0TokenModel(), false, error)
                }
            }
    }
}
