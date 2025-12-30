//
//  SelectAccountViewController.swift
//  Solid
//
//  Created by Solid iOS Team on 3/2/21.
//

import Foundation
import UIKit

struct AddAccountRowData {
    var key: String?
    var rows: [String]?
}

class SelectAccountVC: BaseVC {
    @IBOutlet weak var tblAccountTypes: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!

    let defaultSectionHeight: CGFloat = 50.0
    
    var businessList = [BusinessDataModel]()
    var data = [AddAccountRowData]()
    var arrAccountTypes: [String] = []
    var arrAddAccountTo: [String] = []
    var selectedIndexpathForAccType: IndexPath? = IndexPath(row: 0, section: 0)
    var selectedIndexpathForAccTo: IndexPath? = IndexPath(row: -1, section: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        registerCellsAndHeaders()
        setupUI()
       
        AppGlobalData.shared().isSelectedCardAccount = false

        self.setFooterUI()
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            let bottomConst = Utility.isDeviceIpad() ? 105.0 : 90.0
            tblBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : bottomConst
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarHidden = false
        getBusinessList()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(handleNavigation(sender:)), for: .touchUpInside)
        footerView.btnApply.isEnabled = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tblAccountTypes.reloadData()
    }
}

// MARK: - UI Methods
extension SelectAccountVC {
    func setupUI() {
        // For floating tableview header
        let dummyViewHeight = CGFloat(defaultSectionHeight)
        self.tblAccountTypes.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: (self.tblAccountTypes.bounds.size.width), height: dummyViewHeight))
        self.tblAccountTypes.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
    }
    
    func setNavigationBar() {
        isScreenModallyPresented = true
        isNavigationBarHidden = false

        addBackNavigationbarButton()

        self.title = Utility.localizedString(forKey: "selectAcc_screenTitle")
    }

    func setupData() {
        arrAccountTypes.removeAll()
        arrAddAccountTo.removeAll()
        
        //for section 0..Add account type
        if !AppGlobalData.shared().isMaxCashAccontLimitReached() {
            arrAccountTypes.append("Cash")
        }
        if AppGlobalData.shared().accTypeCardAccount {
            arrAccountTypes.append("Card")
        }
 
        selectedIndexpathForAccType = IndexPath(row: 0, section: 0)
        
        //for section 1..Add account to
        arrAddAccountTo.append(AppGlobalData.shared().personData.name ?? "Personal Checking")
        
        if AppGlobalData.shared().accTypeBusinessChecking {
            if let globalBusinessList = AppGlobalData.shared().allBusiness, globalBusinessList.count > 0 {
                businessList = globalBusinessList.sorted(by: { $0.legalName! > $1.legalName!})
                for business in businessList {
                    arrAddAccountTo.append(business.legalName ?? "")
                }
            }
            
            arrAddAccountTo.append(Utility.localizedString(forKey: "selectAcc_businessCell_title"))
        }

        createTableData()
    }
    
    @IBAction func handleNavigation(sender: UIButton) {
        if selectedIndexpathForAccTo?.row == 0 {
            //personal checking account...
            AppGlobalData.shared().selectedAccountType = .personalChecking
            handleNavigationForAccountSetup()
        } else {
            //business checking account...
            AppGlobalData.shared().selectedAccountType = .businessChecking

            if selectedIndexpathForAccTo?.row == arrAddAccountTo.count - 1 && !AppGlobalData.shared().isSelectedCardAccount {
                self.gotoKYBScreen(businessData: nil)
            } else if let globalBusinessList = AppGlobalData.shared().allBusiness, globalBusinessList.count > 0 {
                AppGlobalData.shared().businessData = businessList.filter({ $0.legalName == arrAddAccountTo[selectedIndexpathForAccTo?.row ?? 0]}).first
                
                if AppGlobalData.shared().businessData?.kyb?.status == .approved {
                    handleNavigationForAccountSetup()
                } else {
                    getBusinessData()
                }
            }
        }
    }
}

// MARK: - Other methods
extension SelectAccountVC {
    func createTableData() {
        data = [AddAccountRowData]()

        let accountTypeData = createAccountTypeData()
        data.append(accountTypeData)
        
        let accountAddToRowData = createAccountAddToData()
        data.append(accountAddToRowData)
        
        tblAccountTypes.reloadData()
    }
    
    func createAccountTypeData() -> AddAccountRowData {
        var rowData = AddAccountRowData()
        rowData.key = "Add account type"
        rowData.rows = arrAccountTypes
        return rowData
    }
    
    func createAccountAddToData() -> AddAccountRowData {
        var rowData = AddAccountRowData()
        rowData.key = "Add account to"
        rowData.rows = arrAddAccountTo
        return rowData
    }
}

// MARK: - UITableView
extension SelectAccountVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblAccountTypes.register(UINib(nibName: "FilterRadiobuttonCell", bundle: nil), forCellReuseIdentifier: "FilterRadiobuttonCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].rows?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterRadiobuttonCell", for: indexPath) as? FilterRadiobuttonCell {

            var isSelected = false

            cell.radioDelegate = self

            if indexPath == selectedIndexpathForAccType || indexPath == selectedIndexpathForAccTo {
                isSelected = true
            }
            
            let item = data[indexPath.section].rows?[indexPath.row] ?? ""
            cell.configureForAddAccount(title: item, isSelected: isSelected)

            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reloadTable(selectedIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: defaultSectionHeight))
        returnedView.backgroundColor = .clear

        let lblTitle = UILabel()
        lblTitle.font = UIFont.sfProDisplayMedium(fontSize: 16)
        lblTitle.textColor = UIColor.primaryColor
        lblTitle.text = data[section].key

        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        returnedView.addSubview(lblTitle)
        lblTitle.leftAnchor.constraint(equalTo: returnedView.leftAnchor).isActive = true
        lblTitle.rightAnchor.constraint(equalTo: returnedView.rightAnchor).isActive = true
        lblTitle.topAnchor.constraint(equalTo: returnedView.topAnchor).isActive = true
        lblTitle.bottomAnchor.constraint(equalTo: returnedView.bottomAnchor).isActive = true

        return returnedView
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.orientationChangedViewController(tableview: self.tblAccountTypes, with: coordinator)
    }
}

// MARK: - RadiobuttonCellDelegate
extension SelectAccountVC: RadiobuttonCellDelegate {
    func selectedRadioButton(cell: FilterRadiobuttonCell) {
        guard let indexPath = self.tblAccountTypes.indexPath(for: cell) else {
            return
        }
        
        reloadTable(selectedIndex: indexPath)
    }
    
    func reloadTable(selectedIndex: IndexPath) {
        //set data
        switch selectedIndex.section {
        case 0:
            if AppGlobalData.shared().allBusiness == nil || AppGlobalData.shared().allBusiness?.count == 0 {
                arrAddAccountTo = []
                arrAddAccountTo.append(AppGlobalData.shared().personData.name ?? "Personal Checking")
                
                if selectedIndex.row == 0 && AppGlobalData.shared().accTypeBusinessChecking {
                    arrAddAccountTo.append(Utility.localizedString(forKey: "selectAcc_businessCell_title"))
                }
                
                selectedIndexpathForAccTo = IndexPath(row: 0, section: 1)
                footerView.btnApply.isEnabled = true
            }
            
            AppGlobalData.shared().isSelectedCardAccount = false
            
            switch arrAccountTypes[selectedIndex.row] {
            case "Card":
                if arrAddAccountTo.contains(Utility.localizedString(forKey: "selectAcc_businessCell_title")) {
                    arrAddAccountTo.removeLast()
                }
                AppGlobalData.shared().isSelectedCardAccount = true
            default:
                if !arrAddAccountTo.contains(Utility.localizedString(forKey: "selectAcc_businessCell_title")) {
                    arrAddAccountTo.append(Utility.localizedString(forKey: "selectAcc_businessCell_title"))
                }
                break
            }
            selectedIndexpathForAccType = IndexPath(row: selectedIndex.row, section: 0)
        case 1:
            footerView.btnApply.isEnabled = true
            selectedIndexpathForAccTo = IndexPath(row: selectedIndex.row, section: 1)
        default:
            return
        }

        createTableData()
        
        //reload table
        UIView.performWithoutAnimation {
            self.tblAccountTypes.beginUpdates()
            tblAccountTypes.reloadData()
            self.tblAccountTypes.endUpdates()
        }
    }
}

// MARK: - API CALLS
extension SelectAccountVC {
    func getBusinessList() {
        self.activityIndicatorBegin()
        self.getBusinessFromList { (_, _) in
            self.activityIndicatorEnd()
            self.setupData()
        }
    }
    
    func getBusinessData() {
        if let aBusinessData = AppGlobalData.shared().businessData, let kyb = aBusinessData.kyb, let kybStatus = kyb.status {
            self.createAutoLockPINforKYB(showAutoLockWithVC: self, aKybStatus: kybStatus, aBusinessData: aBusinessData)
        } else {
            self.gotoKYBScreen(businessData: nil)
        }
    }
}
