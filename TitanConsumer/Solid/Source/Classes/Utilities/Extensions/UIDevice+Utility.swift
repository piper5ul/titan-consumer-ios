//
//  UIDevice+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 01/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit

public enum Model: String {

    //Simulator
    case simulator     = "simulator/sandbox",

         //iPod
         iPod1              = "iPod 1",
         iPod2              = "iPod 2",
         iPod3              = "iPod 3",
         iPod4              = "iPod 4",
         iPod5              = "iPod 5",
         iPod6              = "iPod 6",
         iPod7              = "iPod 7",

         //iPad
         iPad2              = "iPad 2",
         iPad3              = "iPad 3",
         iPad4              = "iPad 4",
         iPadAir            = "iPad Air ",
         iPadAir2           = "iPad Air 2",
         iPadAir3           = "iPad Air 3",
         iPadAir4           = "iPad Air 4",
         iPad5              = "iPad 5", //iPad 2017
         iPad6              = "iPad 6", //iPad 2018
         iPad7              = "iPad 7", //iPad 2019
         iPad8              = "iPad 8", //iPad 2020
         iPad9              = "iPad 9", //iPad 2021

         //iPad Mini
         iPadMini           = "iPad Mini",
         iPadMini2          = "iPad Mini 2",
         iPadMini3          = "iPad Mini 3",
         iPadMini4          = "iPad Mini 4",
         iPadMini5          = "iPad Mini 5",
         iPadMini6          = "iPad Mini 6",

         //iPad Pro
         iPadPro9point7         = "iPad Pro 9.7\"",
         iPadPro10point5        = "iPad Pro 10.5\"",
         iPadPro11          = "iPad Pro 11\"",
         iPadPro211        = "iPad Pro 11\" 2nd gen",
         iPadPro311        = "iPad Pro 11\" 3rd gen",
         iPadPro12point9        = "iPad Pro 12.9\"",
         iPadPro212point9      = "iPad Pro 2 12.9\"",
         iPadPro312point9      = "iPad Pro 3 12.9\"",
         iPadPro412point9      = "iPad Pro 4 12.9\"",
         iPadPro512point9      = "iPad Pro 5 12.9\"",

         //iPhone
         iPhone4            = "iPhone 4",
         iPhone4S           = "iPhone 4S",
         iPhone5            = "iPhone 5",
         iPhone5S           = "iPhone 5S",
         iPhone5C           = "iPhone 5C",
         iPhone6            = "iPhone 6",
         iPhone6Plus        = "iPhone 6 Plus",
         iPhone6S           = "iPhone 6S",
         iPhone6SPlus       = "iPhone 6S Plus",
         iPhoneSE           = "iPhone SE",
         iPhone7            = "iPhone 7",
         iPhone7Plus        = "iPhone 7 Plus",
         iPhone8            = "iPhone 8",
         iPhone8Plus        = "iPhone 8 Plus",
         iPhoneX            = "iPhone X",
         iPhoneXS           = "iPhone XS",
         iPhoneXSMax        = "iPhone XS Max",
         iPhoneXR           = "iPhone XR",
         iPhone11           = "iPhone 11",
         iPhone11Pro        = "iPhone 11 Pro",
         iPhone11ProMax     = "iPhone 11 Pro Max",
         iPhoneSE2          = "iPhone SE 2nd gen",
         iPhone12Mini       = "iPhone 12 Mini",
         iPhone12           = "iPhone 12",
         iPhone12Pro        = "iPhone 12 Pro",
         iPhone12ProMax     = "iPhone 12 Pro Max",
         iPhone13Mini       = "iPhone 13 Mini",
         iPhone13           = "iPhone 13",
         iPhone13Pro        = "iPhone 13 Pro",
         iPhone13ProMax     = "iPhone 13 Pro Max",
         iPhoneSE3          = "iPhone SE 3rd gen",
         iPhone14           = "iPhone 14",
         iPhone14Plus       = "iPhone 14 Plus",
         iPhone14Pro        = "iPhone 14 Pro",
         iPhone14ProMax     = "iPhone 14 Pro Max",
         
         unrecognized       = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#
// MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    
    func calculateCardWidth() -> (CGFloat, CGFloat, CGFloat) {

        var cardWidth: CGFloat = 0.0
        var cardHeight: CGFloat = 0.0
        var cardHeightRation: CGFloat = 0.0
        
        if UIScreen.main.bounds.width  == UIDevice.DeviceSize.iPadAir.size.width || UIScreen.main.bounds.width == UIDevice.DeviceSize.iPadMini.size.width {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/2) - 30
        } else if UIScreen.main.bounds.width ==  UIDevice.DeviceSize.iPad9.size.width {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/2) - 35
        } else if UIScreen.main.bounds.width == UIDevice.DeviceSize.iPadAir4th.size.width {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/2) - 38
        } else if UIScreen.main.bounds.width ==  UIDevice.DeviceSize.iPadPro10AndHalfInch.size.width || UIScreen.main.bounds.width == UIDevice.DeviceSize.iPadPro11Inch.size.width {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/2) - 40
        } else if UIScreen.main.bounds.width ==  UIDevice.DeviceSize.iPadPro11Inch.size.height {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/3) - 40
        } else if UIScreen.main.bounds.width ==  UIDevice.DeviceSize.iPadAir.size.height {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/3) - 23
        } else if UIScreen.main.bounds.width == UIDevice.DeviceSize.iPadPro11Inch.size.width || UIScreen.main.bounds.width == UIDevice.DeviceSize.iPad9.size.height {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/3) - 35
        } else if UIScreen.main.bounds.width == UIDevice.DeviceSize.iPadMini.size.height || UIScreen.main.bounds.width == UIDevice.DeviceSize.iPadAir4th.size.height {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/3) - 35
        } else {
            cardWidth = (CGFloat(UIScreen.main.bounds.width)/4) - 20
        }

        cardHeightRation = cardWidth * 60.3 / 100
        cardHeight = CGFloat(cardWidth /  cardHeightRation)
        
        return (cardWidth, cardHeight, cardHeightRation)
    }
    
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String.init(validatingUTF8: ptr)
            }
        }

        let modelMap: [ String: Model ] = [
            //Simulator
            "i386": .simulator,
            "x86_64": .simulator,

            //iPod
            "iPod1,1": .iPod1,
            "iPod2,1": .iPod2,
            "iPod3,1": .iPod3,
            "iPod4,1": .iPod4,
            "iPod5,1": .iPod5,
            "iPod7,1": .iPod6,
            "iPod9,1": .iPod7,

            //iPad
            "iPad2,1": .iPad2,
            "iPad2,2": .iPad2,
            "iPad2,3": .iPad2,
            "iPad2,4": .iPad2,
            "iPad3,1": .iPad3,
            "iPad3,2": .iPad3,
            "iPad3,3": .iPad3,
            "iPad3,4": .iPad4,
            "iPad3,5": .iPad4,
            "iPad3,6": .iPad4,
            "iPad6,11": .iPad5, //iPad 2017
            "iPad6,12": .iPad5,
            "iPad7,5": .iPad6, //iPad 2018
            "iPad7,6": .iPad6,
            "iPad7,11": .iPad7, //iPad 2019
            "iPad7,12": .iPad7,
            "iPad11,6": .iPad8, //iPad 2020
            "iPad11,7": .iPad8,
            "iPad12,1": .iPad9, //iPad 2021
            "iPad12,2": .iPad9,

            //iPad Mini
            "iPad2,5": .iPadMini,
            "iPad2,6": .iPadMini,
            "iPad2,7": .iPadMini,
            "iPad4,4": .iPadMini2,
            "iPad4,5": .iPadMini2,
            "iPad4,6": .iPadMini2,
            "iPad4,7": .iPadMini3,
            "iPad4,8": .iPadMini3,
            "iPad4,9": .iPadMini3,
            "iPad5,1": .iPadMini4,
            "iPad5,2": .iPadMini4,
            "iPad11,1": .iPadMini5,
            "iPad11,2": .iPadMini5,
            "iPad14,1": .iPadMini6,
            "iPad14,2": .iPadMini6,

            //iPad Pro
            "iPad6,3": .iPadPro9point7,
            "iPad6,4": .iPadPro9point7,
            "iPad7,3": .iPadPro10point5,
            "iPad7,4": .iPadPro10point5,
            "iPad6,7": .iPadPro12point9,
            "iPad6,8": .iPadPro12point9,
            "iPad7,1": .iPadPro212point9,
            "iPad7,2": .iPadPro212point9,
            "iPad8,1": .iPadPro11,
            "iPad8,2": .iPadPro11,
            "iPad8,3": .iPadPro11,
            "iPad8,4": .iPadPro11,
            "iPad8,9": .iPadPro211,
            "iPad8,10": .iPadPro211,
            "iPad13,4": .iPadPro311,
            "iPad13,5": .iPadPro311,
            "iPad13,6": .iPadPro311,
            "iPad13,7": .iPadPro311,
            "iPad8,5": .iPadPro312point9,
            "iPad8,6": .iPadPro312point9,
            "iPad8,7": .iPadPro312point9,
            "iPad8,8": .iPadPro312point9,
            "iPad8,11": .iPadPro412point9,
            "iPad8,12": .iPadPro412point9,
            "iPad13,8": .iPadPro512point9,
            "iPad13,9": .iPadPro512point9,
            "iPad13,10": .iPadPro512point9,
            "iPad13,11": .iPadPro512point9,

            //iPad Air
            "iPad4,1": .iPadAir,
            "iPad4,2": .iPadAir,
            "iPad4,3": .iPadAir,
            "iPad5,3": .iPadAir2,
            "iPad5,4": .iPadAir2,
            "iPad11,3": .iPadAir3,
            "iPad11,4": .iPadAir3,
            "iPad13,1": .iPadAir4,
            "iPad13,2": .iPadAir4,

            //iPhone
            "iPhone3,1": .iPhone4,
            "iPhone3,2": .iPhone4,
            "iPhone3,3": .iPhone4,
            "iPhone4,1": .iPhone4S,
            "iPhone5,1": .iPhone5,
            "iPhone5,2": .iPhone5,
            "iPhone5,3": .iPhone5C,
            "iPhone5,4": .iPhone5C,
            "iPhone6,1": .iPhone5S,
            "iPhone6,2": .iPhone5S,
            "iPhone7,1": .iPhone6Plus,
            "iPhone7,2": .iPhone6,
            "iPhone8,1": .iPhone6S,
            "iPhone8,2": .iPhone6SPlus,
            "iPhone8,4": .iPhoneSE,
            "iPhone9,1": .iPhone7,
            "iPhone9,3": .iPhone7,
            "iPhone9,2": .iPhone7Plus,
            "iPhone9,4": .iPhone7Plus,
            "iPhone10,1": .iPhone8,
            "iPhone10,4": .iPhone8,
            "iPhone10,2": .iPhone8Plus,
            "iPhone10,5": .iPhone8Plus,
            "iPhone10,3": .iPhoneX,
            "iPhone10,6": .iPhoneX,
            "iPhone11,2": .iPhoneXS,
            "iPhone11,4": .iPhoneXSMax,
            "iPhone11,6": .iPhoneXSMax,
            "iPhone11,8": .iPhoneXR,
            "iPhone12,1": .iPhone11,
            "iPhone12,3": .iPhone11Pro,
            "iPhone12,5": .iPhone11ProMax,
            "iPhone12,8": .iPhoneSE2,
            "iPhone13,1": .iPhone12Mini,
            "iPhone13,2": .iPhone12,
            "iPhone13,3": .iPhone12Pro,
            "iPhone13,4": .iPhone12ProMax,
            "iPhone14,4": .iPhone13Mini,
            "iPhone14,5": .iPhone13,
            "iPhone14,2": .iPhone13Pro,
            "iPhone14,3": .iPhone13ProMax,
            "iPhone14,6": .iPhoneSE3,
            "iPhone14,7": .iPhone14,
            "iPhone14,8": .iPhone14Plus,
            "iPhone15,2": .iPhone14Pro,
            "iPhone15,3": .iPhone14ProMax
        ]

        guard let mcode = modelCode, let map = String(validatingUTF8: mcode), let model = modelMap[map] else { return Model.unrecognized }
            if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"], let simMap = String(validatingUTF8: simModelCode), let simModel = modelMap[simMap], model == .simulator {
                return simModel
            }
        return model
    }

    enum DeviceSize: CaseIterable {
            // iPhones:
            case iPhoneX // XS
            case iPhoneXSMax // Fun fact: Xr has same logical resolution as XS Max.
                             // https://stackoverflow.com/a/52425261/5774854
            case iPhone8Plus // Since iPhone 6+, this works for all of our screens
            case iPhone8 // Since iPhone 6, this works for all of our screens
            case iPhoneSE // iPhone 5, 5S... SE 2 maybe? 🚀
            case iPhone4 // 4S
            // iPads:
            case iPadAir // Also known as: iPad 3, iPad 4, iPad Air, iPad Air 2, 9.7-inch iPad Pro
                        // iPad Minis have same logical resolutions, but are different in PPI (higher) and physical display.
                        // I expect them to behave the same in same logical resolutions.
            case iPad9
            case iPadAir4th
            case iPadPro10AndHalfInch
            case iPadPro11Inch
            case iPadPro12Point9Inch
            case iPadMini
            case iPadMiniLandScape
            case iPadAirLandScape
            case iPadPro10AndHalfInchLandScape
            case iPadPro11InchLandScape
            case iPadPro12Point9InchLandScape
            case iPad9LandsScape
            case iPadAir4thLandScape

            var size: CGSize {
                switch self {
                // iPhones
                case .iPhoneX:
                    return .init(width: 375, height: 812)
                case .iPhoneXSMax:
                    return .init(width: 414, height: 896)
                case .iPhone8Plus:
                    return .init(width: 414, height: 736)
                case .iPhone8:
                    return .init(width: 375, height: 667)
                case .iPhoneSE:
                    return .init(width: 320, height: 568)
                case .iPhone4:
                    return .init(width: 320, height: 480)
                case .iPadMini:
                    return .init(width: 744, height: 1133)
                case .iPadAir:
                    return .init(width: 768, height: 1024)
                case .iPadPro10AndHalfInch:
                    return .init(width: 834, height: 1112)
                case .iPadPro11Inch:
                    return .init(width: 834, height: 1194)
                case .iPadPro12Point9Inch:
                    return .init(width: 1024, height: 1366)
                case .iPad9:
                    return .init(width: 810, height: 1080)
                case .iPadAir4th:
                    return .init(width: 820, height: 1180)
                case .iPadMiniLandScape:
                    return .init(width: 1133, height: 744)
                case .iPadAirLandScape:
                    return .init(width: 1024, height: 768)
                case .iPadPro10AndHalfInchLandScape:
                    return .init(width: 1112, height: 834)
                case .iPadPro11InchLandScape:
                    return .init(width: 1194, height: 834)
                case .iPadPro12Point9InchLandScape:
                    return .init(width: 1366, height: 1024)
                case .iPad9LandsScape:
                    return .init(width: 1080, height: 810)
                case .iPadAir4thLandScape:
                    return .init(width: 1180, height: 820)
                }
            }
        }

        // Probable iPhone/iPad model acording to size. Because we want to make different screen designs
        // according to device sizes, it is more than appropriate to finaly differ the screen resolutions.
        var sizeModel: DeviceSize {

            guard let size = DeviceSize.allCases.first(where: { $0.size == UIScreen.main.bounds.size }) else {
                fatalError("Size detected from this enum was not found. Either some 👽 device or the device is new and was not added.")
            }
            return size
        }
}
