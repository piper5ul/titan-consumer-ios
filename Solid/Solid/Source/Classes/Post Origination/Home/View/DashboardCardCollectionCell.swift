//
//  DashboardCardCollectionCell.swift
//  Solid
//

import UIKit

class DashboardCardCollectionCell: UICollectionViewCell {

    @IBOutlet weak var cardFrontView: CardFrontView!
    var isHeightCalculated: Bool = false

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

    func configureCell(with card: CardModel, shouldShowCardStatus: Bool? = false) {
		cardFrontView.shouldShowCardStateStack = true
        cardFrontView.cardData = card
	}
}
