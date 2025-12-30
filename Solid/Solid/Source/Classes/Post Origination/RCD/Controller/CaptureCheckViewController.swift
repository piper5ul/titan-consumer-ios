//
//  CaptureCheckViewController.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class CaptureCheckViewController: BaseVC {

    var paymentModel: RCModel!
    var viewModel: RCDViewModel!

    var currentUploadingSide: CheckImageSide = .front
    var currentCaptureAction: CaptureActions = .capture
	var transferId: String?
	var contactId: String?
    var contactName: String?

    private let defaultAmount = "$0.00"
    var amount = 0.00

    @IBOutlet weak var captureTableView: UITableView? {
        didSet {
            captureTableView?.register(UINib(nibName: "CheckInfoCell", bundle: nil), forCellReuseIdentifier: "CheckInfoCell")
            captureTableView?.register(UINib(nibName: "BusinessDetailsCell", bundle: nil), forCellReuseIdentifier: "BusinessDetailsCell")
        }
    }

    @IBOutlet weak var payorTitleLabel: UILabel?
    @IBOutlet weak var txtPayorName: BaseTextField!

    @IBOutlet weak var amountTitleLabel: UILabel?
    @IBOutlet weak var addCheckImagesLabel: UILabel?
    @IBOutlet weak var maxAmountLabel: UILabel?

    @IBOutlet weak var txtAmount: CurrencyTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = RCDViewModel(rcdModel: paymentModel!)
        self.txtAmount.tfDecimalLimit = Constants.cardSpendDigitsLimit
        self.txtAmount.delegateCurreny = self
        self.txtAmount.delegate = self
		setupInitialUI()

        self.setFooterUI()

        self.shouldShowTableView(shouldShow: false)
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(depositCheckClicked), for: .touchUpInside)
    }

    func shouldShowTableView(shouldShow: Bool) {
        addCheckImagesLabel?.isHidden = !shouldShow
        captureTableView?.isHidden = !shouldShow
        updateDepositButton()
    }

    func validate() {
        if self.amount > 0 {
            // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.shouldShowTableView(shouldShow: true)
            // }
        } else {
            self.shouldShowTableView(shouldShow: false)
        }
    }

    @objc func depositCheckClicked() {
        gotoRCDConfirmationScreen()
    }

    func startObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUI), name: NSNotification.Name(rawValue: NotificationConstants.onRCDImageUploadSuccess), object: nil)
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        payorTitleLabel?.textColor = UIColor.secondaryColor
        amountTitleLabel?.textColor = UIColor.secondaryColor
        maxAmountLabel?.textColor = UIColor.secondaryColor
        addCheckImagesLabel?.textColor = UIColor.primaryColor
    }
}

// MARK: - CurrencyDelegate methods
extension CaptureCheckViewController: CurrencyDelegate {
    func current(amount: Double) {
        self.amount = amount

        if amount > Constants.checkDepositMaxLimit {
            self.shouldShowTableView(shouldShow: false)
        } else {
            validate()
        }
    }
}

// MARK: - Textfield delegate method
extension CaptureCheckViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= 9
    }
}

// MARK: - UI Methods
extension CaptureCheckViewController {

    func setupInitialUI() {

        addBackNavigationbarButton()

        self.title = viewModel.screenTitleString
		let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
		
        payorTitleLabel?.text = Utility.localizedString(forKey: "RCD_captureScreen_payorName")
        payorTitleLabel?.font = labelFont
        payorTitleLabel?.textColor = UIColor.secondaryColor

        amountTitleLabel?.text = Utility.localizedString(forKey: "RCD_captureScreen_enterAmount")
        amountTitleLabel?.font = labelFont
        amountTitleLabel?.textColor = UIColor.secondaryColor

        maxAmountLabel?.text = Utility.localizedString(forKey: "RCD_captureScreen_maxAmount")
        maxAmountLabel?.font = labelFont
        maxAmountLabel?.textColor = UIColor.secondaryColor
        addCheckImagesLabel?.text = Utility.localizedString(forKey: "RCD_captureScreen_addCheckImages")
		addCheckImagesLabel?.font = Constants.commonFont
        addCheckImagesLabel?.textColor = UIColor.primaryColor

        txtPayorName.cornerRadius = Constants.cornerRadiusThroughApp
        txtPayorName.layer.masksToBounds = true
        txtPayorName.text = contactName

        txtAmount.cornerRadius = Constants.cornerRadiusThroughApp
        txtAmount.layer.masksToBounds = true

        txtAmount.setDefault(value: defaultAmount)
        txtAmount.addDoneButtonOnKeyboard()
    }

   @objc func reloadUI() {
        removeObserver()
        updateDepositButton()
        captureTableView?.reloadData()
    }

    func updateDepositButton() {
        self.footerView.btnApply.isEnabled = viewModel.isFrontImageAvailable && viewModel.isRearImageAvailable && !(captureTableView?.isHidden ?? true)
    }

    func reloadTable(for checkSide: CheckImageSide) {
        let reloadRow = checkSide == .front ? 0 : 1
        captureTableView?.reloadRows(at: [IndexPath(row: reloadRow, section: 0)], with: .automatic)
    }

    func gotoConfirmationScreen(with image: UIImage?) {
        startObserver()
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let confirmVC = storyboard.instantiateViewController(withIdentifier: "CaptureConfirmationViewController") as? CaptureConfirmationViewController {
            confirmVC.viewModel = viewModel
            confirmVC.currentUploadingSide = currentUploadingSide
            confirmVC.currentCaptureAction = currentCaptureAction
            confirmVC.selectedImage = image
            self.navigationController?.pushViewController(confirmVC, animated: true)
        }
    }

    func gotoCaptureScreen() {
        self.currentCaptureAction = .capture

        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            cameraVC.viewModel = viewModel
            cameraVC.currentUploadingSide = currentUploadingSide

            cameraVC.onCapture = { (image: UIImage) in
                self.gotoConfirmationScreen(with: image)
            }

            self.navigationController?.pushViewController(cameraVC, animated: true)
        }
    }

    func showImagePreview(resultImage: UIImage) {
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let previewVC = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewViewController") as? PhotoPreviewViewController {
            previewVC.image = resultImage
            previewVC.currentUploadingSide = currentUploadingSide
            self.navigationController?.pushViewController(previewVC, animated: true)
        }
    }

    func gotoRCDConfirmationScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let confirmVC = storyboard.instantiateViewController(withIdentifier: "RCDConfirmVC") as? RCDConfirmVC {
            viewModel.amount = amount
            confirmVC.viewModel = viewModel
            confirmVC.contactId = self.contactId
            self.navigationController?.pushViewController(confirmVC, animated: true)
        }
    }
}

// MARK: - Tableview delegate, datasource
extension CaptureCheckViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return (viewModel.isFrontImageAvailable && viewModel.isRearImageAvailable) ? 3 : 2
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()

        if let aCell = tableView.dequeueReusableCell(withIdentifier: "CheckInfoCell") as? CheckInfoCell, viewModel != nil {

            aCell.delegate = self

            if indexPath.row == 0 {
                if viewModel.isFrontImageAvailable {
                    aCell.configureCellForResultView(resultImage: viewModel.checkFrontImage, for: .front, action: viewModel.frontImageAction!)
                } else {
                    aCell.configureCellForUploadView(checkSide: .front, action: viewModel.frontImageAction)
                }
            } else if indexPath.row == 1 {

                if viewModel.isRearImageAvailable {
                    aCell.configureCellForResultView(resultImage: viewModel.checkRearImage, for: .rear, action: viewModel.rearImageAction!)
                } else {
                    aCell.configureCellForUploadView(checkSide: .rear, action: viewModel.rearImageAction)
                }
            }
            aCell.selectionStyle = .none
            return aCell
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 158.0
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && viewModel.isFrontImageAvailable {
            currentUploadingSide = .front
            self.showImagePreview(resultImage: viewModel.checkFrontImage)
        } else if indexPath.row == 1 && viewModel.isRearImageAvailable {
            currentUploadingSide = .rear
            self.showImagePreview(resultImage: viewModel.checkRearImage)
        }
    }
}

// MARK: - CheckInfoCellDelegate
extension CaptureCheckViewController: CheckInfoCellDelegate {

    func checkInfoCellDelegateCaptureAction(action: CaptureActions, for checkSide: CheckImageSide) {

        self.view.endEditing(true)
        currentUploadingSide = checkSide
        currentCaptureAction = action

        switch action {
        case .upload:
            startUploadingPhoto()
        case .capture:
            startCapturingPhoto()
        case .retake:
            viewModel.resetCheckData(for: checkSide)
            updateDepositButton()
            captureTableView?.reloadData()
        }
    }
}

// MARK: - Upload Document
extension CaptureCheckViewController: DelegateUploadDocumentHelper {
    func initializeUploadHelper() {

        UploadDocumentHelper.sharedInstance.parent = self
        UploadDocumentHelper.sharedInstance.delegate = self
    }

    func startUploadingPhoto() {
        initializeUploadHelper()
        UploadDocumentHelper.sharedInstance.displayPhotoUploadOptions(sourceView: self.view)
    }

    func startCapturingPhoto() {
        gotoCaptureScreen()
    }

    func delegateUploadDocumentHelperDocumentPickerDidFinishSuccess(fileUrl aFielURL: URL) {

        if aFielURL.absoluteString.count > 0 {
            let image = viewModel.getImageFor(fileUrl: aFielURL)
            viewModel.setImageActionHappen(action: currentCaptureAction)
            gotoConfirmationScreen(with: image ?? nil)
        }
    }

    func delegateUploadDocumentHelperImagePickerDidFinishFail(errorString anErrorString: String) {
        // self.alert("Error", anErrorString)
        debugPrint("Error", anErrorString)
    }

    func delegateUploadDocumentHelperImagePickerDidFinishSuccess(tempImage aTempImage: UIImage, fileName: String) {
        gotoConfirmationScreen(with: aTempImage)
		debugPrint()
        viewModel.setImageActionHappen(action: currentCaptureAction)
    }
}
