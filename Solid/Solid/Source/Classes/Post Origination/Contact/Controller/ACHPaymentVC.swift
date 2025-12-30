//
//  ACHPaymentVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import UIKit
class ACHPaymentVC: BaseVC, FormDataCellDelegate {

    @IBOutlet weak var tblACH: UITableView!
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    var arrTitles = [String]()
    var arrFieldTypes = [String]()
    var arrContactData = [String]()
    var contactData: ContactDataModel?
    var sholudEditContact: Bool = false
    var bankData = ACHAccount()
	var originalData: ContactDataModel?
    var achpaymentResponse: PaymentModel?
    var achpaymentRequestBody = PaymentModel()

    private let defaultAmount = "$0.00"
    var amount = 0.00
    var paymentAmount: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.validate()
    }

    func setUI() {
        self.setNavigationBar()
        self.setData()
        self.registerCellsAndHeaders()
        self.setContactData()
        self.tblACH.reloadData()
        self.setFooterUI()
        
        self.tblACH.backgroundColor = .clear
    }

    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {

        var cFrame = footerView.frame

        var cY: CGFloat = footerView.frame.origin.y

        let navBarHeight = self.getNavigationbarHeight()

        UIView.animate(withDuration: 0.2) {
            cY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
            cFrame.origin.y = cY
            self.footerView.frame = cFrame
            self.view.layoutIfNeeded()

            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
            self.tblACH.contentInset = contentInsets
            self.tblACH.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblACH.scrollIndicatorInsets = self.tblACH.contentInset
        }
    }
}

extension ACHPaymentVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        addBackNavigationbarButton()
        self.title = Utility.localizedString(forKey: "accountType_ach")
    }

    func setData() {
        arrTitles = ["payment_name", "contact_Account_AccNo", "contact_Account_RoutingNo", "contact_Account_Type", "contact_Account_Bank", "payment_amount", "payment_purpose"]
        arrFieldTypes = ["contactname", "accountNumber", "routingNumber", "stringPicker", "alphaNumeric", "currency", "alphaNumeric"]
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
			self.makeACHPayment()
		}
	}

	func checkForContactUpdate() -> Bool {
		if originalData?.ach?.accountNumber != contactData?.ach?.accountNumber || originalData?.ach?.routingNumber != contactData?.ach?.routingNumber || originalData?.ach?.bankName != contactData?.ach?.bankName {
			return true
		} else {
			return false
		}
	}

    func validate() {
        // for name and number
        if let _ = contactData?.name,
           let accountNumber = contactData?.ach?.accountNumber, accountNumber.isAccountNumberInLimit(),
           self.paymentAmount > 0,
           let purpose = contactData?.ach?.purpose, !purpose.isEmpty,
           let routingNumber = contactData?.ach?.routingNumber, !routingNumber.isEmpty,
           let bankName = contactData?.ach?.bankName, !bankName.isEmpty {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }

    func setContactData() {
        if let _ = contactData?.ach {
            self.sholudEditContact = false

        } else {
            self.sholudEditContact = true
        }

        let name = contactData?.name ?? ""
        let accNo = contactData?.ach?.accountNumber ?? ""
        let routingNo = contactData?.ach?.routingNumber ?? ""
        var type = ""
        let bankName = contactData?.ach?.bankName ?? ""

        if let bType =  contactData?.ach?.accountType {
            type =  AccountType.title(for: bType.rawValue)
            bankData.accountType = bType
        }

        bankData.accountNumber = accNo
        bankData.routingNumber = routingNo
        bankData.bankName = bankName

        contactData?.ach = bankData

        let amount = contactData?.ach?.amount ?? ""
        let purpose  = contactData?.ach?.purpose ?? ""

		self.originalData = contactData
        arrContactData = [name, accNo, routingNo, type, bankName, amount, purpose]
    }
}

// MARK: - UITableView
extension ACHPaymentVC: UITableViewDelegate, UITableViewDataSource {

    func registerCellsAndHeaders() {
        self.tblACH.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        self.tblACH.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cheight: CGFloat
		cheight	= Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
		return cheight
	}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strTitle = arrTitles[indexPath.row]

        if indexPath.row == 5 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
                // let rowData = rows[indexPath.row] as ContactRowData
                // cell.configureCellForIntrabankPay(dataModel: rowData)
                cell.delegate = self
                cell.lblTitle?.text = Utility.localizedString(forKey: strTitle)
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {
				cell.isUserInteractionEnabled = true
				if cell.fieldType == "contactname" {
			    cell.isUserInteractionEnabled = false
				}
                cell.arrPickerData = AccountType.dataNodes
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
extension ACHPaymentVC {

    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {

        guard let indexPath = self.tblACH.indexPath(for: cell) else {return}

        self.scrollToIndexPath = indexPath
    }

    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

        guard let indexPath = self.tblACH.indexPath(for: cell), let text = data as? String else {return}

        switch indexPath.row {
        case 0:
            contactData?.name = text.trim

        case 1: // Account Number
            contactData?.ach?.accountNumber = text.trim
            var achAccount = self.contactData?.ach
            achAccount?.accountNumber = text.trim
            contactData?.ach = achAccount
			arrContactData[indexPath.row] = text.trim

        case 2:// Routing Number
            var achAccount = self.contactData?.ach
            achAccount?.routingNumber = text.trim
            contactData?.ach = achAccount
			arrContactData[indexPath.row] = text.trim

        case 3:// Account Type
            var achAccount = self.contactData?.ach
            achAccount?.accountType = AccountType(rawValue: AccountType.entityId(for: text.trim))
            contactData?.ach = achAccount
			arrContactData[indexPath.row] = text.trim

        case 4:// Bank Name
            var achAccount = self.contactData?.ach
            achAccount?.bankName = text.trim
            contactData?.ach = achAccount
            cell.validateEnteredText(enteredText: text.trim)

        case 6: // purpose
            let purpose = text.trim
            var achAccount = self.contactData?.ach
            achAccount?.purpose = purpose
			arrContactData[indexPath.row] = text.trim
            contactData?.ach = achAccount

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
extension ACHPaymentVC {
    func makeACHPayment() {
        if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = contactData, let contactId = contact.id {
            self.view.endEditing(true)
            self.activityIndicatorBegin()
            var achpaymentRequestBody = PaymentModel()
            achpaymentRequestBody.accountId = accId
			achpaymentRequestBody.contactId = contactId
			achpaymentRequestBody.amount = self.paymentAmount.toString()
			achpaymentRequestBody.description = self.contactData?.ach?.purpose
			let selectedPaymentType =  ContactAccountType.ach

            PaymentViewModel.shared.makePayment(payRequestBody: achpaymentRequestBody, paymentType: selectedPaymentType) { (achresponse, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
					if let resp = achresponse {
						self.getAccountDetails(for: accId) { (_, _) in
						self.achpaymentResponse = resp
						self.gotoachPaymentSuccess()
						}
					}
                }
            }
        }
    }

    func updateContact(contactID: String) {
        if let data = contactData {
            var postBody = ContactDataModel()
            postBody.accountId = AppGlobalData.shared().accountData?.id
            
            postBody.ach = data.ach
            postBody.ach?.purpose = nil
            postBody.ach?.amount = nil
            
            self.activityIndicatorBegin()

            ContactViewModel.shared.updateContact(contactId: contactID, contactData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()

                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        self.makeACHPayment()
                    }
                }
            }
        }
    }
}

extension ACHPaymentVC: CurrencyEntryCellDelegate {
    func amountEntered(amount: Double) {
        self.paymentAmount = amount
        validate()
    }

    func gotoachPaymentSuccess() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Pay", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentSuccessVC") as? PaymentSuccessVC {
            vc.contactData = self.contactData
            vc.paymentData = self.achpaymentResponse
            self.show(vc, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
}
