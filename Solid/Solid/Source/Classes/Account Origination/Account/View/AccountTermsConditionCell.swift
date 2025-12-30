//
//  AccountTermsConditionCell.swift
//  Solid
//
//  Created by Solid iOS Team on 30/04/21.
//

import UIKit

protocol AccountTermsCellDelegate: AnyObject {
    func termLinkClick(withURL: URL)
    func shouldCreatePhysicalCard(cardEnable: Bool)
    func isTermsAgreed(termsAgreed: Bool)
}

class AccountTermsConditionCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var txtVwTerms: UITextView!
    @IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var cardContainerView: UIView!
	@IBOutlet weak var termsContainerView: UIView!
    @IBOutlet weak var imgVwSeparator: UIImageView!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var cardEnableSwitch: UISwitch!
	@IBOutlet weak var maincontainerTop: NSLayoutConstraint!
	@IBOutlet weak var cardcontainerHeight: NSLayoutConstraint!
    @IBOutlet weak var checkboxTerms: UIButton!

    weak var termsDelegate: AccountTermsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkboxTerms.setBackgroundImage(UIImage(named: "checkbox_unSelected"), for: .normal)
        checkboxTerms.tintColor = .primaryColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func configureUI() {
        cardEnableSwitch.isOn = false
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize18: Constants.mediumFontSize16
        self.lblTitle.font = labelFont
        self.lblTitle.text = Utility.localizedString(forKey: "acc_setup_cardoption_title")

		let lblTermsFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize17
        self.lblTerms.font = lblTermsFont
        self.lblTerms.textColor = .secondaryColor

        mainContainerView.layer.cornerRadius = Constants.cornerRadiusThroughApp
        mainContainerView.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
        mainContainerView.layer.borderWidth = 1.0
        mainContainerView.layer.borderColor = UIColor.customSeparatorColor.cgColor
        showTermsText()

        imgVwSeparator.backgroundColor = UIColor.customSeparatorColor
		
        if let isSendCardByMailVisible = AppMetaDataHelper.shared.config?.validateFlag?.isSendCardByMailVisible, !isSendCardByMailVisible {
            cardcontainerHeight.constant = 0
            cardEnableSwitch.isHidden = true
            imgVwSeparator.isHidden = true
        }
        
        mainContainerView.backgroundColor = .clear
    }

    func showTermsText() {
        let strTerms = Utility.localizedString(forKey: "acc_setup_term_label")
        let lcbBankTermLinkString = Utility.localizedString(forKey: "acc_setup_lcbBankTerm_link")
        let solidBankTermLinkString = Utility.localizedString(forKey: "acc_setup_solidBankTerm_link")
        lblTerms.text = strTerms
        
        let strLinks = "\n" + lcbBankTermLinkString + "\n" + solidBankTermLinkString
        let colorAttriString = NSMutableAttributedString(string: strLinks)
        let rangeEbank = (strLinks as NSString).range(of: lcbBankTermLinkString)
        let rangeSbank = (strLinks as NSString).range(of: solidBankTermLinkString)

        let fullTextRange = (strLinks as NSString).range(of: strLinks)
        let paragraph = NSMutableParagraphStyle()

        paragraph.lineSpacing = 5.0
        colorAttriString.addAttributes([.paragraphStyle: paragraph, .foregroundColor: UIColor.secondaryColorWithOpacity, .font: UIFont.sfProDisplayRegular(fontSize: 17.0)], range: fullTextRange)

        if let config = AppMetaDataHelper.shared.config,
           let lcbBankTermsLink = config.lcbBankTermsLink, !lcbBankTermsLink.isEmpty,
           let solidBankTermsLink = config.platformTerms, !solidBankTermsLink.isEmpty {
            colorAttriString.addAttribute(.link, value: lcbBankTermsLink, range: rangeEbank)
            colorAttriString.addAttribute(.link, value: solidBankTermsLink, range: rangeSbank)
        }

        txtVwTerms.attributedText = colorAttriString
        paragraph.alignment = .left

        if #available(iOS 13.0, *) {
            txtVwTerms.linkTextAttributes = [.foregroundColor: UIColor.systemIndigo, .underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.sfProDisplayRegular(fontSize: 17.0)]
        } else {
            txtVwTerms.linkTextAttributes = [.foregroundColor: UIColor.blue, .underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.sfProDisplayRegular(fontSize: 17.0)]
        }
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        termsDelegate?.termLinkClick(withURL: URL)

        return false
    }

    @IBAction func termsSwitchValueChanged(_ sender: Any) {
        termsDelegate?.shouldCreatePhysicalCard(cardEnable: cardEnableSwitch.isOn)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        mainContainerView.layer.borderColor = UIColor.customSeparatorColor.cgColor
        self.lblTerms.textColor = .secondaryColor
        checkboxTerms.tintColor = .primaryColor
    }
    
    @IBAction func termsAndConditionTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setBackgroundImage(UIImage(named: "checkbox_selected"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "checkbox_unSelected"), for: .normal)
        }
        termsDelegate?.isTermsAgreed(termsAgreed: sender.isSelected)
    }
}
