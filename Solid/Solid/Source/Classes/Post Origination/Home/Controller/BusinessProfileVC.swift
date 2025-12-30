//
//  BusinessProfileVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/19/21.
//

import Foundation
import UIKit
import SkeletonView

class BusinessProfileVC: BaseVC {
    @IBOutlet weak var tblBusinessProfile: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var businessData: BusinessDataModel?
    var businessActionData: BusinessDataModel?
    
    var dataSource: [UserProfileRowData]?
    let dataHandler = BusinessDataHandler()
    
    var arrTitles = [String]()
    var accList = [AccountDataModel]()
    
    var naicsList = [BusinessSectorType]()
    var businessProjectionResponse = ProjectionAnnualModel()
    
    public var isprofileloading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCustomNavigationBar()
        
        arrTitles = ["business_profile_header", "etv_Title", "profile_account_header", "profile_action_header", "location"]
        
        registerBusinessProfileCell()
        self.tblBusinessProfile.showAnimatedGradientSkeleton()
        self.getBusiness()
        tableViewTopConstraint.constant = Utility.getTopSpacing()
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
    
    @objc func getBusiness() {
        self.getBusinessDetails { (response, _) in
            self.isprofileloading = true
            if let businessDetails = response {
                self.businessData = businessDetails
                self.getAccountList()
                self.createDataForBusinessInfo()
                self.getBusinessNAICSData()
            }
        }
    }
}

// MARK: - Other methods
extension BusinessProfileVC {
    func createDataForBusinessInfo() {
        var infoSection = DashboardRowData()
        infoSection.key = ""
        infoSection.captionValue = ""
    }
    
    func generateTableViewData() {
        if let busProfile = businessData {
            dataHandler.dataSource.removeAll()
            dataHandler.allIndustries = naicsList
            dataHandler.createDataSource(busProfile)
            tblBusinessProfile.reloadData()
            tblBusinessProfile.layoutIfNeeded()
        }
    }
}

// MARK: - API calls
extension BusinessProfileVC {
    func getBusinessNAICSData() {
        KYBViewModel.shared.getNAICSCodesList { response, errorMessage in
            if let errorData = errorMessage {
                self.showAlertMessage(titleStr: errorData.title, messageStr: errorData.body )
            } else {
                if let sectorsList = response, let sectorData = sectorsList.data, let totalCount = sectorsList.total, totalCount > 0 {
                    self.naicsList = sectorData
                    self.getGetProjectionData()
                }
            }
        }
    }
    
    func getGetProjectionData() {
        if let bid = AppGlobalData.shared().businessData?.id {
            KYBViewModel.shared.getProjection(businessId: bid) { (response, errorMessage) in
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let projectionData = response, let transactions = projectionData.transactions, let transAnnual = transactions.annual {
                        self.businessProjectionResponse = transAnnual
                        self.generateTableViewData()
                        self.tblBusinessProfile.hideSkeleton()
                    }
                }
            }
        }
    }
    
    func getAccountList() {
        AccountViewModel.shared.getAccountList(businessId: (businessData?.id)!) { (accountList, errorMessage) in
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                
            } else {
                if let accListData = accountList?.data, accListData.count > 0 {
                    self.accList = accListData
                    self.tblBusinessProfile.reloadSections(IndexSet(0...2), with: .fade)
                }
            }
        }
    }
}

// MARK: - UITableView
extension BusinessProfileVC: UITableViewDelegate, UITableViewDataSource {
    func registerBusinessProfileCell() {
        tblBusinessProfile.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        tblBusinessProfile.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
        tblBusinessProfile.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
        tblBusinessProfile.register(UINib(nibName: "LocationCell", bundle: nil),
                                    forCellReuseIdentifier: "LocationCell")
        tblBusinessProfile.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil),
                                    forCellReuseIdentifier: "SkeletonLoaderCell")
        tblBusinessProfile.register(UINib(nibName: "BusinessProfileETVCell", bundle: nil), forCellReuseIdentifier: "BusinessProfileETVCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataHandler.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return  1
        } else if section == 2 {
            return  self.accList.count
        } else {
            let dataSource = dataHandler.dataSource
            return section < dataSource.count ? dataSource[section].count  : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessProfileETVCell", for: indexPath) as? BusinessProfileETVCell {
            cell.configureCell(businessProjectionData: self.businessProjectionResponse)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 0 || indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
                if indexPath.section == 0 {
                    let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as UserProfileRowData
                    cell.configureProfileCell(forRow: rowData, hideSeparator: true)
                    cell.selectionStyle = .none
                    cell.imgSeperator.isHidden = true
                    return cell
                } else if let rowData = accList[indexPath.row] as AccountDataModel?, let accname = rowData.label, let accnumber = rowData.accountNumber {
                    cell.lblDescription.text =  ""
                    cell.lblDescription.isHidden = true
                    
                    cell.lblValue.text = accnumber
                    cell.lblTitle.text = accname
                    cell.lblTitle.font = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
                    cell.lblTitle.textColor = .primaryColor
                    cell.lblValue.font = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize14
                    cell.lblValue.textColor = .secondaryColor
                    
                    cell.imgSeperator.isHidden = false
                    cell.imgSeperator.backgroundColor = .customSeparatorColor
                    
                    if indexPath.row == accList.count - 1 {
                        cell.imgSeperator.isHidden = true
                    }
                    cell.selectionStyle = .none
                    return cell
                }
            }
        } else if indexPath.section == 3, let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
            let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as UserProfileRowData
            cell.configureProfileCell(forRow: rowData, hideSeparator: true)
            cell.selectionStyle = .none
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationCell, let rowData = businessData?.address {
            cell.showLocationData(forRow: rowData)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let businessProfileheader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        businessProfileheader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: Constants.defaultSectionHeight)
        businessProfileheader.backgroundColor = .clear
        businessProfileheader.lblSectionHeader.text = Utility.localizedString(forKey: arrTitles[section])
        businessProfileheader.lblSectionHeader.font = Constants.commonFont
        businessProfileheader.lblSectionHeader.leftAnchor.constraint(equalTo: businessProfileheader.leftAnchor, constant: 0).isActive = true
        businessProfileheader.lblSectionHeader.rightAnchor.constraint(equalTo: businessProfileheader.rightAnchor).isActive = true
        businessProfileheader.lblSectionHeader.topAnchor.constraint(equalTo: businessProfileheader.topAnchor, constant: 0).isActive = true
        businessProfileheader.lblSectionHeader.bottomAnchor.constraint(equalTo: businessProfileheader.bottomAnchor).isActive = true
        businessProfileheader.backgroundColor = .grayBackgroundColor
        businessProfileheader.contentView.backgroundColor = .grayBackgroundColor
        
        businessProfileheader.layoutIfNeeded()
        
        return businessProfileheader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.defaultSectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            if let strKey = dataHandler.dataSource[indexPath.section][indexPath.row].key {
                self.handleBusinessUserProfileActionClick(actionKey: strKey)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var heightV: CGFloat
        if !isprofileloading {
            return Constants.skeletonCellHeight
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                let str = dataHandler.dataSource[indexPath.section][indexPath.row].value as! String
                heightV = CGFloat(str.count) + 15
            } else {
                heightV = 48
            }
        } else if indexPath.section == 2 {
            heightV = 48
        } else if indexPath.section == 1 {
            heightV = 575
        } else if indexPath.section == 4 {
            heightV = 320
        } else {
            heightV = 65
        }
        
        return heightV
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
    
    func gotoAddressScreen() {
        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                let storyboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "UserBusinessAddressVC") as? UserBusinessAddressVC {
                    vc.businessData = self.businessData!
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension BusinessProfileVC: SkeletonTableViewDataSource {
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
		self.orientationChangedViewController(tableview: self.tblBusinessProfile, with: coordinator)
	}
}
