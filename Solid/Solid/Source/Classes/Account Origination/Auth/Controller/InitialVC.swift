//
//  InitialVC.swift
//  Solid
//
//  Created by Solid iOS Team on 23/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit

class InitialVC: BaseVC {
    
    var initialViewModal = InitialViewModal()
    @IBOutlet weak var btnRetry: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
        btnRetry.isHidden = true
        btnRetry.setTitleColor(UIColor.red, for: .normal)
        
        if let data = AppGlobalData.getSessionData() {
            AppData.updateSession(idToken: data.idToken ?? "" as String, accessToken: data.accessToken ?? "" as String, refreshToken: data.refreshToken ?? "" as String)
            APIManager.networkEnviroment = NetworkEnvironment.getApiEnv(for: AppGlobalData.apiEnv)
        }
        
        fetchJsonData()
        goToNextScreen()
    }
    
    func fetchJsonData() {
        AppMetaDataHelper.shared.config = Utility.parseLocal("AppMetaData.json") as AppConfig
    }
    
    @IBAction func btnRetryPress(_ sender: Any) {
        self.fetchJsonData()
    }
    
    func goToNextScreen() {
        if let _ = AppGlobalData.getSessionData() {
            BiometricHelper.showAuth(sourceController: self, withScreen: true) { (shouldMoveAhead) in
                if shouldMoveAhead {
                    self.getPersonDetail(showAutoLockWithVC: self)
                }
            }
        } else {
            gotoWelcomeScreen()
        }
    }
}
