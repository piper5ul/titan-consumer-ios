//
//  JailBrokenViewController.swift
//  Solid
//
//  Created by Solid iOS Team
//

import UIKit

class JailBrokenViewController: UIViewController {

    @IBOutlet weak var bypassButton: UIButton!
    @IBOutlet weak var lblDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize24: Constants.mediumFontSize20
        lblDescription.font = labelFont
        lblDescription.textColor = UIColor.primaryColor
        lblDescription.text = Utility.localizedString(forKey: "jailbreak_error_message")
    }
}
