//
//  ErrorObject.swift
//  Solid
//
//  Created by Solid iOS Team on 2/8/21.
//

import Foundation

class ErrorObject: Codable {
	let message: String
	let key: String?
	let sysMessage: String?
    let code: String?
    let statusCode: Int?
}
