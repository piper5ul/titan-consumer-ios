//
//  LoginCreatedVC.swift
//  Solid
//
//  Created by Solid iOS Team on 05/02/21.
//

import UIKit

class LoginCreatedVC: BaseVC {
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    
    var mobileNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setNavigationBar()
        self.setData()
        self.setFooterUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        isNavigationBarHidden = true
        isScreenModallyPresented = true
    }
    
    func setData() {
        let titlefontsize = Utility.isDeviceIpad() ? Constants.regularFontSize28 : Constants.regularFontSize24
        let descfontsize = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        
        lblTitle.font = titlefontsize
        lblDesc.font = descfontsize
        
        lblTitle.text = Utility.localizedString(forKey: "loggedIn_title")
        lblDesc.text = Utility.localizedString(forKey: "loggedIn_desc")
        
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
        
        vwAnimationContainer?.animationFile = "success"
    }
    
    func setFooterUI() {
        self.shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "loggedIn_buttonTitle"))
        footerView.btnApply.addTarget(self, action: #selector(btnClickProceed(sender:)), for: .touchUpInside)
    }
    
    @IBAction func btnClickProceed(sender: UIButton) {
        Segment.addSegmentEvent(name: .proceedPersonal)
        
        let storedPin = Security.fetchPin()
        if storedPin == nil {
            createAutoLockPIN()
        } else {
            self.gotoPersonDetailScreen()
        }
    }
    
    func gotoPersonDetailScreen() {
        self.performSegue(withIdentifier: "GoToKYC", sender: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
    }
}

// MARK: - Other methods
extension LoginCreatedVC {
    func createAutoLockPIN() {
        if !BiometricHelper.devicePasscodeEnabled() {
            let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
            let autolockVC = storyboard.instantiateViewController(withIdentifier: "PinVC") as? PinVC
            let navController = UINavigationController(rootViewController: autolockVC!)
            if !(Security.hasPin()) {
                autolockVC?.context = .creatPin
                self.present(navController, animated: true, completion: nil)
                autolockVC?.onPinSuccess = {
                    AppGlobalData.shared().storeSessionData()
                    self.gotoPersonDetailScreen()
                }
            }
        } else {
            AppGlobalData.shared().storeSessionData()
            self.gotoPersonDetailScreen()
        }
    }
}
