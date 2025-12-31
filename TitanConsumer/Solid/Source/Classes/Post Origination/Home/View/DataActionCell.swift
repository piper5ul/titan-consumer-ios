//
//  DataActionCell.swift
//  Solid
//
//  Created by Solid iOS Team on 01/03/21.
//

import Foundation
import UIKit

@objc protocol DataActionCellDelegate {
    @objc optional func actionButtonClicked(for type: String)
    @objc optional func actionSwitchValueChanged(isOn: Bool)
}

class DataActionCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblrightValue: UILabel!
    @IBOutlet weak var lblcenterValue: UILabel!
    
    @IBOutlet weak var lblContactInitial: UILabel!
    
    @IBOutlet weak var imgIcon: BaseImageView!
    @IBOutlet weak var detailIcon: UIImageView!
    @IBOutlet weak var lockSwitch: UISwitch!
    @IBOutlet weak var btnAccesory: BaseButton!
    
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInitialWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var imgSeperator: UIImageView!
    
    weak var delegate: DataActionCellDelegate?
    
    override func awakeFromNib() {
        imgIcon.isHidden = false
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblTitle.font = labelFont
        lblTitle.textAlignment = .left
        lblTitle.textColor = .primaryColor
        lblValue.font = labelFont
        lblrightValue.font = titleFont
        lblValue.textColor = UIColor.secondaryColorWithOpacity
        lblValue.textAlignment = .left
        lblcenterValue.font = labelFont
        lblcenterValue.textAlignment = .left
        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: UIColor.primaryColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let btnTitle = Utility.localizedString(forKey: "dashboard_row_pay_title")
        let attributedString = NSMutableAttributedString(string: btnTitle, attributes: attrs)
        btnAccesory.setAttributedTitle(NSAttributedString(attributedString: attributedString), for: .normal)
        btnAccesory.backgroundColor = UIColor.clear
        
        innerView.backgroundColor = .background
        outerView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = .primaryColor
        lblValue.textColor = UIColor.secondaryColorWithOpacity
        lblContactInitial.textColor = .brandColor
        lblcenterValue.textColor = .primaryColor
        
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: UIColor.primaryColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedString = NSMutableAttributedString(string: btnAccesory.titleLabel?.text ?? "", attributes: attrs)
        btnAccesory.setAttributedTitle(NSAttributedString(attributedString: attributedString), for: .normal)
        
        self.innerView.borderColor = .customSeparatorColor
    }
    
    @IBAction func btnAccessoryClicked(_ sender: Any) {
        if let btn = sender as? BaseButton, let btnTitle = btn.titleLabel, let btnText = btnTitle.text {
            delegate?.actionButtonClicked?(for: btnText)
        }
    }
    
    @IBAction func switchAccessoryValueChanged(_ sender: Any) {
        let accessorySwitch = sender as! UISwitch
        delegate?.actionSwitchValueChanged?(isOn: accessorySwitch.isOn)
    }
    
    func configureCell(forRow rowData: AccountRowData, hideSeparator: Bool = false) {
        showData(forRow: rowData, hideSeparator: hideSeparator)
    }
    
    func showData(forRow rowData: AccountRowData, hideSeparator: Bool = false) {
        lblTitle.text = rowData.key
        lblValue.text = rowData.value as? String
        imgIcon.image = nil
        titleBottomConstraint.constant = -10
        titleLeadingConstraint.constant = 15
        
        let shouldShowDetail = rowData.cellType == .detail
        let shouldShowSwitch = rowData.cellType == .switched
        
        showDetailIcon(shouldShow: shouldShowDetail)
        showlockSwitch(shouldShow: shouldShowSwitch)
        
        lblContactInitial.font = UIFont.sfProDisplayRegular(fontSize: 24)
    }
    
    func configureContactListCell(forRow rowData: ContactDataModel, hideSeparator: Bool = false) {
        lblTitle.text = rowData.name
        lblValue.text = ""
        
        titleBottomConstraint.constant = -10 // SET IT TO 0 WHEN VALUE OF lblValue.text IS SET
        titleLeadingConstraint.constant = 80
        
        imgIcon.image = nil
        imgIcon.makeIconImageView(for: "")
        showDetailIcon(shouldShow: true)
        showInitialLabel(shouldShow: true)
        
        contactInitialWidthConstraint.constant = 35
        lblContactInitial.text = rowData.iconImageLetter?.uppercased()
        lblContactInitial.layer.cornerRadius = Constants.cornerRadiusThroughApp
        lblContactInitial.layer.masksToBounds = true
        lblContactInitial.backgroundColor = UIColor.grayBackgroundColor
        lblContactInitial.textColor = .brandColor
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblContactInitial.font = labelFont
        lblContactInitial.textAlignment = .center
        lblcenterValue.font = labelFont
        
        innerView.backgroundColor = .clear
        self.backgroundColor = .background
    }
    
    func configureStatementCell(forRow rowData: StatementDataModel, hideSeparator: Bool = false) {
        let month = rowData.month ?? 0
        let year = rowData.year ?? 0
        let xmonthString = String(month)
        let xyearString  = String(year)
        
        let titleString = xmonthString + "/" + xyearString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        if let dat = dateFormatter.date(from: titleString) {
            dateFormatter.dateFormat = "MMM yyyy"
            let sDate = dateFormatter.string(from: dat)
            lblTitle.text = sDate
        }
        
        if let generatedDate = rowData.createdAt {
            let gDate = (generatedDate.utcDateTo(formate: "MMM dd, yyyy") ?? "") as String
            lblValue.text = "Generated on \(gDate)"
        }
        
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        let attrs = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: UIColor.primaryColor,
            NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]
        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitleStr = NSMutableAttributedString(string: Utility.localizedString(forKey: "statement_view"), attributes: attrs)
        attributedString.append(buttonTitleStr)
        btnAccesory.setAttributedTitle(attributedString, for: .normal)
        btnAccesory.layer.borderWidth = 0
        
        lblValue.textColor = UIColor.secondaryColor
        
        showDetailIcon(shouldShow: false)
        showInitialLabel(shouldShow: false)
        shouldShowAccessoryButton(shouldShow: true)
    }
    
    func showDetailIcon(shouldShow: Bool) {
        detailIcon.isHidden = !shouldShow
    }
    
    func showlockSwitch(shouldShow: Bool) {
        lockSwitch.isHidden = !shouldShow
    }
    
    func showInitialLabel(shouldShow: Bool) {
        lblContactInitial.isHidden = !shouldShow
    }
    
    func shouldShowAccessoryButton(shouldShow: Bool) {
        btnAccesory.isHidden = !shouldShow
    }
    
    func configureAccountTypeCell(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        showAccountTypeData(forRow: rowData, hideSeparator: hideSeparator)
    }
    
    func showAccountTypeData(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        lblcenterValue.text = rowData.key
        
        lblTitle.isHidden = true
        lblcenterValue.isHidden = false
        
        showDetailIcon(shouldShow: true)
        
        let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        lblcenterValue.font = labelFont
        lblcenterValue.textColor = .primaryColor
    }
    
    func configureContactCell(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        showContactData(forRow: rowData, hideSeparator: hideSeparator)
    }
    
    func showContactData(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        lblcenterValue.text = rowData.key
        
        lblTitle.isHidden = true
        lblcenterValue.isHidden = false
        
        let shouldShowDetail = rowData.cellType == .detail
        let shouldShowSwitch = rowData.cellType == .switched
        let shouldShowButton = rowData.cellType == .btn
        
        if shouldShowSwitch {
            lockSwitch.isOn = rowData.isSwitchOn ?? false
        }
        showDetailIcon(shouldShow: shouldShowDetail)
        showlockSwitch(shouldShow: shouldShowSwitch)
        shouldShowAccessoryButton(shouldShow: shouldShowButton)
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblcenterValue.font = labelFont
        lblcenterValue.textColor = .primaryColor
        
        imgIcon.image = nil
        imgIcon.makeIconImageView(for: "")
    }
    
    func configureCardDetailsCell(forRow rowData: CardRowData, hideSeparator: Bool = false) {
        showCardData(forRow: rowData, hideSeparator: hideSeparator)
    }
    
    func showCardData(forRow rowData: CardRowData, hideSeparator: Bool = false) {
        lblTitle.text = rowData.key
        lblValue.text = ""
        // imgIcon.makeIconImageView(for: rowData.iconName ?? "")
        
        let shouldShowDetail = rowData.cellType == .detail
        let shouldShowSwitch = rowData.cellType == .switched
        showDetailIcon(shouldShow: shouldShowDetail)
        showlockSwitch(shouldShow: shouldShowSwitch)
        
        let shouldShowButton = rowData.cellType == .btn
        shouldShowAccessoryButton(shouldShow: shouldShowButton)
        
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        let attrs = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: UIColor.primaryColor,
            NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]
        
        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitleStr = NSMutableAttributedString(string: Utility.localizedString(forKey: "Edit"), attributes: attrs)
        attributedString.append(buttonTitleStr)
        btnAccesory.setAttributedTitle(attributedString, for: .normal)
        btnAccesory.layer.borderWidth = 0
        
        titleBottomConstraint.constant = -10
    }
    
    func configureProfileCell(forRow rowData: UserProfileRowData, hideSeparator: Bool = false) {
        showData(forRow: rowData, hideSeparator: hideSeparator)
    }
    
    func showData(forRow rowData: UserProfileRowData, hideSeparator: Bool = false) {
        lblTitle.text = rowData.key
        lblValue.text = "" // rowData.value as? String
        let shouldShowDetail = rowData.cellType == .detail
        let shouldShowSwitch = rowData.cellType == .switched
        
        showDetailIcon(shouldShow: shouldShowDetail)
        showlockSwitch(shouldShow: shouldShowSwitch)
        
        titleBottomConstraint.constant = -10
    }
    
    func configureCardInfoCell(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        showCardInfoData(forRow: rowData, hideSeparator: hideSeparator)
    }
    
    func showCardInfoData(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        lblTitle.text = ""
        lblValue.text = ""
        lblcenterValue.text = rowData.key
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblcenterValue.font = labelFont
        lblcenterValue.textColor = .primaryColor
        
        imgIcon.makeIconImageView(for: rowData.iconName ?? "")
        lblcenterValue.isHidden = false
        let shouldShowDetail = rowData.cellType == .detail
        let shouldShowSwitch = rowData.cellType == .switched
        if shouldShowSwitch {
            lockSwitch.isOn = rowData.isSwitchOn ?? false
        }
        showDetailIcon(shouldShow: shouldShowDetail)
        showlockSwitch(shouldShow: shouldShowSwitch)
        
        let shouldShowButton = rowData.cellType == .btn
        if shouldShowButton {
            let btnTitle = rowData.title ?? Utility.localizedString(forKey: "contact_row_pay_title")
            let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
            let attrs = [
                NSAttributedString.Key.font: titleFont,
                NSAttributedString.Key.foregroundColor: UIColor.primaryColor,
                NSAttributedString.Key.underlineStyle: 1] as [NSAttributedString.Key: Any]
            
            let attributedString = NSMutableAttributedString(string: "")
            let buttonTitleStr = NSMutableAttributedString(string: btnTitle, attributes: attrs)
            attributedString.append(buttonTitleStr)
            btnAccesory.setAttributedTitle(attributedString, for: .normal)
            btnAccesory.layer.borderWidth = 0
        }
        shouldShowAccessoryButton(shouldShow: shouldShowButton)
    }
    
    func configureCardTypeSelection(cardType: String, cardDesc: String) {
        showCardTypeSelection(cardType: cardType, cardDesc: cardDesc)
    }
    
    func showCardTypeSelection(cardType: String, cardDesc: String) {
        self.lblTitle.text = cardType
        self.lblValue.text = cardDesc
        self.showDetailIcon(shouldShow: true)
        self.selectionStyle = .none
        
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        self.lblTitle.font = titleFont
        self.lblTitle.textColor = UIColor.primaryColor
        self.titleBottomConstraint.constant = -10
        
        self.innerView.cornerRadius = Constants.cornerRadiusThroughApp
        self.innerView.layer.masksToBounds = true
        self.innerView.borderColor = .customSeparatorColor
        self.innerView.borderWidth = 1
        
        detailIcon.image = UIImage(named: "Chevron-right")
    }
    
    func configureFundCell(forRow rowData: ContactRowData) {
        showFundData(forRow: rowData)
    }
    
    func showFundData(forRow rowData: ContactRowData) {
        lblTitle.text = rowData.key
        lblValue.text = rowData.value as? String
        imgIcon.image = nil
        let shouldShowDetail = rowData.cellType == .detail
        self.showDetailIcon(shouldShow: shouldShowDetail)
        detailIcon.image = UIImage(named: "Chevron-right")
        lblTitle.font = Constants.commonFont
        lblValue.font = Utility.isDeviceIpad() ? Constants.regularFontSize16 : Constants.regularFontSize12
        lblValue.textColor = UIColor.secondaryColor
        
        if rowData.key == Utility.localizedString(forKey: "fund_row_title") {
            self.showDetailIcon(shouldShow: true)
            detailIcon.image = UIImage(named: "down")
        }
    }
    
    func showFundLinkedAccountData() {
        lblTitle.isHidden = true
        lblcenterValue.isHidden = false
        
        showDetailIcon(shouldShow: true)
        
        let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        lblcenterValue.font = labelFont
        lblcenterValue.textColor = .primaryColor
    }
    
    func configureTransactionDetail (hideSeparator: Bool = false) {
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        self.lblcenterValue.font = labelFont
        self.lblTitle.text = ""
        self.lblcenterValue.isHidden = false
        self.showDetailIcon(shouldShow: true)
        self.selectionStyle = .none
    }
}
