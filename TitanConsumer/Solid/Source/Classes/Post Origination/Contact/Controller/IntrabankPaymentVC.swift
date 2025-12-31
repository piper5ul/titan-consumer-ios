//
//  IntrabankPaymentVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import UIKit

class IntrabankPaymentVC: BaseVC, FormDataCellDelegate {
	var arrTitles = [String]()
	var arrFieldTypes = [String]()
	var arrContactData = [String]()
	var contactData: ContactDataModel?
	var intraBankData: IntrabankAccount?
	var sholudEditContact: Bool = false
	var originalData: ContactDataModel?

	var paymentResponse: PaymentModel?
	var paymentRequestBody = PaymentModel()

	private let defaultAmount = "$0.00"
	var amount = 0.00
	var paymentAmount: Double = 0.0

    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    @IBOutlet weak var tblIntrabank: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setNavigationBar()
		self.setData()
		self.registerCellsAndHeaders()
		self.setContactData()

		self.tblIntrabank.reloadData()
		self.setFooterUI()
		self.validate()
        
        self.tblIntrabank.backgroundColor = .clear
    }
}

extension IntrabankPaymentVC {
	func setNavigationBar() {
		self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

		addBackNavigationbarButton()
		self.title = Utility.localizedString(forKey: "accountType_intrabank")
	}

	func setData() {
		arrTitles = ["payment_name", "payment_accountnumber", "payment_amount", "payment_purpose"]
		arrFieldTypes = ["alphaNumeric", "accountNumber", "currency", "alphaNumeric"]
	}

	func setFooterUI() {
		shouldShowFooterView = true
		footerView.configureButtons()
		footerView.btnApply.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
	}

	@objc func handleNavigation() {
		if checkForContactUpdate() {
			if let contactId = self.contactData?.id {
				self.updateContact(contactID: contactId)
			}
		} else {
			makeIntrabankPayment()
		}
	}

	func validate() {
		// for name and number
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

	func setContactData() {
		let name = contactData?.name ?? ""
		let accountNumber = contactData?.intrabank?.accountNumber ?? ""
		let amount = contactData?.intrabank?.amount ?? ""
		let purpose  = contactData?.intrabank?.description ?? ""
		arrContactData = [name, accountNumber, amount, purpose]
		if let _ = contactData?.intrabank {
			self.sholudEditContact = false
		} else {
			self.sholudEditContact = true
		}
		originalData = contactData
	}

	func checkForContactUpdate() -> Bool {
		if originalData?.intrabank?.accountNumber != contactData?.intrabank?.accountNumber {
			return true
		} else {
			return false
		}
	}

	func setIntrabankData() {
		let amount = ""
		let purpose  = ""
		arrContactData = [amount, purpose, amount, purpose]
	}

    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        var fFrame = footerView.frame
        var fY: CGFloat = footerView.frame.origin.y

        let navBarHeight = self.getNavigationbarHeight()

        UIView.animate(withDuration: 0.2) {
			fY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
			fFrame.origin.y = fY
            self.footerView.frame = fFrame
            self.view.layoutIfNeeded()

            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
            self.tblIntrabank.contentInset = contentInsets
            self.tblIntrabank.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblIntrabank.scrollIndicatorInsets = self.tblIntrabank.contentInset
        }
    }
}

// MARK: - UITableView
extension IntrabankPaymentVC: UITableViewDelegate, UITableViewDataSource {

	func registerCellsAndHeaders() {
		self.tblIntrabank.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
		self.tblIntrabank.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
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

		if indexPath.row == 2 {
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
				}
				cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
				cell.fieldType = arrFieldTypes[indexPath.row]
				cell.inputTextField?.text = arrContactData[indexPath.row]
				cell.inputTextField?.tag = indexPath.row
				cell.delegate = self
				return cell
		}
		}
		return UITableViewCell()
	}
}

// MARK: - FormDataCellDelegate
extension IntrabankPaymentVC {

    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {

        guard let indexPath = self.tblIntrabank.indexPath(for: cell) else {return}

        self.scrollToIndexPath = indexPath
    }

	func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

		guard let indexPath = self.tblIntrabank.indexPath(for: cell), let text = data as? String else {return}

		switch indexPath.row {
			case 0: // Name
				contactData?.name = text.trim
				cell.validateEnteredText(enteredText: text.trim)

			case 1:// Account Number
				let accountNumber = text.accountNumberString()
				var ibank = IntrabankAccount()
				ibank.accountNumber = accountNumber
				ibank.description = self.contactData?.intrabank?.description
				contactData?.intrabank = ibank

			case 2:// amount
				contactData?.intrabank?.amount = text.trim

			case 3: // purpose
				let purpose = text.trim
				var ibank = IntrabankAccount()
				ibank.accountNumber = self.contactData?.intrabank?.accountNumber
				ibank.description = purpose
				contactData?.intrabank = ibank

			default:break
		}
		validate()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func cell(shouldCelar _: CustomTableViewCell) -> Bool {
		return false
	}
}

// MARK: - API calls
extension IntrabankPaymentVC {
func updateContact(contactID: String) {
    if let data = contactData {
        var postBody = ContactDataModel()
        var ibank = IntrabankAccount()
        ibank.accountNumber = data.intrabank?.accountNumber

        postBody.accountId = AppGlobalData.shared().accountData?.id
        postBody.intrabank = ibank

        self.activityIndicatorBegin()

        ContactViewModel.shared.updateContact(contactId: contactID, contactData: postBody) { (response, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let _ = response {
                    self.makeIntrabankPayment()
                }
            }
        }
    }
}

func makeIntrabankPayment() {
	if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = contactData, let contactId = contact.id {
		self.view.endEditing(true)
		self.activityIndicatorBegin()
		var paymentRequestBody = PaymentModel()
		paymentRequestBody.accountId = accId
		paymentRequestBody.contactId = contactId
		paymentRequestBody.amount = self.paymentAmount.toString()
		paymentRequestBody.description = self.contactData?.intrabank?.description
		let selectedPaymentType = ContactAccountType.intrabank
		contactData?.selectedPaymentMode = ContactAccountType.intrabank
		PaymentViewModel.shared.makePayment(payRequestBody: paymentRequestBody, paymentType: selectedPaymentType) { (response, errorMessage) in
			self.activityIndicatorEnd()
			if let error = errorMessage {
				self.showAlertMessage(titleStr: error.title, messageStr: error.body )
			} else {
				if let resp = response {
					self.getAccountDetails(for: accId) { (_, _) in
						self.paymentResponse = resp
						self.gotoPaymentSuccess()
					}
				}
			}
		}
	}
  }
}

extension IntrabankPaymentVC: CurrencyEntryCellDelegate {
	func amountEntered(amount: Double) {
		self.paymentAmount = amount
		validate()
	}

	func gotoPaymentSuccess() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Pay", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentSuccessVC") as? PaymentSuccessVC {
			vc.contactData = self.contactData
			vc.paymentData = self.paymentResponse
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}
