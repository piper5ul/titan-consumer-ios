//
//  ListItems.swift
//  Solid
//
//  Created by Solid iOS Team on 15/02/21.
//

import Foundation

class ListItems: NSObject {
    var title: String?
    var id: String?
    var decimalPrecision: Int?

    init(title: String, id: String, decimalPoint: Int? = 6) {
        self.title  = title
        self.id     = id
        self.decimalPrecision = decimalPoint
    }
}
