//
//  CaptureConfirmationViewController.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class CaptureConfirmationViewController: BaseVC {

    var viewModel: RCDViewModel!
    var currentUploadingSide: CheckImageSide!
    var currentCaptureAction: CaptureActions!
    var selectedImage: UIImage?

    @IBOutlet var checkImageView: UIImageView!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!

    @IBOutlet var infoView: UIView!

    @IBOutlet weak var detailsViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFooterUI()
        
        setupInitialUI()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(havingTwoButtons: true)
        footerView.btnApply.addTarget(self, action: #selector(looksGoodClicked(_:)), for: .touchUpInside)
        footerView.btnClose.addTarget(self, action: #selector(tryAgainClicked(_:)), for: .touchUpInside)
    }
    
    @IBAction func looksGoodClicked(_ sender: Any) {

        self.viewModel.setDocumentImage(image: selectedImage!, for: self.currentUploadingSide)
        goBackToCaptureVC()
    }

    @IBAction func tryAgainClicked(_ sender: Any) {

        switch currentCaptureAction {
        case .upload:
            startUploadingPhoto()
        case .capture:
            startCapturingPhoto()
        default:
            break
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        titleLabel.textColor = .primaryColor
        if let desc = descLabel.text {
            descLabel.attributedText = desc.getAttributedString(forLineSpacing: 5.0)
        }
    }
}

extension CaptureConfirmationViewController {

    func goBackToCaptureVC() {

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.onRCDImageUploadSuccess), object: nil)

        if let viewControllers = self.navigationController?.viewControllers {
            for controller in viewControllers {
                if controller.isKind(of: CaptureCheckViewController.self) {
                    self.navigationController?.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
}

// MARK: - UI Methods
extension CaptureConfirmationViewController {

    func setupInitialUI() {

        addBackNavigationbarButton()
        self.title = viewModel.screenTitleString

        if let side = currentUploadingSide {
            let confirmString = Utility.localizedString(forKey: "RCD_confirmLabelTitle")
            var sideTitleString = ""
            var description = ""

            if side == .front {
                sideTitleString = Utility.localizedString(forKey: "RCD_frontTitle")
                description = Utility.localizedString(forKey: "RCD_confirmFrontCheck_desc1") + "\n" + Utility.localizedString(forKey: "RCD_confirmFrontCheck_desc2")
                detailsViewHeightConstraint.constant = 80

            } else {
                sideTitleString = Utility.localizedString(forKey: "RCD_backTitle")
                description = Utility.localizedString(forKey: "RCD_confirmBackCheck_desc1") + "\n" + Utility.localizedString(forKey: "RCD_confirmBackCheck_desc2") + "\n" + Utility.localizedString(forKey: "RCD_confirmBackCheck_desc3")
                detailsViewHeightConstraint.constant = 100
            }

            titleLabel.text = String(format: confirmString, sideTitleString)
            descLabel.attributedText = description.getAttributedString(forLineSpacing: 5.0)
            
            infoView.backgroundColor = .background
        }

        if let action = currentCaptureAction {
            var buttonTitle = ""
            if action == .capture {
                buttonTitle = Utility.localizedString(forKey: "RCD_retakePhotoTitle")
            } else if action == .upload {
                buttonTitle = Utility.localizedString(forKey: "RCD_chooseAnotherTitle")
            }
            footerView.btnClose.setTitle(buttonTitle, for: .normal)
        }

        footerView.btnApply.setTitle(Utility.localizedString(forKey: "RCD_looksGoodTitle"), for: .normal)
        titleLabel?.font = Constants.commonFont
        titleLabel?.textColor = UIColor.primaryColor
        
       setImageData()
    }

    func setImageData() {
        if let alreadySelectedImage = selectedImage {
            checkImageView.image = alreadySelectedImage
        }
    }

    func gotoCaptureScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            cameraVC.viewModel = viewModel
            cameraVC.currentUploadingSide = currentUploadingSide
            cameraVC.onCapture = { (image: UIImage) in
                self.selectedImage = image
                self.setImageData()
            }
            self.present(cameraVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Upload Document
extension CaptureConfirmationViewController: DelegateUploadDocumentHelper {
    func initializeUploadHelper() {
        UploadDocumentHelper.sharedInstance.parent = self
        UploadDocumentHelper.sharedInstance.delegate = self
    }

    func startUploadingPhoto() {
        initializeUploadHelper()
        UploadDocumentHelper.sharedInstance.displayPhotoUploadOptions(sourceView: self.view)
    }

    func startCapturingPhoto() {
        //        initializeUploadHelper()
        //        UploadDocumentHelper.sharedInstance.capture()
        gotoCaptureScreen()
    }

    func delegateUploadDocumentHelperDocumentPickerDidFinishSuccess(fileUrl aFielURL: URL) {

        if aFielURL.absoluteString.count > 0 {
            selectedImage = viewModel.getImageFor(fileUrl: aFielURL)
            setImageData()
            viewModel.setImageActionHappen(action: currentCaptureAction)
        }
    }

    func delegateUploadDocumentHelperImagePickerDidFinishFail(errorString anErrorString: String) {
        // self.alert("Error", anErrorString)
        debugPrint("Error", anErrorString)
    }

    func delegateUploadDocumentHelperImagePickerDidFinishSuccess(tempImage aTempImage: UIImage, fileName: String) {

        selectedImage = aTempImage
        setImageData()
        viewModel.setImageActionHappen(action: currentCaptureAction)

    }
}
