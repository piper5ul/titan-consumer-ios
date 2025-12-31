//
//  DataSectionHeader.swift
//  Solid
//
//  Created by Solid iOS Team on 01/03/21.
//

import Foundation
import UIKit

class SectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var lblSectionHeader: UILabel!
    var font = UIFont()
    var editBtn = UIButton()
    var headerText: String = "" {
        didSet {
            lblSectionHeader.text = headerText
        }
    }
    
    override func awakeFromNib() {
        //lblSectionHeader.font = font
        lblSectionHeader.textColor = UIColor.primaryColor
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblSectionHeader.textColor = UIColor.primaryColor
        editBtn.setTitleColor(.secondaryColor, for: .normal)
    }
    
    func addEditHeaderBtn() {
        editBtn.frame = CGRect(x: self.frame.width - 55, y: 26, width: 80, height: 20)
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        editBtn.titleLabel?.font = titleFont
        editBtn.setTitle(Utility.localizedString(forKey: "Edit"), for: .normal)
        editBtn.setTitleColor(.secondaryColor, for: .normal)
        self.addSubview(editBtn)
    }
}
