//
//  UIColor+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64() // UInt32()
        Scanner(string: hex).scanHexInt64(&int)
        let aRGB: UInt64 // UInt32
        let rRGB: UInt64
        let gRGB: UInt64
        let bRGB: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (aRGB, rRGB, gRGB, bRGB) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (aRGB, rRGB, gRGB, bRGB) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (aRGB, rRGB, gRGB, bRGB) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (aRGB, rRGB, gRGB, bRGB) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(rRGB) / 255, green: CGFloat(gRGB) / 255, blue: CGFloat(bRGB) / 255, alpha: CGFloat(aRGB) / 255)
    }
}

extension UIColor {
    //for white and grey colors
    public class var background: UIColor {
        return UIColor.tertiarySystemBackground
    }
    
    //for grey and black colors
    public class var grayBackgroundColor: UIColor {
        return UIColor.systemGroupedBackground //UIColor(hexString: "#F6F7F9")
    }
    
    public class var primaryColor: UIColor {
        //return UIColor.label
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: AppMetaDataHelper.shared.config?.darkPrimaryTextColor ?? "") : UIColor(hexString: AppMetaDataHelper.shared.config?.primaryTextColor ?? "")
    }
    
    public class var secondaryColor: UIColor {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: AppMetaDataHelper.shared.config?.darkSecondaryTextColor ?? "") : UIColor(hexString: AppMetaDataHelper.shared.config?.secondaryTextColor ?? "")
    }
    
    public class var secondaryColorWithOpacity: UIColor {
        return UIColor.secondaryColor.withAlphaComponent(0.6)
    }
    
    //FOR STATUS TYPES..
    public class var greenMain: UIColor {
        return UIColor.systemGreen
    }
    
    public class var redMain: UIColor {
        return UIColor.systemRed
    }
    
    public class var blueMain: UIColor {
        return UIColor.systemBlue
    }
    
    public class var yellowMain: UIColor {
        return UIColor.systemYellow
    }
    
    public class var orangeMain: UIColor {
        return UIColor.systemOrange
    }
    
    //FOR TRANSACTIONS TYPES..
    public class var trnsTypeCardColor: UIColor {
        return UIColor.systemPurple
    }
    
    public class var trnsTypeIntrabankColor: UIColor {
        return UIColor.systemIndigo
    }
    
    public class var trnsTypeACHColor: UIColor {
        return UIColor.systemBlue
    }
    
    public class var trnsTypeCheckColor: UIColor {
        return UIColor.systemOrange
    }
    
    public class var trnsTypeWireColor: UIColor {
        return UIColor.systemTeal
    }
    
    public class var trnsTypeDefaultColor: UIColor {
        return UIColor(hexString: "#1AAEC7")
    }
    
    public class var customSeparatorColor: UIColor {
        return UIColor.separator
    }
    
    //FOR BRAND COLOR..
    public class var brandColor: UIColor {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: AppMetaDataHelper.shared.config?.darkPrimaryColor ?? "") : UIColor(hexString: AppMetaDataHelper.shared.config?.appBrandColor ?? "")
    }
    
    public class var brandDisableColor: UIColor {
        return brandColor.withAlphaComponent(0.25)
    }
    
    public class var grayInternetContainerColor: UIColor {
        return UIColor(hexString: "E1E1E1")
    }
    
    public class var ctaTextColor: UIColor {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: AppMetaDataHelper.shared.config?.darkCtaTextColor ?? "") : UIColor(hexString: AppMetaDataHelper.shared.config?.ctaTextColor ?? "")
    }
    
    public class var ctaColor: UIColor {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: AppMetaDataHelper.shared.config?.darkCtaColor ?? "") : UIColor(hexString: AppMetaDataHelper.shared.config?.ctaColor ?? "")
    }
    
    public class var physicalCardTextColor: UIColor {
        return UIColor(hexString: AppMetaDataHelper.shared.config?.physicalCardTextColor ?? "")
    }
    
    public class var virtualCardTextColor: UIColor {
        return UIColor(hexString: AppMetaDataHelper.shared.config?.virtualCardTextColor ?? "")
    }
}
