//
//  KYCStatusVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/02/21.
//

import Foundation
import UIKit
import Lottie

class KYCStatusVC: BaseVC {

	@IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var topConstBtnClose: NSLayoutConstraint!
	@IBOutlet weak var centerConstivContainer: NSLayoutConstraint!

    var kycStatus: KYCStatus? = .notStarted
    var isIDVCheck = false

    private var autoRefreshTimer: Timer?
    let fetchStatusDuration = 5.0
    var totalWaitTime = 15.0
    var isAutoRefreshGoingOn = false    // Using this variable to identify auto-refresh after review state

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isNavigationBarHidden = true
        self.isScreenModallyPresented = true

        setupUI()
        self.setFooterUI()
        self.setupData()

        if kycStatus != .approved && !isIDVCheck {
            makeInitialFetchCall()
            addRefreshDataTimer()
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.isNavigationBarHidden = true
		deregisterKeyboardObserver()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		registerKeyboardObserver()
	}

    func setFooterUI() {
        self.shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(btnProceedClicked(_:)), for: .touchUpInside)
        footerView.isHidden = true
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        removeRefreshDataTimer()
        self.closeClicked(sender: sender as! UIButton)
    }

    @IBAction func btnProceedClicked(_ sender: Any) {
                
        if kycStatus == KYCStatus.approved {

            Segment.addSegmentEvent(name: .proceedBusiness)

            if AppGlobalData.shared().bothPersonalAndBusinessChecking {
                self.getAccountFromList { (_, _) in
                    self.activityIndicatorEnd()
                    if AppGlobalData.shared().accountList?.count ?? 0 > 0 {
                        self.gotoHomeScreen()
                    } else {
                        // SHOW OPTION
                        self.gotoAccountTypeSelectioncreen()
                    }
                }
            } else if AppGlobalData.shared().accTypePersonalChecking {
                self.getAccountData()
            } else if AppGlobalData.shared().accTypeBusinessChecking {
                self.getBusinessList()
            }
        } else if (kycStatus == KYCStatus.inReview) || (kycStatus == KYCStatus.submitted && totalWaitTime <= 0) {
            self.callAPIGetPersonDetails()
        } else {
            removeRefreshDataTimer()
            self.openEmail()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
        btnClose.setTitleColor(.primaryColor, for: .normal)
    }
}

// MARK: - Other methods
extension KYCStatusVC {

    func getAccountData() {
        self.activityIndicatorBegin()

        self.getAccountFromList { (accountData, _) in

            self.activityIndicatorEnd()

            if let accData = accountData, let _ = accData.id {
                AppGlobalData.shared().appFlow = .PO
                self.gotoHomeScreen()
            } else {
                self.gotoAccountSetupScreen()
            }
        }
    }

    // To get business list
    func getBusinessList() {

        self.activityIndicatorBegin()
        self.getBusinessFromList { (businessData, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let aBusinessData = businessData {
                    let businessData = aBusinessData
                    self.gotoKYBScreen(businessData: businessData)
                } else {
                    self.gotoKYBScreen(businessData: nil)
                }
            }
        }
    }
}

// MARK: - Timer Methods
extension KYCStatusVC {

    func addRefreshDataTimer() {
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(fetchStatusDuration), repeats: true, block: { (_) in
            self.callAPIGetPersonDetails()
        })
    }

    func removeRefreshDataTimer() {
        isAutoRefreshGoingOn = false
        totalWaitTime = 0
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
}

// MARK: - API
extension KYCStatusVC {

    func callAPIGetPersonDetails() {

        totalWaitTime -= fetchStatusDuration

        self.getPersonDetails { (personeResponseBody, errorMessage) in
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                self.removeRefreshDataTimer()
                self.kycStatus = .inReview
            } else {
                if let personData = personeResponseBody, let aKYC = personData.kyc, let aKycStatus = aKYC.status {
                    self.kycStatus = aKycStatus
                }
            }
            
            self.setupData()
        }
    }
}

// MARK: - Data methods
extension KYCStatusVC {

    func setupUI() {
        lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 24)
		let labelDescFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        lblDesc.font = labelDescFont

        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor

        shouldShowCloseButton(shouldShow: false)
        btnClose.setTitle(Utility.localizedString(forKey: "close"), for: .normal)
        btnClose.setTitle(Utility.localizedString(forKey: "close"), for: .highlighted)
		let lblTitleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize17
        btnClose.titleLabel?.font = lblTitleFont
        btnClose.setTitleColor(.primaryColor, for: .normal)
    }

    func makeInitialFetchCall() {
        setupData()
        callAPIGetPersonDetails()
    }

    func shouldShowCloseButton(shouldShow: Bool) {
        btnClose.isHidden = !shouldShow
        if shouldShow {
            topConstBtnClose.constant = self.isModal ? 6.0 : 0.0
        }
    }

    func setupData() {
		if let currentKycStatus = kycStatus {
			centerConstivContainer.constant = -40

			lblTitle.text = Utility.localizedString(forKey: "kycStatus_waiting_title")
			lblDesc.text = ""
            footerView.btnApply.setTitle("", for: .normal)
			vwAnimationContainer?.animationFile = "searching"
			if currentKycStatus == .approved {
				setupDataForApproved(imageName: "success")
			} else if currentKycStatus == .declined {
				setupDataForDeclined(imageName: "failure")
			} else  if currentKycStatus == .inReview ||  totalWaitTime <= 0 {
				setupDataForReview(imageName: "searching")
			}
        }
    }

	func setupDataForApproved(imageName: String) {
		var title = ""
		var description = ""
		var buttonTitle = ""
		shouldShowCloseButton(shouldShow: true)
		title = Utility.localizedString(forKey: "kycStatus_approved_title")
		if AppGlobalData.shared().bothPersonalAndBusinessChecking {
			buttonTitle = Utility.localizedString(forKey: "next")
			description = Utility.localizedString(forKey: "kycStatus_approved_description")
		} else if AppGlobalData.shared().accTypeBusinessChecking {
			buttonTitle = Utility.localizedString(forKey: "kycStatus_approved_buttonTitle")
			description = Utility.localizedString(forKey: "kycStatus_approved_description")
		} else {
			description = Utility.localizedString(forKey: "kycStatus_approved_description_personalChecking")
			title = Utility.localizedString(forKey: "kycStatus_personchecking_approved_title")
			buttonTitle = Utility.localizedString(forKey: "next")
		}
		
		lblTitle.text = title
		lblDesc.text = description
        footerView.btnApply.setTitle(buttonTitle, for: .normal)

		vwAnimationContainer?.animationFile = imageName
		removeRefreshDataTimer()
		
        footerView.isHidden = false
		centerConstivContainer.constant = -130
	}

	func setupDataForDeclined(imageName: String) {
		var title = ""
		var description = ""
		var buttonTitle = ""

		shouldShowCloseButton(shouldShow: true)
		title = Utility.localizedString(forKey: "kycStatus_declined_title")
		description = Utility.localizedString(forKey: "kycStatus_declined_description")
		buttonTitle = Utility.localizedString(forKey: "kycStatus_declined_buttonTitle")
		removeRefreshDataTimer()
        footerView.isHidden = false
		centerConstivContainer.constant = -130

		lblTitle.text = title
		lblDesc.text = description
        footerView.btnApply.setTitle(buttonTitle, for: .normal)
		vwAnimationContainer?.animationFile = imageName
	}

	func setupDataForReview(imageName: String) {
		var title = ""
		var description = ""
		var buttonTitle = ""
		isAutoRefreshGoingOn = true
		shouldShowCloseButton(shouldShow: true)

		title = Utility.localizedString(forKey: "kycStatus_inReview_title")
		description = Utility.localizedString(forKey: "kycStatus_inReview_description")
        buttonTitle = Utility.localizedString(forKey: "refresh")
       
        footerView.isHidden = false

		centerConstivContainer.constant = -130

		lblTitle.text = title
		lblDesc.text = description
        footerView.btnApply.setTitle(buttonTitle, for: .normal)
		vwAnimationContainer?.animationFile = imageName
	}
}
