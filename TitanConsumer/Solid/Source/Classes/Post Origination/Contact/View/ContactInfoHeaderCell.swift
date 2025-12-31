//
//  ContactInfoHeaderCell.swift
//  Solid
//
//  Created by Solid iOS Team on 06/04/21.
//

import Foundation
import UIKit

class ContactInfoHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblAccType: UILabel!
    @IBOutlet weak var lblAccNo: UILabel!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var imgVArrow: UIImageView!

    override func awakeFromNib() {

        lblHeader.text = Utility.localizedString(forKey: "contact_Account_Title")
		let titleFont = Constants.commonFont
        lblHeader.font = titleFont
        lblHeader.textColor = UIColor.primaryColor

        lblAccType.font = titleFont
        lblAccType.textColor = UIColor.primaryColor

        lblAccNo.font = titleFont
        lblAccNo.textColor = UIColor.secondaryColor

        imgVArrow.backgroundColor = .clear
        btnExpand.backgroundColor = .clear

        self.cornerRadius = Constants.cornerRadiusThroughApp
        self.layer.masksToBounds = true
    }
}
