//
//  BankAccListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 23/02/21.
//

import Foundation
import UIKit
import LinkKit
import SkeletonView

class BankAccListVC: BaseVC {
    @IBOutlet weak var tblVwBankAcc: UITableView!
    @IBOutlet weak var btnAddAccount: ColoredButton!
    @IBOutlet weak var buttonViewHeightConst: NSLayoutConstraint!

    @IBOutlet weak var lblNoAccount: UILabel!
    @IBOutlet weak var emptyAccountView: UIView!
    
    let defaultRowHeight: CGFloat = 70.0
    let defaultSectionHeight: CGFloat = 30.0
    let dispatchGroup = DispatchGroup()
    
    var initialAccountsCount = 2
    
    var arrGroupedAccounts = [AccountsGroup]()
    var arrBankAccounts = [AccountDataModel]()

    var strSelectedBusienssName = ""
    var strSelectedBusienssID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationBar()
        registerCell()
        self.view.showAnimatedGradientSkeleton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.isNavigationBarTranslucent = true
        
        setPin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isNavigationBarTranslucent = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tblVwBankAcc.reloadData()
    }
   
    @IBAction func btnAddAccountClicked(sender: UIButton) {
        self.performSegue(withIdentifier: "GoToSelectAccountVC", sender: self)
    }
}

// MARK: - UI Methods
extension BankAccListVC {

    func setNavigationBar() {
        addCustomNavigationBar(havingLogoOnly: true, havingBackButton: false)
    }

    func setupUI() {
        //For floating tableview header
        let dummyViewHeight = CGFloat(defaultSectionHeight)
        self.tblVwBankAcc.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: (self.tblVwBankAcc.bounds.size.width), height: dummyViewHeight))
        self.tblVwBankAcc.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        let labelButtonFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        lblNoAccount.text = Utility.localizedString(forKey: "no_account_text")
        
        lblNoAccount.font = labelButtonFont
        lblNoAccount.textColor = UIColor.secondaryColorWithOpacity
        btnAddAccount.setTitle(Utility.localizedString(forKey: "buttn_addAccount"), for: .normal)
       
        emptyAccountView.isHidden = true
    }
    
    func setupButtonUI() {
        btnAddAccount.isHidden = true
        btnAddAccount.isEnabled = true
        buttonViewHeightConst.constant = 50

        if !AppGlobalData.shared().isMaxCashAccontLimitReached() {
            btnAddAccount.isHidden = false
        } else {
            buttonViewHeightConst.constant = 0
        }
    }
}

// MARK: - Other methods
extension BankAccListVC {
    func setPin() {
        if !BiometricHelper.devicePasscodeEnabled() {
            let storedPin = Security.fetchPin()
            if storedPin == nil {
                let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                autolockVC = storyboard.instantiateViewController(withIdentifier: "PinVC") as? PinVC
                let navController = UINavigationController(rootViewController: autolockVC!)
                if !Security.hasPin() {
                    // completion(false)
                    autolockVC?.context = .creatPin
                    self.present(navController, animated: true, completion: nil)
                    autolockVC?.onPinSuccess = {
                        AppGlobalData.shared().storeSessionData()
                        self.getBusinessList()
                    }
                }
            } else {
                self.getBusinessList()
            }
        } else {
            AppGlobalData.shared().storeSessionData()
            self.getBusinessList()
        }
    }

    func getTotalBalanceFor(accountList: [AccountDataModel]) -> Double {
        let totalBankAccBalance: Double = accountList.map({ Double($0.availableBalance ?? "") ?? 0.00 }).reduce(0, +)

        return totalBankAccBalance
    }
    
    @objc func btnViewAllClicked(sender: UIButton) {
        strSelectedBusienssName = arrGroupedAccounts[sender.tag].groupTitle
        let isBusinessChecking = (arrGroupedAccounts[sender.tag].accountType == .businessChecking)
        strSelectedBusienssID = ""
        
        if let accounts = arrGroupedAccounts[sender.tag].accounts.first, let strBusinessID = accounts.businessId, isBusinessChecking {
            strSelectedBusienssID = strBusinessID
        }
        
        self.performSegue(withIdentifier: "GoToAccountsList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AccountsListVC {
            destinationVC.strSelectedBusinessName =  strSelectedBusienssName
            destinationVC.strSelectedBusinessID =  strSelectedBusienssID
        }
    }
}

// MARK: - API Calls
extension BankAccListVC {
    func getBusinessList() {
        self.getBusinessFromList { (_, error) in
            if error != nil {
                self.view.hideSkeleton()
            } else {
                self.getAccounts()
            }
        }
    }

    func getAccounts() {        
        self.view.showSkeleton()
        arrBankAccounts = [AccountDataModel]()
        AccountViewModel.shared.getAccountList(businessId: "") { (accountList, _) in
            if let accListData = accountList?.data {
                AppGlobalData.shared().accountList = accListData
                
                self.arrBankAccounts = accListData
                self.formatAccountList()
                
                self.emptyAccountView.isHidden = !(self.arrBankAccounts.count == 0)
            } else {
                self.view.hideSkeleton()
            }
            self.setupButtonUI()
        }
    }
    
    func formatAccountList() {
        
        arrGroupedAccounts = [AccountsGroup]()

        if let businessList = AppGlobalData.shared().allBusiness, businessList.count > 0 {
            // EITHER having both personal and business accounts OR only business accounts
            // get personal checking accounts
            getPersonalCheckingAccounts(accountList: arrBankAccounts)

            // get business checking accounts
            getBusinessCheckingAccounts(businessList: businessList, accountList: arrBankAccounts)
        } else { // having only personal checking accounts
            getPersonalCheckingAccounts(accountList: arrBankAccounts)
        }

        self.view.hideSkeleton()
        tblVwBankAcc.reloadData()
    }

    // personal checking accounts
    func getPersonalCheckingAccounts(accountList: [AccountDataModel]) {
        let personalAccGroup = AccountsGroup()
        let personalAccList = accountList.filter({ $0.type == .personalChecking || $0.businessId == "" })
        if personalAccList.count > 0 {
            let personName = AppGlobalData.shared().personData.name ?? ""
            personalAccGroup.groupTitle = personName
            personalAccGroup.accounts = personalAccList
            personalAccGroup.initialAccounts = Array(personalAccList.prefix(initialAccountsCount))
            personalAccGroup.accountType = .personalChecking
            arrGroupedAccounts.append(personalAccGroup)
        }
    }

    // business checking accounts
    func getBusinessCheckingAccounts(businessList: [BusinessDataModel], accountList: [AccountDataModel]) {
        let businessCheckingList = accountList.filter({ $0.type == .businessChecking || $0.businessId != ""})
        if businessCheckingList.count > 0 {
            for bData in businessList {
                let businessAccList = businessCheckingList.filter({ $0.businessId == bData.id})
                if businessAccList.count > 0 {
                    let businessAccGroup = AccountsGroup()
                    let businessLegalName = bData.legalName ?? ""
                    businessAccGroup.groupTitle = businessLegalName
                    businessAccGroup.accounts = businessAccList
                    businessAccGroup.initialAccounts = Array(businessAccList.prefix(initialAccountsCount))
                    businessAccGroup.accountType = .businessChecking
                    arrGroupedAccounts.append(businessAccGroup)
                }
            }
        }
    }
}

// MARK: - Tableview methods
extension BankAccListVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        tblVwBankAcc.register(UINib(nibName: "DashboardCell", bundle: .main), forCellReuseIdentifier: "DashboardCell")
        tblVwBankAcc.register(UINib(nibName: "AccountsListSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "AccountsListSectionHeader")
        tblVwBankAcc.register(UINib(nibName: "SkeletonLoaderAccountCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderAccountCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return arrGroupedAccounts.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrGroupedAccounts[section].initialAccounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let values = arrGroupedAccounts[indexPath.section].initialAccounts
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as? DashboardCell {
            let accountModel = values[indexPath.row]
            cell.configureForAccounts(accountModel: accountModel)
            cell.indexPath = indexPath
            cell.selectionStyle = .none
        
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = arrGroupedAccounts[indexPath.section].groupTitle
        let values = arrGroupedAccounts[indexPath.section].initialAccounts
        let accountModel = values[indexPath.row]
        if let allBusiness = AppGlobalData.shared().allBusiness {
            if let business = allBusiness.filter({ $0.legalName == key}).first {
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
        return Utility.isDeviceIpad() ? 84 : defaultRowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHeight: CGFloat = 0.0
        
        if arrGroupedAccounts.count > 0 {
            headerHeight = arrGroupedAccounts[section].accounts.count > 2 ? 55.0 : 30.0
        }
        
        return headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AccountsListSectionHeader") as? AccountsListSectionHeader {
            headerView.isSkeletonable = true
            
            headerView.lblTitle.isSkeletonable = true
            headerView.lblBalance.isSkeletonable = true

            headerView.btnViewAll.tag = section
            headerView.btnViewAll.addTarget(self, action: #selector(btnViewAllClicked(sender:)), for: .touchUpInside)
            
            headerView.btnViewAll.isHidden = true
            headerView.lblAccountTotal.isHidden = true
            headerView.lblViewAll.isHidden = true
            headerView.imgViewAll.isHidden = true

            headerView.backgroundColor = .clear
            
            if arrGroupedAccounts.count > 0 {
                let title = arrGroupedAccounts[section].groupTitle
                let allAccounts = arrGroupedAccounts[section].accounts
                let totalAccounts = arrGroupedAccounts[section].accounts.count

                headerView.lblTitle.text = title
                let totalBalance = getTotalBalanceFor(accountList: allAccounts)
                let number = NSNumber(value: totalBalance)
                let formatted = Utility.getCurrencyForAmount(amount: number, isDecimalRequired: true, withoutSpace: true)
                headerView.lblBalance.text = formatted
                
                headerView.lblAccountTotal.text = totalAccounts.string + " " + Utility.localizedString(forKey: "accList_title")
                
                if arrGroupedAccounts[section].accounts.count > 2 {
                    headerView.btnViewAll.isHidden = false
                    headerView.lblAccountTotal.isHidden = false
                    headerView.lblViewAll.isHidden = false
                    headerView.imgViewAll.isHidden = false
                }
            }
            
            return headerView
        }

        return nil
    }
}

extension BankAccListVC: SkeletonTableViewDataSource {
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
