//
//  CardTypeSelectionVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/9/21.
//

import Foundation
import UIKit

class CardTypeSelectionVC: BaseVC {
	@IBOutlet weak var lblHeaderDesc: UILabel!
	let defaultSectionHeight: CGFloat = 50.0
	@IBOutlet weak var tableView: UITableView!
	var cardData: CardModel?
    var cardArray = [String]()

    override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		cardData = CardModel()
		setNavigationBar()
        setupData()
		registerCell()
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarHidden = false
    }
    
    func setupData() {
        if let physicalCardEnable = AppGlobalData.shared().accountData?.config?.card?.physicalCardSettings?.enabled, physicalCardEnable {
            cardArray.append(CardType.physical.rawValue)
        }
        
        if let virtualCardEnable = AppGlobalData.shared().accountData?.config?.card?.virtualCardSettings?.enabled, virtualCardEnable {
            cardArray.append(CardType.virtual.rawValue)
        }
    }
    
	func setNavigationBar() {
        addBackNavigationbarButton()

		self.title = Utility.localizedString(forKey: "cardType_title")
        self.isScreenModallyPresented = true
	}
    
    @objc override func backClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)
        self.popVC()
    }
}

extension CardTypeSelectionVC: UITableViewDelegate, UITableViewDataSource {

	func registerCell() {
		tableView.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
	}

	func numberOfSections(in tableView: UITableView) -> Int {
        return cardArray.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
                if cardArray[indexPath.section] == CardType.allValues[0].rawValue {
                    cell.configureCardTypeSelection(cardType: CardType.allValues[0].localizecardTypeDescription(), cardDesc: "")
                } else if cardArray[indexPath.section] == CardType.allValues[1].rawValue {
                    cell.configureCardTypeSelection(cardType: CardType.allValues[1].localizecardTypeDescription(), cardDesc: "")
                }
                
				return cell
			}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if cardArray[indexPath.section] == CardType.allValues[0].rawValue {
			cardData?.cardType = CardType.physical
		} else {
			cardData?.cardType = CardType.virtual
		}
		self.performSegue(withIdentifier: "ShowSpendLimit", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? CardLimitScreenVC {
			destinationVC.cardData = cardData
		}
	}

}
