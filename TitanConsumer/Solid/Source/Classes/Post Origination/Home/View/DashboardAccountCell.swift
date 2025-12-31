//
//  DashboardAccountCell.swift
//  Solid
//
//  Created by Solid iOS Team on 09/06/21.
//

import UIKit

protocol DashboardCellDelegate: AnyObject {
    func buttonViewAccountClicked(strType: String)
}

class DashboardAccountCell: UITableViewCell {

    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var lblAccountNumber: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var imgCopy: BaseImageView!
    @IBOutlet weak var btnView: BaseButton!

    @IBOutlet weak var innerView: UIView!

    weak var dashboardCellDelegate: DashboardCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        self.lblAccountName.font = UIFont.sfProDisplayBold(fontSize: 16)
        self.lblAccountNumber.font = labelFont

        self.lblAccountNumber.textColor = UIColor.primaryColor
        self.lblBalance.font = UIFont.sfProDisplayBold(fontSize: 14.0)
        self.lblBalance.textColor = UIColor.primaryColor

        imgCopy.image = UIImage(named: "copy_black")
        imgCopy.isUserInteractionEnabled = true
        let gestureRecoAccNo = UITapGestureRecognizer(target: self, action: #selector(copyAccNumberClick))
        imgCopy.addGestureRecognizer(gestureRecoAccNo)
        
        self.innerView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        self.innerView.layer.masksToBounds = true
        setTextColor()
    }
    
    @objc func copyAccNumberClick() {
        if let accNo = AppGlobalData.shared().accountData?.accountNumber {
            let pasteboard = UIPasteboard.general
            pasteboard.string = accNo

            self.makeToast(Utility.localizedString(forKey: "cardNumber_copied"), duration: 1.3)
        }
    }
    
    func setTextColor () {
        self.lblAccountName.textColor = UIColor.primaryColor
        self.lblBalance.textColor = UIColor.primaryColor
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14

        var viewColor = UIColor()
        self.innerView.backgroundColor = .ctaColor
        self.lblAccountName.textColor = .ctaTextColor
        self.lblAccountNumber.textColor = .ctaTextColor
        self.lblBalance.textColor = .ctaTextColor
        viewColor = .ctaTextColor
        imgCopy.tintColor = .ctaTextColor
        
        let attrs = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: viewColor,
            NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]
        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitleStr = NSMutableAttributedString(string: Utility.localizedString(forKey: "statement_view"), attributes: attrs)
        attributedString.append(buttonTitleStr)
        btnView.setAttributedTitle(attributedString, for: .normal)
        btnView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnViewClicked(_ sender: UIButton) {
        dashboardCellDelegate?.buttonViewAccountClicked(strType: "ACCOUNT_DETAILS")
    }

    func configure(withModel model: DashboardCellModel) {

        if let aTitleValue = model.titleValue {
            lblAccountName.text = aTitleValue
        }
        if let aDescriptionValue = model.descriptionValue {
            lblAccountNumber.text = aDescriptionValue
        }
        if let aDescriptionValue = model.descriptionValue2 {
            lblBalance.text = aDescriptionValue
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setTextColor()
    }
}
