//
//  PaymentSuccessVC.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import Foundation
import UIKit

class PaymentSuccessVC: BaseVC {

    @IBOutlet weak var tblDetails: UITableView!

    var contactData: ContactDataModel?
    var paymentData: PaymentModel?
	var addressData: Address?
    let dataHandler = IBankPaymentDataHandler()
    let defaultSectionHeight: CGFloat = 30.0

    var sectionList: [String] {
        return ["",
                ""]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        self.setFooterUI()
		createTableData()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "done"))
        footerView.btnApply.addTarget(self, action: #selector(doneClick), for: .touchUpInside)
    }
}

// MARK: - UI methods
extension PaymentSuccessVC {

    func setupInitialUI() {
        setNavigationBar()
        registerCell()
    }

    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        self.isNavigationBarHidden = true
        if let contact = self.contactData, let name = contact.name {
            self.title = name
			let paymentMode = contact.selectedPaymentMode
			switch paymentMode {
				case .intrabank:
					tblDetails.center = self.view.center
				case .check :
					tblDetails.center = self.view.center
				case .sendVisaCard :
					tblDetails.center = self.view.center
				default:
					break
			}
        }
    }

    @objc func doneClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadAccountsAfterAdding), object: nil)
        self.popToHomeScreen()
    }
}

// MARK: - Data methods
extension PaymentSuccessVC {

    func createTableData() {
        if let contactModel = contactData, let paymentModel = paymentData {
            dataHandler.dataSource.removeAll()
            dataHandler.createSuccessTableData(contactModel, paymentModel)
            tblDetails.reloadData()
        }
    }
}

// MARK: - Tableview methdos
extension PaymentSuccessVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        tblDetails.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        tblDetails.register(UINib(nibName: "PaymentSuccessCell", bundle: nil), forCellReuseIdentifier: "PaymentSuccessCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return (section == 0) ? 1 : dataHandler.dataSource[section-1].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentSuccessCell", for: indexPath) as? PaymentSuccessCell {
            if let paymentModel = paymentData, let amount = paymentModel.amount {
                let strAmt = Utility.getFormattedAmount(amount: amount)
                cell.titleString = String(format: Utility.localizedString(forKey: "paid_to_title"), strAmt)
            }
            if let contact = contactData, let contactName = contact.name {
                var localizedTitle = ""
                var descriptionStr = ""
                let selectedPaymentMode = contact.selectedPaymentMode
                
                switch selectedPaymentMode {
                case  .ach:
                    localizedTitle = Utility.localizedString(forKey: "pay_success_description")
                    descriptionStr = String(format: localizedTitle, contactName)
                case .check:
                    localizedTitle = Utility.localizedString(forKey: "pay_check_success_description")
                    descriptionStr = String(format: localizedTitle, contactName)
                case  .intrabank:
                    localizedTitle = Utility.localizedString(forKey: "pay_intra_success_description")
                    descriptionStr = String(format: localizedTitle, contactName)
                case .domesticWire, .internationalWire:
                    localizedTitle = Utility.localizedString(forKey: "pay_wire_success_description")
                    descriptionStr = String(format: localizedTitle, contactName)
                case .sendVisaCard:
                    localizedTitle = Utility.localizedString(forKey: "pay_card_success_description")
                    descriptionStr = String(format: localizedTitle, contactName)
                default :
                    break
                }
                cell.descriptionString = descriptionStr
            }
            
            cell.animationImageName = "success"
            cell.backgroundColor = .clear
            return cell
            
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
            let rows = dataHandler.dataSource[indexPath.section-1]
            let rowData = rows[indexPath.row] as ContactRowData
            cell.configureContactCell(forRow: rowData, hideSeparator: true)
           
            if indexPath.row == dataHandler.dataSource[indexPath.section-1].count - 1 {
                cell.imgSeperator.isHidden = true
            }
            
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: defaultSectionHeight))
        containerView.backgroundColor = UIColor.clear

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 1 : defaultSectionHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            tableView.drawCornerAroundTableView(for: indexPath, willDisplay: cell)
        }
    }
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.orientationChangedViewController(tableview: self.tblDetails, with: coordinator)
	}
}
