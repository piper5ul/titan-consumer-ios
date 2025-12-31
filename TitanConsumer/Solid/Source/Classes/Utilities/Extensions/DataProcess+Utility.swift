//
//  DataProcess+Utility.swift
//  Solid
//
//  Created by Solid iOS Team on 22/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation

extension Encodable {
    var convertToDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        return json
    }
}
