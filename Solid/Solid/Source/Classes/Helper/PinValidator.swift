//
//  PinValidator.swift
//  Solid
//
//   Created by Solid iOS Team on  15/02/22.
//  Copyright © 2022 Solid. All rights reserved.
//

import Foundation
import UIKit

protocol ValidationRule {
    func isValid(for number: Int) -> Bool
}

class FourDigitNumberRule: ValidationRule {
    let allowedRange = 1000...9999
    func isValid(for number: Int) -> Bool {
        return allowedRange.contains(number)
    }
}

class NoConsecutiveDigitsRule: ValidationRule {
    func isValid(for number: Int) -> Bool {
        let coef = 10
        var remainder = number
        var curr: Int?
        var prev: Int?
        var diff: Int?

        while remainder > 0 {
            defer {
                remainder = Int(remainder / coef)
            }
            prev = curr
            curr = remainder % coef
            guard let previous = prev, let current = curr else {
                continue
            }
            let lastDiff = diff
            diff = previous - current
            guard let ld = lastDiff else {
                continue
            }
            if ld != diff {
                return true
            }
            if diff != 1 && diff != -1 {
                return true
            }
        }
        return false
    }
}

class NonRepeatRule: ValidationRule {

    func isValid(for number: Int) -> Bool {
        let coef = 10
        var map = [Int: Int]()
        
        for iterator in 0...9 {
            map[iterator] = 0
        }
        
        var remainder = number
        while remainder > 0 {
            let iterator = remainder % coef
            map[iterator]! += 1
            remainder = Int(remainder / coef)
        }
        
        for iteratori in 0...9 where map[iteratori]! > 2 {
            return false
        }
        
        return true
    }
}
