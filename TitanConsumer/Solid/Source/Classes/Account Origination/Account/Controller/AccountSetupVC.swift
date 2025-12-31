//
//  AccountSetupVC.swift
//  Solid
//
//  Created by Solid iOS Team on 15/02/21.
//

import Foundation
import UIKit

class AccountSetupVC: BaseVC {

    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDisclaimer: UILabel!
    var isreachable: Bool = false

    var appFlow: AppFlow?
    var accBody = AccountRequestBody()
    
    var isTermsAgreed = false {
        didSet {
            validate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appFlow = AppGlobalData.shared().appFlow
        setupUI()
        setupData()
        if appFlow == .AO {
            addProgressbar(percentage: 80)
            getBusinessList()
        }
        self.setFooterUI()
        validate()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        let buttonTitle = Utility.localizedString(forKey: "acc_setup_button")
        footerView.configureButtons(rightButtonTitle: buttonTitle)
        footerView.btnApply.addTarget(self, action: #selector(btnCreateAccountClicked), for: .touchUpInside)
    }

    @objc func btnCreateAccountClicked() {
        self.view.endEditing(true)
        Segment.addSegmentEvent(name: .createAccount)
        callCreateAccountAPI()
    }

    func gotoAccountDetailsScreen() {
        self.performSegue(withIdentifier: "GoToAccountDetailsVC", sender: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblDisclaimer.textColor = UIColor.secondaryColor
    }

}

// MARK: - API calls
extension AccountSetupVC {
    
    func getBusinessList() {
        self.activityIndicatorBegin()
        self.getBusinessFromList { (_, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
            }
        }
    }
    
    func createPostBodyData() -> AccountRequestBody {
        var postBody = AccountRequestBody()
        postBody.createPhysicalCard = accBody.createPhysicalCard ?? false
        postBody.acceptedTerms = true
        postBody.label = accBody.label ?? ""
        postBody.type = AccountType.personalChecking.rawValue
        
        if AppGlobalData.shared().isSelectedCardAccount {
            postBody.type = AccountType.cardAccount.rawValue
            if AppGlobalData.shared().selectedAccountType == AccountType.businessChecking {
                postBody.businessId = AppGlobalData.shared().businessData?.id
            }
        } else if AppGlobalData.shared().bothPersonalAndBusinessChecking {
            if AppGlobalData.shared().selectedAccountType == AccountType.businessChecking {
                postBody.type = AccountType.businessChecking.rawValue
                postBody.businessId = AppGlobalData.shared().businessData?.id
            }
        } else if AppGlobalData.shared().accTypeBusinessChecking {
            postBody.type = AccountType.businessChecking.rawValue
            postBody.businessId = AppGlobalData.shared().businessData?.id
        }
        
        return postBody
    }
    
    func callCreateAccountAPI() {
        let postBody = createPostBodyData()
        self.activityIndicatorBegin()
        AccountViewModel.shared.createNewAccount(accountData: postBody) { (response, errorMessage) in
            if let error = errorMessage {
                self.activityIndicatorEnd()
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let accountResp = response {
                    AppGlobalData.shared().accountData = accountResp
                }
                //ADDED 4 SECONDS DELAY TO GET CARDS DATA ON DASHBOARD....
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
                    self.activityIndicatorEnd()
                    self.gotoAccountDetailsScreen()
                }
            }
        }
    }
}

// MARK: - UI Methods
extension AccountSetupVC: UITextViewDelegate {

    func setupUI() {
        self.isScreenModallyPresented = true
        self.isNavigationBarHidden = false

        if appFlow == .PO && AppGlobalData.shared().creationFlow == .addAccount {
            addBackNavigationbarButton()
        } else {
            self.navigationItem.setHidesBackButton(true, animated: true)
        }
        
        registerCellsAndHeaders()
        let font = Utility.isDeviceIpad() ? Constants.regularFontSize20: Constants.regularFontSize12
        lblDisclaimer.font = font
        lblDisclaimer.textColor = UIColor.secondaryColor
        lblTitle.font = font
        lblDisclaimer.textColor = UIColor.secondaryColor
    }

    func setupData() {
        let strDisc = Utility.localizedString(forKey: "acc_setup_disclaimer")
        lblDisclaimer.text = strDisc
        
        self.title = (appFlow == .AO) ? Utility.localizedString(forKey: "acc_setup_screen_title") : Utility.localizedString(forKey: "selectAcc_screenTitle")

        accBody.label = (appFlow == .AO) ? Utility.localizedString(forKey: "acc_setup_default_title") : Utility.localizedString(forKey: "acc_setup_additional_default_title")
    }
}

extension AccountSetupVC {

    func validate() {
        var shouldEnable = false
        if let accLable = accBody.label, !accLable.isEmpty && !accLable.isInvalidInput() && isTermsAgreed {
              shouldEnable = true
        }

        footerView.btnApply.isEnabled = shouldEnable
    }
}

// MARK: - Tableview methods
extension AccountSetupVC: UITableViewDelegate, UITableViewDataSource {

    func registerCellsAndHeaders() {
        self.detailsTableView.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        self.detailsTableView.register(UINib(nibName: "AccountTermsConditionCell", bundle: .main), forCellReuseIdentifier: "AccountTermsConditionCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightV: CGFloat = (indexPath.row == 0) ? 96.0 : 310.0
        return heightV
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomTableViewCell {
                let strTitle = Utility.localizedString(forKey: "acc_setup_name_title")
                cell.titleLabel?.text = strTitle
                cell.inputTextField?.text = accBody.label ?? ""
                cell.fieldType = strTitle
                cell.delegate = self
                cell.backgroundColor = .clear
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTermsConditionCell", for: indexPath) as? AccountTermsConditionCell {
                cell.configureUI()
                cell.termsDelegate = self
                cell.selectionStyle = .none
                return cell
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
}

// MARK: - UITableView
extension AccountSetupVC: FormDataCellDelegate {

    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

        guard let indexPath = self.detailsTableView.indexPath(for: cell), let text = data as? String else {return}
        if indexPath.row == 0 {
                accBody.label = text.trim
                cell.validateEnteredText(enteredText: text.trim)
        }
        validate()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func cell(shouldCelar cell: CustomTableViewCell) -> Bool {
        return true
    }
}

extension AccountSetupVC: AccountTermsCellDelegate {
    func termLinkClick(withURL: URL) {

        if withURL.absoluteString == AppMetaDataHelper.shared.config?.lcbBankTermsLink {
            self.showLCBBankTermsAndConditions()
        } else if withURL.absoluteString == AppMetaDataHelper.shared.config?.platformTerms {
            self.showSolidBankTermsAndConditions()
        }
    }

    func shouldCreatePhysicalCard(cardEnable: Bool) {
        accBody.createPhysicalCard = cardEnable
        self.view.endEditing(true)
    }
    
    func isTermsAgreed(termsAgreed: Bool) {
        isTermsAgreed = termsAgreed
        validate()
    }
}
