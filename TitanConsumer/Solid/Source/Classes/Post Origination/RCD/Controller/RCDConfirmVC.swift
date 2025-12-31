//
//  RCDConfirmVC.swift
//  Solid
//
//  Created by Solid iOS Team on 8/6/21
//

import UIKit

class RCDConfirmVC: BaseVC {

    var viewModel: RCDViewModel!

    var transferId: String?
    var contactId: String?

    @IBOutlet weak var rcdDataView: RCDDataView!

    @IBOutlet weak var captureTableView: UITableView? {
        didSet {
            captureTableView?.register(UINib(nibName: "CheckInfoCell", bundle: nil), forCellReuseIdentifier: "CheckInfoCell")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFooterUI()

        setupInitialUI()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(depositCheckClicked(_:)), for: .touchUpInside)
    }
}

// MARK: - UI Methods
extension RCDConfirmVC {

    func setupInitialUI() {

        addBackNavigationbarButton()

        self.title = viewModel.screenTitleString

        footerView.btnApply.setTitle(Utility.localizedString(forKey: "RCD_deposit"), for: .normal)

        setAccountNameAndNumber()
    }

    func setAccountNameAndNumber() {
		self.setAccountType()
        rcdDataView.setRCDData(accountType: accountType ?? .businessChecking, viewModel: viewModel)
    }

    func gotoSuccessScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let successVC = storyboard.instantiateViewController(withIdentifier: "RCDSuccessViewController") as? RCDSuccessViewController {
            successVC.viewModel = self.viewModel
            self.navigationController?.pushViewController(successVC, animated: true)
        }
    }

    @IBAction func depositCheckClicked(_ sender: Any) {
        self.sendCheck()
    }
}

// MARK: - Tableview delegate, datasource
extension RCDConfirmVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        if indexPath.row == 0 || indexPath.row == 1 {
            if let aCell = tableView.dequeueReusableCell(withIdentifier: "CheckInfoCell") as? CheckInfoCell {
                if viewModel != nil {
                    if indexPath.row == 0 && viewModel.isFrontImageAvailable {
                        aCell.configureCellForResultView(resultImage: viewModel.checkFrontImage, for: .front, action: viewModel.frontImageAction!)
                        aCell.retakeButton.isHidden = true
                    } else if indexPath.row == 1 && viewModel.isRearImageAvailable {
                        aCell.configureCellForResultView(resultImage: viewModel.checkRearImage, for: .rear, action: viewModel.rearImageAction!)
                        aCell.retakeButton.isHidden = true
                    }
                }
                aCell.selectionStyle = .none
                return aCell
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 158.0
        }
        return UITableView.automaticDimension
    }
}

// MARK: - API
extension RCDConfirmVC {
    func sendCheck() {
        self.activityIndicatorBegin()
        var postBody = ReceiveCheckRequestBody()
        postBody.amount = viewModel.amount?.toString()
        postBody.contactId = self.contactId
        postBody.accountId = AppGlobalData.shared().accountData?.id
        postBody.description = "description"
        RCDCheckViewModel.shared.postReceiveCheck(checkData: postBody) { (response, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let checkResponse = response {
                    self.transferId = checkResponse.id
                    self.updateCheck()
                }
            }
        }
    }

    func updateCheck() {
        self.activityIndicatorBegin()
        var postBody = UploadCheckModel()
        postBody.checkFrontImage = viewModel.checkFrontImage
        postBody.checkRearImage = viewModel.checkRearImage
        postBody.accountId = AppGlobalData.shared().accountData?.id
        if let tId = transferId {
            RCDCheckViewModel.shared.uploadImage(checkData: postBody, transferId: tId
            ) { (response, _) in
                self.activityIndicatorEnd()
                if let _ = response {
                    self.gotoSuccessScreen()
                }
            }
        }
    }
}
