//
//  IntrabankPaymentSelfVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import UIKit

class IntrabankPaymentSelfVC: BaseVC, FormDataCellDelegate {
	var arrTitles = [String]()
	var arrFieldTypes = [String]()
	var contactData: ContactDataModel?
	var intraBankData: IntrabankAccount?
	var intrabankDescription: String?
	var nodes = [ListItems]()
	
	var pResponse: PaymentModel?
	var requestBody = PaymentModel()

	private let defaultAmount = "$0.00"
	var amount = 0.00
	var paymentAmount: Double = 0.0

	var destinationAccountLabel: String?
	var destinationAccountNumber: String?
	
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    @IBOutlet weak var tblSelfIntrabank: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setNavigationBar()
		self.setUserData()
		self.registerCells()

		self.tblSelfIntrabank.reloadData()
		self.setFooter()
		self.validateData()
        
        self.tblSelfIntrabank.backgroundColor = .clear
    }
}

extension IntrabankPaymentSelfVC {
	func setNavigationBar() {
		self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

		addBackNavigationbarButton()
		self.title = Utility.localizedString(forKey: "move_fund_navTitle")
	}

	func setUserData() {
		arrTitles = ["source", "pay_section_destination", "payment_amount", "description"]
		arrFieldTypes = ["alphaNumeric", "stringPicker", "currency", "alphaNumeric"]
		let selectecAccountId = AppGlobalData.shared().accountData?.id
		if let accountList = (AppGlobalData.shared().accountList?.filter({ $0.id != selectecAccountId!})) {
			for account in accountList {
				let accountlabel = account.label ?? ""
				let accountNumber = account.accountNumber ?? ""
				nodes.append(ListItems(title: accountlabel, id: accountNumber))
			}
		}
	}
	
	func setFooter() {
		shouldShowFooterView = true
		footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "pull_fund_transfer_btnTitle"))
		footerView.btnApply.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
	}

	@objc func handleNavigation() {
		self.createContact()
	}

	func validateData() {
		if let _ = contactData?.name,
           let accountNumber = contactData?.intrabank?.accountNumber,
           let _ = contactData?.intrabank?.description, accountNumber.isAccountNumberInLimit(),
           self.paymentAmount > 0, self.paymentAmount > 0,
           let description = contactData?.intrabank?.description, !description.isEmpty {
			self.footerView.btnApply.isEnabled = true
		} else {
			self.footerView.btnApply.isEnabled = false
		}
	}

    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        var footerviewFrame = footerView.frame
        var footerY: CGFloat = footerView.frame.origin.y

        let navigationBarHeight = self.getNavigationbarHeight()
        UIView.animate(withDuration: 0.2) {
			footerY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navigationBarHeight - 80 : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navigationBarHeight
			footerviewFrame.origin.y = footerY
            self.footerView.frame = footerviewFrame
            self.view.layoutIfNeeded()

            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
            self.tblSelfIntrabank.contentInset = contentInsets
            self.tblSelfIntrabank.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblSelfIntrabank.scrollIndicatorInsets = self.tblSelfIntrabank.contentInset
        }
    }
}

// MARK: - UITableView
extension IntrabankPaymentSelfVC: UITableViewDelegate, UITableViewDataSource {

	func registerCells() {
		self.tblSelfIntrabank.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
		self.tblSelfIntrabank.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
	}

    func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrTitles.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let height: CGFloat
		height	= Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
		return height
	}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let strTitle = arrTitles[indexPath.row]
		if indexPath.row == 1 {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {
		    cell.arrPickerData = self.nodes
			cell.titleLabel?.text  = Utility.localizedString(forKey: strTitle)
			cell.fieldType = arrFieldTypes[indexPath.row]
            if self.nodes.isEmpty {
                cell.inputTextField?.placeholderString = Utility.localizedString(forKey: "no_account_text")
                cell.inputTextField?.isUserInteractionEnabled = false
            }
			cell.delegate = self
			return cell
		}
		} else if indexPath.row == 2 {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
				cell.delegate = self
				cell.lblTitle?.text = Utility.localizedString(forKey: strTitle)
				cell.selectionStyle = .none
				return cell
			}
		} else {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {
				if indexPath.row == 0 {
					cell.isUserInteractionEnabled = false
					cell.inputTextField?.text = AppGlobalData.shared().accountData?.label
				}
				cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
				cell.fieldType = arrFieldTypes[indexPath.row]
				cell.inputTextField?.tag = indexPath.row
				cell.delegate = self
				return cell
		}
		}
		return UITableViewCell()
	}
}

// MARK: - FormDataCellDelegate
extension IntrabankPaymentSelfVC {

    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
        guard let indexPath = self.tblSelfIntrabank.indexPath(for: cell) else {return}
        self.scrollToIndexPath = indexPath
    }

	func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

		guard let indexPath = self.tblSelfIntrabank.indexPath(for: cell), let text = data as? String else {return}

		switch indexPath.row {
			case 1:// Account Number
				destinationAccountLabel = text
				destinationAccountNumber = self.getaccountNumber(for: destinationAccountLabel!)
				contactData?.name = destinationAccountLabel
				var ibank = IntrabankAccount()
				ibank.accountNumber = destinationAccountNumber
				contactData?.intrabank = ibank
				
			case 2:// amount
				contactData?.intrabank?.amount = text.trim

			case 3: // purpose
				let purpose = text.trim
				var ibank = IntrabankAccount()
				ibank.accountNumber = self.contactData?.intrabank?.accountNumber
				ibank.description = purpose
				intrabankDescription = purpose
				contactData?.intrabank = ibank
			default:break
		}
		validateData()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func cell(shouldCelar _: CustomTableViewCell) -> Bool {
		return false
	}
	
	func getaccountNumber(for type: String) -> String {
		var accountNumber = ""
		_ = nodes.map { (item) in
			if item.title == type {
				accountNumber = item.id!
			}
		}
		return accountNumber
	}
}

// MARK: - API calls
extension IntrabankPaymentSelfVC {
	func createContact() {
		var postBody = ContactDataModel()
		postBody.accountId = AppGlobalData.shared().accountData?.id
		postBody.name = destinationAccountLabel
		var ibank = IntrabankAccount()
		ibank.accountNumber = destinationAccountNumber
		postBody.intrabank = ibank
		
		self.activityIndicatorBegin()
		ContactViewModel.shared.createNewContact(contactData: postBody) { (response, errorMessage) in
			self.activityIndicatorEnd()
			if let error = errorMessage {
				self.showAlertMessage(titleStr: error.title, messageStr: error.body )
			} else {
				if let _ = response {
					self.contactData = response
					self.contactData?.intrabank?.description = self.intrabankDescription
					self.makeIntrabankSelfPayment()
				}
			}
		}
	}
	
func makeIntrabankSelfPayment() {
	if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = contactData, let contactId = contact.id {
		self.view.endEditing(true)
		self.activityIndicatorBegin()
		var requestBody = PaymentModel()
		requestBody.accountId = accId
		requestBody.contactId = contactId
		requestBody.amount = self.paymentAmount.toString()
		requestBody.description = self.contactData?.intrabank?.description
		let selectedPaymentType = ContactAccountType.intrabank
		contactData?.selectedPaymentMode = ContactAccountType.intrabank
		PaymentViewModel.shared.makePayment(payRequestBody: requestBody, paymentType: selectedPaymentType) { (response, errorMessage) in
			self.activityIndicatorEnd()
			if let error = errorMessage {
				self.showAlertMessage(titleStr: error.title, messageStr: error.body )
			} else {
				if let resp = response {
					self.getAccountDetails(for: accId) { (_, _) in
						self.pResponse = resp
						self.gotoSuccessScreen()
					}
				}
			}
		}
	}
  }
}

extension IntrabankPaymentSelfVC: CurrencyEntryCellDelegate {
	func amountEntered(amount: Double) {
		self.paymentAmount = amount
		validateData()
	}

	func gotoSuccessScreen() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Pay", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentSuccessVC") as? PaymentSuccessVC {
			vc.contactData = self.contactData
			vc.paymentData = self.pResponse
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}
