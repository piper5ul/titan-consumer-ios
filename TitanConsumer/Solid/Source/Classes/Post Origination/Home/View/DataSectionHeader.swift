//
//  DataSectionHeader.swift
//  Solid
//
//  Created by Solid iOS Team on 01/03/21.
//

import Foundation
import UIKit

class DataSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var lblSectionHeader: UILabel!

    override func awakeFromNib() {
        lblSectionHeader.font = UIFont.sfProDisplayRegular(fontSize: 13.0)
        lblSectionHeader.textColor = UIColor.secondaryColorWithOpacity
    }
}
