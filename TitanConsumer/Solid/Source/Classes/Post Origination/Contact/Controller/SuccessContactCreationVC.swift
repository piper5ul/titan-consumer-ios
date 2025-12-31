//
//  SuccessContactCreationVC.swift
//  Solid
//
//  Created by Solid iOS Team on 7/5/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class SuccessContactCreationVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    
    var contactData: ContactDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isNavigationBarHidden = true
        self.isScreenModallyPresented = true
        
        self.setFooterUI()
        
        self.setUI()
        
        self.addCloseButton()
    }
    
    func setUI() {
        let titlefontsize = Utility.isDeviceIpad() ? Constants.regularFontSize28 : Constants.regularFontSize24
        let descfontsize = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        
        lblTitle.font = titlefontsize
        lblDesc.font = descfontsize
        
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
        
        lblTitle.text = Utility.localizedString(forKey: "contact_creation_title")
        lblDesc.text = Utility.localizedString(forKey: "contact_creation_description")
        footerView.btnApply.setTitle(Utility.localizedString(forKey: "contact_Details_Title"), for: .normal)
        vwAnimationContainer?.animationFile = "success"
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(btnProceedClicked(_:)), for: .touchUpInside)
    }
    
    @IBAction func btnProceedClicked(_ sender: Any) {
        self.isNavigationBarHidden = false
        let storyboard = UIStoryboard.init(name: "Contact", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ContactInfoVC") as? ContactInfoVC {
            vc.contactData = self.contactData
            self.show(vc, sender: self)
        }
    }
    
    @objc override func closeClicked(sender: UIButton) {
        self.isNavigationBarHidden = false
        self.navigationController?.backToViewController(viewController: ContactsListVC.self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
    }
}
