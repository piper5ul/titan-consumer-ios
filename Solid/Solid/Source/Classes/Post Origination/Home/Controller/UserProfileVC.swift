//
//  UserProfileVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/19/21.
//

import Foundation
import UIKit
import SkeletonView

class UserProfileVC: BaseVC {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var userData: PersonResponseBody?
    var accountActionData: AccountActionDataModel?
    var dataSource: [[UserProfileRowData]]?
    let dataHandler = UserProfileDataHandler()
    public var isuserloading: Bool = false
    let defaultSectionHeight: CGFloat = 60.0
    var arrTitles = [String]()
    public var allBusiness: [BusinessDataModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        addCustomNavigationBar()
        self.setFooterUI()
        
        arrTitles = ["personal_profile_header", "personal_profile_AccountType_title", "profile_action_header", "location"]
        allBusiness = AppGlobalData.shared().allBusiness
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.showAnimatedGradientSkeleton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.getPerson()
        self.isNavigationBarTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isNavigationBarTranslucent = false
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "profile_logoutn_btn"))
        footerView.btnApply.addTarget(self, action: #selector(btnLogoutClicked(_:)), for: .touchUpInside)
        footerView.isHidden = true
    }
    
    @objc func getPerson() {
        self.getPersonDetails { (person, _) in
            self.isuserloading = true
            self.view.hideSkeleton()
            if let personDetails = person {
                self.userData = personDetails
                self.createDataForAccInfo()
                self.generateTableViewData()
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        self.alert(src: self, Utility.localizedString(forKey: "profile_logoutn_btn"), Utility.localizedString(forKey: "profile_signout_alert_message"), Utility.localizedString(forKey: "yes"), Utility.localizedString(forKey: "no")) { button in
            if button == 1 {
                self.callAPIToLogoutUser()
            }
        }
    }
}

// MARK: - Other methods
extension UserProfileVC {
    func setupInitialUI() {
        registerProfileCell()
        tableViewTopConstraint.constant = Utility.getTopSpacing()
    }
}

// MARK: - Other methods
extension UserProfileVC {
    func createDataForAccInfo() {
        var infoSection = DashboardRowData()
        infoSection.key = ""
        infoSection.captionValue = ""
    }
    
    func generateTableViewData() {
        if let userProfile = userData {
            dataHandler.dataSource.removeAll()
            dataHandler.createDataSource(userProfile)
            footerView.isHidden = false
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }
}

// MARK: - API calls
extension UserProfileVC {
    func callAPIToLogoutUser() {
        self.activityIndicatorBegin()
        self.logoutUser { (_, errorMessage) in
            self.activityIndicatorEnd()
            self.gotoWelcomeScreen()
        }
    }
}

// MARK: - UITableViewDelegates
extension UserProfileVC: UITableViewDelegate, UITableViewDataSource {
    func registerProfileCell() {
        tableView.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        
        tableView.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
        
        tableView.register(UINib(nibName: "LocationCell", bundle: nil),
                           forCellReuseIdentifier: "LocationCell")
        tableView.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
        tableView.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil),
                           forCellReuseIdentifier: "SkeletonLoaderCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataHandler.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = dataHandler.dataSource
        if section == 1 {
            return allBusiness?.count ?? 0
        } else {
            return section < dataSource.count ? dataSource[section].count  : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1 {
            if let dataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
                if indexPath.section == 0 {
                    let data = dataHandler.dataSource[indexPath.section][indexPath.row] as UserProfileRowData
                    dataCell.configureProfileCell(forRow: data, hideSeparator: true)
                    if indexPath.row == dataHandler.dataSource[indexPath.section].count - 1 {
                        dataCell.imgSeperator.isHidden = true
                    }
                } else if let businessName =  allBusiness?[indexPath.row] {
                    dataCell.lblTitle.text = ""
                    dataCell.lblValue.text = ""
                    dataCell.lblDescription.text = businessName.legalName
                    dataCell.lblDescription.isHidden = false
                    dataCell.selectionStyle = .none
                    dataCell.imgSeperator.isHidden = indexPath.row == (allBusiness?.count ?? 0) - 1
                    dataCell.lblDescription.font =  Constants.mediumFontSize14
                }
                
                dataCell.selectionStyle = .none
                
                return dataCell
            }
        } else if indexPath.section == 2, let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
            let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as UserProfileRowData
            cell.configureProfileCell(forRow: rowData, hideSeparator: true)
            cell.selectionStyle = .none
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationCell, let rowData = userData?.address {
            cell.showLocationData(forRow: rowData)
            cell.selectionStyle = .none
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        headerCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: defaultSectionHeight)
        
        headerCell.lblSectionHeader.text = Utility.localizedString(forKey: arrTitles[section])
        headerCell.lblSectionHeader.font = Constants.commonFont
        headerCell.lblSectionHeader.leftAnchor.constraint(equalTo: headerCell.leftAnchor, constant: 0).isActive = true
        headerCell.lblSectionHeader.rightAnchor.constraint(equalTo: headerCell.rightAnchor).isActive = true
        headerCell.lblSectionHeader.topAnchor.constraint(equalTo: headerCell.topAnchor, constant: 0).isActive = true
        headerCell.lblSectionHeader.bottomAnchor.constraint(equalTo: headerCell.bottomAnchor).isActive = true
        headerCell.backgroundColor = .grayBackgroundColor
        headerCell.contentView.backgroundColor = .grayBackgroundColor
        headerCell.layoutIfNeeded()
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightV: CGFloat
        
        if !isuserloading {
            return Constants.skeletonCellHeight
        } else if indexPath.section == 2 {
            heightV = 64
        } else if indexPath.section == 3 {
            heightV = 320
        } else {
            heightV = 48
        }
        return heightV
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let  allbusiness = allBusiness?.count ?? 0
        if section == 1 &&  allbusiness == 0 {
            return 1
        }
        return defaultSectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let str = dataHandler.dataSource[indexPath.section][indexPath.row].key, indexPath.section == 2 {
            self.handleBusinessUserProfileActionClick(actionKey: str)
        }
    }
    
    func gotoAddressScreen() {
        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                let storyboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "UserAddressVC") as? UserAddressVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension UserProfileVC: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "SkeletonLoaderCell"
    }
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 3
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.orientationChangedViewController(tableview: self.tableView, with: coordinator)
    }
}
