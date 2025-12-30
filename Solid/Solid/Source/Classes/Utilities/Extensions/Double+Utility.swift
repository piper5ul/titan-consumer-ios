//
//  Double+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 14/02/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func toString() -> String {
           return String(format: "%.2f", self)
    }

    func toStringWithoutDecimal() -> String {
       return String(format: "%.0f", self)
    }

    public var formattedDouble: String {
        let number = NSNumber(value: abs(self))
        var formatted = Utility.getCurrencyForAmount(amount: number, isDecimalRequired: true, withoutSpace: true)
        
        let amountGot = self
        if amountGot != 0 {
            if amountGot < 0 {
                formatted = "- \(formatted)"
            } else {
                formatted = "+ \(formatted)"
            }
        }
        
        return formatted
    }

    public var negativeFormattedDouble: String {
        let number = NSNumber(value: abs(self))
        var formatted = Utility.getCurrencyForAmount(amount: number, isDecimalRequired: true, withoutSpace: true)
        
        let amountGot = self
        if amountGot != 0 {
            formatted = "- \(formatted)"
        }
        
        return formatted
    }
}
