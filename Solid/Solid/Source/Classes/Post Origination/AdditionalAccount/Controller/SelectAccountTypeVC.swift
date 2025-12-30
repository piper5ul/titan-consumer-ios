//
//  SelectAccountTypeVC.swift
//  Solid
//
//  Created by Solid iOS Team on 6/23/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class SelectAccountTypeVC: BaseVC {
    @IBOutlet weak var tblAccountType: UITableView!
    @IBOutlet weak var imgLogo: BaseImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblOptionTitle: UILabel!

    var arrTitles = [String]()
    let defaultSectionHeight: CGFloat = 80.0
    var businessList = [BusinessDataModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCellsAndHeaders()
        arrTitles = ["personal_checking_account", "business_checking_account"]
        tblAccountType.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        setupUI()
    }

    func setNavigationBar() {
        self.isNavigationBarHidden = true
        self.isScreenModallyPresented = true
    }
    
    func setupUI() {
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblOptionTitle.font = labelFont
        lblOptionTitle.textAlignment = .center
        lblOptionTitle.textColor = UIColor.primaryColor
        
        lblDescription.text = Utility.localizedString(forKey: "account_selection_desription_text")
        lblDescription.font = labelFont
        lblDescription.textColor = UIColor.secondaryColor
        lblDescription.textAlignment = .center
        tblAccountType.backgroundColor = .clear
        setLogoImage()
    }
    
    func setLogoImage() {
        let image = UIImage(named: "Logo")
        if let logoUrl = traitCollection.userInterfaceStyle == .dark ? AppGlobalData.shared().programData.brand?.darkLandscapeLogo : AppGlobalData.shared().programData.brand?.landscapeLogo {
            imgLogo.loadSVGImage(url: logoUrl, placeholderImage: nil) { (_) in
                // No action required on success for this particular case
                //self.imgLogo.customTintColor = AppGlobalData.shared().brandColorForMode
            } failer: { (_) in
                //nothing in case of failure
                self.imgLogo.image = image
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblOptionTitle.textColor = UIColor.primaryColor
        lblDescription.textColor = UIColor.secondaryColor
        
        setLogoImage()
    }
}

// MARK: - TABLEVIEW
extension SelectAccountTypeVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblAccountType.register(UINib(nibName: "DataActionCell", bundle: .main), forCellReuseIdentifier: "DataActionCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
            var item = arrTitles[indexPath.row]
            item = Utility.localizedString(forKey: item)
            cell.configureCardTypeSelection(cardType: item, cardDesc: "")
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            AppGlobalData.shared().selectedAccountType = AccountType.personalChecking
            self.getAccountData()
        } else {
            AppGlobalData.shared().selectedAccountType = AccountType.businessChecking
            self.getBusinessList()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
}

// MARK: - API CALLS
extension SelectAccountTypeVC {
func getBusinessList() {
    self.activityIndicatorBegin()
    self.getBusinessFromList { (businessData, errorMessage) in
        self.activityIndicatorEnd()
        if let error = errorMessage {
            self.showAlertMessage(titleStr: error.title, messageStr: error.body )
        } else {
            if let aBusinessData = businessData, let kyb = aBusinessData.kyb, let kybStatus = kyb.status {
                if kybStatus == .approved {
                    self.getAccountDetails(showAutoLockWithVC: self, aBusinessData: aBusinessData, kybStatus: kybStatus)
                } else {
                    self.createAutoLockPINforKYB(showAutoLockWithVC: self, aKybStatus: kybStatus, aBusinessData: aBusinessData)
                }
            } else {
                self.gotoKYBScreen(businessData: nil)
            }
        }
    }
}

func getAccountData() {
        self.activityIndicatorBegin()
        self.getAccountFromList { (accountData, _) in
            self.activityIndicatorEnd()
            if let accData = accountData, let _ = accData.id {
                AppGlobalData.shared().appFlow = .PO
            }
            
            self.gotoAccountSetupScreen()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.orientationChangedViewController(tableview: self.tblAccountType, with: coordinator)
    }
}
