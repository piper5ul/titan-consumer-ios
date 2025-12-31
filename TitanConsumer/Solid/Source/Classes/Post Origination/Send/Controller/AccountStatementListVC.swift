//
//  AccountStatementListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/16/21.
//

import Foundation
import UIKit
import SkeletonView

class AccountStatementListVC: BaseVC {
	var originalStatements = [StatementDataModel]()
	@IBOutlet weak var tblStatements: UITableView!
	@IBOutlet weak var lblNoStatementTitle: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		setNavigationBar()
		registerCellsAndHeaders()
		setUI()
		getStatements()
    }

	func setUI() {
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
		lblNoStatementTitle.font = labelFont
		lblNoStatementTitle.textAlignment = .center
		lblNoStatementTitle.textColor = UIColor.secondaryColorWithOpacity
		lblNoStatementTitle.text = Utility.localizedString(forKey: "no_statement_text")
	}
	
	@objc func getStatements() {
		self.tblStatements.showAnimatedGradientSkeleton()
		if let accData = AppGlobalData.shared().accountData, let accId = accData.id {
			AccountViewModel.shared.getaccountStatementList(accountId: accId) { (response, errorMessage) in
				self.tblStatements.hideSkeleton()
				if let error = errorMessage {
					self.showAlertMessage(titleStr: error.title, messageStr: error.body )
				} else {
					if let responseData = response, let statements = responseData.data {
						self.originalStatements = statements
						
						if self.originalStatements.count == 0 {
							self.lblNoStatementTitle.isHidden = false
						} else {
							self.lblNoStatementTitle.isHidden = true
							self.tblStatements.reloadData()
						}
						
					}
				}
			}
		}
	}
}

// MARK: - Navigationbar
extension AccountStatementListVC {

	func setNavigationBar() {
		self.isNavigationBarHidden = false
		self.title = Utility.localizedString(forKey: "statements")
        addBackNavigationbarButton()
	}
}

extension AccountStatementListVC: UITableViewDataSource, UIDocumentInteractionControllerDelegate {
	func registerCellsAndHeaders() {
		self.tblStatements.register(UINib(nibName: "DataActionCell", bundle: .main), forCellReuseIdentifier: "DataActionCell")
		self.tblStatements.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return originalStatements.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
			cell.selectionStyle = .none
				if let rowData = originalStatements[indexPath.row] as StatementDataModel? {
					cell.configureStatementCell(forRow: rowData)
					cell.btnAccesory.tag = indexPath.row
					cell.btnAccesory.addTarget(self, action: #selector(btnViewPdfClicked(sender:)), for: .touchUpInside)
					return cell
			}
		}
		return UITableViewCell()
	}

	@objc func btnViewPdfClicked(sender: UIButton) {
		let itag = sender.tag
		var queryString = ""
		var fname = ""
		if let rowData = originalStatements[itag] as StatementDataModel? {
			let month = rowData.month ?? 0
			let year = rowData.year ?? 0
			let xmonthString = String(month)
			let xyearString  = String(year)
			queryString = xyearString + "/" + xmonthString

			// Filename
			fname = xmonthString + "/" + xyearString
			fname = fname.getStatementDate(dateString: fname)
			fname = "Statement_\(fname).pdf"
		}
		self.activityIndicatorBegin()
		if let accData = AppGlobalData.shared().accountData, let accId = accData.id {
			AccountViewModel.shared.getaccountStatement(accountId: accId, query: queryString, filename: fname) { (filepath, _) in
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

extension AccountStatementListVC: SkeletonTableViewDataSource {
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
		return 1
	}
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let screenRectHeight = UIScreen.main.bounds.height
		return Int(screenRectHeight/78)
	}
}
