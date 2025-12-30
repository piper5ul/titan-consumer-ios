//
//  PersonaModel.swift
//  Solid
//
//  Created by Solid iOS Team on 23/09/21.
//

import Foundation

public struct IdVerificationResponseBody: Codable {
    public var id: String?
    public var url: String?
    public var status: String?
    public var createdAt: String?
    public var modifiedAt: String?
}

public struct KYCStatusResponseBody: Codable {
    public var id: String?
    public var personId: String?
    public var status: KYCStatus?
    public var reviewMessage: String?
    public var createdAt: String?
    public var modifiedAt: String?
}
