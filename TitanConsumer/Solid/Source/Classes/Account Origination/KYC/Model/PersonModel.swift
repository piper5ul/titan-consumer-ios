//
//  PersonModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/10/21.
//

import Foundation
import CoreLocation

public struct PersonResponseBody: Codable {
    public var id: String?
    public var firstName: String?
    public var middleName: String?
    public var lastName: String?
    public var phone: String?
    public var phoneVerified: Bool?
    public var email: String?
    public var emailVerified: Bool?
    public var dateOfBirth: String?
    public var idNumber: String?
    public var idType: String?
    public var kyc: KYC?
    public var source: Source?
    public var address: Address?
    public var reviewCode: String?
    public var programId: String?

    public var name: String? {
        var aFullName: String?
        var value = ""
        if let firstName = firstName {
            value = firstName
        }
        if let lastName = lastName {
            value += " " + lastName
        }
        if !value.isEmpty {
            aFullName = value
        }
        return aFullName
    }

    public var initials: String? {
        var strInitials: String?
        var value = ""
        
        if let firstName = firstName {
            value = firstName.substring(start: 0, end: 1)
        }
        if let lastName = lastName {
            value += lastName.substring(start: 0, end: 1)
        }
        if !value.isEmpty {
            strInitials = value
        }        
        return strInitials
    }
}

public struct KYC: Codable {
    public var id: String?
    public var personId: String?
    public var status: KYCStatus?
    public var reviewMessage: String?
    public var results: Results?
    public var dateOfBirth: String?
    public var createdAt: String?
    public var modifiedAt: String?
}

public struct Source: Codable {
    public var partnerId: String?
    public var partnerName: String?
}

public struct Results: Codable {
    public var idv: String?
    public var address: String?
    public var fraud: String?
    public var match: String?

    enum CodingKeys: String, CodingKey {
        case idv
        case address
        case fraud
        case match
    }
}

// For Update Person
public struct UpdatePersonPostBody: Codable {
    public var firstName: String?
    public var middleName: String?
    public var lastName: String?
    public var phone: String?
    public var code: String?
    public var dateOfBirth: String?
    public var idType: String?
    public var idNumber: String?
    public var email: String?
    public var address: Address?
}
