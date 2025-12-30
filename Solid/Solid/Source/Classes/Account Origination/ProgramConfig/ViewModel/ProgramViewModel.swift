//
//  ProgramViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 5/15/21.
//

import Foundation

class ProgramViewModel: BaseViewModel {
    static let shared = ProgramViewModel()
    let apiManager = APIManager.shared()
}

extension ProgramViewModel {
    func getProgramDetails(programId: String, _ completion: @escaping(_ response: ProgramModel?, _ errorMessage: AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.getProgramDetail(programId)) { (programResponse, errorMessage) in
            completion(programResponse, errorMessage)
        }
    }
}
