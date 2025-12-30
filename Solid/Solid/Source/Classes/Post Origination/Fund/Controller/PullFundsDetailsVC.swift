//
//  PullFundsDetailsVC.swift
//  Solid
//
//  Created by  Solid iOS Team on 06/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import LinkKit

class PullFundsDetailsVC: BaseVC, FormDataCellDelegate {

    @IBOutlet weak var tblPullFundsDetails: UITableView!

    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    var arrTitles = [String]()
    var arrFieldTypes = [String]()
    var arrFundsData = [String]()

    var accountData: ContactDataModel?
    var fundsData = PaymentModel()
    var paymentAmount: Double = 0.0

    var pullFundsFlow: PullFundsFlow? = .pullFundsIn

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        registerCellsAndHeaders()
        setData()

        self.tblPullFundsDetails.reloadData()
        self.tblPullFundsDetails.backgroundColor = .clear
        self.setFooterUI()
        validate()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "pull_fund_transfer_btnTitle"))
        footerView.btnApply.addTarget(self, action: #selector(transferClick), for: .touchUpInside)
    }

    func setData() {
        arrTitles = ["source", "pay_section_destination", "payment_amount", "description"]
        arrFieldTypes = ["alphaNumeric", "accountNumber", "currency", "alphaNumeric"]

        let strBankName = accountData?.ach?.bankName ?? ""
        let strAccNo = accountData?.ach?.accountNumber?.last4() ?? ""
        var strSource = strBankName + " XXXXXX" + strAccNo

        if pullFundsFlow == .debitPull {
            let strDebitCardNo = accountData?.debitCard?.last4 ?? ""
            strSource = "XXXX XXXX XXXX " + strDebitCardNo
        }
        
        let strDestination = AppGlobalData.shared().accountData?.label ?? ""

        arrFundsData = (pullFundsFlow == PullFundsFlow.pullFundsOut) ? [strDestination, strSource, "", ""] : [strSource, strDestination, "", ""]

        fundsData.accountId = AppGlobalData.shared().accountData?.id
        fundsData.contactId = accountData?.id
    }

    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {

        var pullfundcFrame = footerView.frame

        var pullfundcY: CGFloat = footerView.frame.origin.y

        let navBarHeight = self.getNavigationbarHeight()

        UIView.animate(withDuration: 0.2) {
			pullfundcY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
			pullfundcFrame.origin.y = pullfundcY
            self.footerView.frame = pullfundcFrame
            self.view.layoutIfNeeded()

            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
            self.tblPullFundsDetails.contentInset = contentInsets
            self.tblPullFundsDetails.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblPullFundsDetails.scrollIndicatorInsets = self.tblPullFundsDetails.contentInset
        }
    }
}

// MARK: - Navigation
extension PullFundsDetailsVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        addBackNavigationbarButton()

        self.title = (pullFundsFlow == PullFundsFlow.pullFundsOut) ? Utility.localizedString(forKey: "move_fund_navTitle") : Utility.localizedString(forKey: "pull_fund_row_title")
    }

    @objc func transferClick() {
        self.view.endEditing(true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
                if shouldMoveAhead {
                    self.callPullFundsAPI()
                }
            }
        }
    }

    func goToSuccessScreen() {
        self.performSegue(withIdentifier: "GoToPullFundsSuccessVC", sender: self)
    }

    func validate() {
        if self.paymentAmount > 0, let description = fundsData.description, !description.isEmpty && !description.isInvalidInput() {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? PullFundsSuccessVC {
            destinationVC.contactData = self.accountData
            destinationVC.paymentData = self.fundsData
            destinationVC.pullFundsFlow = self.pullFundsFlow
        }
    }
}

// MARK: - FormDataCellDelegate
extension PullFundsDetailsVC {
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {

        guard let indexPath = self.tblPullFundsDetails.indexPath(for: cell) else {return}

        self.scrollToIndexPath = indexPath
    }

    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

        guard let indexPath = self.tblPullFundsDetails.indexPath(for: cell), let text = data as? String else {return}

        switch indexPath.row {
              case 2: // amount
                fundsData.amount = text.trim

              case 3:// description
                cell.validateEnteredText(enteredText: text.trim)
                fundsData.description = text.trim

              default:break
       }

        validate()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func cell(shouldCelar cell: CustomTableViewCell) -> Bool {
        return false
    }
}

// MARK: - UITableView
extension PullFundsDetailsVC: UITableViewDelegate, UITableViewDataSource {

    func registerCellsAndHeaders() {
        self.tblPullFundsDetails.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        self.tblPullFundsDetails.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let strTitle = arrTitles[indexPath.row]

        if indexPath.row == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
                cell.delegate = self
                cell.lblTitle?.text = Utility.localizedString(forKey: strTitle)
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {

                if indexPath.row == 0 || indexPath.row == 1 {
                    cell.isUserInteractionEnabled = false
                }

                cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
                cell.fieldType = arrFieldTypes[indexPath.row]
                cell.inputTextField?.text = arrFundsData[indexPath.row]
				cell.inputTextField?.tag = indexPath.row
                cell.delegate = self
                return cell
            }
        }

        return UITableViewCell()
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cheight: CGFloat
		cheight	= Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
		return cheight
	}
}

// MARK: - Currency
extension PullFundsDetailsVC: CurrencyEntryCellDelegate {
    func amountEntered(amount: Double) {
        self.paymentAmount = amount
        validate()
    }
}

// MARK: - API
extension PullFundsDetailsVC {

    func callPullFundsAPI() {
        if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = accountData, let contactId = contact.id {

            self.activityIndicatorBegin()

            fundsData.amount = self.paymentAmount.toString()

            var requestBody = PaymentModel()
            requestBody.accountId = accId
            requestBody.contactId = contactId
            requestBody.amount = fundsData.amount
            requestBody.description = fundsData.description

            FundViewModel.shared.pullFunds(pullFundsFlow: self.pullFundsFlow!, requestBody: requestBody) { (response, errorMessage) in
                self.activityIndicatorEnd()

                if let error = errorMessage {
                    //handle error of plaid in-active case
                    if error.errorCode == "EC_PLAID_LINK_MODE_UPDATE_ITEM_LOGIN_REQUIRED" {
                        self.getPlaidToken()
                    } else {
                        self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                    }
                } else {
                    if let _ = response {
                        self.getAccountDetails(for: accId) { (_, _) in
                            self.goToSuccessScreen()
                        }
                    }
                }
            }
        }
    }
    
    func getPlaidToken() {
        if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id {
            self.activityIndicatorBegin()
            
            var updateBody = PlaidUpdateTokenRequestModel()
            updateBody.type = "itemLoginRequired"
            updateBody.contactId = accountData?.id
            
            var requestBody = PlaidTempTokenRequestModel()
            requestBody.plaidUpdateMode = updateBody
            
            FundViewModel.shared.getPlaidTempToken(accountId: accId, requestBody: requestBody) { (response, errorMessage) in
                self.activityIndicatorEnd()

                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let linkToken = response?.linkToken {
                        self.configurePlaid(withToken: linkToken)

                        let method: PresentationMethod = .viewController(self)
                        AppGlobalData.shared().plaidHandler?.open(presentUsing: method)
                    }
                }
            }
        }
    }
}

// MARK: - Plaid
extension PullFundsDetailsVC {

    func configurePlaid(withToken: String) {
        // Create Plaid Link configuration..
        var configuration = LinkTokenConfiguration(
            token: withToken,
            onSuccess: { linkSuccess in
                debugPrint("success : \(linkSuccess)")
                self.callPullFundsAPI()
            }
        )

        configuration.onExit = { linkExit in
            // Optionally handle linkExit data according to your application's needs
              debugPrint("linkExit : \(linkExit)")
          }

        configuration.onEvent = { linkEvent in
            // Optionally handle linkEvent data according to your application's needs
            debugPrint("linkEvent : \(linkEvent)")
        }

        // Create Plaid Link Session and store it for further use..
        let result = Plaid.create(configuration)
        switch result {
          case .failure(let error):
                print("Unable to create Plaid handler due to: \(error)")
          case .success(let handler):
                print("Plaid handler : \(handler)")
                AppGlobalData.shared().plaidHandler = handler
        }
    }
}

