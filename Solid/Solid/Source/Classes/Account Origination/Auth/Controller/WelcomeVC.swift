//
//  WelcomeVC.swift
//  Solid
//
//  Created by Solid iOS Team on 05/02/21.
//

import UIKit
import Reachability

class WelcomeVC: BaseVC {

    @IBOutlet weak var logoImageV: BaseImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var prodtestButton: UIButton!
    @IBOutlet weak var prodliveButton: UIButton!
    @IBOutlet weak var prodtestLabel: UILabel!
    @IBOutlet weak var prodliveLabel: UILabel!
    @IBOutlet weak var prodtestImageV: UIImageView!
    @IBOutlet weak var prodliveImageV: UIImageView!
    @IBOutlet weak var prodtestContainerView: UIView!
    @IBOutlet weak var prodliveContainerView: UIView!
    @IBOutlet weak var prodtestArrowImageV: UIImageView!
    @IBOutlet weak var prodliveArrowImageV: UIImageView!

    @IBOutlet weak var getStartedButton: ColoredButton!
    @IBOutlet weak var getStartedContainerStack: UIStackView!

    var initialViewModal = InitialViewModal()

    var dummyTextField: UITextField?
	var localizedTitle: String?
	var getStartedTitle: String?

    let reachability = try? Reachability()
    var isreachable: Bool = true

    var setupLiveModeOnly: Bool = true {
        didSet {
            handleViews()
            APIManager.networkEnviroment = setupLiveModeOnly ? .productionLive : .productionTest
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //ADD TARGET NAME TO SUPPORT LIVE MODE ONLY...
        
        if let isTestMode = AppMetaDataHelper.shared.config?.validateFlag?.isTestModeEnabled {
            setupLiveModeOnly = !isTestMode
        }
        
        setupUI()
        setData()
        setEnvironmentSelectoion()
        addObserverForNotification()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObserverForNotification()
    }

    func setEnvironmentSelectoion() {
        getStartedTitle = ""
        localizedTitle = ""
        let font = Utility.isDeviceIpad() ? Constants.regularFontSize24 : Constants.regularFontSize12
        prodtestLabel.text = Utility.localizedString(forKey: "prod_test")
        prodtestLabel.font = font
        prodtestLabel.textColor = .primaryColor
        prodliveLabel.text = NetworkEnvironment.productionLive.localizeDescription()
        prodliveLabel.font = font
        prodliveLabel.textColor = .primaryColor
        getStartedButton.isEnabled = true
        getStartedButton.set(title: Utility.localizedString(forKey: "Restart_get_started_button_title"))
    }
    
	@IBAction func btnRadioCategoryClicked(_ sender: UIButton) {
        AppConfigurations.configureSegment()
        APIManager.networkEnviroment = (sender.tag == 1) ? .productionTest : .productionLive
        gotoMobileScreen()
	}

    func gotoMobileScreen() {
        self.performSegue(withIdentifier: "GoToMobileNumberScreen", sender: self)
    }
}

// MARK: - Reachability
extension WelcomeVC {
    func addObserverForNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    func removeObserverForNotification() {
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi, .cellular:
            if !isreachable {
                self.getPersonDetail(showAutoLockWithVC: self)
            }
        case .none, .unavailable:
            isreachable = false
        }
    }
}

// MARK: - Other methods
extension WelcomeVC {

    func hideViews() {
        lblDesc.isHidden = true
        prodtestContainerView.isHidden = true
        prodliveContainerView.isHidden = true
        getStartedContainerStack.isHidden = true
	}
    
    func handleViews() {
        prodtestContainerView.isHidden = setupLiveModeOnly
        prodliveContainerView.isHidden = setupLiveModeOnly
        getStartedContainerStack.isHidden = setupLiveModeOnly ? false : true
    }
    
    func setupUI() {

        self.view.backgroundColor = .background
        
        prodtestContainerView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        prodtestContainerView.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
        prodtestContainerView.layer.borderWidth = 1.0
        prodtestContainerView.layer.borderColor = UIColor.customSeparatorColor.cgColor
        prodtestContainerView.backgroundColor = .background

        prodliveContainerView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        prodliveContainerView.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
        prodliveContainerView.layer.borderWidth = 1.0
        prodliveContainerView.layer.borderColor = UIColor.customSeparatorColor.cgColor
        prodliveContainerView.backgroundColor = .background

        prodtestImageV.layer.cornerRadius = prodtestImageV.frame.height/2
        prodtestImageV.layer.masksToBounds = prodtestImageV.frame.height/2 > 0
        prodtestImageV.backgroundColor = UIColor.orangeMain //UIColor(hexString: "#FFAC4A")
        prodliveImageV.layer.cornerRadius = prodliveImageV.frame.height/2
        prodliveImageV.layer.masksToBounds = prodliveImageV.frame.height/2 > 0
        prodliveImageV.backgroundColor = UIColor.greenMain

        prodtestArrowImageV.image = UIImage(named: "Chevron-right-grey")
        prodliveArrowImageV.image = UIImage(named: "Chevron-right-grey")

        logoImageV.image = UIImage(named: "launch_icon")
    }

    func setData() {
		let font = Utility.isDeviceIpad() ? Constants.regularFontSize28 : Constants.regularFontSize14
		lblTitle.font = Utility.isDeviceIpad() ? Constants.regularFontSize48 : Constants.regularFontSize24
		lblDesc.font = font
        let localizedTitle = Utility.localizedString(forKey: "welcome_title")
        lblTitle.text = String(format: localizedTitle, AppMetaDataHelper.shared.getAppName)

        let localizedDesc = Utility.localizedString(forKey: "welcome_desc")
        let strDesc = String(format: localizedDesc, AppMetaDataHelper.shared.getAppName)

        lblDesc.text = strDesc
       // btnGetStarted.setTitle(Utility.localizedString(forKey: "welcome_buttonTitle"), for: .normal)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = segue.destination as? MobileNumberVC {
            Segment.addSegmentEvent(name: .getStarted)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        prodtestContainerView.layer.borderColor = UIColor.customSeparatorColor.cgColor
        prodliveContainerView.layer.borderColor = UIColor.customSeparatorColor.cgColor
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
        prodtestLabel.textColor = .primaryColor
        prodliveLabel.textColor = .primaryColor
    }
}
