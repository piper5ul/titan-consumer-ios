//
//  BusinessDetailsCell.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class BusinessDetailsCell: UITableViewCell {

    @IBOutlet weak var toAccNameLabel: UILabel!
    @IBOutlet weak var toAccNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setAccountNameAndNumber() {
        if let business = AppGlobalData.shared().businessData {
               toAccNameLabel.text = business.legalName
           }

        guard let acc = AppGlobalData.shared().accountData  else {
               return
           }

           if let accNo = (acc.accountNumber) {
            let checkingString = Utility.localizedString(forKey: "RCD_checkingTitle")
               let accNoString = "•••• \(accNo.substring(start: (accNo.count) - 4, end: accNo.count))"
               toAccNumberLabel.text = "\(checkingString) \(accNoString)"
           }
       }
}
