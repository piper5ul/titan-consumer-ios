//
//  AppData.swift
//
//  Solid
//
//  Created by Solid iOS Team on 2/10/21.

import UIKit

class AppData {
	static let session  = SessionData()

	static func load() {
		session.load()
	}

    static func updateSession(idToken: String, accessToken: String, refreshToken: String) {
        session.idToken         = idToken
        session.accessToken     = accessToken
        session.refreshToken    = refreshToken
        session.store()
    }

	static func store() {
		session.store()
	}

	static func logout() {
		session.reset()
	}
}

class SessionData: Codable {
    var idToken: String?
    var accessToken: String?
    var refreshToken: String?
    var deviceId: String?
    var isLoggedIn  = false

    func store() {
        isLoggedIn = true
        let defaults = UserDefaults.standard
        defaults.synchronize()
    }

    func load() {
        _ = UserDefaults.standard
    }

    func reset() {
        idToken = nil
        accessToken = nil
        refreshToken = nil
        deviceId = nil
        isLoggedIn = false
    }
}
