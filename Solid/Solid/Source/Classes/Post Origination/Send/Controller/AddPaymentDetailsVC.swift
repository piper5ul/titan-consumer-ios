//
//  AddPaymentDetailsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation
import UIKit

class AddPaymentDetailsVC: BaseVC {

    var contactData: ContactDataModel?
	var selectedPaymentType: String?

    var paymentResponse: PaymentModel?
    var paymentRequestBody = PaymentModel()
    let dataHandler = IBankPaymentDataHandler()

    let defaultSectionHeight: CGFloat = 60.0
    var paymentAmount: Double = 0.0

    @IBOutlet weak var tblDetails: UITableView!

    var sectionList: [String] {
        return [Utility.localizedString(forKey: "contact_makepayment_title"),
                Utility.localizedString(forKey: "pay_section_source"),
                Utility.localizedString(forKey: "pay_section_destination")]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialUI()
        createTableData()

        self.setFooterUI()
        validate()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "pay"))
        footerView.btnApply.addTarget(self, action: #selector(callPaymentAPI), for: .touchUpInside)
    }
}

// MARK: - UI methods
extension AddPaymentDetailsVC {

    func setupInitialUI() {
        setNavigationBar()
        registerCell()
    }

    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        // addBackNavigationButton()

        if let contact = self.contactData, let name = contact.name {
            self.title = name
        }
    }
}

// MARK: - Other methods
extension AddPaymentDetailsVC {

    @objc func callPaymentAPI() {
        callAPIForPayment()
    }

    func validate() {
        if let desc = paymentRequestBody.description, !desc.isEmpty && !desc.isInvalidInput(), paymentAmount >= 0.50 {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }

    func gotoPaymentSuccess() {
        self.performSegue(withIdentifier: "GotoPaymentSuccess", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let paymentSuccessVC = segue.destination as? PaymentSuccessVC {
            paymentSuccessVC.contactData = self.contactData
            paymentSuccessVC.paymentData = self.paymentResponse
        }
    }
}
// MARK: - Data methods
extension AddPaymentDetailsVC {

    func createTableData() {
        if let contactModel = contactData {
            dataHandler.dataSource.removeAll()
            dataHandler.createTableData(contactModel, paymentRequestBody)
            tblDetails.reloadData()
        }
    }
}

// MARK: - API call
extension AddPaymentDetailsVC {

    func callAPIForPayment() {
        if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = contactData, let contactId = contact.id {
            self.view.endEditing(true)
            self.activityIndicatorBegin()
            paymentRequestBody.accountId = accId
            paymentRequestBody.contactId = contactId
            paymentRequestBody.amount = self.paymentAmount.toString()
			let selectedPaymentType = self.contactData?.selectedPaymentMode ?? .intrabank

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

// MARK: - FormDataCellDelegate, CurrencyEntryCellDelegate methods

extension AddPaymentDetailsVC: CurrencyEntryCellDelegate {
    func amountEntered(amount: Double) {
        self.paymentAmount = amount

        let allRows = dataHandler.dataSource[0] as [ContactRowData]
        if var amountRow = allRows.first {
            amountRow.value = self.paymentAmount.toString()
            dataHandler.dataSource[0][0] = amountRow
        }

        validate()
    }
}

extension AddPaymentDetailsVC: FormDataCellDelegate {

    func cell(_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

        guard let indexPath = self.tblDetails.indexPath(for: cell), let text = data as? String else {return}

        if indexPath.section == 0 && indexPath.row == 1 {
                paymentRequestBody.description = text
                let allRows = dataHandler.dataSource[0] as [ContactRowData]
                var purposeRow = allRows[1]
                purposeRow.value = text
                dataHandler.dataSource[0][1] = purposeRow

                cell.validateEnteredText(enteredText: text.trim)
        }

        validate()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Tableview methdos
extension AddPaymentDetailsVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        tblDetails.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        tblDetails.register(UINib(nibName: "DataEntryCell", bundle: nil), forCellReuseIdentifier: "DataEntryCell")
        tblDetails.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return dataHandler.dataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard dataHandler.dataSource[indexPath.section].count > indexPath.row else {
            return UITableViewCell()
        }

        let rows = dataHandler.dataSource[indexPath.section]

        if indexPath.section == 0 {

            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
                    let rowData = rows[indexPath.row] as ContactRowData
                    cell.configureCellForIntrabankPay(dataModel: rowData)
                    cell.delegate = self
                    cell.selectionStyle = .none
                    return cell
                }

            } else {

                if let cell = tableView.dequeueReusableCell(withIdentifier: "DataEntryCell", for: indexPath) as? DataEntryCell {
                    let rowData = rows[indexPath.row] as ContactRowData
                    cell.configureCellForIntrabankPay(dataModel: rowData)
                    cell.delegate = self
                    cell.selectionStyle = .none
                    return cell
                }
            }

        } else {

            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
                let rowData = rows[indexPath.row] as ContactRowData
                cell.configureContactCell(forRow: rowData, hideSeparator: true)
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: defaultSectionHeight))
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)

        label.font = UIFont.sfProDisplayBold(fontSize: 18)
        label.textAlignment = .left
        label.textColor = UIColor.primaryColor
        label.text = sectionList[section]

        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 2).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerView.layoutIfNeeded()

        containerView.backgroundColor = UIColor.white

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            tableView.drawCornerAroundTableView(for: indexPath, willDisplay: cell)
        }
    }
}
