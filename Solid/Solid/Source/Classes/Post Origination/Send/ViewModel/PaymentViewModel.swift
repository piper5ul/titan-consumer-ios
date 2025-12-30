//
//  PaymentViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation

class PaymentViewModel: BaseViewModel {
    static let shared = PaymentViewModel()
    let apiManager = APIManager.shared()
}

extension PaymentViewModel {
	func makePayment(payRequestBody: PaymentModel, paymentType: ContactAccountType, _ completion : @escaping (PaymentModel?, AlertMessage?) -> Void) {
        self.decode(modelType: payRequestBody)
		var etype = ""

        switch paymentType {
        case .intrabank:
            etype = "intrabank"
        case .ach:
            etype = "ach"
        case .check:
            etype = "check"
        case .domesticWire, .internationalWire:
            etype = "wire"
        case .sendVisaCard:
            etype = "card"
        default :
            etype = ""
        }

		self.apiManager.call(type: EndpointItem.paymentMethod(etype), params: postParams) { (paymentResponse, errorMessage) in
            completion(paymentResponse, errorMessage)
        }
    }
}
