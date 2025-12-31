//
//  SendFundVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import Foundation
import UIKit
import SkeletonView

class SendFundVC: BaseVC {

    @IBOutlet weak var tblDetails: UITableView!
    var dataSource = [[ContactRowData]]()
    var arrSectionTitles: [String] = []
    var pushFundData = [ContactRowData]()
    var pullFundsFlow: PullFundsFlow? = .pullFundsIn
	var contactData: ContactDataModel? = ContactDataModel()
	var intraBankData: IntrabankAccount?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        arrSectionTitles = [Utility.localizedString(forKey: "move_fund_row_title")]
		setNavigationBar()
		setupInitialUI()
        setupInitialData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		self.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
    }

	func setNavigationBar() {
		self.isNavigationBarHidden = false
		addBackNavigationbarButton()
		self.title =  Utility.localizedString(forKey: "move_fund_row_title")
	}
	
    @objc override func backClick() {
        self.popVC()
    }
}

// MARK: - UI methods
extension SendFundVC {

    func setupInitialUI() {
        registerCell()
        tblDetails.allowsSelection = true
    }

    func setupInitialData() {
        createTableData()
        tblDetails.isHidden = false
        tblDetails.reloadData()
    }
}

// MARK: - Navigation
extension SendFundVC {
    func goToPullFundsOut() {
        pullFundsFlow = .pullFundsOut
        self.performSegue(withIdentifier: "GoToLinkedAccounts", sender: self)
    }
	
	func gotoContactList() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "ContactsListVC") as? ContactsListVC {
			//vc.checkStatusType = .checkDeposit
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	func goToIntrabankPaymentVC() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
		if let destinationVC = storyboard.instantiateViewController(withIdentifier: "IntrabankPaymentSelfVC") as? IntrabankPaymentSelfVC {
			self.contactData?.selectedPaymentMode = .intrabank
			destinationVC.contactData = self.contactData
			self.show(destinationVC, sender: self)
			self.modalPresentationStyle = .fullScreen
		}
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? LinkedAccountsListVC {
            destinationVC.pullFundsFlow = self.pullFundsFlow
        }
    }
}

// MARK: - Set data
extension SendFundVC {

    func createTableData() {
        dataSource = [[ContactRowData]]()
        let fundsOutSection = createFundsOutData()
        dataSource.append(fundsOutSection)
    }

    func createFundsOutData() -> [ContactRowData] {

        var fundOutData = [ContactRowData]()

		var row1 = ContactRowData()
		row1.key = Utility.localizedString(forKey: "move_fund_contact_title")
		row1.value = Utility.localizedString(forKey: "move_fund_contact_desc")
		row1.iconName = ""
		row1.cellType = .detail
		fundOutData.append(row1)
        
        // Intrabank Fund Transfer
        if let isIntrabankTransferEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isIntrabankTransferEnabled, isIntrabankTransferEnabled {
                var row2 = ContactRowData()
                row2.key = Utility.localizedString(forKey: "move_fund_intrabank_title")
                row2.value = Utility.localizedString(forKey: "move_fund_intrabank_desc")
                row2.iconName = ""
                row2.cellType = .detail
                fundOutData.append(row2)
        }
        
        // To another bank
        if let isToAnotherBankEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isToAnotherBankEnabled, isToAnotherBankEnabled {
                var row3 = ContactRowData()
                row3.key = Utility.localizedString(forKey: "move_fund_anotherBank_title")
                row3.value = Utility.localizedString(forKey: "move_fund_anotherBank_desc")
                row3.iconName = ""
                row3.cellType = .detail
                fundOutData.append(row3)
        }
		
        return fundOutData
    }
}

// MARK: - Tableview methdos
extension SendFundVC: UITableViewDelegate, UITableViewDataSource, DataActionCellDelegate {

    func registerCell() {
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
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
			
			let rowData = dataSource[indexPath.section][indexPath.row] as ContactRowData
			cell.configureFundCell(forRow: rowData)
			
			cell.selectionStyle = .none
			return cell
		}
		return UITableViewCell()
	}

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.0
    }
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedType = dataSource[indexPath.section][indexPath.row].key {
            switch selectedType {
            case Utility.localizedString(forKey: "move_fund_contact_title"):
                self.gotoContactList()
            case Utility.localizedString(forKey: "move_fund_intrabank_title"):
                self.goToIntrabankPaymentVC()
            case Utility.localizedString(forKey: "move_fund_anotherBank_title"):
                self.goToPullFundsOut()
            default:
                break
            }
        }
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightV: CGFloat = 85
        return heightV
	}
}

extension SendFundVC: SkeletonTableViewDataSource {
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
