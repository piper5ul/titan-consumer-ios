//
//  CheckInfoCell.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

protocol CheckInfoCellDelegate: AnyObject {
    func checkInfoCellDelegateCaptureAction(action: CaptureActions, for checkSide: CheckImageSide)
}

class CheckInfoCell: UITableViewCell {

    @IBOutlet var iconImageView: BaseImageView!
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var dataView: UIView!

    @IBOutlet var uploadImageView: UIView!
    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var checkResultView: UIView!
    @IBOutlet var checkImageView: UIImageView!
    @IBOutlet var wConstRetakeButton: NSLayoutConstraint!

    @IBOutlet var retakeButton: UIButton!
    @IBOutlet var uploadButton: ColoredButton!
    @IBOutlet var captureButton: UIButton!

    weak var delegate: CheckInfoCellDelegate?
    var currentCheckSide: CheckImageSide?

    override func awakeFromNib() {
        super.awakeFromNib()
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        titleLabel.font = labelFont
        titleLabel.textColor = .primaryColor

        uploadButton.isEnabled = true
        uploadButton.setTitle(Utility.localizedString(forKey: "RCD_upload_photo"), for: .normal)

        captureButton.setTitle(Utility.localizedString(forKey: "RCD_take_photo"), for: .normal)
        captureButton.setTitleColor(.primaryColor, for: .normal)
		let captureButtonFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        captureButton.titleLabel?.font = captureButtonFont
        captureButton.cornerRadius = Constants.cornerRadiusThroughApp
        captureButton.borderWidth = 1
        captureButton.borderColor = .primaryColor

        dataView.backgroundColor = .background
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configureCellForResultView(resultImage: UIImage, for checkSide: CheckImageSide, action: CaptureActions) {
        self.currentCheckSide = checkSide
        iconImageView.image = UIImage(named: "checkbox_selected")
        titleLabel.text = checkSide == .front ? Utility.localizedString(forKey: "RCD_frontTitle") : Utility.localizedString(forKey: "RCD_backTitle")
        let buttonTitle = (action == .capture) ? Utility.localizedString(forKey: "RCD_retakeButton") : Utility.localizedString(forKey: "RCD_reuploadButton")

		let cFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14

        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: cFont,
            NSAttributedString.Key.foregroundColor: UIColor.secondaryColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedString = NSMutableAttributedString(string: buttonTitle, attributes: attrs)
        retakeButton.setAttributedTitle(NSAttributedString(attributedString: attributedString), for: .normal)

        iconImageView.customTintColor = .primaryColor

        checkImageView.image = resultImage
        showResultView()
    }

    func configureCellForUploadView(checkSide: CheckImageSide, action: CaptureActions?) {
        self.currentCheckSide = checkSide
        showUploadView()
        showDescription(for: checkSide)

        if let action = action, action != .retake {
            if action == .capture {
                uploadButton.isHidden = true
            } else {
                captureButton.isHidden = true
            }
        } else {
            uploadButton.isHidden = false
            captureButton.isHidden = false
        }
    }

    func showDescription(for checkSide: CheckImageSide) {

        var description = ""
        var imageName = ""
        var title = ""

        if checkSide == .front {
            title = Utility.localizedString(forKey: "RCD_frontTitle")
            imageName = "checkbox_unSelected"
            description = Utility.localizedString(forKey: "RCD_captureInstruction1") + "\n" + Utility.localizedString(forKey: "RCD_captureInstruction2") + "\n" + Utility.localizedString(forKey: "RCD_captureInstruction3")
        } else {

            title = Utility.localizedString(forKey: "RCD_backTitle")
            imageName = "checkbox_unSelected"
            description = Utility.localizedString(forKey: "RCD_captureInstruction4") + "\n" + Utility.localizedString(forKey: "RCD_captureInstruction1") + "\n" + Utility.localizedString(forKey: "RCD_captureInstruction2") + "\n" + Utility.localizedString(forKey: "RCD_captureInstruction3")
        }

        titleLabel.text = title
        descriptionLabel.attributedText = description.getAttributedString(forLineSpacing: 5.0)
        iconImageView.image = UIImage(named: imageName)
        iconImageView.customTintColor = .primaryColor
    }

    func showResultView() {
        checkResultView.isHidden = false
        uploadImageView.isHidden = true
        wConstRetakeButton.constant = 70.0
        retakeButton.isHidden = false
    }

    func showUploadView() {
        checkResultView.isHidden = true
        uploadImageView.isHidden = false
        wConstRetakeButton.constant = 0.0
        retakeButton.isHidden = true
    }

    @IBAction func retakeClicked(_ sender: Any) {
        if let aDelegate = delegate {
            aDelegate.checkInfoCellDelegateCaptureAction(action: .retake, for: self.currentCheckSide!)
        }
    }

    @IBAction func uploadClicked(_ sender: Any) {
        if let aDelegate = delegate {
            aDelegate.checkInfoCellDelegateCaptureAction(action: .upload, for: self.currentCheckSide!)
        }
    }

    @IBAction func captureClicked(_ sender: Any) {
        if let aDelegate = delegate {
            aDelegate.checkInfoCellDelegateCaptureAction(action: .capture, for: self.currentCheckSide!)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        captureButton.borderColor = .primaryColor
        titleLabel.textColor = .primaryColor
        if let descriptionText = descriptionLabel.text {
            descriptionLabel.attributedText = descriptionText.getAttributedString(forLineSpacing: 5.0)
        }
        iconImageView.customTintColor = .primaryColor
        captureButton.setTitleColor(.primaryColor, for: .normal)
        captureButton.borderColor = .primaryColor
        
        if let retakeBtnText = retakeButton.titleLabel?.text {
            let cFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
            let attrs: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: cFont,
                NSAttributedString.Key.foregroundColor: UIColor.secondaryColor,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attributedString = NSMutableAttributedString(string: retakeBtnText, attributes: attrs)
            retakeButton.setAttributedTitle(NSAttributedString(attributedString: attributedString), for: .normal)
        }
    }
}
