//
//  InfoCardCell.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import Foundation
import UIKit

class InfoCardCell: UITableViewCell {
    @IBOutlet weak var vwCardFront: CardFrontView!
    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
		super.awakeFromNib()
    }

    func configureCard(frontData: CardModel) {
        vwCardFront.cardData = frontData
		vwCardFront.shouldShowCardStateStack = true
        vwCardFront.layoutIfNeeded()
    }
}
