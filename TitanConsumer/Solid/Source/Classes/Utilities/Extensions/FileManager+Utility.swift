//
//  FileManager+Utility.swift
//  Solid
//
//  Created by Solid on 23/02/22.
//  Copyright © 2022 Solid. All rights reserved.
//

import Foundation
extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                debugPrint("path: \(path)")
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
