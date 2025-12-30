//
//  CardViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 3/9/21.
//

import Foundation
import UIKit
import VGSCollectSDK

class CardViewModel: BaseViewModel {
	static let shared = CardViewModel()
	let apiManager = APIManager.shared()
    
    var cardWidth: CGFloat = 0.0
    var cardHeight: CGFloat = 0.0
    var cardHeightRation: CGFloat = 0.0
    var cardPinModal: CardPinTokenModel?
    let vgsCollect = VGSCollect(id: Config.VGS.vaultId, environment: Config.VGS.VGSEnv.rawValue)
    var path = String()
}

extension CardViewModel {
    // new card
	func createNewCard(cardData: CardCreateRequestBody, _ completion: @escaping(_ response: CardModel?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: cardData)
		self.apiManager.call(type: EndpointItem.createCard as EndPointType, params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// Get Business Agreement
	func getcardList(accountId: String, limit: String, offset: String, _ completion : @escaping (CardsListResponseBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getCards(accountId, limit, offset), params: nil) { (_ response, errorMessage) in
			completion(response, errorMessage)
		}
	}

    // update card
    func updateCard(cardID: String, contactData: CardUpdateRequestBody, _ completion: @escaping(_ response: CardModel?, _ errorMessage: AlertMessage?) -> Void) {
        self.decode(modelType: contactData)
        self.apiManager.call(type: EndpointItem.updateCard(cardID), params: postParams) { (response, errorMessage) in
            completion(response, errorMessage)
        }
    }

	// Activate Card
	func activateCard(cardID: String, cardData: CardActivateRequestBody, _ completion: @escaping(_ response: CardActivationResponseBody?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: cardData)
		self.apiManager.call(type: EndpointItem.activateCard(cardID), params: postParams) { (_ response, errorMessage) in
			completion(response, errorMessage)
		}
	}

    // Cancel Card
    func deleteCard(cardId: String, _ completion : @escaping (CardActivationResponseBody?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.deleteCard(cardId) as EndPointType, params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
    
    // Calculate Card Size
    func calculateCardWidth() {
        cardWidth = UIDevice.current.calculateCardWidth().0
        cardHeight = UIDevice.current.calculateCardWidth().1
        cardHeightRation = UIDevice.current.calculateCardWidth().2
    }
    
    //Enroll Card to Apple Wallet
    
    func enrollCard(cardId: String, walletData: CardWalletRequestBody, _ completion: @escaping(_ response: CardWalletResponseBody?, _ errorMessage: AlertMessage?) -> Void) {
        self.decode(modelType: walletData)
        self.apiManager.call(type: EndpointItem.enrollWallet(cardId), params: postParams) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
}

extension CardViewModel {

    func getcardDetails(cardId: String, _ completion : @escaping (CardModel?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getCardDetails(cardId), params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }

    func getcardUnredacted(cardId: String, _ completion : @escaping (CardDetailsModel?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getCardUnredacted(cardId), params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
    
    func getVGSShowToken(cardId: String, _ completion : @escaping (CardVGSShowTokenModel?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getVGSShowToken(cardId), params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
    
    func getCardPinToken(cardId: String, _ completion : @escaping (CardPinTokenModel?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getCardPinToken(cardId), params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
    
    func setVGSPinToken(cardId: String, cardSdToken: String, params: [String: Any], _ completion : @escaping (Bool?, String?) -> Void) {
        
        self.path = AppGlobalData.shared().accessPinVGSContentPath(cardId: cardId)
        
        vgsCollect.customHeaders = [
            "sd-pin-token": cardSdToken,
            "content-type": "application/json;charset=UTF-8",
            "Authorization": "Bearer \(AppData.session.accessToken ?? "")"
        ]
        
        vgsCollect.sendData(path: self.path, method: .post, extraData: params as [String: Any]) {(response) in
            
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
                switch code {
                case 400..<499:
                    debugPrint("Error: Wrong Request, code: \(code)")
                case VGSErrorType.inputDataIsNotValid.rawValue:
                    if let error = error as? VGSError {
                        debugPrint("Error: Input data is not valid. Details:\n \(error)")
                    }
                default:
                    debugPrint("Error: Something went wrong. Code: \(code)")
                }
                completion(false, Utility.localizedString(forKey: "generic_ErrorMessage"))
                return
            }
        }
    }
    
    func getATMlocation(cardId: String, limit: String, offset: String, latitude: String, longitude: String, radius: String, _ completion : @escaping (ATMLocations?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getATMLocation(cardId, limit, offset, latitude, longitude, radius), params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
}
