//
//  BaseVC.swift
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit
import SkeletonView

class BaseVC: APIBaseVC {
    var autolockVC: PinVC?
    var sourceController: UIViewController?
    var isIpadFormsheet = false //To handle keyboard event for form sheet in ipad.
    var footerView: ButtonFooterView!
    var accountType: AccountType? = .businessChecking
    var bottomConstraint: NSLayoutConstraint?
    var defaultTopLogoHeight: CGFloat = 30.0
    var baseVkeyboardHeight: CGFloat = 0.0
    
    //ADD VIEW CONTROLLER WHERE BACK SWIPE GESTURE IS NOT REQUIRED....
    var restrictedVCs = [LoginCreatedVC.self, KYCVC.self, KYCStatusVC.self, VerifyPersonaVC.self, BusinessDetailsVC.self, KYBStatusVC.self, AccountSetupVC.self, AccountDetailsVC.self]
    
    var shouldShowFooterView = false {
        didSet {
            if shouldShowFooterView {
                self.addButtonFooter()
            }
        }
    }
    
    var isNavigationBarHidden = false {
        didSet {
            self.navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: false)
        }
    }
    
    var isScreenModallyPresented = false {
        didSet {
            self.view.backgroundColor = .background
        }
    }
    
    var isNavigationBarTranslucent = false {
        didSet {
            if let navCtrl = self.navigationController {
                navCtrl.navigationBar.isTranslucent = isNavigationBarTranslucent
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let restrictedPOVCs = [BankAccListVC.self, SuccessContactCreationVC.self, PaymentSuccessVC.self, PullFundsSuccessVC.self, CreateCardSuccessVC.self, RCDSuccessViewController.self, ActivateCardSuccessScreen.self]
        restrictedVCs.append(contentsOf: restrictedPOVCs)
        
        self.view.backgroundColor = .grayBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setNavigationTitleUI()
        
        if shouldShowFooterView {
            registerKeyboardObserver()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deregisterKeyboardObserver()
        
        self.view.endEditing(true)
    }
    
    func addButtonFooter() {
        self.isNavigationBarTranslucent = false
        footerView = ButtonFooterView()
        self.view.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bottomConstraint = footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        bottomConstraint?.isActive =  true
        footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: Constants.footerViewHeight).isActive = true
    }
    
    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        if !isIpadFormsheet {
            baseVkeyboardHeight = keyboardHeight
            UIView.animate(withDuration: 0.2) {
                self.bottomConstraint?.isActive = false
                if keyboardHeight > 0 {
                    let bheight = 0 - keyboardHeight + 30
                    self.bottomConstraint?.constant = bheight
                } else {
                    self.bottomConstraint?.constant = 0
                }
                self.bottomConstraint?.isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func addCustomNavigationBar(havingLogoOnly: Bool = false, havingBackButton: Bool = true, backButtonImage: String = "", withBackTitle: String = "" ) {
        self.isNavigationBarHidden = true
        let topViewHeight: CGFloat = 65.0
        let bottomViewHeight: CGFloat = 65
        var topPadding: CGFloat = 22.0
        var hasBottomView = false
        
        if let accountsList = AppGlobalData.shared().accountList, accountsList.count > 0 && !havingLogoOnly {
            let businessAccountsList = accountsList.filter({ $0.type == .businessChecking})
            hasBottomView = businessAccountsList.count > 0
        }
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            topPadding = aKeywindow.safeAreaInsets.top
        }
        let customViewHeight: CGFloat = hasBottomView ? (topViewHeight + CGFloat(bottomViewHeight) + topPadding) : (topViewHeight + topPadding)
        //********CUSTOM VIEW********//
        let customNavBar = UIView()
        customNavBar.backgroundColor = .background
        customNavBar.tag = Constants.tagForTopCustomNavView
        self.view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        customNavBar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        customNavBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        customNavBar.heightAnchor.constraint(equalToConstant: customViewHeight).isActive = true
        //********TOP VIEW********//
        let topView = UIView()
        topView.backgroundColor = .background
        topView.tag = Constants.tagForTopView
        customNavBar.addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topPadding).isActive = true
        topView.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: topViewHeight).isActive = true
        // SET BACK BUTTON
        if havingBackButton {
            let backButton = BaseButton()
            let imageName = backButtonImage.isEmpty ? "navBack" : backButtonImage
            let backImg = UIImage(named: imageName)?.withTintColor(UIColor.primaryColor, renderingMode: .alwaysOriginal)
            let img = withBackTitle.isEmpty ? backImg : UIImage(named: "back")
            var backButtonWidth = backButtonImage.isEmpty ? 20 : 40
            backButtonWidth = withBackTitle.isEmpty ? backButtonWidth : 100
            let backButtonHeight = 40
            let backButtonY = Int(topViewHeight)/2 - backButtonHeight/2
            backButton.frame = CGRect(x: 15, y: backButtonY, width: backButtonWidth, height: 40)
            backButton.backgroundColor = .clear
            backButton.setTitleColor(UIColor.primaryColor, for: .normal)
            backButton.titleLabel?.font = UIFont.sfProDisplayMedium(fontSize: 14)
            backButton.addTarget(self, action: #selector(customBarBackClicked(sender:)), for: .touchUpInside)
            backButton.setTitle(withBackTitle, for: .normal)
            backButton.setImage(img, for: .normal)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            backButton.tag = Constants.tagForCustomBackButton
            backButton.updateImageColor()
            topView.addSubview(backButton)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 15).isActive = true
            backButton.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(backButtonY)).isActive = true
            backButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            backButton.widthAnchor.constraint(equalToConstant: CGFloat(backButtonWidth)).isActive = true
        }
        // SET APP LOGO..
        let image = UIImage(named: "Logo")
        let imageView = BaseImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let bannerWidth = self.view.bounds.size.width / 2
        var bannerHeight: CGFloat = image?.size.height ?? defaultTopLogoHeight // navCtrl.navigationBar.frame.size.height
        let bannerY = (bannerHeight / 2 - (image?.size.height)! / 2) + 15
        bannerHeight = bannerHeight > defaultTopLogoHeight ? defaultTopLogoHeight : bannerHeight
        imageView.center.x = topView.center.x
        imageView.contentMode = .scaleAspectFit
        imageView.tag = Constants.tagForTopLogoImgView
        topView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(bannerY + 5)).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: CGFloat(bannerHeight)).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: CGFloat(bannerWidth)).isActive = true
        
        if let logoUrl = traitCollection.userInterfaceStyle == .dark ? AppGlobalData.shared().programData.brand?.darkLandscapeLogo : AppGlobalData.shared().programData.brand?.landscapeLogo {
            imageView.loadSVGImage(url: logoUrl, placeholderImage: nil) { (_) in
                debugPrint("success and image load")
            } failer: { (_) in
                imageView.image = image
            }
        }
        // SET PROFILE BUTTON..
        let profileButtonText = AppGlobalData.shared().personData.initials
        let profileButton = UIButton()
        let profileButtonWidthHeight = havingLogoOnly ? 36 : 48
        profileButton.layer.cornerRadius = Constants.cornerRadiusThroughApp
        profileButton.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
        profileButton.backgroundColor = .grayBackgroundColor
        profileButton.setTitleColor(UIColor.brandColor, for: .normal)
        profileButton.titleLabel?.font = Utility.isDeviceIpad() ? Constants.mediumFontSize18 : Constants.mediumFontSize14
        profileButton.addTarget(self, action: #selector(btnProfileClicked(sender:)), for: .touchUpInside)
        profileButton.contentHorizontalAlignment = .center
        profileButton.setTitle(profileButtonText, for: .normal)
        profileButton.tag = Constants.tagForTopProfileButton
        topView.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: CGFloat(-15)).isActive = true
        profileButton.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(bannerY)).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: CGFloat(profileButtonWidthHeight)).isActive = true
        profileButton.widthAnchor.constraint(equalToConstant: CGFloat(profileButtonWidthHeight)).isActive = true
        //********BOTTOM VIEW********//
        if hasBottomView {
            let bottomView = UIView()
            bottomView.backgroundColor = .background
            // SET BUSINESS BUTTON VIEW....
            let businessButton = UIButton()
            businessButton.layer.cornerRadius = Constants.cornerRadiusThroughApp
            businessButton.layer.masksToBounds = true
            businessButton.backgroundColor = .grayBackgroundColor
            businessButton.setTitleColor(UIColor.primaryColor, for: .normal)
            businessButton.titleLabel?.font = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
            businessButton.contentHorizontalAlignment = .left
            businessButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            businessButton.setTitle(AppGlobalData.shared().personData.name, for: .normal)
            if let selectedAccData = AppGlobalData.shared().accountData, let bid = selectedAccData.businessId, !bid.trim.isEmpty {
                businessButton.addTarget(self, action: #selector(btnBusinessProfileClicked(sender:)), for: .touchUpInside)
                businessButton.setTitle(AppGlobalData.shared().businessData?.legalName, for: .normal)
            }
            businessButton.tag = Constants.tagForCustomSearchText
            bottomView.addSubview(businessButton)
            customNavBar.addSubview(bottomView)
            bottomView.translatesAutoresizingMaskIntoConstraints = false
            bottomView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: CGFloat(15)).isActive = true
            bottomView.topAnchor.constraint(equalTo: topView.topAnchor, constant: CGFloat(topViewHeight)).isActive = true
            bottomView.heightAnchor.constraint(equalToConstant: CGFloat(bottomViewHeight)).isActive = true
            bottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            businessButton.translatesAutoresizingMaskIntoConstraints = false
            businessButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: CGFloat(0)).isActive = true
            businessButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: CGFloat(-15)).isActive = true
            businessButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: CGFloat(5)).isActive = true
            businessButton.heightAnchor.constraint(equalToConstant: CGFloat(46)).isActive = true
        }
    }
    
    func addProgressbar(percentage: Int) {
        let progressImageV = BaseImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
        progressImageV.backgroundColor = .brandColor
        let  totalPercentage = (Int(UIScreen.main.bounds.size.width) * percentage) / 100
        progressImageV.frame.size.width = CGFloat(totalPercentage)
        progressImageV.tag = Constants.tagForProgressbarImgView
        self.view.addSubview(progressImageV)
    }
    
    @objc func btnBusinessProfileClicked(sender: UIButton) {
        
        var shouldNavigate =  true
        
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc.isKind(of: BusinessProfileVC.classForCoder()) {
                    shouldNavigate = false
                }
            }
        }
        
        if shouldNavigate {
            Segment.addSegmentEvent(name: .homeEntityDetails)
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "BusinessProfileVC") as? BusinessProfileVC {
                // let navController = UINavigationController(rootViewController: vc)
                // navController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func btnProfileClicked(sender: UIButton) {
        var shouldNavigate =  true
        
        if let viewControllers = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc.isKind(of: UserProfileVC.classForCoder()) {
                    shouldNavigate = false
                }
            }
        }
        
        if shouldNavigate {
            Segment.addSegmentEvent(name: .homeUserDetails)
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                // let navController = UINavigationController(rootViewController: vc)
                // navController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func customBarBackClicked(sender: UIButton) {
        self.popVC()
    }
}

// MARK: - Other common methods
extension BaseVC {
    func openHelpCenter() {
        if let config = AppMetaDataHelper.shared.config, let helpCenterLink = config.helpCenterLink, !helpCenterLink.isEmpty {
            WebViewHelperVC.present(source: self, path: helpCenterLink, title: Utility.localizedString(forKey: "profile_helpcenter"))
        }
    }
    
    func openEmail() {//this will open Email app in device, in simulator it won't work..
        if let config = AppMetaDataHelper.shared.config, let toEmail = config.getInTouchEmail, !toEmail.isEmpty, let url = URL(string: "mailto:\(toEmail)") {
            UIApplication.shared.open(url)
        }
    }
    
    func showDisclosures() {
        if let config = AppMetaDataHelper.shared.config, let disclosureLink = config.disclosuresLink, !disclosureLink.isEmpty {
            WebViewHelperVC.present(source: self, path: disclosureLink, title: Utility.localizedString(forKey: "disclosure_title"))
        }
    }
    
    func showLCBBankTermsAndConditions() {
        if let config = AppMetaDataHelper.shared.config, let lcbBankTermsLink = config.lcbBankTermsLink, !lcbBankTermsLink.isEmpty {
            WebViewHelperVC.present(source: self, path: lcbBankTermsLink, title: Utility.localizedString(forKey: "terms_title"))
        }
    }
    
    func showSolidBankTermsAndConditions() {
        if let config = AppMetaDataHelper.shared.config, let solidBankTermsLink = config.platformTerms, !solidBankTermsLink.isEmpty {
            WebViewHelperVC.present(source: self, path: solidBankTermsLink, title: Utility.localizedString(forKey: "terms_title"))
        }
    }
    
    func showSolidWalletTermsAndConditions() {
        if let config = AppMetaDataHelper.shared.config, let solidWalletTermsLink = config.solidWalletTermsLink, !solidWalletTermsLink.isEmpty {
            WebViewHelperVC.present(source: self, path: solidWalletTermsLink, title: Utility.localizedString(forKey: "terms_title"))
        }
    }
    
    func showOTPTerms() {
        if let config = AppMetaDataHelper.shared.config, let otpTermsLink = config.auth0Terms, !otpTermsLink.isEmpty {
            WebViewHelperVC.present(source: self, path: otpTermsLink, title: Utility.localizedString(forKey: "terms_title"))
        }
    }
    
    func showOTPPrivacyPolicy() {
        if let config = AppMetaDataHelper.shared.config, let otpPrivacyLink = config.auth0Privacy, !otpPrivacyLink.isEmpty {
            WebViewHelperVC.present(source: self, path: otpPrivacyLink, title: Utility.localizedString(forKey: "privacy_policy"))
        }
    }
    
    func openNAICSReadMore() {
        if !AppMetaDataHelper.shared.naicsReadMoreLink.isEmpty {
            WebViewHelperVC.present(source: self, path: AppMetaDataHelper.shared.naicsReadMoreLink, title: Utility.localizedString(forKey: "naics"))
        }
    }
    
    func addCloseButton() {
        let btnClose = UIButton(frame: CGRect(x: self.view.frame.width - 65, y: 50, width: 50, height: 20))
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        btnClose.titleLabel?.font = titleFont
        btnClose.tag = 1000
        btnClose.setTitle(Utility.localizedString(forKey: "close"), for: .normal)
        btnClose.addTarget(self, action: #selector(closeClicked(sender:)), for: .touchUpInside)
        btnClose.setTitleColor(UIColor.primaryColor, for: .normal)
        if self.view.viewWithTag(1000) == nil {
            self.view.addSubview(btnClose)
        }
    }
    
    @objc func closeClicked(sender: UIButton) {
        if AppGlobalData.shared().appFlow == AppFlow.AO {
            logoutUser()
        } else {
            self.navigationController?.backToViewController(viewController: SelectAccountVC.self)
        }
    }
    
    func logoutUser() {
        self.activityIndicatorBegin()
        self.logoutUser { (_, _) in
            self.activityIndicatorEnd()
            self.clearDataOnLogout() // CLEAR STORED SESSION & OTHER DATA...
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.gotoWelcomeScreen()
            }
        }
    }
    
    // Set selected accounttype id both is true
    func setAccountType() {
        if AppGlobalData.shared().bothPersonalAndBusinessChecking {
            if AppGlobalData.shared().selectedAccountType == .personalChecking {
                accountType = .personalChecking
            }
        } else if AppGlobalData.shared().accTypePersonalChecking {
            accountType = .personalChecking
        }
    }
}

// MARK: - Logout methods
extension BaseVC {
    func logoutUser(_ completion : @escaping (Bool, AlertMessage?) -> Void) {
        if let refreshToken = AppData.session.refreshToken {
            
            var postBody = LogoutPostBody()
            postBody.clientId = Client.clientId
            postBody.phone = AppGlobalData.personPhone
            postBody.refreshToken = refreshToken
            
            AuthViewModel.shared.logout(tokenData: postBody) { (_, errorMessage) in
                if let error = errorMessage {
                    completion(false, error)
                } else {
                    self.clearDataOnLogout()
                    completion(true, nil)
                }
            }
        }
    }
    
    func clearDataOnLogout() {
        self.removeAllObservers()// removed added observers fron Dashboard, Card list, Contact list screens
        AppGlobalData.destroy() // Data stored globally
        AppData.logout() // Session data
        Security.clearKeychain()// clear keychain data
    }
    
    func removeAllObservers() {
        if let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window, let rootVC = window.rootViewController, let rootNavCtrl = rootVC as? UINavigationController {
            if let dashboardObj = rootNavCtrl.viewControllers.filter({ $0.isKind(of: DashboardVC.self) }).first {
                NotificationCenter.default.removeObserver(dashboardObj)
            }
            
            if let cardObj = rootNavCtrl.viewControllers.filter({ $0.isKind(of: CardsListVC.self) }).first {
                NotificationCenter.default.removeObserver(cardObj)
            }
            
            if let contactObj = rootNavCtrl.viewControllers.filter({ $0.isKind(of: ContactsListVC.self) }).first {
                NotificationCenter.default.removeObserver(contactObj)
            }
        }
    }
}

// MARK: - Business and User Profile actions navigation
extension BaseVC {
    func handleBusinessUserProfileActionClick(actionKey: String) {
        if actionKey == UserActionDetails.helpcenter.getTitleKey() {
            self.openHelpCenter()
        } else if actionKey == UserActionDetails.getintouch.getTitleKey() {
            self.openEmail()
        } else if actionKey == UserActionDetails.disclosures.getTitleKey() {
            //self.showDisclosures()
        }
    }
}

// MARK: - userInterfaceStyle methods
extension BaseVC {
    func updateTopLogo() {
        let image = UIImage(named: "Logo")
        if let imgView = self.view.viewWithTag(Constants.tagForTopLogoImgView) as? UIImageView, let logoUrl = traitCollection.userInterfaceStyle == .dark ? AppGlobalData.shared().programData.brand?.darkLandscapeLogo : AppGlobalData.shared().programData.brand?.landscapeLogo {
            imgView.loadSVGImage(url: logoUrl, placeholderImage: nil) { (success) in
                debugPrint(success ?? true)
            } failer: { (errorFlag) in
                debugPrint(errorFlag ?? false)
                imgView.image = image
            }
        }
    }
    
    func updateProgressbarColor() {
        if let progressbarView = self.view.viewWithTag(Constants.tagForProgressbarImgView) {
            progressbarView.backgroundColor = .brandColor
        }
    }
    
    func updateTopProfileColor() {
        if let topButtonView = self.view.viewWithTag(Constants.tagForTopProfileButton) as? UIButton {
            topButtonView.setTitleColor(UIColor.brandColor, for: .normal)
        }
    }
    
    func updateNavCloseButtonColor() {
        if let navItem = self.navigationItem.rightBarButtonItem, let rightButton = navItem.customView, rightButton.isKind(of: UIButton.self) && rightButton.tag == Constants.tagForNavRightCloseButton {
            rightButton.tintColor = .brandColor
        }
    }
    
    func updateCustomBackButtonColor() {
        if let backButtonView = self.view.viewWithTag(Constants.tagForCustomBackButton) as? BaseButton {
            backButtonView.updateImageColor()
        }
    }
    
    func updateSearchTextFieldColor() {
        if let topButtonView = self.view.viewWithTag(Constants.tagForCustomSearchText) as? UIButton {
            topButtonView.setTitleColor(UIColor.brandColor, for: .normal)
        }
    }
    
    func updateBtnCloseTextColor() {
        if let topButtonView = self.view.viewWithTag(1000) as? UIButton {
            topButtonView.setTitleColor(UIColor.primaryColor, for: .normal)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _ = traitCollection.userInterfaceStyle // Either .unspecified, .light, or .dark
        // Update your user interface based on the appearance
        //updating navigation title color..
        setNavigationTitleUI()
        
        //updating top logo..
        updateTopLogo()
        
        //updating top progressbar color..
        updateProgressbarColor()
        
        //updating close button color used in webview...
        //NOTE: remove tag condition if want to update color for any button..
        updateNavCloseButtonColor()
        
        //updating top right profile text color
        updateTopProfileColor()
        
        //updating color for custom back navigation button
        updateCustomBackButtonColor()
        
        //updating Search Textfield color
        updateSearchTextFieldColor()
        
        //updating close button color
        updateBtnCloseTextColor()
        
        self.updateBackBtnColor()
    }
}

extension BaseVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer else {
            return true // default value
        }
        
        var shouldNavigate = false
        
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
            let lastVC = viewControllers.last!
            var isRestricted = false
            
            //explicitly check navigation stack and restrict back swipe
            if let _ = viewControllers.filter({ $0.isKind(of: SuccessContactCreationVC.self) }).first, lastVC.classForCoder == ContactInfoVC.classForCoder() {
                isRestricted = true
            } else if let _ = viewControllers.filter({ $0.isKind(of: CreateCardSuccessVC.self) }).first, lastVC.classForCoder == CardInfoVC.classForCoder() {
                isRestricted = true
            } else if let _ = viewControllers.filter({ $0.isKind(of: CreateCardSuccessVC.self) }).first, lastVC.classForCoder == CardActivationVC.classForCoder() {
                isRestricted = true
            } else if let _ = viewControllers.filter({ $0.isKind(of: ActivateCardSuccessScreen.self) }).first, lastVC.classForCoder == CardInfoVC.classForCoder() {
                isRestricted = true
            } else {
                for vc in restrictedVCs  where vc == lastVC.classForCoder {
                    isRestricted = true
                    
                    //Unrestrict back swipe as these screens are used in PO flow too which has back navigation
                    if (vc == BusinessDetailsVC.classForCoder() || vc == AccountSetupVC.classForCoder()) && AppGlobalData.shared().appFlow == AppFlow.PO {
                        isRestricted = false
                    }
                    
                    break
                }
            }
            
            shouldNavigate = !isRestricted
        }
        
        return shouldNavigate
    }
}
