//
//  AccountDetailsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 16/02/21.
//

import Foundation
import UIKit

class AccountDetailsVC: BaseVC {
    @IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    @IBOutlet weak var imgVwIllustrator: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imgVwIconAccNum: BaseImageView!
    @IBOutlet weak var lblTitleAccNum: UILabel!
    @IBOutlet weak var lblValueAccNum: UILabel!
    
    @IBOutlet weak var imgVwIconRoutNum: BaseImageView!
    @IBOutlet weak var lblTitleRoutNum: UILabel!
    @IBOutlet weak var lblValueRoutNum: UILabel!
    
    @IBOutlet weak var vwMainContainer: UIView!
    @IBOutlet weak var imgVwSeparator: UIImageView!
    @IBOutlet weak var lblDisclaimer: UILabel!
    
    @IBOutlet weak var disclaimerBottomConstraint: NSLayoutConstraint!
    
    var accountData = AccountDataModel()
    var appFlow: AppFlow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appFlow = AppGlobalData.shared().appFlow
        setupUI()
        self.setFooterUI()
        setupData()
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            disclaimerBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : Constants.footerViewHeight + 10
        }
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(btnStartAccClicked(_:)), for: .touchUpInside)
    }
    
    @IBAction func btnStartAccClicked(_ sender: Any) {
        if appFlow == .AO {
            self.gotoHomeScreen()
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadAccountsAfterAdding), object: nil)
            self.popToHomeScreen()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDescription.textColor = UIColor.secondaryColor
        lblTitleAccNum.textColor = UIColor.primaryColor
        lblValueAccNum.textColor = UIColor.secondaryColor
        lblTitleRoutNum.textColor = UIColor.primaryColor
        lblValueRoutNum.textColor = UIColor.secondaryColor
        lblDisclaimer.textColor = UIColor.secondaryColor
    }
}

extension AccountDetailsVC {
    func setupUI() {
        self.isScreenModallyPresented = true
        self.isNavigationBarHidden = true
        
        let titlefontsize = Utility.isDeviceIpad() ? Constants.regularFontSize28 : Constants.regularFontSize24
        let descfontsize = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        let fontsize = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize14
        
        vwAnimationContainer?.animationFile = "success"
        lblTitle.font = titlefontsize
        lblTitle.textColor = UIColor.primaryColor
        
        lblDescription.font = descfontsize
        lblDescription.textColor = UIColor.secondaryColor
        
        lblTitleAccNum.font = fontsize
        lblTitleAccNum.textColor = UIColor.primaryColor
        lblValueAccNum.font = fontsize
        lblValueAccNum.textColor = UIColor.secondaryColor
        
        lblTitleRoutNum.font = fontsize
        lblTitleRoutNum.textColor = UIColor.primaryColor
        lblValueRoutNum.font = fontsize
        lblValueRoutNum.textColor = UIColor.secondaryColor
        
        imgVwSeparator.backgroundColor = UIColor.customSeparatorColor
        vwMainContainer.layer.cornerRadius = Constants.cornerRadiusThroughApp
        vwMainContainer.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
        vwMainContainer.layer.borderColor = UIColor.customSeparatorColor.cgColor
        vwMainContainer.layer.borderWidth = 1.0
        vwMainContainer.backgroundColor = .clear
        
        let lblDisclaimerfont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        lblDisclaimer.font = lblDisclaimerfont
        lblDisclaimer.textColor = UIColor.secondaryColor
    }
    
    func setupData() {
        let localizedStr = Utility.localizedString(forKey: "acc_detail_title")
        lblTitle.text = localizedStr
        
        var localizedStr2 = Utility.localizedString(forKey: "acc_detail_description")
        let accountName = AppGlobalData.shared().accountData?.label
        localizedStr2 = String(format: localizedStr2, accountName!)
        lblDescription.text = localizedStr2
        
        lblTitleAccNum.text = Utility.localizedString(forKey: "acc_detail_num_title")
        lblTitleRoutNum.text = Utility.localizedString(forKey: "acc_detail_rout_title")
        
        let localizedStr3 = Utility.localizedString(forKey: "done")
        footerView.btnApply.set(title: localizedStr3)
        
        if let accData = AppGlobalData.shared().accountData {
            lblValueAccNum.text = accData.accountNumber ?? ""
            lblValueRoutNum.text = accData.routingNumber ?? ""
        }
        
        let strDisc = Utility.localizedString(forKey: "acc_setup_disclaimer")
        lblDisclaimer.text = strDisc
        
        AppGlobalData.shared().selectedAccountType = AppGlobalData.shared().accountData?.type
    }
}
