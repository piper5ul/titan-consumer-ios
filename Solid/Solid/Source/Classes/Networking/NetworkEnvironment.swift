//
//  NetworkEnvironment.swift
//  Solid
//
//  Created by Solid iOS Team on 2/8/21.
//

import Foundation
enum NetworkEnvironment {
    case productionTest
    case productionLive
    
    func localizeDescription() -> String {
        switch self {
        case .productionTest: return Utility.localizedString(forKey: "env_test")
        case .productionLive: return Utility.localizedString(forKey: "env_live")
        }
    }
    
    static func getApiEnv(for type: String) -> NetworkEnvironment {
        if type == NetworkEnvironment.productionTest.localizeDescription() {
            return productionTest
        }
        
        return productionLive
    }
}

struct Client {
    static var clientId: String {
        return AppMetaDataHelper.shared.currentEnvKeys.auth0ClientId ?? ""
    }
}
