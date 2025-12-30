//
//  MaintenanceVC.swift
//  Solid
//
//  Created by Solid on 19/10/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class MaintenanceVC: BaseVC {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background
        self.isNavigationBarHidden = true
        
        let strTitle = Utility.localizedString(forKey: "solid_maintenance_title")
        let localizedStrStatusText = Utility.localizedString(forKey: "solid_maintenance_statusCheck")
        let localizedStrDescText = Utility.localizedString(forKey: "solid_maintenance_description")

        let strDesc =  String(format: localizedStrDescText, localizedStrStatusText)

        lblTitle.text = strTitle
        lblDesc.text = strDesc
        imgV.image = UIImage(named: "maintenance")
        
        let titleFont = Utility.isDeviceIpad() ? Constants.boldFontSize28 : Constants.boldFontSize24
        let descFont = Utility.isDeviceIpad() ? Constants.mediumFontSize20 : Constants.mediumFontSize16

        lblTitle.font = titleFont
        lblDesc.font = descFont
        
        lblTitle.textColor = .primaryColor
        lblDesc.textColor = .secondaryColor
    }
}
