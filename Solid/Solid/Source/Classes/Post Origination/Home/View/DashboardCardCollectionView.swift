//
//  DashboardCardCollectionView.swift
//  Solid
//

import Foundation
import UIKit
import SkeletonView

@objc protocol DashboardCardCollectionViewDelegate {
    @objc optional func dashboardCardClick (_ cardsArray: [Any], _ indexPathRow: Int)
    func dashboardAddCardClick()
    func dashboardCardSwitchClick(cardIndex: Int)
}

class DashboardCardCollectionView: UICollectionView {
	var allCards = [Any]()
	weak var dashboardCardCollectionViewDelegate: DashboardCardCollectionViewDelegate?

	public func setup() {

		registerCell()
		delegate = self
		dataSource = self
		self.isSkeletonable = true
		self.reloadCards()
	}

	func configure() {
		setup()
	}

	func registerCell() {
		self.register(UINib(nibName: "DashboardCardCollectionCell", bundle: nil), forCellWithReuseIdentifier: "DashboardCardCollectionCell")
        self.register(UINib(nibName: "DashboardEmptyCard", bundle: nil), forCellWithReuseIdentifier: "DashboardEmptyCard")
	}

}

// MARK: - API calls
extension DashboardCardCollectionView {
	func reloadCardsList() {
		self.reloadData()
		if AppGlobalData.shared().cardList.count == 0 {
			// self.isHidden = true
			// self.superview?.viewWithTag(1)?.isHidden = false
		}
	}

	func reloadCards() {
		self.reloadData()
	}
}
extension DashboardCardCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppGlobalData.shared().cardList.count > 0 ? AppGlobalData.shared().cardList.count + 1 : 1
		// return 6
	}

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = UICollectionViewCell()

        if indexPath.item == AppGlobalData.shared().cardList.count {
            if let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardEmptyCard", for: indexPath) as? DashboardEmptyCard {
                aCell.configureUI()
                aCell.btnCreateCard.addTarget(self, action: #selector(addCard), for: .touchUpInside)
                return aCell
            }
        } else if AppGlobalData.shared().cardList.count > 0 {

            if let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCardCollectionCell", for: indexPath) as? DashboardCardCollectionCell {
                let cardObject = AppGlobalData.shared().cardList[indexPath.row]
                aCell.configureCell(with: cardObject )
				aCell.cardFrontView.cellWidth.constant = 312
                aCell.cardFrontView.cellHeight.constant = 312/1.57
				aCell.cardFrontView.switchCardState.tag = indexPath.row
                aCell.cardFrontView.imgVwCard.contentMode = .scaleToFill
				aCell.cardFrontView.switchCardState.addTarget(self, action: #selector(cardStateChanged(sender:)), for: .valueChanged)
                return aCell
            }
        }
        return cell
    }

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width: CGFloat = 312
		if indexPath.item == AppGlobalData.shared().cardList.count {
			let height: CGFloat = 210
			return CGSize(width: width, height: height)
		} else {
			let height: CGFloat = 220
			return CGSize(width: width, height: height)
		}
	}

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.item == AppGlobalData.shared().cardList.count {
            addCard()
        } else if AppGlobalData.shared().cardList.count > 0 {
            cardClicked(for: indexPath.row)
        }
    }

    func cardClicked(for index: Int) {
        let selectedCard = AppGlobalData.shared().cardList[index] as CardModel
        AppGlobalData.shared().selectedCardModel = selectedCard
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.selectCardFromDashboard), object: nil)
    }

	@objc func cardClicked(sender: UIButton) {
		let itag = sender.tag
		let selectedCard = AppGlobalData.shared().cardList[itag] as CardModel

		AppGlobalData.shared().selectedCardModel = selectedCard
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.selectCardFromDashboard), object: nil)
	}

	@objc func btnActivateClick(sender: UIButton) {
		let itag = sender.tag
		let selectedCard = AppGlobalData.shared().cardList[itag] as CardModel

		AppGlobalData.shared().selectedCardModel = selectedCard
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.activateCardFromDashboard), object: nil)
	}

    @objc func addCard() {
        dashboardCardCollectionViewDelegate?.dashboardAddCardClick()
    }

    @objc func cardStateChanged(sender: UISwitch) {
        dashboardCardCollectionViewDelegate?.dashboardCardSwitchClick(cardIndex: sender.tag)
    }
	
}
extension DashboardCardCollectionView: SkeletonCollectionViewDataSource {
	
	func numSections(in collectionSkeletonView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let screenRectHeight = UIScreen.main.bounds.height
		return Int(screenRectHeight/78)
	}
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "AddAccountCollectionCell"
	}
}
