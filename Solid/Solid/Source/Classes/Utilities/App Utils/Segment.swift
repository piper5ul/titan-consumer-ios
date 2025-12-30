//
//  Segment.swift
//  Solid
//
//  Created by Solid iOS Team on 24/03/21.
//

import UIKit
import Segment

enum SegmentEventType {
    case track
    case screen
    case none
}

class Segment {
    static let sharedSegment = Segment()
    var segmentConfigObj: Analytics?
    
    static func identify(userId: String!, name: String?) {
        if let segmentObj = sharedSegment.segmentConfigObj {
            if let name = name {
                segmentObj.identify(userId, traits: ["name": name])
            } else {
                segmentObj.identify(userId)
            }
        } else {
            debugPrint("Segment Config object nil")
        }
    }
    
    static func addSegmentEvent(name: EventName, type: SegmentEventType = .none, properties: [String: String] = [:]) {
        if let segmentObj = sharedSegment.segmentConfigObj {
            var segmentProperties = properties
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                let appVersion = "iOS_\(version)"
                segmentProperties.updateValue(appVersion, forKey: "app version")
            }
            let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
            let strBatteryLevel = "\(batteryLevel)%"
            segmentProperties.updateValue(strBatteryLevel, forKey: "battery level")
            
            let eventString = name.rawValue
			if type == .screen {
				segmentObj.screen(eventString, properties: segmentProperties)
				debugPrint("Screen - '\(eventString)' \n properties : \(segmentProperties)")
			} else {
				segmentObj.track(eventString, properties: segmentProperties)
				debugPrint("Track - '\(eventString)' \n properties : \(segmentProperties)")
			}
        } else {
            debugPrint("Segment Config object nil")
        }
    }
}

//MARK:- EventName
extension Segment {
    enum EventName: String {
        //TRACK EVENTS.....
        
        //*** Welcome Screen
        case getStarted                         = "getStarted"
        
        //*** AO Screens
        case proceedPersonal                    = "proceedPersonal"
        case proceedIdentity                    = "proceedIdentity"
        case proceedBusiness                    = "proceedBusiness"
        case proceedSign                        = "proceedSign"
        case createAccount                      = "createAccount"
        
        //*** Home Screens
        case homeEntityDetails                  = "homeEntityDetails"
        case homeUserDetails                    = "homeUserDetails"
        case homeViewAllAccounts                = "homeViewAllAccounts"
        case homeAccountDetails                 = "homeAccountDetails"
        case homeFund                           = "homeFund"
        case homePay                            = "homePay"
        case homeViewAllTransactions            = "homeViewAllTransactions"
        case homeTransactionsDetails            = "homeTransactionsDetails"
        case homeViewAllCards                   = "homeViewAllCards"
        case homeCardDetails                    = "homeCardDetails"
        case homeViewAllContacts                = "homeViewAllContacts"
    }
}
