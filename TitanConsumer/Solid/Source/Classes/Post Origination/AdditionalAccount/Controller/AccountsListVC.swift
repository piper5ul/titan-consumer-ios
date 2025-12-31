//
//  AccountsListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 13/01/22.
//  Copyright © 2022 Solid. All rights reserved.
//

import UIKit
import LinkKit
import SkeletonView

class AccountsListVC: BaseVC {
    @IBOutlet weak var tblAccountsList: UITableView!
    
    var arrAccounts = [AccountDataModel]()
    
    let defaultRowHeight: CGFloat = 70.0
    
    var strSelectedBusinessName = ""
    var strSelectedBusinessID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        
        self.view.showAnimatedGradientSkeleton()
        
        tblAccountsList.backgroundColor = .clear
        
        getAccounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = false
        
        addBackNavigationbarButton()
        
        self.title = strSelectedBusinessName
    }
}

// MARK: - API Calls
extension AccountsListVC {
    func getAccounts() {
        self.view.showSkeleton()
        
        AccountViewModel.shared.getAccountList(businessId: strSelectedBusinessID) { (accountList, _) in
            self.arrAccounts = [AccountDataModel]()
            if let accListData = accountList?.data, accListData.count > 0 {
                if self.strSelectedBusinessID.isEmpty {
                    let personalAccList = accListData.filter({ $0.type == .personalChecking || ($0.type == .cardAccount && $0.businessId == "")})
                    
                    self.arrAccounts = personalAccList
                } else {
                    self.arrAccounts = accListData
                }
            }
            
            self.view.hideSkeleton()
            self.tblAccountsList.reloadData()
        }
    }
}

// MARK: - Tableview methods
extension AccountsListVC: UITableViewDelegate, UITableViewDataSource {
    func registerCell() {
        tblAccountsList.register(UINib(nibName: "DashboardCell", bundle: .main), forCellReuseIdentifier: "DashboardCell")
        tblAccountsList.register(UINib(nibName: "SkeletonLoaderAccountCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderAccountCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as? DashboardCell {
            let accountModel = arrAccounts[indexPath.row]
            cell.configureForAccounts(accountModel: accountModel)
            cell.indexPath = indexPath
            cell.selectionStyle = .none
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accountModel = arrAccounts[indexPath.row]
        if let allBusiness = AppGlobalData.shared().allBusiness {
            if let business = allBusiness.filter({ $0.legalName == strSelectedBusinessName}).first {
                AppGlobalData.shared().businessData = business
            } else {
                AppGlobalData.shared().businessData = allBusiness.first
            }
        }
        
        self.navigatetoCashDashboard()
        
        AppGlobalData.shared().accountData = accountModel
        AppGlobalData.shared().selectedAccountType = accountModel.type
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cheight    = Utility.isDeviceIpad() ? 84 : defaultRowHeight
        return cheight
    }
}

extension AccountsListVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "SkeletonLoaderAccountCell"
    }
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
}
