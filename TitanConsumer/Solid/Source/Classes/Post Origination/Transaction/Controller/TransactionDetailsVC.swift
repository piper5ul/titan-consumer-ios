//
//  TransactionDetailsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import UIKit
import SkeletonView

class TransactionDetailsVC: BaseVC, DataActionCellDelegate {

    @IBOutlet weak var tblTransactionDetails: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    var transactionData: TransactionModel?
    var contactActionData: AccountActionDataModel?
    var dataSource: [[TransactionRowData]]?
    let dataHandler = TransactionDataHandler()
	var listingType: TransactionListingType? = .transaction
	var transferType: TransferType?
	public var isloading: Bool = false
    let defaultSectionHeight: CGFloat = 60.0

    var arrHeaderTitles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerCell()
        addCustomNavigationBar()
		var summary  = "transaction_summary_tittle"
		if transferType ==  TransferType.card {
			summary = "cardtransactionsummary"
		}

        arrHeaderTitles = [summary, "other_details", "actions", "location"]

		self.getTransactionDetail()
    }

    func setupUI() {
        tableViewTopConstraint.constant = Utility.getTopSpacing()
    }

    func getTransactionDetail() {
        self.isloading = false
        self.tblTransactionDetails.showGradientSkeleton()
        
        let strID = AppGlobalData.shared().accountData?.id ?? ""
        
        if !strID.isEmpty {
            let transactionId = AppGlobalData.shared().selectedTransaction.id ?? ""
            TransactionViewModel.shared.getTransactionDetail(strId: strID, transactionId: transactionId) { (response, errorMessage) in
                self.isloading = true
                self.view.hideSkeleton()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let transactionresponse =  response {
                        AppGlobalData.shared().selectedTransaction = transactionresponse
                        self.setTableData()
                        self.generateTableViewData()
                    }
                }
            }
        }
    }

	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.isNavigationBarTranslucent = true
	}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isNavigationBarTranslucent = false
    }
}

// MARK: - Navigation
extension TransactionDetailsVC {

    func setTableData() {
		transactionData = AppGlobalData.shared().selectedTransaction
    }

    func generateTableViewData() {
        if let transaction = transactionData {
            dataHandler.dataSource.removeAll()
            dataHandler.createDataSource(transaction)
            tblTransactionDetails.reloadData()
            tblTransactionDetails.layoutIfNeeded()
        }
    }
}

// MARK: - Tableview methdos
extension TransactionDetailsVC: UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate {

    func registerCell() {
        tblTransactionDetails.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        tblTransactionDetails.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
		tblTransactionDetails.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
        tblTransactionDetails.register(UINib(nibName: "TransactionActionCell", bundle: nil), forCellReuseIdentifier: "TransactionActionCell")
        tblTransactionDetails.register(UINib(nibName: "LocationCell", bundle: nil),
                               forCellReuseIdentifier: "LocationCell")
        tblTransactionDetails.register(UINib(nibName: "DashboardSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "DashboardSectionHeaderView")
		tblTransactionDetails.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil), forCellReuseIdentifier: "SkeletonLoaderCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
		return dataHandler.dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = dataHandler.dataSource
		
        return section < dataSource.count ? dataSource[section].count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if indexPath.section == 0 {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
				if let aData = transactionData {
					cell.configureTransactionCell(forRow: aData, hideSeparator: true)
				}
				cell.selectionStyle = .none
				return cell
			}
		} else if indexPath.section == 1, let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
			let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as TransactionRowData
			cell.configureTransactionCell(forRow: rowData, hideSeparator: true)
			cell.selectionStyle = .none
			return cell
			
		} else if indexPath.section == 2 {
			if Utility.isDeviceIpad(), let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
					let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as TransactionRowData
					cell.configureTransactionDetail()
					cell.lblcenterValue.text = rowData.key
					return cell
					
			} else {
				if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionActionCell", for: indexPath) as? TransactionActionCell {
					cell.configureTransactionActionData()
					cell.btnPDF.addTarget(self, action: #selector(btnViewPdfClicked(sender:)), for: .touchUpInside)
					cell.btnReportIssue.addTarget(self, action: #selector(btnReportIssueClicked(sender:)), for: .touchUpInside)
					return cell
				}
			}
       } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationCell {
                if let rowData = transactionData {
                    cell.showTransactionLocationData(forRow: rowData)
                    cell.selectionStyle = .none
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DashboardSectionHeaderView") as? DashboardSectionHeaderView {

            headerView.titleString = Utility.localizedString(forKey: arrHeaderTitles[section])
            headerView.subTitleString = ""

            headerView.rightTitleString = ""
            headerView.imgViewRightIcon.isHidden = true
            headerView.imgViewLeftIcon.isHidden = true

            return headerView
        }

        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightV: CGFloat
		if !isloading {
			return Constants.skeletonCellHeight
		}
		
        if indexPath.section == 0 {
            heightV = 84
        } else if indexPath.section == 2 {
			heightV = Utility.isDeviceIpad() ? 65 : 48
        } else if indexPath.section == 3 {
            heightV = 320
        } else {
            heightV = 60
        }
        return heightV
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if Utility.isDeviceIpad() {
			if indexPath.section == 2 && indexPath.row == 0 {
				btnViewPdfClicked(sender: self)
			} else if indexPath.section == 2 && indexPath.row == 1 {
                self.openEmail()
			}
		}
	}
	
    @objc func btnReportIssueClicked(sender: UIButton) {
        self.openEmail()
    }

	@objc func btnViewPdfClicked(sender: Any) {
        self.activityIndicatorBegin()
        
        let strID = AppGlobalData.shared().accountData?.id ?? ""
        let filename = "\(AppGlobalData.shared().selectedTransaction.id ?? "Transaction").pdf"
        
        if let strTrnsId = AppGlobalData.shared().selectedTransaction.id, !strID.isEmpty {
            TransactionViewModel.shared.transactionDetailExport(strId: strID, transactionId: strTrnsId, filename: filename) { (filepath, _) in
                self.activityIndicatorEnd()
                if let fpath = filepath {
                    self.showPDF(forFile: fpath)
                }
            }
        }
    }

	func showPDF(forFile fileURL: URL) {
		let dc = UIDocumentInteractionController(url: fileURL)
		dc.delegate = self
		dc.presentPreview(animated: true)
	}

	func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
		return self// or use return self.navigationController for fetching app navigation bar colour
	}
}

extension TransactionDetailsVC: SkeletonTableViewDataSource {
	
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 3
	}
	
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.orientationChangedViewController(tableview: self.tblTransactionDetails, with: coordinator)
	}
}
