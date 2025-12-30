//
//  Config.swift
//  Solid
//
//  Created by Solid iOS Team on 2/10/21.
//

import Foundation
import VGSShowSDK

struct Config {
    struct GooglePlaces {
        static var apiKey: String {
            return "GOOGLE_API_KEY" //ENTER YOUR GOOGLE API KEY HERE..
        }
    }

    struct VGS {
        static var vaultId: String {
            return "xxxxxxxxxxx" //ENTER YOUR VGS VAULT ID HERE..
        }
        
        static var VGSEnv: VGSEnvironment {
            switch APIManager.networkEnviroment {
            case .productionLive :
                return VGSEnvironment.live
            default:
                return VGSEnvironment.sandbox
            }
        }
    }
    
    struct DocuSign {
        static var docuSignHost: String {
            switch APIManager.networkEnviroment {
            case .productionTest:
                return "test.solid.app"
            default:
                return "solid.app"
            }
        }

        static var docuSignKey: String {
            return "8551fa2b-862b-43d0-bd2d-adb8a7af05fe" //ENTER YOUR DOCUSIGN INTEGRATION KEY HERE..
        }
    }
}
