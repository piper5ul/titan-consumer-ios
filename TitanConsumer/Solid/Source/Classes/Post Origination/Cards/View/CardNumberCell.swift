//
//  CardNumberCell.swift
//  Solid
//
//  Created by Solid iOS Team on 11/06/21.
//

import Foundation
import UIKit
import VGSShowSDK

@objc protocol DelegateCardNumberCell {
    @objc optional func actionButtonClicked()
}

class CardNumberCell: UITableViewCell {

    var cardId: String = "" {
        didSet {
           path = AppGlobalData.shared().getVGSContentPath(cardId: cardId)
        }
    }
    
    /// VGSShow instance.
    let vgsCardNumberShow = VGSShow(id: Config.VGS.vaultId, environment: Config.VGS.VGSEnv)
    var path: String?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var lblCardNumberValue: VGSLabel!
    @IBOutlet weak var stackViewCardNumber: UIStackView!
    @IBOutlet weak var cardNumberView: UIView!

    @IBOutlet weak var btnAccesory: UIButton!
    weak var delegate: DelegateCardNumberCell?

    override func awakeFromNib() {
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblTitle.font = labelFont
        lblTitle.textAlignment = .left
        lblTitle.textColor = .primaryColor
        cardNumberView.backgroundColor = .background
    }

    func configureCell(forRow rowData: ContactRowData, hideSeparator: Bool = false) {
        lblTitle.text = rowData.key
        if let aValue = rowData.value as? String {
            self.cardId = aValue
            configureVGS()
        }

        if let aIconName = rowData.iconName, !aIconName.isEmpty {
            let iconImage = UIImage(named: aIconName)
            btnAccesory.setImage(iconImage, for: .normal)
            btnAccesory.setImage(iconImage, for: .highlighted)
            btnAccesory.setImage(iconImage, for: .selected)
            btnAccesory.imageView?.tintColor = .primaryColor
        }
    }

    @IBAction func btnAccessoryClicked(_ sender: Any) {
        self.superview?.makeToast(Utility.localizedString(forKey: "cardNumber_copied"), duration: 1.3)
        lblCardNumberValue.copyTextToClipboard()
    }
    
    func configureVGS() {
        lblCardNumberValue = VGSLabel()
        vgsCardNumberShow.subscribe(lblCardNumberValue)
        
        configureView()
    }
    
    func configureView() {
        let paddings = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let textColor = UIColor.secondaryColor
        let borderColor = UIColor.clear
        let font = UIFont.sfProDisplayMedium(fontSize: 16)
        let backgroundColor = UIColor.clear
        let cornerRadius: CGFloat = 6
        let textAlignment = NSTextAlignment.left
        let placeholderColor = UIColor.primaryColor
        
        // Set placeholder text. Placeholder will appear until revealed text will be set in VGSLabel
        lblCardNumberValue.placeholder = "**** **** **** ****"
        lblCardNumberValue.contentPath = "cardNumber"
        
        // Create regex object, split card number to XXXX-XXXX-XXXX-XXXX format.
        do {
            let cardNumberPattern = "(\\d{4})(\\d{4})(\\d{4})(\\d{4})"
            let template = "$1 $2 $3 $4"
            let regex = try NSRegularExpression(pattern: cardNumberPattern, options: [])
            
            // Add transformation regex to your label.
            lblCardNumberValue.addTransformationRegex(regex, template: template)
        } catch {
            assertionFailure("invalid regex, error: \(error)")
        }
        
        vgsCardNumberShow.subscribedLabels.forEach {
            $0.textAlignment = textAlignment
            $0.textColor = textColor
            $0.paddings = paddings
            $0.borderColor = borderColor
            $0.font = font
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = cornerRadius
            //$0.characterSpacing = 0.83
            $0.placeholderStyle.color = placeholderColor
            $0.placeholderStyle.textAlignment = textAlignment
            $0.placeholderStyle.font = font
            
            // set delegate to follow the updates in VGSLabel
            $0.delegate = self
        }

        for subView in stackViewCardNumber.subviews {
            subView.removeFromSuperview()
        }
        stackViewCardNumber.addArrangedSubview(lblCardNumberValue)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.getVGSShowToken()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = .primaryColor
        btnAccesory.imageView?.tintColor = .primaryColor
    }
}

extension CardNumberCell {
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
        vgsCardNumberShow.customHeaders = ["sd-show-token": showToken]
        vgsCardNumberShow.request(path: self.path ?? "",
                        method: .get) { (result) in
            switch result {
                case .success(let code):
                    debugPrint("vgsCardNumberShow success, code: \(code)")
                case .failure(let code, let error):
                    debugPrint("vgsCardNumberShow failed, code: \(code), error: \(String(describing: error))")
            }
        }
    }
}

/// Optional. Implement `VGSLabelDelegate` to track changes in VGSShow views.
extension CardNumberCell: VGSLabelDelegate {
    
    // Track errors in labels.
    func labelRevealDataDidFail(_ label: VGSLabel, error: VGSShowError) {
        debugPrint("error \(error) in label with \(label.contentPath ?? "no path")")
        //label.borderColor = .red
    }
    
    // Track text changes in labels.
    func labelTextDidChange(_ label: VGSLabel) {
       // label.borderColor = .green
    }
    
    // Track when text is copied from labels.
    func labelCopyTextDidFinish(_ label: VGSLabel, format: VGSLabel.CopyTextFormat) {
        UIView.animate(withDuration: 0.3) {
            //label.backgroundColor = .systemYellow
            //label.borderColor = .black
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
               // label.backgroundColor = .white
               // label.borderColor = .green
            }
        }
    }
}
