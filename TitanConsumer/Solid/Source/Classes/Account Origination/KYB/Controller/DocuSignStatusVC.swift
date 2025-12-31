//
//  DocuSignStatusVC.swift
//  Solid
//
//  Created by Solid iOS Team on 30/01/24.
//

import UIKit

class DocuSignStatusVC: BaseVC {
	@IBOutlet weak var vwAnimationContainer: BaseAnimationView?

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var topConstBtnClose: NSLayoutConstraint!
	@IBOutlet weak var centerConstivContainer: NSLayoutConstraint!

    var disclosureStatus: DisclosureStatus? = .notStarted

    private var autoRefreshTimer: Timer?
    let fetchStatusDuration = 5.0
    var totalWaitTime = 30.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isNavigationBarHidden = true
		self.isScreenModallyPresented = true
        
        self.setFooterUI()
        setupUI()

        makeInitialFetchCall()
        addRefreshDataTimer()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		deregisterKeyboardObserver()
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
        if disclosureStatus != DisclosureStatus.completed {
            checkDisclosureStatus()
        }
    }

    @IBAction func btnCloseClicked(_ sender: Any) {
        self.closeClicked(sender: sender as! UIButton)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
    }
}

// MARK: - Timer Methods
extension DocuSignStatusVC {
    func addRefreshDataTimer() {
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(fetchStatusDuration), repeats: true, block: { (_) in
            self.checkDisclosureStatus()
        })
    }

    func removeRefreshDataTimer() {
        totalWaitTime = 0
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
}

// MARK: - UI methods
extension DocuSignStatusVC {
    func setupUI() {
		let labelfont = Utility.isDeviceIpad() ? Constants.regularFontSize18: Constants.regularFontSize14
        lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 24)
		lblTitle.textAlignment = .center
        lblDesc.font = labelfont

        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor

        shouldShowCloseButton(shouldShow: false)
        btnClose.setTitle(Utility.localizedString(forKey: "close"), for: .normal)
        btnClose.setTitle(Utility.localizedString(forKey: "close"), for: .highlighted)
		let lblTitleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize17
        btnClose.titleLabel?.font = lblTitleFont
        btnClose.setTitleColor(.primaryColor, for: .normal)
    }

    func shouldShowCloseButton(shouldShow: Bool) {
        btnClose.isHidden = !shouldShow
        if shouldShow {
            topConstBtnClose.constant = self.isModal ? 4.0 : 0.0
        }
    }

    func makeInitialFetchCall() {
        setupData()
        checkDisclosureStatus()
    }

    func setupData() {
        if let currentStatus = disclosureStatus {
            footerView.isHidden = true
			centerConstivContainer.constant = -30

            var title = Utility.localizedString(forKey: "docuSignStatus_waiting_title")
            let description = ""
            var buttonTitle = ""
            var imageName = "searching"

            if currentStatus == .completed {
                title = "" //Utility.localizedString(forKey: "success")
                imageName = "" //"success"
                removeRefreshDataTimer()
                submitKYB()
            } else if totalWaitTime <= 0 {
                shouldShowCloseButton(shouldShow: true)
                title = Utility.localizedString(forKey: "docuSignStatus_inReview_title")
                imageName = "searching"

                footerView.isHidden = false
                buttonTitle = Utility.localizedString(forKey: "refresh")

				centerConstivContainer.constant = -130
                removeRefreshDataTimer()
            }

            lblTitle.text = title
            lblDesc.text = description
            footerView.btnApply.set(title: buttonTitle)
			vwAnimationContainer?.animationFile = imageName
        }
    }
}

// MARK: - API call
extension DocuSignStatusVC {
    func checkDisclosureStatus() {
        if let bId = AppGlobalData.shared().businessData?.id {
            self.activityIndicatorBegin()
            KYBViewModel.shared.getOwnershipDisclosureLink(businessId: bId) { (response, _) in
                self.activityIndicatorEnd()
                if let data = response, let disStatus = data.status {
                    self.disclosureStatus = disStatus
                    self.setupData()
                }
            }
        }
    }
    
    //To submit KYB
    func submitKYB() {
        var postBody = SubmitBusinessPostBody()
        postBody.phone = AppGlobalData.shared().businessData?.phone
        postBody.email = AppGlobalData.shared().businessData?.email
        postBody.idNumber = AppGlobalData.shared().businessData?.idNumber
        postBody.idType = TaxType.ein.rawValue
        postBody.address = AppGlobalData.shared().businessData?.address
        
        self.activityIndicatorBegin()
        KYBViewModel.shared.submitKyb(businessId: AppGlobalData.shared().businessData?.id ?? "", businessData: postBody) { (_, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                self.gotoKYBStatusScreen(aKybStatus: AppGlobalData.shared().businessData?.kyb?.status ?? .unknown, aBusinessData: AppGlobalData.shared().businessData ?? BusinessDataModel())
            }
        }
    }
}
