//
//  FundViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 05/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import VGSCollectSDK

class FundViewModel: BaseViewModel {
    static let shared = FundViewModel()
    let apiManager = APIManager.shared()
    
    var vgsCollect = VGSCollect(id: Config.VGS.vaultId, environment: Config.VGS.VGSEnv.rawValue)
    var path = String()
}

extension FundViewModel {
    func getPlaidTempToken(accountId: String, requestBody: PlaidTempTokenRequestModel, _ completion : @escaping (PlaidTempTokenReponseModel?, AlertMessage?) -> Void) {
        self.decode(modelType: requestBody)
        self.apiManager.call(type: EndpointItem.getPlaidTempToken(accountId) as EndPointType, params: postParams) { (paymentResponse, errorMessage) in
            completion(paymentResponse, errorMessage)
        }
    }

    func submitPlaidPublicToken(accountId: String, requestBody: PlaidPublicTokenRequestModel, _ completion : @escaping (ContactDataModel?, AlertMessage?) -> Void) {
        self.decode(modelType: requestBody)
        self.apiManager.call(type: EndpointItem.submitPlaidPublicToken(accountId) as EndPointType, params: postParams) { (paymentResponse, errorMessage) in
            completion(paymentResponse, errorMessage)
        }
    }

    func pullFunds(pullFundsFlow: PullFundsFlow, requestBody: PaymentModel, _ completion : @escaping (PaymentModel?, AlertMessage?) -> Void) {
        self.decode(modelType: requestBody)

        var endPointItem: EndpointItem
        if pullFundsFlow == .debitPull {
            endPointItem = EndpointItem.debitPull
        } else if pullFundsFlow == .pullFundsOut {
            endPointItem = EndpointItem.pullFundsOut
        } else {
            endPointItem = EndpointItem.pullFundsIn
        }

        self.apiManager.call(type: endPointItem as EndPointType, params: postParams) { (paymentResponse, errorMessage) in
            completion(paymentResponse, errorMessage)
        }
    }
}

//FOR VGS COLLECT TO ADD DEBIT CARD..
extension FundViewModel {
    func getAddDebitCardToken(contactId: String, _ completion : @escaping (DebitCardTokenModel?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getAddDebitCardToken(contactId), params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
    
    func callVGSAddDebitCard(contactId: String, cardSdToken: String, cardData: VGSDebitCardData, _ completion : @escaping (Bool?, String?) -> Void) {
        self.path = AppGlobalData.shared().addDebitCardContentPath(contactID: contactId)
        
        vgsCollect.customHeaders = [
            "sd-debitcard-token": cardSdToken
        ]
        
        var vgsDebitCardModel = VGSDebitCardModel()
        vgsDebitCardModel.debitCard = cardData
        
        let param = vgsDebitCardModel.dictionary ?? [:]
        
        vgsCollect.sendData(path: self.path, method: .patch, extraData: param as [String: Any]) {(response) in
            
            switch response {
                
            case .success(_, let data, _):
                if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                   debugPrint(jsonData)
                    completion(true, nil)
                } else {
                    completion(true, nil)
                }
                return
            case .failure(let code, _, _, let error):
                var errorMessage = Utility.localizedString(forKey: "generic_ErrorMessage")
                switch code {
                case 400..<499:
                    debugPrint("Error: Wrong Request, code: \(code)")
                    errorMessage = "Invalid card details"
                case VGSErrorType.inputDataIsNotValid.rawValue:
                    if let error = error as? VGSError {
                        debugPrint("Error: Input data is not valid. Details:\n \(error)")
                        errorMessage = "Invalid card details"
                    }
                default:
                    debugPrint("Error: Something went wrong. Code: \(code)")
                }
                
                completion(false, errorMessage)
                return
            }
        }
    }
}
