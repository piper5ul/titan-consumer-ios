//
//  BaseErrorLabel.swift
//  Solid
//
//  Created by Solid iOS Team on 26/05/21.
//

import Foundation
import UIKit

class BaseErrorLabel: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialise()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialise()
    }

    func initialise() {
        self.font = UIFont.sfProDisplayRegular(fontSize: 12)
        self.textColor = UIColor.redMain
        self.addConstraint(self.heightAnchor.constraint(equalToConstant: 12))
    }
}
