//
//  KYCViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 10/02/21.
//

import Foundation

class KYCViewModel: BaseViewModel {
    static let shared = KYCViewModel()
    let apiManager = APIManager.shared()
}

extension KYCViewModel {
    func getPersonaHostedURL(_ completion : @escaping (IdVerificationResponseBody?, AlertMessage?) -> Void) {
        if let personId = AppGlobalData.shared().personId {
            self.apiManager.call(type: EndpointItem.getPersonaHostedUrl(personId), params: nil) { (_ idvResponse, errorMessage) in
                completion(idvResponse, errorMessage)
            }
        }
    }

    func submitKYCCall(_ completion : @escaping (KYCStatusResponseBody?, AlertMessage?) -> Void) {

        if let personId = AppGlobalData.shared().personId {

            self.apiManager.call(type: EndpointItem.submitKYC(personId), params: nil) { (_ kycesponse, errorMessage) in
                completion(kycesponse, errorMessage)
            }
        }
    }
}
