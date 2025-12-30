//
//  AuthLoginModel.swift
//  Solid
//
//  Created by Solid iOS Team on 2/8/21.
//

import Foundation

//for Auth0
public struct Auth0TokenModel: Codable {
    public var accessToken: String?
    public var refreshToken: String?
    public var idToken: String?
}

public struct AuthTokenModel: Codable {
    public var accessToken: String?
    public var refreshToken: String?
    public var idToken: String?
    public var scope: String?
    public var expiresIn: Int?
    public var refreshRequired: Bool?
}

public struct RegisterPostBody: Codable {
    public var clientId: String?
    public var idNumberLast4: String?
    public var refreshToken: String?
    public var idToken: String?
}

public struct LogoutPostBody: Codable {
	public var clientId: String?
	public var refreshToken: String?
	public var phone: String?
}
