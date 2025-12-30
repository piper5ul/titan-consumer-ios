//
//  OwnerViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/23/21.
//

import Foundation
class OwnerViewModel: BaseViewModel {
	static let shared = OwnerViewModel()
	let apiManager = APIManager.shared()
}

extension OwnerViewModel {
	// Get owner list

	func getOwnerList(businessId: String, _ completion : @escaping (OwnerListResponseBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.listAllOwner(businessId) as EndPointType, params: nil) { (_ ownerListResponseBody, errorMessage) in
			completion(ownerListResponseBody, errorMessage)
		}
	}

	// new owner
	func createNewOwner(ownerData: CreateOwnerRequestbody, _ completion: @escaping(_ response: OwnerDataModel?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: ownerData)
		self.apiManager.call(type: EndpointItem.createOwner as EndPointType, params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// get owner details
	func getownerDetail(ownerId: String, _ completion : @escaping (OwnerDataModel?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getOwnerDetails(ownerId) as EndPointType, params: nil) { (_ ownerDataModel, errorMessage) in
			completion(ownerDataModel, errorMessage)
		}
	}

	// update owner
	func updateOwner(ownerId: String, ownerData: UpdateOwnerRequestbody, _ completion: @escaping(_ response: OwnerDataModel?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: ownerData)
		self.apiManager.call(type: EndpointItem.updateOwner(ownerId) as EndPointType, params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// submit owner kyc
	func submitOwnerKyc(ownerId: String, ownerData: KYCOwnerRequestbody, _ completion: @escaping(_ response: KYCOwnerResponsetbody?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: ownerData)
		self.apiManager.call(type: EndpointItem.submitOwnerKyc(ownerId) as EndPointType, params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// Owner Kyc List
	func getOwnerKycList(ownerId: String, _ completion : @escaping (OwnerListResponseBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getOwnerKyc(ownerId) as EndPointType, params: nil) { (_ ownerListResponseBody, errorMessage) in
			completion(ownerListResponseBody, errorMessage)
		}
	}
}
