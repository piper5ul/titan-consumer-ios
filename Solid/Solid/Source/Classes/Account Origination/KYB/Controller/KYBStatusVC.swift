//
//  KYBStatusVC.swift
//  Solid
//
//  Created by Solid iOS Team on 14/02/21.
//

import UIKit

class KYBStatusVC: BaseVC {
	@IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var topConstBtnClose: NSLayoutConstraint!

    var kybStatus: KYBStatus? = .notStarted
    var signUrl: String!
    var businessData = BusinessDataModel()

    private var autoRefreshTimer: Timer?
    let fetchStatusDuration = 5.0
    var totalWaitTime = 15.0
	var businessId: String?
    var isAutoRefreshGoingOn = false    // Using this variable to identify auto-refresh after review state

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
        self.isScreenModallyPresented = true
        
        setupUI()
        self.setFooterUI()
        self.setupData()

        if kybStatus != .approved {
            makeInitialFetchCall()
            addRefreshDataTimer()
        }

        self.businessId = AppGlobalData.shared().businessData?.id // AppGlobalData.shared().businessId
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.isNavigationBarHidden = true
		deregisterKeyboardObserver()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.view.endEditing(true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		registerKeyboardObserver()
	}

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(btnProceedClicked(_:)), for: .touchUpInside)
    }
    
    @IBAction func btnProceedClicked(_ sender: Any) {
        if kybStatus == KYBStatus.approved {
            handleNavigationForAccountSetup()
        } else if kybStatus == KYBStatus.inReview {
            self.callAPIBusinessDetails()
        } else {
            self.openEmail()
        }
    }

    @IBAction func btnCloseClicked(_ sender: Any) {
        removeRefreshDataTimer()
        self.closeClicked(sender: sender as! UIButton)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
        btnClose.setTitleColor(.primaryColor, for: .normal)
    }
}

// MARK: - Timer Methods
extension KYBStatusVC {
    func addRefreshDataTimer() {
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(fetchStatusDuration), repeats: true, block: { (_) in
            self.callAPIBusinessDetails()
        })
    }

    func removeRefreshDataTimer() {
        isAutoRefreshGoingOn = false
        totalWaitTime = 0
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
}

// MARK: - UI methods
extension KYBStatusVC {
    func setupUI() {
		let labelfont = Utility.isDeviceIpad() ? Constants.regularFontSize18: Constants.regularFontSize14

		lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 24)
        lblDesc.font = labelfont

        lblTitle.textColor = UIColor.primaryColor
		lblTitle.textAlignment = .center
        lblDesc.textColor = UIColor.secondaryColor

        shouldShowCloseButton(shouldShow: false)
        btnClose.setTitle(Utility.localizedString(forKey: "close"), for: .normal)
        btnClose.setTitle(Utility.localizedString(forKey: "close"), for: .highlighted)
        btnClose.titleLabel?.font = labelfont
        btnClose.setTitleColor(.primaryColor, for: .normal)
    }

    func makeInitialFetchCall() {
        callAPIBusinessDetails()
    }

    func setupData() {
        if let currentKybStatus = kybStatus {
            footerView.isHidden = true
            var title = Utility.localizedString(forKey: "kybStatus_waiting_title")
            var description = ""
            var buttonTitle = ""
            var imageName = "searching"

            if currentKybStatus == .approved {
                shouldShowCloseButton(shouldShow: true)
                title = Utility.localizedString(forKey: "kybStatus_approved_title")

				description = Utility.localizedString(forKey: "kybStatus_approved_description_soleProp")
				buttonTitle = Utility.localizedString(forKey: "next")
                 imageName = "success"
                removeRefreshDataTimer()
                footerView.isHidden = false
            } else if currentKybStatus == .declined {
                shouldShowCloseButton(shouldShow: true)
                title = Utility.localizedString(forKey: "kybStatus_declined_title")
                description = Utility.localizedString(forKey: "kybStatus_declined_description")
                buttonTitle = Utility.localizedString(forKey: "kybStatus_declined_buttonTitle")
                imageName = "failure"
                removeRefreshDataTimer()
                footerView.isHidden = false
            } else if currentKybStatus == .inReview ||  totalWaitTime <= 0 {
                isAutoRefreshGoingOn = true
                shouldShowCloseButton(shouldShow: true)

                title = Utility.localizedString(forKey: "kybStatus_inReview_title")
                description = Utility.localizedString(forKey: "kybStatus_inReview_description")
                imageName = "searching"

                footerView.isHidden = false
                buttonTitle = Utility.localizedString(forKey: "refresh")
            }

            lblTitle.text = title
            lblDesc.text = description
            footerView.btnApply.set(title: buttonTitle)
            vwAnimationContainer?.animationFile = imageName
		}
    }

    func shouldShowCloseButton(shouldShow: Bool) {
        btnClose.isHidden = !shouldShow
        if shouldShow {
            topConstBtnClose.constant = self.isModal ? 4.0 : 0.0
        }
    }
}

// MARK: - API call
extension KYBStatusVC {
    func callAPIBusinessDetails() {
        if let _ = self.businessId {
            totalWaitTime -= fetchStatusDuration

            self.getBusinessDetails { (response, errorMessage) in

                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                    self.removeRefreshDataTimer()
                    self.kybStatus = .inReview
                } else {
                    if let businessData = response, let aKyb = businessData.kyb, let aKybStatus = aKyb.status {
                        self.businessData = businessData
                        self.kybStatus = aKybStatus
                    }
                }
                
                self.setupData()
            }
        }
    }
}
