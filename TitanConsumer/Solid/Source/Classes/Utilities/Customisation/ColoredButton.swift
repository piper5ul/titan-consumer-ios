//
//  ColoredButton.swift
//  Solid
//
//  Created by Solid iOS Team on 21/03/19.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class ColoredButton: BaseButton {

    override var isEnabled: Bool {
        didSet {
            setColor()
        }
    }
    
    func setColor() {
        backgroundColor = UIColor.ctaColor
        alpha = isEnabled ? 1.0 : 0.4
        setTitleColor(UIColor.ctaTextColor, for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColor()
    }
}
