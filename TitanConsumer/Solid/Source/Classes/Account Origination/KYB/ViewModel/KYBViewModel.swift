//
//  KYBViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/12/21.
//

import Foundation
class KYBViewModel: BaseViewModel {
	static let shared = KYBViewModel()
	let apiManager = APIManager.shared()
}

extension KYBViewModel {

    // Get NAICS codes List
    func getNAICSCodesList(_ completion : @escaping (NAICSCodesListResponseBody?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.listAllNAICSCodes, params: nil) { (_ naicsCodesListResponseBody, errorMessage) in
            completion(naicsCodesListResponseBody, errorMessage)
        }
    }
    
    // Get Projection/ETV data
    func getProjection(businessId: String, _ completion : @escaping (ProjectionModel?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getProjection(businessId), params: nil) { (_ projectionResponse, errorMessage) in
            completion(projectionResponse, errorMessage)
        }
    }

    // Update Projection/ETV data
    func updateProjection(businessId: String, projectionData: ProjectionModel, _ completion: @escaping(_ response: ProjectionModel?, _ errorMessage: AlertMessage?) -> Void) {
        self.decode(modelType: projectionData)
        self.apiManager.call(type: EndpointItem.updateProjection(businessId), params: postParams) { (response, errorMessage) in
            completion(response, errorMessage)
        }
    }
    
	// Submit KYB
	func submitKyb(businessId: String, businessData: SubmitBusinessPostBody, _ completion: @escaping(_ response: SubmitBusinessResponseBody?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: businessData)
		self.apiManager.call(type: EndpointItem.submitKyb(businessId), params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// Get KYB Status
	func getKybstatus(businessId: String, _ completion : @escaping (KYBStatusResponseBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getKybStatus(businessId), params: nil) { (_ kybStatusResponseBody, errorMessage) in
			completion(kybStatusResponseBody, errorMessage)
		}
	}

	// Get Ownership Disclosure
	func getOwnershipDisclosureLink(businessId: String, _ completion : @escaping (OwnershipDisclosureResponseBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getOwnershipDisclosure(businessId), params: nil) { (_ ownershipDisclosureResponseBody, errorMessage) in
			completion(ownershipDisclosureResponseBody, errorMessage)
		}
	}

    // Generate Ownership Disclosure
    func generateOwnershipDisclosureLink(businessId: String, disclosureRequest: OwnershipDisclosureRequestBody, _ completion : @escaping (OwnershipDisclosureResponseBody?, AlertMessage?) -> Void) {
        self.decode(modelType: disclosureRequest)
        self.apiManager.call(type: EndpointItem.generateOwnershipDisclosure(businessId), params: postParams) { (_ ownershipDisclosureResponseBody, errorMessage) in
            completion(ownershipDisclosureResponseBody, errorMessage)
        }
    }
    
	// Get Business List
	func getbusinessList(_ completion : @escaping (BusinessListResponseBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.listAllBusiness, params: nil) { (_ businessListResponseBody, errorMessage) in
			completion(businessListResponseBody, errorMessage)
		}
	}

	// new business
	func createNewBusiness(businessData: CreateBusinessPostBody, _ completion: @escaping(_ response: BusinessDataModel?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: businessData)
		self.apiManager.call(type: EndpointItem.createBusiness, params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// get business details
	func getBusinessDetails(businessId: String, _ completion : @escaping (BusinessDataModel?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getBusiness(businessId), params: nil) { (_ response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	func updateBusiness(businessId: String, businessData: CreateBusinessPostBody, _ completion: @escaping(_ response: BusinessDataModel?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: businessData)
		self.apiManager.call(type: EndpointItem.updateBusiness(businessId), params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

}
