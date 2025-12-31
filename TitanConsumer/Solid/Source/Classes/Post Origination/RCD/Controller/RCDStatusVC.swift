//
//  RCDStatusVC.swift
//  Solid
//
//  Created by Solid iOS Team on 8/6/21
//

import UIKit
import SkeletonView

class RCDStatusVC: BaseVC {

    @IBOutlet weak var tblRCDStatus: UITableView!
    @IBOutlet weak var lblNoChecks: UILabel!

    var rcdStatusList = [ReceiveCheckResponseBody]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblNoChecks.textColor = UIColor.secondaryColorWithOpacity
    }
}

// MARK: - UI
extension RCDStatusVC {

    func setupInitialUI() {
        self.title = Utility.localizedString(forKey: "RCD_captureScreen_navTitle")

        lblNoChecks.isHidden = true
        lblNoChecks.text = Utility.localizedString(forKey: "RCD_no_check_found")
        lblNoChecks.font = UIFont.sfProDisplayMedium(fontSize: 16)
        lblNoChecks.textAlignment = .center
        lblNoChecks.textColor = UIColor.secondaryColorWithOpacity

        setNavigationBar()
        registerCell()
        getAllRCDStatus()
    }
}

// MARK: - Navigation
extension RCDStatusVC {

    func setNavigationBar() {
        self.isNavigationBarHidden = false
        addBackNavigationbarButton()
    }

    func gotoContactList() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ContactsListVC") as? ContactsListVC {
            vc.checkStatusType = .checkDeposit
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UITableView
extension RCDStatusVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        tblRCDStatus.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
		tblRCDStatus.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil), forCellReuseIdentifier: "SkeletonLoaderCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rcdStatusList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
            cell.selectionStyle = .none

            if let rowData = rcdStatusList[indexPath.row] as ReceiveCheckResponseBody? {
                cell.configureRCDStatusCell(forRow: rowData)
            }

            cell.imgVwSeparator.isHidden = indexPath.row == rcdStatusList.count - 1
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
}

// MARK: - API
extension RCDStatusVC {

    func getAllRCDStatus() {

        if let accountID = AppGlobalData.shared().accountData?.id {
			self.tblRCDStatus.showAnimatedGradientSkeleton()
            RCDCheckViewModel.shared.getAllReceiveCheck(accountId: accountID) { (response, errorMessage) in
				self.tblRCDStatus.hideSkeleton()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let list = response?.data {
                        self.rcdStatusList = list
                    }

                    self.lblNoChecks.isHidden = self.rcdStatusList.count > 0

                    self.tblRCDStatus.reloadData()
                }
            }
        }
    }
}

extension RCDStatusVC: SkeletonTableViewDataSource {
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
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.orientationChangedViewController(tableview: self.tblRCDStatus, with: coordinator)
	}
}
