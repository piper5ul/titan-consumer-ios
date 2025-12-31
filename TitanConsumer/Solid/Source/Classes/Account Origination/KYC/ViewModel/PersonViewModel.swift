//
//  PersonModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/10/21.
//

import Foundation

// To fetch person details
class PersonViewModel: BaseViewModel {
	static let shared = PersonViewModel()
	let apiManager = APIManager.shared()
}

extension PersonViewModel {
	func getPersonDetail(_ completion : @escaping (PersonResponseBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getPerson, params: nil) { (_ personResponseBody, errorMessage) in
			completion(personResponseBody, errorMessage)
		}
	}
}

// To update Person detail
class UpdatePersonViewModel: BaseViewModel {
	static let shared = UpdatePersonViewModel()
	let apiManager = APIManager.shared()
}

extension UpdatePersonViewModel {

	func updatePersonDetail(personId: String, userData: UpdatePersonPostBody, _ completion: @escaping(_ response: PersonResponseBody?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: userData)
		self.apiManager.call(type: EndpointItem.updatePerson(personId), params: postParams) { (otpResponse, errorMessage) in
			completion(otpResponse, errorMessage)
		}
	}
}
