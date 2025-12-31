//
//  OTPTextField.swift
//  Solid
//
//  Created by Solid iOS Team on 20/02/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class OTPTextField: AuthTextField {

    var onDelete:((_ field: OTPTextField) -> Void)?

    override func deleteBackward() {
        super.deleteBackward()
        onDelete?(self)
    }
}
