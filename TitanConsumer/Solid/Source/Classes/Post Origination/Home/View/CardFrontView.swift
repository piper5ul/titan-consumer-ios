//
//  CardFrontView.swift
//  Solid
//
//  Created by Solid iOS Team on 07/05/21.
//

import Foundation
import UIKit
import SDWebImage
import SDWebImageSVGCoder
import VGSShowSDK

class CardFrontView: UIView {
    @IBOutlet weak var imgVwCard: UIImageView!
    @IBOutlet weak var lblCardHolderName: UILabel!
    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var lblCardTypeName: UILabel!
    @IBOutlet weak var lblLimitValue: UILabel!
    @IBOutlet weak var lblLimitTitle: UILabel!
    @IBOutlet weak var imgVwIcon: UIImageView!
    @IBOutlet weak var lblVirtualCardText: UILabel!
    @IBOutlet weak var lblMaskCardNumber: UILabel!
    @IBOutlet weak var lblCardType: UILabel!
    @IBOutlet weak var lblExpiryTitle: UILabel!
    @IBOutlet weak var lblExpiryValue: UILabel!
    @IBOutlet weak var lblCvvTitle: UILabel!
    @IBOutlet var lblCvvValue: VGSLabel!
    @IBOutlet weak var stackViewCVVNo: UIStackView!
    @IBOutlet weak var stackViewCardNumber: UIStackView!
    @IBOutlet var lblCardNumber: VGSLabel!
    
    @IBOutlet weak var stackVwCardState: UIStackView!
    @IBOutlet weak var switchCardState: UISwitch!
    @IBOutlet weak var vwCardState: UIView!
    @IBOutlet weak var lblCardState: UILabel!
    
    @IBOutlet weak var hConstStackVwCardState: NSLayoutConstraint!
    
    @IBOutlet weak var cellWidth: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    var cardViewModal = CardModel()
    
    var authToken: String = ""
    
    var cardId: String = "" {
        didSet {
            path = AppGlobalData.shared().getVGSContentPath(cardId: cardId)
        }
    }
    
    var shouldShowCardStateStack: Bool? = false {
        didSet {
            if let shouldShow = shouldShowCardStateStack {
                hConstStackVwCardState.constant = shouldShow ? 20.0 : 0.0
                stackVwCardState.isHidden = !shouldShow
                if shouldShow {
                    configureStateStack()
                }
            }
        }
    }
    
    var cardData: CardModel? {
        didSet {
            if let aCardData = cardData {
                configureData(for: aCardData)
            }
        }
    }
    
    /// VGSShow instance.
    let vgsShow = VGSShow(id: Config.VGS.vaultId, environment: Config.VGS.VGSEnv)
    var path: String?
    
    let nibName = "CardFrontView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nibSetup()
    }
    
    private func nibSetup() {
        guard let contentView = loadViewFromNib() else { return }
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let cardTextColor = cardViewModal.cardType == CardType.physical ? UIColor.physicalCardTextColor : UIColor.virtualCardTextColor
        
        lblCardHolderName.textColor = cardTextColor
        lblAccountName.textColor = cardTextColor
        lblCardTypeName.textColor = cardTextColor
        lblVirtualCardText.textColor = cardTextColor
        lblCvvTitle.textColor = cardTextColor
        lblExpiryTitle.textColor = cardTextColor
        lblExpiryValue.textColor = cardTextColor
        lblCardState.textColor = cardTextColor
        lblMaskCardNumber.textColor = cardTextColor
        lblCardType.textColor = cardTextColor
    }
}

extension CardFrontView {
    func configureStateStack() {
        if let cardModel = cardData, let status = cardModel.cardStatus, status == .active || status == .inactive || status == .pendingActivation {
            self.lblVirtualCardText.isHidden = true
            vwCardState.isHidden = false
            lblCardState.text = status.localizeDescription()
            switchCardState.isOn = (status == .active)
        }
    }
    
    func configureVGS(for cardModel: CardModel) {
        stackViewCardNumber.isHidden = false
        lblMaskCardNumber.isHidden = true
        lblCvvValue = VGSLabel()
        lblCardNumber = VGSLabel()
        vgsShow.subscribe(lblCvvValue)
        vgsShow.subscribe(lblCardNumber)
        configureView(for: cardModel)
    }
    
    func configureView(for cardModel: CardModel) {
        let paddings = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let textColor = cardModel.cardType == CardType.physical ? UIColor.physicalCardTextColor : UIColor.virtualCardTextColor
        let borderColor = UIColor.clear
        let backgroundColor = UIColor.clear
        let cornerRadius: CGFloat = 6
        let placeholderColor = UIColor.white
        
        let textAlignment = NSTextAlignment.left
        let cardNoFont = UIFont.sfProDisplayBold(fontSize: 16)
        let cvvFont = UIFont.sfProDisplayBold(fontSize: 14)
        
        if let last4 = cardModel.last4 {
            lblCardNumber.placeholder = "**** **** **** \(last4)"
        }
        
        lblCvvValue.placeholder = "***"
        lblCvvValue.contentPath = "cvv"
        // Set placeholder text. Placeholder will appear until revealed text will be set in VGSLabel
        
        lblCardNumber.contentPath = "cardNumber"
        
        // Create regex object, split card number to XXXX-XXXX-XXXX-XXXX format.
        do {
            let cardNumberPattern = "(\\d{4})(\\d{4})(\\d{4})(\\d{4})"
            let template = "$1 $2 $3 $4"
            let regex = try NSRegularExpression(pattern: cardNumberPattern, options: [])
            
            // Add transformation regex to your label.
            lblCardNumber.addTransformationRegex(regex, template: template)
        } catch {
            assertionFailure("invalid regex, error: \(error)")
        }
        
        vgsShow.subscribedLabels.forEach {
            $0.textAlignment = textAlignment
            $0.textColor = textColor
            $0.paddings = paddings
            $0.borderColor = borderColor
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            $0.placeholderStyle.color = placeholderColor
            $0.placeholderStyle.textAlignment = textAlignment
            $0.delegate = self
        }
        
        lblCardNumber.placeholderStyle.font = cardNoFont
        lblCardNumber.font =  cardNoFont
        
        lblCvvValue.placeholderStyle.font = cvvFont
        lblCvvValue.font =  cvvFont
        
        stackViewCVVNo.addArrangedSubview(lblCvvValue)
        stackViewCardNumber.addArrangedSubview(lblCardNumber)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.getVGSShowToken()
        }
    }
    
    func setupUI() {
        lblCardHolderName.font = UIFont.sfProDisplayMedium(fontSize: 8.57)
        lblAccountName.font = UIFont.sfProDisplayMedium(fontSize: 8.57)
        lblCardTypeName.font = UIFont.sfProDisplayBold(fontSize: 11.00)
        lblCardType.font = UIFont.sfProDisplayBold(fontSize: 11.00)
        lblMaskCardNumber.font = UIFont.sfProDisplayBold(fontSize: 16)
        lblVirtualCardText.font = UIFont.sfProDisplayBold(fontSize: 9.00)
        lblCvvTitle.font = UIFont.sfProDisplayRegular(fontSize: 10)
        lblExpiryTitle.font = UIFont.sfProDisplayRegular(fontSize: 10)
        lblExpiryValue.font = UIFont.sfProDisplayBold(fontSize: 14)
        lblCardState.font = UIFont.sfProDisplayRegular(fontSize: 12)
        switchCardState.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        switchCardState.center = vwCardState.center
        shouldShowCardStateStack = false
    }
    
    func configureData(for cardModel: CardModel) {
        cardViewModal = cardModel
        if cardModel.cardType == CardType.virtual {
            if let virtualCardUrl = AppGlobalData.shared().programData.brand?.cardArtVirtual {
                imgVwCard.loadSVGImage(url: virtualCardUrl, placeholderImage: nil) { (_) in
                    // No action is required on success on this screen
                } failer: { (_) in
                    // Failure case not yet handled
                }
            }
            
            self.lblVirtualCardText.text =  Utility.localizedString(forKey: "virtualcardtext")
        } else {
            self.lblVirtualCardText.text = ""
            if let physicalCardUrl = AppGlobalData.shared().programData.brand?.cardArtPhysical {
                imgVwCard.loadSVGImage(url: physicalCardUrl, placeholderImage: nil) { (_) in
                    // No action is required on success on this screen
                } failer: { (_) in
                    // Failure case not yet handled
                }
            }
        }
        
        configureStateStack()
        
        self.lblMaskCardNumber.isHidden = false
        self.lblVirtualCardText.isHidden = false
        imgVwCard.contentMode = .scaleAspectFit
        
        let cardTextColor = cardModel.cardType == CardType.physical ? UIColor.physicalCardTextColor : UIColor.virtualCardTextColor
        
        lblCardHolderName.textColor = cardTextColor
        lblAccountName.textColor = cardTextColor
        lblCardTypeName.textColor = cardTextColor
        lblVirtualCardText.textColor = .lightText
        lblCvvTitle.textColor = .lightText
        lblExpiryTitle.textColor = .lightText
        lblExpiryValue.textColor = cardTextColor
        lblCardState.textColor = cardTextColor
        lblMaskCardNumber.textColor = cardTextColor
        lblCardType.textColor = cardTextColor
        
        if let name = cardModel.cardholder?.name {
            lblCardHolderName.text = name
        }
        
        if let bid = cardModel.businessId, !bid.isEmpty {
            lblAccountName.text = AppGlobalData.shared().businessData?.legalName
            lblAccountName.isHidden = false
        } else {
            lblAccountName.text = ""
            lblAccountName.isHidden = true
        }
        
        if AppGlobalData.shared().selectedAccountType == .businessChecking {
            lblCardType.text = cardModel.cardTypeLabel
        }
        
        lblCardTypeName.text = cardModel.cardType?.localizeDescription()
        
        if let last4 = cardModel.last4 {
            lblMaskCardNumber.text = "**** **** **** \(last4)"
        }
        
        if let aMonth = cardModel.expiryMonth, let aYear = cardModel.expiryYear {
            let dtStr = aYear.count > 2 ? String(aYear.suffix(2)) : aYear
            lblExpiryValue.text = "\(aMonth)/\(dtStr)"
        }
        
        if cardModel.cardStatus == CardStatus.inactive || cardModel.cardStatus == CardStatus.pendingActivation {
            self.alpha = 0.4
            self.tintColor = .brandDisableColor
        } else {
            self.alpha = 1.0
            self.tintColor = .clear
        }
        
    }
    
    func configureVirtualCardVGS(for cardModel: CardModel) {
        if let cId = cardModel.id {
            self.cardId = cId
            self.configureVGS(for: cardModel)
            self.lblCvvTitle.isHidden = false
        }
    }
}

extension CardFrontView {
    func getVGSShowToken() {
        CardViewModel.shared.getVGSShowToken(cardId: cardId) { (result, errorMessage) in
            if let error = errorMessage {
                debugPrint("VGS Show token error: \(error)")
            } else {
                if let response = result, let showToken = response.showToken {
                    self.requestData(showToken: showToken)
                }
            }
        }
    }
    
    private func requestData(showToken: String) {
        vgsShow.customHeaders = ["sd-show-token": showToken]
        vgsShow.request(path: self.path ?? "",
                        method: .get) { (requestResult) in
            
            switch requestResult {
            case .success(let code):
                debugPrint("vgsshow success, code: \(code)")
            case .failure(let code, let error):
                debugPrint("vgsshow failed, code: \(code), error: \(String(describing: error))")
            }
        }
    }
}

/// Optional. Implement `VGSLabelDelegate` to track changes in VGSShow views.
extension CardFrontView: VGSLabelDelegate {
    // Track errors in labels.
    func labelRevealDataDidFail(_ label: VGSLabel, error: VGSShowError) {
        debugPrint("error \(error) in label with \(label.contentPath ?? "no path")")
    }
    
    // Track text changes in labels.
    func labelTextDidChange(_ label: VGSLabel) {
        debugPrint("labelTextDidChange")
    }
    
    // Track when text is copied from labels.
    func labelCopyTextDidFinish(_ label: VGSLabel, format: VGSLabel.CopyTextFormat) {
        UIView.animate(withDuration: 0.3) {
            debugPrint("labelCopyTextDidFinish")
        } completion: { _ in
            debugPrint("Label copy")
        }
    }
}
