//
//  DashboardCardsCell.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit

class DashboardCardsCell: UITableViewCell {
	@IBOutlet weak var cardCollection: DashboardCardCollectionView!
    func configureUI() {
		self.backgroundColor = .clear
		cardCollection.setup()
    }

}
