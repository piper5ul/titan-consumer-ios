//
//  BaseLabel.swift
//  Solid
//
//  Created by Solid iOS Team on 7/16/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit
import SkeletonView

class BaseLabel: UILabel {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialise()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialise()
	}
	
	func initialise() {
		self.isSkeletonable = true
	}

}
