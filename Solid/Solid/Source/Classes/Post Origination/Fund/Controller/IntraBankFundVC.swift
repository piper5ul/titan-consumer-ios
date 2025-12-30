//
//  IntraBankFundVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import Foundation
import UIKit
import SkeletonView

class IntraBankFundVC: BaseVC {

    @IBOutlet weak var tblDetails: UITableView!
    var dataSource = [[ContactRowData]]()
    var arrSectionTitles: [String] = []
    var pushFundData = [ContactRowData]()

    var pullFundsFlow: PullFundsFlow? = .pullFundsIn

    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        arrSectionTitles = [Utility.localizedString(forKey: "fund_account_tittle")]
		setNavigationBar()
		setupInitialUI()
        setupInitialData()
        addObserverToReloadAccountSwitch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
		self.isNavigationBarTranslucent = false
    }

	func setNavigationBar() {
		self.isNavigationBarHidden = false
		addBackNavigationbarButton()
		self.title =  Utility.localizedString(forKey: "fund_account_tittle")
	}
    @objc override func backClick() {
        self.removeObserverOfReloadAccountSwitch()
        self.popVC()
    }

    func addObserverToReloadAccountSwitch() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAfterAccountSwitch), name: NSNotification.Name(rawValue: NotificationConstants.reloadAfterAccountSwitch), object: nil)
    }

    func removeObserverOfReloadAccountSwitch() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationConstants.reloadAfterAccountSwitch), object: nil)
    }

    @objc func reloadAfterAccountSwitch(notification: NSNotification) {
        setupInitialData()
    }
}

// MARK: - UI methods
extension IntraBankFundVC {

    func setupInitialUI() {
        registerCell()
        tblDetails.allowsSelection = true
	}

    func setupInitialData() {
        createTableData()
        createPushFundRowData()
        tblDetails.isHidden = false
        tblDetails.reloadData()
    }
}

// MARK: - Navigation
extension IntraBankFundVC {

    func goToPullFundsIn() {
        pullFundsFlow = .pullFundsIn
        self.performSegue(withIdentifier: "GoToLinkedAccounts", sender: self)
    }

    func goToDebitPull() {
         pullFundsFlow = .debitPull
         self.performSegue(withIdentifier: "GoToLinkedAccounts", sender: self)
     }
    
    func goToRCD() {
        self.performSegue(withIdentifier: "GoToRCDTypeVC", sender: self)
    }

    func goToPullFundsOut() {
        pullFundsFlow = .pullFundsOut
        self.performSegue(withIdentifier: "GoToLinkedAccounts", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? LinkedAccountsListVC {
            destinationVC.pullFundsFlow = self.pullFundsFlow
        }
    }
}

// MARK: - Set data
extension IntraBankFundVC {

    func createTableData() {

        dataSource = [[ContactRowData]]()

       let fundsInSection = createFundsInData()
       dataSource.append(fundsInSection)

        let fundsOutSection = createFundsOutData()
        dataSource.append(fundsOutSection)
    }

    func createFundsOutData() -> [ContactRowData] {

        var fundOutData = [ContactRowData]()

        // To another bank
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "move_fund_anotherBank_title")
        row1.value = Utility.localizedString(forKey: "move_fund_anotherBank_desc")
        row1.iconName = ""
        row1.cellType = .detail
        fundOutData.append(row1)

        return fundOutData
    }

    func createFundsInData() -> [ContactRowData] {

        var fundInData = [ContactRowData]()

        // Push funds
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "fund_row_title")
        row1.value = Utility.localizedString(forKey: "fund_desc_short")
        row1.iconName = ""
        fundInData.append(row1)

        // Pull funds
        if let isPullFundsEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isPullFundsEnabled, isPullFundsEnabled {
                var row2 = ContactRowData()
                row2.key = Utility.localizedString(forKey: "funds_pull_rowtitle")
                row2.value = Utility.localizedString(forKey: "pull_fund_desc_short")
                row2.iconName = ""
                row2.cellType = .detail
                fundInData.append(row2)
        }
        
        // Debit Pull..only for US country...
        if AppGlobalData.shared().personData.phone?.countryCode() == Constants.countryCodeUS {
            var row3 = ContactRowData()
            row3.key = Utility.localizedString(forKey: "funds_debitPull_rowtitle")
            row3.value = Utility.localizedString(forKey: "funds_debitPull_desc")
            row3.iconName = ""
            row3.cellType = .detail
            fundInData.append(row3)
        }
        
        // Check deposite
        if let isDepositCheckEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isDepositCheckEnabled, isDepositCheckEnabled {
                var row4 = ContactRowData()
                row4.key = Utility.localizedString(forKey: "RCD_depositCheck")
                row4.value = Utility.localizedString(forKey: "RCD_depositCheckDesc")
                row4.iconName = ""
                row4.cellType = .detail
                fundInData.append(row4)
        }
        
        return fundInData
    }

    func createPushFundRowData() {

         pushFundData = [ContactRowData]()

        // Account name
        var row11 = ContactRowData()
        var localizedStr = Utility.localizedString(forKey: "fund_transfer_title")
        let accountName = (AppGlobalData.shared().accountData?.label ?? "") as String
       // let appName = AppMetaDataHelper.shared.getAppName
        localizedStr = String(format: localizedStr, accountName)
        row11.key = localizedStr
        row11.value = Utility.localizedString(forKey: "fund_desc")
        row11.iconName = ""
        pushFundData.append(row11)

        // Account Number
        var row2 = ContactRowData()
        row2.key = Utility.localizedString(forKey: "acc_detail_num_title")
        if let accData = AppGlobalData.shared().accountData, let accNum = accData.accountNumber {
            row2.value = "\(accNum)"
        }
        pushFundData.append(row2)

        // Routing Number
        var row3 = ContactRowData()
        row3.key = Utility.localizedString(forKey: "acc_detail_rout_title")
        if let accData = AppGlobalData.shared().accountData, let routingNum = accData.routingNumber {
            row3.value = "\(routingNum)"
        }
        pushFundData.append(row3)

        // Account type
        var row4 = ContactRowData()
        row4.key = Utility.localizedString(forKey: "fund_type_row")
        if let accData = AppGlobalData.shared().accountData, let type = accData.type {
            row4.value = AccountType.title(for: type.rawValue) // "\(type.rawValue)"
        }
        pushFundData.append(row4)

        // Sponsor bank
        var row5 = ContactRowData()
        row5.key = Utility.localizedString(forKey: "fund_row_sponsorbank")
        if let accData = AppGlobalData.shared().accountData, let sBankName = accData.sponsorBankName {
            row5.value = "\(sBankName)"
        }
        pushFundData.append(row5)
    }
}

// MARK: - Tableview methdos
extension IntraBankFundVC: UITableViewDelegate, UITableViewDataSource, DataActionCellDelegate {

    func registerCell() {
        tblDetails.register(UINib(nibName: "FundCell", bundle: nil), forCellReuseIdentifier: "FundCell")
		tblDetails.register(UINib(nibName: "DataActionCell", bundle: .main), forCellReuseIdentifier: "DataActionCell")
		tblDetails.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
		return arrSectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FundCell", for: indexPath) as? FundCell {
                cell.configurePushFundCell(forRow: pushFundData)
				cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {

                let rowData = dataSource[indexPath.section][indexPath.row] as ContactRowData
                cell.configureFundCell(forRow: rowData)

                cell.selectionStyle = .none
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedType = dataSource[indexPath.section][indexPath.row].key {
            switch selectedType {
            case Utility.localizedString(forKey: "funds_pull_rowtitle"):
                self.goToPullFundsIn()
            case Utility.localizedString(forKey: "funds_debitPull_rowtitle"):
                self.goToDebitPull()
            case Utility.localizedString(forKey: "RCD_depositCheck"):
                self.goToRCD()
            default:
                break
            }
        }
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        var heightV: CGFloat = 85

        if indexPath.section == 0 && indexPath.row == 0 {
			 heightV = 300
		}

        return heightV
	}
}

extension IntraBankFundVC: SkeletonTableViewDataSource {
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
		return 1
	}
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let screenRectHeight = UIScreen.main.bounds.height
		return Int(screenRectHeight/78)
	}
}
