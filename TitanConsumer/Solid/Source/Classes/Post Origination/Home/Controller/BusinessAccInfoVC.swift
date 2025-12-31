//
//  AccountDetailsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 01/03/21.
//

import Foundation
import UIKit
import SkeletonView

class BusinessAccInfoVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tConstTableView: NSLayoutConstraint!
	@IBOutlet weak var hConstTopContainerView: NSLayoutConstraint!    //Notes: Main Constraint for height
	@IBOutlet weak var topContainerView: UIView!
	
	var accountData: AccountDataModel?
	var accountActionData: AccountActionDataModel?
	var dataSource: [[AccountRowData]]?
	let dataHandler = AccountDataHandler()
	let defaultSectionHeight: CGFloat = 60.0
	public var isloading: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        addCustomNavigationBar()

		if let accId = AppGlobalData.shared().accountData?.id {
			callAPIGetAccountDetails(accId: accId)
		}
        
        tConstTableView.constant = Utility.getTopSpacing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.isNavigationBarTranslucent = true
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isNavigationBarTranslucent = false
    }
	
	override func rightButtonAction() {
		self.dismissController()
	}
}

//MARK:- Other methods
extension BusinessAccInfoVC {
    
    func createDataForAccInfo() {
        var infoSection = DashboardRowData()
        infoSection.key = ""
        infoSection.captionValue = ""
    }
	func generateTableViewData() {
		if let account = accountData {
			dataHandler.dataSource.removeAll()
			dataHandler.createDataSource(account)
			tableView.reloadData()
			tableView.layoutIfNeeded()
		}
	}
}

//MARK:- API calls
extension BusinessAccInfoVC {
    
    func callAPIGetAccountDetails(accId: String) {
		self.tableView.showAnimatedGradientSkeleton()

        AccountViewModel.shared.getaccountDetail(accountId: accId) { (accountDataModel, errorMessage) in
			self.isloading = true
			self.view.hideSkeleton()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
				self.accountData = accountDataModel
                
				self.generateTableViewData()
                self.tableView.reloadData()
            }
        }
    }
}

extension BusinessAccInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func registerCell() {
        tableView.register(UINib(nibName: "AccountInfoCell", bundle: nil), forCellReuseIdentifier: "AccountInfoCell")
        tableView.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
		tableView.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
        tableView.register(UINib(nibName: "DashboardSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "DashboardSectionHeaderView")
		tableView.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil), forCellReuseIdentifier: "SkeletonLoaderCell")

    }
	
    func numberOfSections(in tableView: UITableView) -> Int {
		return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
		let dataSource = dataHandler.dataSource
		return section < dataSource.count ? dataSource[section].count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
		if indexPath.section == 0 {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as? AccountInfoCell {
                if let aData = accountData {
                    cell.configureAccountInfoCell(forRow: aData)
                }
				cell.selectionStyle = .none
				return cell
			}
		} else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
                let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as AccountRowData
                cell.configureCell(forRow: rowData, hideSeparator: true)
                cell.selectionStyle = .none
                return cell
            }
        } else {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
				let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as AccountRowData
				cell.configureCell(forRow: rowData, hideSeparator: true)
				cell.selectionStyle = .none
				return cell
			}
		}
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		var heightV: CGFloat
		if !isloading {
			return Constants.skeletonCellHeight
		}

        if indexPath.section == 0 {
            heightV = 130
		} else if indexPath.section == 1 {
			heightV = 45
		} else {
            heightV = 64
        }
        
        return heightV
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DashboardSectionHeaderView") as? DashboardSectionHeaderView {
            
            headerView.rightTitleString = ""
            headerView.iconName = ""

            headerView.imgViewRightIcon.isHidden = true
            headerView.subTitleString = ""
            if section == 0 {
                headerView.titleString = accountData?.label ?? Utility.localizedString(forKey: "acc_info_primary_account")
            } else if section == 1 {

                headerView.titleString = Utility.localizedString(forKey: "acc_info_other_details")
            } else {
                headerView.titleString = Utility.localizedString(forKey: "acc_info_action_title")
            }
            headerView.btnViewAll.isHidden = true
            headerView.backgroundColor = .white
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
    
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                let storyboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "AccountStatementListVC") as? AccountStatementListVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 1:
                break
                //showDisclosures()
            default:
                break
            }
        }
    }
}

extension BusinessAccInfoVC: SkeletonTableViewDataSource {
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
		return 4
	}
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
        
    }
}
