//
//  DashboardTableVC.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import Foundation
import UIKit
import SkeletonView

// MARK: - VIEW ALL DELEGATE
protocol HeaderViewAllDelegate: AnyObject {
    func viewAllClicked (_ type: String, section: Int)

}

// MARK: - CELL CLICK DELEGATE
protocol CellClickDelegate: AnyObject {
    func cellClicked (_ type: String, indexPath: IndexPath)
    func fundClicked()
	func sendMoneyClicked()
    func showAccountDetails()
    func buttonViewAccountClicked(strType: String)
    func dashboardAddCardClick()
    func dashboardCardSwitchClick(cardIndex: Int)
}

class DashboardTableView: UITableView, DashboardCardCollectionViewDelegate {
    var data = [DashboardRowData]()
    let defaultSectionHeight: CGFloat = 40.0
	let defaultRowHeight: CGFloat = Utility.isDeviceIpad() ? 84 : 75
    let cardRowHeight: CGFloat = 208.0
	let contactRowHeight: CGFloat = 108.0
	//let contactRowHeight: CGFloat = Utility.isDeviceIpad() ? 128 : 108.0
    weak var viewAllDelegate: HeaderViewAllDelegate?
    weak var cellClickDelegate: CellClickDelegate?
}

// MARK: - Other methods
extension DashboardTableView {

    func configureTableView() {
        self.delegate = self
        self.dataSource = self
        registerCell()
		self.isSkeletonable = true
        configureData()
    }

    func reloadAccountData() {
        let accountRowData = configureAccountData()
        data[0] = accountRowData

        DispatchQueue.main.async {
            self.beginUpdates()
            self.reloadSections(IndexSet(integersIn: 0...0), with: .none)
            self.endUpdates()
     }
//        self.reloadData()
    }

    @objc func btnViewAllClicked(sender: UIButton) {

        let items = data[sender.tag]
        if items.key == "Transactions" && AppGlobalData.shared().transactionList.count > 0 {
            viewAllDelegate?.viewAllClicked("TRANSACTION", section: sender.tag)
        } else if items.key == "Cards" && AppGlobalData.shared().cardList.count > 0 {
            viewAllDelegate?.viewAllClicked("CARDLIST", section: sender.tag)
        } else if items.key == "Contacts" && AppGlobalData.shared().contactList.count > 0 {
			viewAllDelegate?.viewAllClicked("CONTACTLIST", section: sender.tag)
		} else {
            if sender.tag == 0 { //ACCOUNTS VIEW ALL..
                viewAllDelegate?.viewAllClicked("ACCOUNTS", section: sender.tag)
            }
        }
    }

    @objc func btnCreateCardClick(sender: UIButton) {
        if sender.tag == 100 {
            viewAllDelegate?.viewAllClicked("CREATECARD", section: sender.tag)
        }
    }

    func dashboardAddCardClick() {
        cellClickDelegate?.dashboardAddCardClick()
    }

    func dashboardCardSwitchClick(cardIndex: Int) {
        cellClickDelegate?.dashboardCardSwitchClick(cardIndex: cardIndex)
    }
}

// MARK: - Data creation methods
extension DashboardTableView {
	
    func configureData() {
        configureDashboardData()
    }
	
	func configureDashboardData() {
        data = [DashboardRowData]()

        let accountRowData = configureAccountData()
        data.append(accountRowData)
        
        if AppGlobalData.shared().selectedAccountType != .cardAccount {
            let accountRowData1 = configureMoveMoneyData()
            data.append(accountRowData1)
            
            if AppGlobalData.shared().contactList.count > 0 {
                let contactRowData = configureContactData()
                data.append(contactRowData)
            }
        }
        
        let txnRowData = configureTransactionData()
        data.append(txnRowData)
        
        configureCardData()
    }
    
    func configureAccountData() -> DashboardRowData {
        if let accoutRows = createAccountRows(), accoutRows.count > 0 {
            var rowData = DashboardRowData()
            if let account = AppGlobalData.shared().accountData, let accLabel = account.label {
                let accTitle = Utility.localizedString(forKey: "dashboard_section_account")
                rowData.key = "\(accLabel) \(accTitle)"
            } else {
                rowData.key = DashboardSectionEnums.accounts.localizedString
            }

            rowData.rows = accoutRows
            return rowData
        }

        return DashboardRowData()
    }

	func configureMoveMoneyData() -> DashboardRowData {
		if let accoutRows = createMoveMoneyRows(), accoutRows.count > 0 {
			var rowData = DashboardRowData()
				rowData.key = DashboardSectionEnums.movemoney.localizedString
			rowData.rows = accoutRows
			return rowData
		}
		return DashboardRowData()
	}
	
	func configureContactData() -> DashboardRowData {
		if let contactRows = createContactRows(), contactRows.count > 0 {
			var rowData = DashboardRowData()
			rowData.key = DashboardSectionEnums.contacts.localizedString
			rowData.rows = contactRows
			return rowData
		}
		return DashboardRowData()
	}
	
    func configureTransactionData() -> DashboardRowData {

        if let txnRows = createTransactionRows(), txnRows.count > 0 {
            var rowData = DashboardRowData()
            rowData.key = DashboardSectionEnums.transactions.localizedString
            rowData.rows = txnRows
            rowData.captionValue = ""
            return rowData
        }
        return DashboardRowData()
    }

    func configureCardData() {
        if let cardRows = createCardRows(), cardRows.count > 0 {
            var rowData = DashboardRowData()
            rowData.key = DashboardSectionEnums.cards.localizedString
            rowData.rows = cardRows
            data.append(rowData)
        }
    }

    func createAccountRows() -> [DashboardCellModel]? {

        var rows = [DashboardCellModel]()

        if let account = AppGlobalData.shared().accountData {

            let balanceModel = DashboardCellModel()

            balanceModel.titleValue = account.label

            if let balance = account.availableBalance {
                balanceModel.descriptionValue2 = Utility.getFormattedAmount(amount: balance)
            }
            let accNoString = Utility.localizedString(forKey: "dashboard_accNo_title")
            balanceModel.descriptionValue = "\(accNoString) \(account.accountNumber!)"

            balanceModel.sectionName = DashboardSectionEnums.accounts.localizedString
            balanceModel.cellType = .imageAccessory
            rows.append(balanceModel)
        }
        return rows
    }

    func createMoveMoneyRows() -> [DashboardCellModel]? {
        var rows = [DashboardCellModel]()
        
        let fundModel = DashboardCellModel()
        fundModel.titleValue = Utility.localizedString(forKey: "dashboard_row_fund_title")
        var fundlocalizedStr = Utility.localizedString(forKey: "dashboard_row_fund_desc")
        if let accountName = AppGlobalData.shared().accountData?.label {
            fundlocalizedStr = String(format: fundlocalizedStr, accountName)
        }
        fundModel.descriptionValue = fundlocalizedStr
        fundModel.sectionName = nil
        fundModel.cellType = .imageAccessory
        rows.append(fundModel)
        
        let payModel = DashboardCellModel()
        payModel.titleValue = Utility.localizedString(forKey: "dashboard_row_pay_title")
        var paylocalizedStr = Utility.localizedString(forKey: "dashboard_row_pay_desc")
        let accountName = AppGlobalData.shared().accountData?.label
        paylocalizedStr = String(format: paylocalizedStr, accountName!)
        payModel.descriptionValue = paylocalizedStr
        payModel.sectionName = nil
        payModel.cellType = .imageAccessory
        rows.append(payModel)
        
        return rows
    }

    func createTransactionRows() -> [DashboardCellModel]? {
        if AppGlobalData.shared().transactionList.count > 0 {

            var arrTxnModel = [DashboardCellModel]()

            for _ in AppGlobalData.shared().transactionList {
                let txnModel = DashboardCellModel()
                txnModel.titleValue = ""
                txnModel.descriptionValue = Date().convertDateTo(format: "dd MMM yyyy, HH:mm a")
                txnModel.sectionName = DashboardSectionEnums.transactions.localizedString
                txnModel.cellType = .labelAccessory
                arrTxnModel.append(txnModel)
            }
            return arrTxnModel
        } else {
            let txnModel = DashboardCellModel()
            txnModel.titleValue = ""
            txnModel.descriptionValue = Date().convertDateTo(format: "dd MMM yyyy, HH:mm a")
            txnModel.sectionName = DashboardSectionEnums.transactions.localizedString
            txnModel.cellType = .labelAccessory
            return [txnModel]
        }
    }

    func createCardRows() -> [DashboardCellModel]? {
        let txnModel = DashboardCellModel()
        txnModel.titleValue = ""
        txnModel.sectionName = DashboardSectionEnums.cards.localizedString
        return [txnModel]
    }
	
	func createContactRows() -> [DashboardCellModel]? {
		let txnModel = DashboardCellModel()
		txnModel.titleValue = ""
		txnModel.sectionName = DashboardSectionEnums.contacts.localizedString
		return [txnModel]
	}
}

// MARK: - DashboardCellDelegate methods
extension DashboardTableView: DashboardCellDelegate {

    func buttonViewAccountClicked(strType: String) {
        cellClickDelegate?.buttonViewAccountClicked(strType: strType)
    }
}

// MARK: - Tableview methods
extension DashboardTableView: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        self.register(UINib(nibName: "DashboardCell", bundle: nil), forCellReuseIdentifier: "DashboardCell")
        self.register(UINib(nibName: "DashboardEmptyCard", bundle: nil), forCellReuseIdentifier: "DashboardEmptyCard")
        self.register(UINib(nibName: "DashboardSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "DashboardSectionHeaderView")
		self.register(UINib(nibName: "DashboardCardsCell", bundle: nil), forCellReuseIdentifier: "DashboardCardsCell")
        self.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        self.register(UINib(nibName: "DashboardAccountCell", bundle: nil), forCellReuseIdentifier: "DashboardAccountCell")
		self.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil), forCellReuseIdentifier: "SkeletonLoaderCell")
		self.register(UINib(nibName: "DashboardContactCell", bundle: nil), forCellReuseIdentifier: "DashboardContactCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = data[section]
        if let rows = items.rows, rows.count > 0 {
            return rows.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = data[indexPath.section]
        if items.key == DashboardSectionEnums.cards.localizedString, let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCardsCell", for: indexPath) as? DashboardCardsCell {
                cell.configureUI()
                cell.cardCollection.dashboardCardCollectionViewDelegate = self
                cell.selectionStyle = .none
                return cell
		} else if items.key == DashboardSectionEnums.contacts.localizedString {
			if AppGlobalData.shared().contactList.count > 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardContactCell", for: indexPath) as! DashboardContactCell
				cell.configureUI()
				cell.selectionStyle = .none
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
				let rowData = TransactionModel()
				cell.configureEmptyContactCell(forRow: rowData, hideSeparator: true)
				cell.selectionStyle = .none
				return cell
			}
			
		} else if items.key == DashboardSectionEnums.transactions.localizedString, let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
                cell.selectionStyle = .none
				if AppGlobalData.shared().transactionList.count > indexPath.row {
                    let rowData = AppGlobalData.shared().transactionList[indexPath.row]
                    let shouldHide = indexPath.row >= (AppGlobalData.shared().transactionList.count-1)
                    cell.configureTransactionCell(forRow: rowData, hideSeparator: shouldHide)
                } else {
                    let rowData = TransactionModel()
                    cell.configureTransactionCell(forRow: rowData, hideSeparator: true)
                }
			    self.separatorStyle = .none
                return cell
            
        } else {
            if let rows = items.rows, rows.count > 0 {

                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardAccountCell", for: indexPath) as! DashboardAccountCell
                    cell.configure(withModel: rows[indexPath.row])
                    cell.dashboardCellDelegate = self
                    cell.selectionStyle = .none

                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as! DashboardCell
                    cell.configure(withModel: rows[indexPath.row])
                    cell.titleLabel.textColor = .primaryColor
                    cell.descriptionLabel.textColor = .secondaryColor
                    cell.imgVwAccesory.customTintColor = .primaryColor
					cell.topConstForMainStackView.constant = 5
					cell.bottomConstForMainStackView.constant = 5
                    cell.indexPath = indexPath
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //NOTE : THIS IS TEMPORARY CONDITION TO NAVIGATE TO CONTACT LIST ON CLICK OF PAY.
        //REMOVE IT AND ADD PROPER NAVIGATION CONDTION..
		let items = data[indexPath.section]
		if indexPath.section == 0 {
			cellClickDelegate?.buttonViewAccountClicked(strType: "ACCOUNT_DETAILS")
			return
		}
		if items.key == DashboardSectionEnums.cards.localizedString  || items.key == DashboardSectionEnums.contacts.localizedString {
			//cellClickDelegate?.cellClicked("CARDLIST", indexPath: indexPath)
		} else if items.key == DashboardSectionEnums.transactions.localizedString {
            if AppGlobalData.shared().transactionList.count > indexPath.row {
                cellClickDelegate?.cellClicked("TRANSACTION", indexPath: indexPath)
            }
		} else {
			switch indexPath.row {
				case 0:
					cellClickDelegate?.fundClicked()
				case 1:
					cellClickDelegate?.cellClicked("PAY", indexPath: indexPath)
				default:
					break
			}
		}
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items = data[indexPath.section]
		
		if items.key == DashboardSectionEnums.contacts.localizedString {
			if AppGlobalData.shared().contactList.count == 0 {
				return 68.0
			} else {
				return self.contactRowHeight
			}
		}

		if items.key == DashboardSectionEnums.cards.localizedString {
            return self.cardRowHeight
        }
		
		if items.key == DashboardSectionEnums.transactions.localizedString {
			if AppGlobalData.shared().transactionList.count == 0 {
				return 68.0
			} else {
				return 85.33
			}
		}
        return self.defaultRowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		var aSectionHeight: CGFloat = defaultSectionHeight

        let items = data[section]
		if items.key == DashboardSectionEnums.cards.localizedString  || section == 3 {
			aSectionHeight += 0
		}
		
		if let captionTitle = items.captionValue, !captionTitle.isEmpty {
            aSectionHeight += 0
        }

		if section == 0 {
            aSectionHeight = 20
		}

        return aSectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let items = data[section]
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DashboardSectionHeaderView") as? DashboardSectionHeaderView {
            headerView.isSkeletonable = false
			var shouldHideRightButton: Bool = false
            
            headerView.rightTitleString = Utility.localizedString(forKey: "dashboard_section_viewAll")
            headerView.iconName = "Chevron-right"
            headerView.imgViewRightIcon.customTintColor = UIColor.secondaryColorWithOpacity

            headerView.titleString = data[section].key ?? ""
            headerView.imgViewRightIcon.isHidden = false
            headerView.subTitleString = ""

            headerView.btnViewAll.tag = section

			if items.key == "Move Money" || section == 0 {
				shouldHideRightButton = true
				if section == 0 {
					headerView.titleString = ""
				}
			} else if items.key == "Transactions" && AppGlobalData.shared().transactionList.count == 0 {
				shouldHideRightButton = true
			} else if items.key == "Cards" && AppGlobalData.shared().cardList.count == 0 {
				shouldHideRightButton = true
			} else if items.key == "Contacts" && AppGlobalData.shared().contactList.count == 0 {
				shouldHideRightButton = true
			}
            
			if shouldHideRightButton {
				headerView.rightTitleString = ""
				headerView.imgViewRightIcon.isHidden = true
            }
            
            headerView.btnViewAll.isHidden = shouldHideRightButton
            headerView.bringSubviewToFront(headerView.btnViewAll)
            headerView.btnViewAll.addTarget(self, action: #selector(btnViewAllClicked(sender:)), for: .touchUpInside)
            headerView.backgroundColor = .clear
            return headerView
        }

        return nil
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 2 {
            tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
        }
    }
}

extension DashboardTableView: SkeletonTableViewDataSource {
	
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
        return data.count
	}
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
	}
}
