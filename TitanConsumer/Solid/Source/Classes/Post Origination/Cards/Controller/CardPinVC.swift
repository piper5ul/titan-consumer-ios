//
//  CardPinVC.swift
//  Solid
//
//  Created by Solid iOS Team on 14/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit
import VGSShowSDK
import VGSCollectSDK

class CardPinVC: BaseVC {
    
    @IBOutlet weak var initialPinView: UIView!
    @IBOutlet weak var firstPinView: UIView!
    @IBOutlet weak var secondaryPinView: UIView!

    @IBOutlet weak var initialPinlbl: UILabel!
    @IBOutlet weak var firstPinlbl: UILabel!
    @IBOutlet weak var secondaryPinlbl: UILabel!
    @IBOutlet weak var lblDisclaimer: UILabel!
    
    @IBOutlet weak var otpViewInital: PINOTPView!
    @IBOutlet weak var otpViewSecond: PINOTPView!
    @IBOutlet weak var otpViewThird: PINOTPView!
    
    var pinCardModel: CardModel?
    let vgsCollect = VGSCollect(id: Config.VGS.vaultId, environment: Config.VGS.VGSEnv.rawValue)
    var path = String()
    var cardId = String()
    var otpViewInitalStr: String = ""
    var otpViewSecondStr: String = ""
    var otpViewThirdStr: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupInitialUI()
        setFooterUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setUpThemeColor()
    }
}

// MARK: - UI methods
extension CardPinVC {
    
    func setupInitialUI() {
        
        initialPinlbl.textAlignment = .left
        firstPinlbl.textAlignment = .left
        lblDisclaimer.textAlignment = .left
        
        initialPinlbl.text = Utility.localizedString(forKey: "enter_pin_text")
        firstPinlbl.text = Utility.localizedString(forKey: "re-enter_pin_text")
        secondaryPinView.isHidden = true
        
        otpViewInital.otpFieldsCount = 4
        otpViewInital.otpFieldBorderWidth = 2
        otpViewInital.delegate = self
        otpViewInital.shouldAllowIntermediateEditing = false
        otpViewInital.otpFieldDisplayType = .square
        otpViewInital.otpFieldEntrySecureType = true
        otpViewInital.initializeUI()

        otpViewSecond.otpFieldsCount = 4
        otpViewSecond.otpFieldBorderWidth = 2
        otpViewSecond.delegate = self
        otpViewSecond.shouldAllowIntermediateEditing = false
        otpViewSecond.otpFieldDisplayType = .square
        otpViewSecond.otpFieldEntrySecureType = true
        otpViewSecond.initializeUI()
        
        otpViewThird.otpFieldsCount = 4
        
        otpViewThird.otpFieldBorderWidth = 2
        otpViewThird.delegate = self
        otpViewThird.shouldAllowIntermediateEditing = false
        otpViewThird.otpFieldDisplayType = .square
        otpViewThird.initializeUI()
        otpViewThird.isHidden = true
        
        let font = Utility.isDeviceIpad() ? Constants.regularFontSize18: Constants.regularFontSize14
        initialPinlbl.font = font
        firstPinlbl.font = font
        setUpThemeColor()
    
        if let cardID = pinCardModel?.id {
            self.cardId = cardID
        }
    }
    
    func setUpThemeColor() {
        otpViewInital.otpFieldDefaultBorderColor = UIColor(red: 0.93, green: 0.938, blue: 0.946, alpha: 1)
        otpViewInital.otpFieldEnteredBorderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        otpViewInital.otpFieldErrorBorderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)

        otpViewSecond.otpFieldDefaultBorderColor = UIColor(red: 0.93, green: 0.938, blue: 0.946, alpha: 1)
        otpViewSecond.otpFieldEnteredBorderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        otpViewSecond.otpFieldErrorBorderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        otpViewThird.otpFieldDefaultBorderColor = UIColor.systemBackground
        otpViewThird.otpFieldEnteredBorderColor = UIColor.systemBackground
        otpViewThird.otpFieldErrorBorderColor = UIColor.systemBackground
        initialPinlbl.textColor = UIColor.primaryColor
        firstPinlbl.textColor = UIColor.primaryColor
        
        let description = Utility.localizedString(forKey: "pin_use_desclaimer") + " " + Utility.localizedString(forKey: "learn_more")
        lblDisclaimer.text = description
        let colorText = Utility.localizedString(forKey: "learn_more")
        let colorAttriString = description.getBoldString(bold: colorText, withColor: .primaryColor)
        lblDisclaimer.attributedText = colorAttriString
        lblDisclaimer.isUserInteractionEnabled = true
        lblDisclaimer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(learnMoreCall(gesture:))))
    }

    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        addBackNavigationbarButton()
        self.title = Utility.localizedString(forKey: "set_ATM_Pin")
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "done"))
        footerView.btnApply.addTarget(self, action: #selector(doneClick(_:)), for: .touchUpInside)
        self.footerView.btnApply.isEnabled = false
    }
    
    @objc func learnMoreCall(gesture: UITapGestureRecognizer) {
        
        guard let textT = self.lblDisclaimer.text else { return }
        
        let learnMoreText = Utility.localizedString(forKey: "learn_more")
        let learnMoreTxtRange = (textT as NSString).range(of: learnMoreText)
        
        let learnMoreRange = NSRange.init(location: learnMoreTxtRange.location, length: learnMoreTxtRange.length)
        
        if gesture.didTapAttributedTextInLabel(label: self.lblDisclaimer, inRange: learnMoreRange), let config = AppMetaDataHelper.shared.config, let helpCenterLink = config.helpCenterLink, !helpCenterLink.isEmpty {
            WebViewHelperVC.present(source: self, path: helpCenterLink, title: Utility.localizedString(forKey: "profile_helpcenter"))
        }
    }

    @IBAction func doneClick(_ : UIButton) {
        if otpViewInitalStr != otpViewSecondStr {
            self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "pin_mismatch_error"))
            otpViewInital.removeOtherText()
            otpViewSecond.removeOtherText()
            otpViewThird.removeOtherText()
            return
        }
        getCardPinToken()
    }
}

//API Manages
extension CardPinVC {
    
    func getCardPinToken() {
        if let aCardModel = self.pinCardModel, let cardId = aCardModel.id {
            self.activityIndicatorBegin()
            CardViewModel.shared.getCardPinToken(cardId: cardId) { (response, errorMessage) in
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                    self.activityIndicatorEnd()
                } else {
                    CardViewModel.shared.cardPinModal = response
                    self.setVGSPinToken(sdPinToken: response?.pinToken ?? "")
                }
            }
        }
    }
        
    func setVGSPinToken(sdPinToken: String) {
        
        let param = ["pin": otpViewInitalStr,
                     "expiryMonth": pinCardModel?.expiryMonth ,
                     "expiryYear": pinCardModel?.expiryYear ,
                     "last4": pinCardModel?.last4 ]

        CardViewModel.shared.setVGSPinToken(cardId: self.cardId, cardSdToken: sdPinToken, params: param as [String: Any]) { (isCardAdded, errorMessage) in

            if !self.activityIndicator.isHidden {
                self.activityIndicatorEnd()
            }

            if let _ = isCardAdded {
                self.alert(src: self, Utility.localizedString(forKey: "pin_set_success"), "", Utility.localizedString(forKey: "ok")) { button in
                      if button == 1 {
                          self.navigationController?.popViewController(animated: true)
                      }
                }
            } else {
                self.showAlertMessage(titleStr: "", messageStr: errorMessage ?? "")
            }
        }
    }
}

extension CardPinVC: PINOTPViewDelegate {

    func hasEnteredAllOTP(hasEntered: Bool, otpViewType: UIView) -> Bool {        
        if otpViewType == otpViewInital {
            if otpViewInitalStr.count == 4 {
                let rules: [ValidationRule] = [ NoConsecutiveDigitsRule(), NonRepeatRule()]
                if !(otpViewInitalStr.isValid(rules: rules)) {
                    self.initializeValuesAfterValidation()
                    self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "pincombination_error"))
                }
            } else if hasEntered && otpViewSecondStr.count == 4 {
                footerView.btnApply.isEnabled = true
            } else {
                footerView.btnApply.isEnabled = false
            }
        } else {
            if hasEntered && otpViewInitalStr.count == 4 {
                footerView.btnApply.isEnabled = true
            } else {
                footerView.btnApply.isEnabled = false
            }
        }
        return true
    }
    
    func initializeValuesAfterValidation() {
        otpViewInitalStr = ""
        otpViewSecondStr = ""
        otpViewInital.removeSecureData()
        otpViewSecond.removeOtherText()
        otpViewSecond.removeSecureData()
        footerView.btnApply.isEnabled = false
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otpString: String, otpViewType: UIView) {
        if otpViewType == otpViewInital {
            otpViewInitalStr = otpString
        } else if otpViewType == otpViewSecond {
            otpViewSecondStr = otpString
        } else {
            otpViewThirdStr = otpString
        }

        if otpViewInitalStr.count == otpViewSecondStr.count {
           footerView.btnApply.isEnabled = true
        } else {
            footerView.btnApply.isEnabled = false
        }
    }
}
