//
//  DashboardContactCell.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit

class DashboardContactCell: UITableViewCell {
	@IBOutlet weak var contactCollection: DashboardContactCV!
    func configureUI() {
		self.backgroundColor = .clear
		contactCollection.setup()
    }
}
