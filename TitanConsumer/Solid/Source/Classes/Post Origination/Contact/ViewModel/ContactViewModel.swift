//
//  ContactViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 02/03/21.
//

import Foundation

class ContactViewModel: BaseViewModel {
    static let shared = ContactViewModel()
    let apiManager = APIManager.shared()
}

extension ContactViewModel {

    // new contact
    func createNewContact(contactData: ContactDataModel, _ completion: @escaping(_ response: ContactDataModel?, _ errorMessage: AlertMessage?) -> Void) {
        self.decode(modelType: contactData)
        self.apiManager.call(type: EndpointItem.createContact, params: postParams) { (response, errorMessage) in
            completion(response, errorMessage)
        }
    }

    // update contact
    func updateContact(contactId: String, contactData: ContactDataModel, _ completion: @escaping(_ response: ContactDataModel?, _ errorMessage: AlertMessage?) -> Void) {
        self.decode(modelType: contactData)
        self.apiManager.call(type: EndpointItem.updateContact(contactId), params: postParams) { (response, errorMessage) in
            completion(response, errorMessage)
        }
    }

	func getContactList(accountId: String, type: String, limit: String, offset: String, _ completion : @escaping (ContactListResponseBody?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.listAllContacts(accountId, type, limit, offset) as EndPointType, params: nil) { (_ response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	func getContactDetail(contactId: String, _ completion : @escaping (ContactDataModel?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getContactDetails(contactId) as EndPointType, params: nil) { (_ response, errorMessage) in
			completion(response, errorMessage)
		}
	}

    func deleteContact(contactId: String, _ completion : @escaping (ContactDeleteResponseBody?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.deleteContact(contactId) as EndPointType, params: nil) { (_ response, errorMessage) in
            completion(response, errorMessage)
        }
    }
}
