//
//  ContactInfoVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/4/21.
//

import Foundation
import UIKit
import SkeletonView

class ContactInfoVC: BaseVC {
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    var contactData: ContactDataModel?
	var contactActionData: AccountActionDataModel?
	var dataSource: [[ContactRowData]]?
	let dataHandler = ContactDataHandler()
	public var isloading: Bool = false

    var arrExpand: [Bool] = [false, false]
	let defaultSectionHeight: CGFloat = 60.0
	var arrTitles = [String]()
	var isContactFromRCD = false

    override func viewDidLoad() {
        super.viewDidLoad()

        addCustomNavigationBar()
        registerCell()
        generateTableViewData()

        if let cId = self.contactData?.id {
            callAPIGetContactDetails(cId: cId)
        }

        addObserverToReloadContactData()
        
        tableViewTopConstraint.constant = Utility.getTopSpacing()
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
        
    @objc override func customBarBackClicked(sender: UIButton) {
        navigateToBack()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }
        
    func navigateToBack() {
        if let appDelegate = (UIApplication.shared.delegate) as? AppDelegate, let appwindow = appDelegate.window, let rootVC = appwindow.rootViewController, let rootNavigationCtrl = rootVC as? UINavigationController {
            if let contactlistvc = rootNavigationCtrl.viewControllers.filter({ $0.isKind(of: ContactsListVC.self) }).first {
                rootNavigationCtrl.popToViewController(contactlistvc, animated: true)
                return
            } else {
                self.navigationController?.backToViewController(viewController: DashboardVC.self)
            }
        }
    }
}

// MARK: - Other methods
extension ContactInfoVC {

    func addObserverToReloadContactData() {
        removeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContactDataAfterEdit), name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil)
    }

    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func reloadContactDataAfterEdit(notification: NSNotification) {
        callAPIGetContactDetails(cId: self.contactData?.id ?? "")
    }

	func generateTableViewData() {
		if let contact = contactData {
			isContactFromRCD = false
			let name: String = contactData?.name ?? ""

			// FOR RCD
			arrTitles = [name, "cardInfo_section_actions"]
			isContactFromRCD = true

			dataHandler.dataSource.removeAll()
			dataHandler.createDataSource(contact)
			tableView.reloadData()
			tableView.layoutIfNeeded()
		}
	}

    func gotoIntrabankPay() {
       // self.performSegue(withIdentifier: "gotopaymentselection", sender: self)
		let storyboard = UIStoryboard.init(name: "Contact", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "SendPaymentOptionVC") as? SendPaymentOptionVC {
			vc.contactData = self.contactData
            self.navigationController?.pushViewController(vc, animated: true)
		}
    }

    func goToContactDetailsVC() {
        let storyboard = UIStoryboard.init(name: "Contact", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ContactDetailsVC") as? ContactDetailsVC {
            vc.contactData = self.contactData
            vc.contactFlow = .edit
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func removeContact() {
        if let cId = self.contactData?.id, !cId.isEmpty {

            self.alert(src: self, Utility.localizedString(forKey: "contact_delete_alertMsg"), "", Utility.localizedString(forKey: "yes"), Utility.localizedString(forKey: "cancel")) { button in
                if button == 1 {
                    self.callDeleteContactAPI(contactID: cId)
                }
            }
        }
    }

    func goToTransactionListVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Transaction", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TransactionListVC") as? TransactionListVC {
            vc.listingType = .payment
            vc.contactId = contactData?.id
            vc.contactName = contactData?.name
            self.show(vc, sender: self)
        }
    }

    @objc func btnExpandClicked(sender: UIButton) {

        if let _ = contactData?.intrabank, let _ = contactData?.ach {
            let isExpand = arrExpand[sender.tag]
            arrExpand[sender.tag] = !isExpand
        } else if let _ = contactData?.intrabank {
            let isExpand = arrExpand[0]
            arrExpand[0] = !isExpand
        } else {
            let isExpand = arrExpand[1]
            arrExpand[1] = !isExpand
        }

        generateTableViewData()
    }

    @objc func btnMakePaymentClicked() {
        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                self.gotoIntrabankPay()
            }
        }
    }

    @objc func btnViewHistoryClicked(sender: UIButton) {
        goToTransactionListVC()
    }

    @objc func btnEditClick(sender: UIButton) {
        goToContactDetailsVC()
    }
}

// MARK: - API calls
extension ContactInfoVC {
	func callAPIGetContactDetails(cId: String) {
        self.isloading = false
		self.view.showAnimatedGradientSkeleton()
		ContactViewModel.shared.getContactDetail(contactId: cId) { (response, errorMessage) in
			self.isloading = true
            if let error = errorMessage {
				self.view.hideSkeleton()
				self.showAlertMessage(titleStr: error.title, messageStr: error.body )
			} else {
				self.contactData = response
				self.generateTableViewData()
				self.view.hideSkeleton()
			}
		}
	}

    func callDeleteContactAPI(contactID: String) {

        self.activityIndicatorBegin()

        ContactViewModel.shared.deleteContact(contactId: contactID) { (response, errorMessage) in
            self.activityIndicatorEnd()

            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let _ = response {

                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterDelete), object: nil, userInfo: nil)

                    self.navigateToBack()
                }
            }
         }
    }
}

// MARK: - Tableview methdos
extension ContactInfoVC: UITableViewDelegate, UITableViewDataSource {

	func registerCell() {
        tableView.register(UINib(nibName: "TransactionActionCell", bundle: nil), forCellReuseIdentifier: "TransactionActionCell")
		tableView.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
		tableView.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
        tableView.register(UINib(nibName: "ContactInfoHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ContactInfoHeaderCell")
		tableView.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return dataHandler.dataSource.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let dataSource = dataHandler.dataSource
		return section < dataSource.count ? dataSource[section].count  : 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {

				if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
					let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as ContactRowData
					cell.configureContactCell(forRow: rowData, hideSeparator: true)
					cell.selectionStyle = .none
					return cell
        }
		} else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
                let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as ContactRowData
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
        label.font = Constants.commonFont
        label.textAlignment = .left
        label.textColor = UIColor.primaryColor

        let strTitle = section == 0 ? contactData?.name:  Utility.localizedString(forKey: arrTitles[section])
        label.text = strTitle

        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 2).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerView.layoutIfNeeded()

        containerView.backgroundColor = UIColor.grayBackgroundColor

        return containerView
    }

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if !isloading {
			return Constants.skeletonCellHeight
		}
		let heightV: CGFloat = (indexPath.section == 0) ? 50.0 : 80.0
		return heightV
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if indexPath.section == 1 {
			switch indexPath.row {
				case 0:
					self.btnMakePaymentClicked()
				case 1:
					goToTransactionListVC()
				case 2:
					goToContactDetailsVC()
				case 3:
					removeContact()
				default:
					break
			}
		}
	}

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
}

extension ContactInfoVC: SkeletonTableViewDataSource {
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
		return 2
	}
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.orientationChangedViewController(tableview: self.tableView, with: coordinator)
	}
    
}
