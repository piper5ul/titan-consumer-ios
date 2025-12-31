//
//  TransactionViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 3/16/21.
//

import Foundation

class TransactionViewModel: BaseViewModel {
	static let shared = TransactionViewModel()
	let apiManager = APIManager.shared()
}

extension TransactionViewModel {
    func getTransactionList(strId: String, queryString: String, _ completion : @escaping (TransactionListResponseBody?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.listAllTransaction(strId, queryString) as EndPointType, params: nil) { (_ transactionListResponseBody, errorMessage) in
            completion(transactionListResponseBody, errorMessage)
        }
    }
    
    func getTransactionDetail(strId: String, transactionId: String, _ completion : @escaping (TransactionModel?, AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getTransactionDetail(strId, transactionId) as EndPointType, params: nil) { (_ transactionModel, errorMessage) in
            completion(transactionModel, errorMessage)
        }
    }

    func transactionDetailExport(strId: String, transactionId: String, filename: String, _ completion : @escaping (URL?, Error?) -> Void) {
        self.apiManager.downloadFile(type: EndpointItem.transactionDetailExport(strId, transactionId), filename: filename) { (filepath, errormessage) in
            completion(filepath, errormessage)
        }
    }
}
