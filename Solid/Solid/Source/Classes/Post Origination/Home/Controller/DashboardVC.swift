//
//  DashboardVC.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit
import SkeletonView

struct DashboardRowData {
	var key: String?
	var rows: [DashboardCellModel]?
	var captionValue: String?
}

class DashboardVC: BaseVC, HeaderViewAllDelegate, CellClickDelegate {
	@IBOutlet weak var tableView: DashboardTableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

	var data = [DashboardRowData]()
	var cardData: CardModel?

	let sectionHeight: CGFloat = 50.0
	let rowHeight: CGFloat = 113.0

    let dispatchGroup = DispatchGroup()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		addObservers()
        loadInitialData()
		self.tableView.backgroundColor = .clear
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.tableView.reloadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.isNavigationBarTranslucent = true
	}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
		self.view.hideSkeleton()
        self.isNavigationBarTranslucent = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }
}

// MARK: - Observer methods
extension DashboardVC {

	func addObservers() {
		addObserverToReloadAccounts()
        addObserverToReloadAccountSwitch()
		addObservingCardSelection()
        addObserverToReloadCardTransaction()
		addObserverToReloadContacts()
	}

    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadAccountsAfterAdding), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadAfterAccountSwitch), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterAdding), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.selectCardFromDashboard), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.selectContactFromDashboard), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.activateCardFromDashboard), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterStatusChange), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadCardTransaction), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterDelete), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil)
    }

	func addObserverToReloadAccounts() {
		NotificationCenter.default.addObserver(self, selector: #selector(reloadAccountsAfterAddingNew), name: NSNotification.Name(rawValue: NotificationConstants.reloadAccountsAfterAdding), object: nil)
	}

    func addObserverToReloadAccountSwitch() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterAccountSwitch), name: NSNotification.Name(rawValue: NotificationConstants.reloadAfterAccountSwitch), object: nil)
    }

	private func addObservingCardSelection() {
		NotificationCenter.default.addObserver(self, selector: #selector(getCardList), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterAdding), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(getCardList), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(gotoCardInfo), name: NSNotification.Name(rawValue: NotificationConstants.selectCardFromDashboard), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(gotoContactDetail), name: NSNotification.Name(rawValue: NotificationConstants.selectContactFromDashboard), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(goToActivateCard), name: NSNotification.Name(rawValue: NotificationConstants.activateCardFromDashboard), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(getCardList), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterStatusChange), object: nil)
	}

    func addObserverToReloadCardTransaction() {
        NotificationCenter.default.addObserver(self, selector: #selector(getTransactions), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardTransaction), object: nil)
    }
	
	func addObserverToReloadContacts() {
		NotificationCenter.default.addObserver(self, selector: #selector(getContactsList), name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(getContactsList), name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterDelete), object: nil)

	}
}

// MARK: - Reload
extension DashboardVC {

    func reloadCardListAfterFreezeUnfreeze() {
        self.getDashboardCardsList { (_, _) in
            self.tableView.configureData()
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .none)
        }
    }

    @objc func getCardList() {
        self.getDashboardCardsList { (_, _) in
            self.tableView.configureTableView()
            self.tableView.reloadData()
            
            //CHECK IF ANY CARD IS AVAILABLE OR NOT FOR THE SELECTED CARD ACCOUNT...
            //IF NOT THEN DISPLAY ALERT TO ADD THE CARD..
            self.showAlertOfNoCardAvailable()
        }
    }
	
	@objc func getContactsList() {
		self.getDashboardContactsList { (_, _) in
			self.tableView.configureTableView()
			self.tableView.reloadData()
		}
	}
	
    @objc func getTransactions() {
        if let accData = AppGlobalData.shared().accountData, let accId = accData.id {
            self.getDashboardTransactionList(strId: accId, queryString: "&limit=3") { (_, _) in
                self.tableView.configureTableView()
                self.tableView.reloadData()
            }
        }
    }

    func reloadCards() {
        dispatchGroup.enter()
        self.getDashboardCardsList { (_, _) in
            DispatchQueue.main.async {
                self.dispatchGroup.leave()
            }
            
            //CHECK IF ANY CARD IS AVAILABLE OR NOT FOR THE SELECTED CARD ACCOUNT...
            //IF NOT THEN DISPLAY ALERT TO ADD THE CARD..
            self.showAlertOfNoCardAvailable()
        }
    }
	
	func reloadContacts() {
		dispatchGroup.enter()
		self.getDashboardContactsList { (_, _) in
			DispatchQueue.main.async {
				self.dispatchGroup.leave()
			}
		}
	}
    
    func reloadAccountDetails() {
        dispatchGroup.enter()
        if let accData = AppGlobalData.shared().accountData, let accId = accData.id {
            AccountViewModel.shared.getaccountDetail(accountId: accId) { (accountDataModel, _) in

                if let _ = accountDataModel {
                    AppGlobalData.shared().accountData = accountDataModel
                    self.addCustomNavigationBar(backButtonImage: "home_icon")
                }
                DispatchQueue.main.async {
                    self.dispatchGroup.leave()
                }
            }
        }
    }

    func reloadTransactions() {
        dispatchGroup.enter()
        if let accData = AppGlobalData.shared().accountData, let accId = accData.id {
            self.getDashboardTransactionList(strId: accId, queryString: "&limit=3") { (_, _) in
                DispatchQueue.main.async {
                    self.dispatchGroup.leave()
                }
            }
        }
    }

    @objc func reloadAccountsAfterAddingNew(notification: NSNotification) {
		self.tableView.showAnimatedGradientSkeleton()
        self.tableView.reloadAccountData()
        getTransactions()
        getCardList()
		getContactsList()
		//self.view.hideSkeleton()
		self.tableView.hideSkeleton()
    }

    @objc func reloadAfterAccountSwitch(notification: NSNotification) {
        self.refreshAfterAccountSwitch()
    }
}

// MARK: - UI Methods
extension DashboardVC {

	func setupUI() {
        addCustomNavigationBar(backButtonImage: "home_icon")
        self.navigationItem.leftBarButtonItem = nil

        tableViewTopConstraint.constant = Utility.getTopSpacing()
        
		tableView.viewAllDelegate = self
		tableView.cellClickDelegate = self
		tableView.configureTableView()

        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(pullToRefresh(_:)), for: UIControl.Event.valueChanged)
        rc.tintColor = .primaryColor
        self.tableView.refreshControl = rc
    }

    @objc override func backClick() {
        self.removeObservers()
        self.popVC()
    }

    @objc func pullToRefresh(_ sender: Any?) {
        self.reloadAccountDetails()
        self.reloadTransactions()
        self.reloadCards()

        dispatchGroup.notify(queue: .main) {
            self.tableView.configureData()
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    func refreshAfterAccountSwitch() {
		AppGlobalData.shared().transactionList.removeAll()
		AppGlobalData.shared().cardList.removeAll()
		self.tableView.configureData()
		self.tableView.reloadData()
        self.reloadTransactions()
        self.reloadCards()
		
        dispatchGroup.notify(queue: .main) {
            self.tableView.configureData()
            self.tableView.reloadData()
        }
    }

    func callCardAndTransactionAPIs() {
		self.tableView.showAnimatedGradientSkeleton()
        self.reloadTransactions()
        self.reloadCards()
		self.reloadContacts()
		
        dispatchGroup.notify(queue: .main) {
			self.tableView.hideSkeleton()
            self.tableView.configureData()
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    //FOR THE CARD ACCOUNT TYPE...
    func showAlertOfNoCardAvailable() {
        if AppGlobalData.shared().selectedAccountType == .cardAccount && AppGlobalData.shared().cardList.count == 0 {
            let strMesssage = Utility.localizedString(forKey: "cardAccount_noCardAvailable_alertMsg")
            let createBtn = Utility.localizedString(forKey: "card_add_label").uppercased()
            let cancelBtn = Utility.localizedString(forKey: "cancel")
            alert(src: self, "", strMesssage, createBtn, cancelBtn) { (button: Int) in
                if button == 1 {
                    self.dashboardAddCardClick()
                } else {
                    self.popVC()
                }
            }
        }
    }
}

// MARK: - Other methods
extension DashboardVC {

    func loadInitialData() {
        callCardAndTransactionAPIs()
    }
}

// MARK: - Navigation
extension DashboardVC {

	func gotoAccountsList() {
		self.performSegue(withIdentifier: "GoToBankAccList", sender: self)
	}

	func gotoContactsList() {
		self.performSegue(withIdentifier: "GoToContactsListVC", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? ContactsListVC {
			destinationVC.checkStatusType = .unknown
		}
	}

	func showAccountDetails() {
        Segment.addSegmentEvent(name: .homeAccountDetails)
		self.performSegue(withIdentifier: "presentAccountInfo", sender: self)
	}

	func goToTransactionList() {
		self.performSegue(withIdentifier: "GoToTransactionList", sender: self)
	}
}

// MARK: - View All Delegate
extension DashboardVC {

	func viewAllClicked(_ type: String, section: Int) {

		if type == "ACCOUNTS" {
            Segment.addSegmentEvent(name: .homeViewAllAccounts)
			gotoAccountsList()
		} else if type == "TRANSACTION" {
            Segment.addSegmentEvent(name: .homeViewAllTransactions)
			goToTransactionList()
		} else if type == "CARDLIST" {
			goToCards()
		} else if type == "CREATECARD" {
			goToCreateCard()
		} else if type == "CONTACTLIST" {
            Segment.addSegmentEvent(name: .homeViewAllContacts)
			gotoContactsList()
		}
	}
}

// MARK: - Cell Click Delegate
extension DashboardVC {

	func cellClicked(_ type: String, indexPath: IndexPath) {
        if type == "PAY" {
            Segment.addSegmentEvent(name: .homePay)
			sendMoneyClicked()
        } else if type == "TRANSACTION" {
            Segment.addSegmentEvent(name: .homeTransactionsDetails)
            gotoTransactionDetails(indexPath: indexPath)
        }
	}

    func gotoTransactionDetails(indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Transaction", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TransactionDetailsVC") as? TransactionDetailsVC {
            AppGlobalData.shared().selectedTransaction =  AppGlobalData.shared().transactionList[indexPath.row]
            self.show(vc, sender: self)
        }
    }

	func fundClicked() {
        Segment.addSegmentEvent(name: .homeFund)
		self.performSegue(withIdentifier: "GotoIntraFundScreen", sender: self)
		self.modalPresentationStyle = .fullScreen
	}
	
	func sendMoneyClicked() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Funds", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "SendFundVC") as? SendFundVC {			
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}

	func goToCards() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "CardsListVC") as? CardsListVC {
			self.show(vc, sender: self)
		}
	}

	func goToCreateCard() {
		BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
			if shouldMoveAhead {
				// Handle success code here
				let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
				if let vc = storyboard.instantiateViewController(withIdentifier: "CardTypeSelectionVC") as? CardTypeSelectionVC {
                    self.navigationController?.pushViewController(vc, animated: true)
				}
			}
		}
	}

	@objc func goToActivateCard() {
		BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
			if shouldMoveAhead {
				let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
				if let vc = storyboard.instantiateViewController(withIdentifier: "CardActivationVC") as? CardActivationVC {
					vc.cardData = AppGlobalData.shared().selectedCardModel
                    self.navigationController?.pushViewController(vc, animated: true)
				}
			} else {
                self.tableView.configureTableView()
                self.tableView.reloadData()
            }
		}
	}

	func buttonViewAccountClicked(strType: String) {
		showAccountDetails()
	}

}

// MARK: - UITextFieldDelegate methods
extension DashboardVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

// MARK: - DashboardCardCollectionViewDelegate methods
extension DashboardVC: DashboardCardCollectionViewDelegate {

	func dashboardCardClick (_ cardsArray: [Any], _ indexPathRow: Int) {
		self.cardData = AppGlobalData.shared().cardList[indexPathRow]
		self.gotoCardInfo()
	}
	
	func dashboardContactClick (_ contactArray: [Any], _ indexPathRow: Int) {
		self.gotoContactDetail()
	}

	@objc func gotoContactDetail() {
		let storyboard = UIStoryboard.init(name: "Contact", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "ContactInfoVC") as? ContactInfoVC {
			vc.contactData = AppGlobalData.shared().selectedContactModel
			self.show(vc, sender: self)
		}
	}
	
	@objc func gotoCardInfo() {

        let selectedCard = AppGlobalData.shared().selectedCardModel

        if selectedCard?.cardStatus ==  CardStatus.pendingActivation {
            goToActivateCard()
        } else {
            Segment.addSegmentEvent(name: .homeCardDetails)

            BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
                if shouldMoveAhead {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "CardInfoVC") as? CardInfoVC {
                        vc.cardModel = AppGlobalData.shared().selectedCardModel
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
	}

    func dashboardAddCardClick() {
        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "CardTypeSelectionVC") as? CardTypeSelectionVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

    func dashboardCardSwitchClick(cardIndex: Int) {
        let selectedCard = AppGlobalData.shared().cardList[cardIndex]
		AppGlobalData.shared().selectedCardModel = selectedCard
        if selectedCard.cardStatus ==  CardStatus.pendingActivation {
            goToActivateCard()
        } else {
            showAlertForAction(selectedCard: selectedCard)
        }
    }

    func showAlertForAction(selectedCard: CardModel) {
        let title = (selectedCard.cardStatus == CardStatus.inactive) ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_title") : Utility.localizedString(forKey: "cardInfo_freeze_alert_title")
        let message = (selectedCard.cardStatus == CardStatus.inactive) ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_messsage") : Utility.localizedString(forKey: "cardInfo_freeze_alert_messsage")
        let freezeBtn = (selectedCard.cardStatus == CardStatus.inactive) ? Utility.localizedString(forKey: "cardInfo_unfreeze_button") : Utility.localizedString(forKey: "cardInfo_freeze_button")
        let cancelBtn = Utility.localizedString(forKey: "cancel")
        alert(src: self, title, message, freezeBtn, cancelBtn) { (button: Int) in
            if button == 1 {
                let aStatus = (selectedCard.cardStatus == CardStatus.inactive) ? CardStatus.active : CardStatus.inactive
                self.callAPIToFreezeCard(status: aStatus, selectedCard: selectedCard)
            } else {
                self.tableView.configureTableView()
                self.tableView.reloadData()
            }
        }
    }

    func callAPIToFreezeCard(status: CardStatus, selectedCard: CardModel) {
        if let cardId = selectedCard.id {
            var requestBody = CardUpdateRequestBody()
            requestBody.cardStatus = status

            CardViewModel.shared.updateCard(cardID: cardId, contactData: requestBody) { (response, errorMessage) in
				self.view.hideSkeleton()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        self.reloadCardListAfterFreezeUnfreeze()
                    }
                }
            }
        }
    }
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		let animationHandler: ((UIViewControllerTransitionCoordinatorContext) -> Void) = { [weak self] (_) in
			self?.tableView.reloadData()
		}
		
		let completionHandler: ((UIViewControllerTransitionCoordinatorContext) -> Void) = { [weak self] (_) in
			self?.tableView.reloadData()
		}
		coordinator.animate(alongsideTransition: animationHandler, completion: completionHandler)
	}
}
