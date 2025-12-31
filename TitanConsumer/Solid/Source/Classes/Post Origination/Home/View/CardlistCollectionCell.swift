//
//  DashboardCardCollectionCell.swift
//  Solid
//

import UIKit

class CardlistCollectionCell: UICollectionViewCell {

    @IBOutlet weak var cardFrontView: CardFrontView!
    @IBOutlet weak var lblBalanceTitle: UILabel!
    @IBOutlet weak var lblBalanceValue: UILabel!

    @IBOutlet weak var lblLabelTitle: UILabel!
    @IBOutlet weak var lblLabelValue: UILabel!

    @IBOutlet weak var lblSpendLimitTitle: UILabel!
    @IBOutlet weak var lblSpendLimitValue: UILabel!

    @IBOutlet weak var imgVseparator: UIImageView!
    @IBOutlet weak var imgHseparator: UIImageView!

    var isHeightCalculated: Bool = false

	override func awakeFromNib() {
		super.awakeFromNib()
        lblLabelTitle.text = Utility.localizedString(forKey: "label")
        lblSpendLimitTitle.text = Utility.localizedString(forKey: "card_spendLimit")
        imgVseparator.backgroundColor = UIColor.customSeparatorColor
        imgHseparator.backgroundColor = UIColor.customSeparatorColor

        lblLabelTitle.font = UIFont.sfProDisplayRegular(fontSize: 12)
        lblLabelValue.font = UIFont.sfProDisplayRegular(fontSize: 14)
        lblSpendLimitTitle.font = UIFont.sfProDisplayRegular(fontSize: 12)
        lblSpendLimitValue.font = UIFont.sfProDisplayRegular(fontSize: 14)
        
        lblLabelTitle.textColor = .secondaryColor
        lblSpendLimitTitle.textColor = .secondaryColor
        
        lblLabelValue.textColor = .primaryColor
        lblSpendLimitValue.textColor = .primaryColor
        self.contentView.cornerRadius = 4
        self.contentView.backgroundColor = .background
	}

    func configureCell(with card: CardModel, shouldShowCardStatus: Bool? = false) {
        cardFrontView.shouldShowCardStateStack = true
        cardFrontView.cardData = card
        lblLabelValue.text = card.label
        lblSpendLimitValue.text = Utility.localizedString(forKey: "currency") + (card.limitAmount ?? "0")
        debugPrint(card)
	}
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblLabelTitle.textColor = .secondaryColor
        lblSpendLimitTitle.textColor = .secondaryColor
        lblLabelValue.textColor = .primaryColor
        lblSpendLimitValue.textColor = .primaryColor
    }
}
