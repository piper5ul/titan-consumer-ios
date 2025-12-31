//
//  TransactionActionCell.swift
//  Solid
//
//  Created by Solid iOS Team on 12/05/21.
//

import UIKit

class TransactionActionCell: UITableViewCell {

    @IBOutlet weak var btnPDF: UIButton!
    @IBOutlet weak var btnReportIssue: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		let valueFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        btnPDF.titleLabel?.font = valueFont
        btnPDF.setTitleColor(UIColor.primaryColor, for: .normal)
        btnPDF.cornerRadius = Constants.cornerRadiusThroughApp
        btnPDF.layer.masksToBounds = true

        btnReportIssue.titleLabel?.font = valueFont
        btnReportIssue.setTitleColor(UIColor.primaryColor, for: .normal)
        btnReportIssue.cornerRadius = Constants.cornerRadiusThroughApp
        btnReportIssue.layer.masksToBounds = true
        
        btnPDF.backgroundColor = .background
        btnReportIssue.backgroundColor = .background
    }

    func configureTransactionActionData() {
        // view PDF
        btnPDF.setTitle(TransactionActionDetails.viewPDF.getTitleKey(), for: .normal)
        // report issue
        btnReportIssue.setTitle(TransactionActionDetails.reportProblem.getTitleKey(), for: .normal)
        
        btnReportIssue.isHidden = false
    }

    func configureContactInfoActionData() {
        // Make payment
        btnPDF.setTitle(Utility.localizedString(forKey: "contact_makepayment_title"), for: .normal)

        // View History
        btnReportIssue.setTitle(Utility.localizedString(forKey: "contact_paymenthistory_title"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        btnPDF.setTitleColor(UIColor.primaryColor, for: .normal)
        btnReportIssue.setTitleColor(UIColor.primaryColor, for: .normal)
    }

}
