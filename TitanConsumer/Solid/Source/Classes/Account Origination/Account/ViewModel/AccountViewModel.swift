//
//  KYBViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/12/21.
//

import Foundation
class AccountViewModel: BaseViewModel {
	static let shared = AccountViewModel()
	let apiManager = APIManager.shared()
}

extension AccountViewModel {
    func getAccountList(businessId: String, limit: String = "\(Constants.accountsFetchLimit)", offset: String = "", _ completion : @escaping (AccountListResponseBody?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.listAllAccount(businessId, limit, offset) as EndPointType, params: nil) { (_ accountListResponseBody, errorMessage) in
            completion(accountListResponseBody, errorMessage)
        }
    }

	// new account
	func createNewAccount(accountData: AccountRequestBody, _ completion: @escaping(_ response: AccountDataModel?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: accountData)
		self.apiManager.call(type: EndpointItem.createAccount as EndPointType, params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// get account details
	func getaccountDetail(accountId: String, _ completion : @escaping (AccountDataModel?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.getAccount(accountId) as EndPointType, params: nil) { (_ accountDataModel, errorMessage) in
			completion(accountDataModel, errorMessage)
		}
	}

	// get account Statementlist
	func getaccountStatementList(accountId: String, _ completion : @escaping (AccountStmtListRespBody?, AlertMessage?) -> Void) {
		self.apiManager.call(type: EndpointItem.listStatementForAccount(accountId) as EndPointType, params: nil) { (_ accountStmtListRespBody, errorMessage) in
			completion(accountStmtListRespBody, errorMessage)
		}
	}

	func getaccountStatement(accountId: String, query: String, filename: String, _ completion : @escaping (URL?, Error?) -> Void) {
		self.apiManager.downloadFile(type: EndpointItem.getStatementForAccount(accountId, query), filename: filename) { (filepath, errormessage) in
			   completion(filepath, errormessage)
		}
	}
}
