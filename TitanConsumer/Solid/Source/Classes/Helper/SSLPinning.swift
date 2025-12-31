//
//  SSLPinning.swift
//  Solid
//
//  Created by  Solid iOS Team on 22/02/22.
//  Copyright © 2022 Solid. All rights reserved.
//

import Foundation
import TrustKit

class SSLPinning: NSObject, URLSessionDelegate {
    static let publickKeyHash1 = "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI="
    static let publickKeyHash2 = "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+Nyoxxxxxxxxxx="

    class func startSSLPinning() {
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "api.solidfi.com": [
                    kTSKIncludeSubdomains: true,
                    kTSKEnforcePinning: true,
                    kTSKPublicKeyHashes: [
                        publickKeyHash1,
                        publickKeyHash2
                    ]],
                "test-api.solidfi.com": [
                    kTSKIncludeSubdomains: true,
                    kTSKEnforcePinning: true,
                    kTSKPublicKeyHashes: [
                        publickKeyHash1,
                        publickKeyHash2
                    ]]]] as [String: Any]

        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
    }
}
