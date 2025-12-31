//
//  PullFundsSuccessVC.swift
//  Solid
//
//  Created by Solid iOS Team on 06/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class PullFundsSuccessVC: BaseVC {

    @IBOutlet weak var tblDetails: UITableView!

    var contactData: ContactDataModel?
    var paymentData: PaymentModel?
    let dataHandler = IBankPaymentDataHandler()
    let defaultSectionHeight: CGFloat = 60.0

    var pullFundsFlow: PullFundsFlow? = .pullFundsIn

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialUI()
        createTableData()
        self.setFooterUI()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "done"))
        footerView.btnApply.addTarget(self, action: #selector(doneClick), for: .touchUpInside)
    }
}

// MARK: - UI methods
extension PullFundsSuccessVC {

    func setupInitialUI() {
        setNavigationBar()
        registerCell()
    }

    func setNavigationBar() {
        self.isScreenModallyPresented = true
        self.isNavigationBarHidden = true
    }

    @objc func doneClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadAccountsAfterAdding), object: nil)
        self.popToHomeScreen()
    }
}

// MARK: - Data methods
extension PullFundsSuccessVC {

    func createTableData() {
        if let contactModel = contactData, let paymentModel = paymentData {
            dataHandler.dataSource.removeAll()
            dataHandler.createPullFundsSuccessTableData(contactModel, paymentModel, pullFundsFlow!)
            tblDetails.reloadData()
        }
    }
}

// MARK: - Tableview methdos
extension PullFundsSuccessVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        tblDetails.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        tblDetails.register(UINib(nibName: "PaymentSuccessCell", bundle: nil), forCellReuseIdentifier: "PaymentSuccessCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return (section == 0) ? 1 : dataHandler.dataSource[section-1].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSuccessCell", for: indexPath) as? PaymentSuccessCell {

                if let paymentModel = paymentData, let amount = paymentModel.amount {
                    let strAmt = Utility.getFormattedAmount(amount: amount)

                    cell.titleString = String(format: Utility.localizedString(forKey: "pull_fund_transferred_successAmount"), strAmt)
                }

                cell.descriptionString = Utility.localizedString(forKey: "pull_fund_transferred_successDesc")
                cell.lblDescription.textColor = UIColor.secondaryColor

                cell.animationImageName = "success"

                cell.backgroundColor = .clear
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {

                let rows = dataHandler.dataSource[indexPath.section-1]
                let rowData = rows[indexPath.row] as ContactRowData
                cell.configurePullFundsSuccessCell(forRow: rowData)
                if indexPath.row == dataHandler.dataSource[indexPath.section-1].count - 1 {
                    cell.imgSeperator.isHidden = true
                }
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 10))

        containerView.backgroundColor = UIColor.clear

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0 ? 50 : 10)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            tableView.drawCornerAroundTableView(for: indexPath, willDisplay: cell)
        }
    }
}
