//
//  RCDSuccessViewController.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class RCDSuccessViewController: BaseVC {

    var viewModel: RCDViewModel!

    @IBOutlet weak var rcdDataView: RCDDataView!

    @IBOutlet weak var toAccNumberLabel: UILabel!
	@IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
        self.isScreenModallyPresented = true

        self.setFooterUI()
        setupUI()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(okClicked(_:)), for: .touchUpInside)
    }
    
    @IBAction func okClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadAccountsAfterAdding), object: nil)
        self.popToHomeScreen()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
    }
}

extension RCDSuccessViewController {

    func setupUI() {
        lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 24)
        lblTitle.textColor = UIColor.primaryColor
        lblTitle.textAlignment = .center

		let labelDescFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        lblDesc.font = labelDescFont
        lblDesc.textColor = UIColor.secondaryColor
        lblDesc.textAlignment = .center

        lblTitle.text = Utility.localizedString(forKey: "RCD_successTitle")
        lblDesc.text = Utility.localizedString(forKey: "RCD_successDesc")

		vwAnimationContainer?.animationFile = "success"
        footerView.btnApply.setTitle(Utility.localizedString(forKey: "done"), for: .normal)
        setAccountNameAndNumber()
    }

    func setAccountNameAndNumber() {
		self.setAccountType()
        rcdDataView.setRCDData(accountType: accountType ?? .businessChecking, viewModel: viewModel)
    }
	
}
