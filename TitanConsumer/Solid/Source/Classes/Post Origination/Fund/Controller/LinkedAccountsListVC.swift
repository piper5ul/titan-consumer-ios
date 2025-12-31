//
//  LinkedAccountsListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 05/07/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import LinkKit
import SkeletonView

class LinkedAccountsListVC: BaseVC {

    @IBOutlet weak var tblLinkedAccounts: UITableView!

    var arrLinkedAccounts = [ContactDataModel]()
    var selectedindex: Int = -1
    let defaultSectionHeight: CGFloat = 60.0
	public var isloading: Bool = false

    var pullFundsFlow: PullFundsFlow? = .pullFundsIn

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        registerCellsAndHeaders()
        setFooterUI()
        validate()
		
        tblLinkedAccounts.backgroundColor = .clear
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		deregisterKeyboardObserver()
        getAccountsList()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		registerKeyboardObserver()
	}
	
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(goToPullFundsDetails), for: .touchUpInside)
    }

    func validate() {
        if arrLinkedAccounts.count > 0 && selectedindex >= 0 {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
}

// MARK: - Navigation
extension LinkedAccountsListVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        addBackNavigationbarButton()

        self.title = (pullFundsFlow == PullFundsFlow.pullFundsOut) ? Utility.localizedString(forKey: "move_fund_navTitle") : Utility.localizedString(forKey: "pull_fund_row_title")
    }

    @objc func goToPullFundsDetails() {
        self.performSegue(withIdentifier: "GoToPullFundsDetails", sender: self)
    }

    @objc func goToAddDebitCard() {
        self.performSegue(withIdentifier: "GoToAddDebitCard", sender: self)
    }
    
    @IBAction func removeAccount(sender: UIButton) {

        let acount = arrLinkedAccounts[sender.tag]

        self.alert(src: self, Utility.localizedString(forKey: "pull_fund_removelinkAccount_alertMsg"), "", Utility.localizedString(forKey: "yes"), Utility.localizedString(forKey: "cancel")) { button in
            if button == 1 {
                self.deleteLinkedAccount(contactID: acount.id ?? "", atIndex: sender.tag)
            }
        }
    }

    @IBAction func radioButtonSelected(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        reloadTable(withIndex: sender.tag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? PullFundsDetailsVC {
            destinationVC.accountData = self.arrLinkedAccounts[selectedindex]
            destinationVC.pullFundsFlow = self.pullFundsFlow
        }
    }
}

// MARK: - Tableview
extension LinkedAccountsListVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblLinkedAccounts.register(UINib(nibName: "FundLinkedAccountCell", bundle: .main), forCellReuseIdentifier: "FundLinkedAccountCell")
        self.tblLinkedAccounts.register(UINib(nibName: "DataActionCell", bundle: .main), forCellReuseIdentifier: "DataActionCell")
        self.tblLinkedAccounts.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
		self.tblLinkedAccounts.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return arrLinkedAccounts.count > 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var count = 0
        if section == 0 {
            count = arrLinkedAccounts.count > 0 ? arrLinkedAccounts.count : 1
        } else {
            count = 1
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 && arrLinkedAccounts.count > 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FundLinkedAccountCell", for: indexPath) as? FundLinkedAccountCell {
                cell.selectionStyle = .none

                let accountData = arrLinkedAccounts[indexPath.row]
               
                if pullFundsFlow == .debitPull {
                    let strDebitCardNo = accountData.debitCard?.last4 ?? ""
                    let strTitle = "XXXX XXXX XXXX " + strDebitCardNo
                    cell.lblAccountName.text = strTitle
                } else {
                    let strBankName = accountData.ach?.bankName ?? ""
                    let strAccNo = accountData.ach?.accountNumber?.last4() ?? ""
                    let strTitle = strBankName + " XXXXXX" + strAccNo
                    cell.lblAccountName.text = strTitle
                }

                if indexPath.row == selectedindex {
                    cell.isRadiobuttonSelected = true
                } else {
                    cell.isRadiobuttonSelected = false
                }

                cell.radioButton.tag = indexPath.row
                cell.radioButton.addTarget(self, action: #selector(radioButtonSelected(sender:)), for: .touchUpInside)

                cell.btnRemove.tag = indexPath.row
                cell.btnRemove.addTarget(self, action: #selector(removeAccount(sender:)), for: .touchUpInside)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
                cell.showFundLinkedAccountData()
                cell.lblcenterValue.text = pullFundsFlow == .debitPull ? Utility.localizedString(forKey: "link_debitCard_desc") :  Utility.localizedString(forKey: "pull_fund_linkAccount")

                cell.selectionStyle = .none

                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  60.0
	}
	
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        headerCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30)
        if section == 0 && arrLinkedAccounts.count > 0 {
            let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
            headerCell.lblSectionHeader.font = labelFont
            headerCell.lblSectionHeader.text = (pullFundsFlow == PullFundsFlow.pullFundsOut) ? Utility.localizedString(forKey: "move_fund_headerTitle") : Utility.localizedString(forKey: "pull_fund_headerTitle")
        } else {
            headerCell.lblSectionHeader.text = pullFundsFlow == .debitPull ? Utility.localizedString(forKey: "link_debitCard_title") : Utility.localizedString(forKey: "pull_fund_linkAccount_headerTitle")
            headerCell.lblSectionHeader.font = Constants.commonFont
        }
        
        headerCell.backgroundColor = .grayBackgroundColor
        headerCell.contentView.backgroundColor = .grayBackgroundColor
        
        headerCell.lblSectionHeader.leftAnchor.constraint(equalTo: headerCell.leftAnchor, constant: 1).isActive = true
        headerCell.lblSectionHeader.rightAnchor.constraint(equalTo: headerCell.rightAnchor).isActive = true
        headerCell.lblSectionHeader.topAnchor.constraint(equalTo: headerCell.topAnchor).isActive = true
        headerCell.lblSectionHeader.bottomAnchor.constraint(equalTo: headerCell.bottomAnchor).isActive = true
        headerCell.layoutIfNeeded()

        return headerCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 || (indexPath.section == 0 && arrLinkedAccounts.count == 0) {
            if pullFundsFlow == .debitPull {
                goToAddDebitCard()
            } else {
                // configure and open Plaid Link...
                 getPlaidToken()
            }
        } else {
            reloadTable(withIndex: indexPath.row)
        }
    }

    func reloadTable(withIndex: Int) {
        selectedindex = withIndex
        tblLinkedAccounts.reloadSections(IndexSet(integer: 0), with: .none)
        validate()
    }
}

// MARK: - API
extension LinkedAccountsListVC {

    func getPlaidToken() {
        if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id {
            self.activityIndicatorBegin()

            let requestBody = PlaidTempTokenRequestModel()

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

    func submitPlaidPublicToken(publicToken: String, plaidAccountId: String) {
        if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id {
            self.activityIndicatorBegin()

            var requestBody = PlaidPublicTokenRequestModel()
            requestBody.plaidToken = publicToken
            requestBody.plaidAccountId = plaidAccountId

            FundViewModel.shared.submitPlaidPublicToken(accountId: accId, requestBody: requestBody) { (response, errorMessage) in
                self.activityIndicatorEnd()

                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        self.getAccountsList()
                    }
                }
            }
        }
    }

    func getAccountsList() {
        if let accountID = AppGlobalData.shared().accountData?.id {
			self.view.showAnimatedGradientSkeleton()
            let contactType = pullFundsFlow == .debitPull ? "others" : "selfACH"
            ContactViewModel.shared.getContactList(accountId: accountID, type: contactType, limit: "\(Constants.fetchLimit)", offset: "0") { (response, errorMessage) in
				self.isloading = true
				self.view.hideSkeleton()

                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let accountslist = response?.data {
                        
                        self.arrLinkedAccounts = [ContactDataModel]()
                        
                        if self.pullFundsFlow == .debitPull {
                            for account in accountslist {
                                if let _ = account.debitCard {
                                    self.arrLinkedAccounts.append(account)
                                }
                            }
                        } else {
                            self.arrLinkedAccounts = accountslist
                        }
                        
                        self.selectedindex = -1
                        self.validate()
                        self.tblLinkedAccounts.reloadData()
                    }
                }
            }
        }
    }

    func deleteLinkedAccount(contactID: String, atIndex: Int) {

        self.activityIndicatorBegin()

        ContactViewModel.shared.deleteContact(contactId: contactID) { (response, errorMessage) in
            self.activityIndicatorEnd()

            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let _ = response {
                    self.arrLinkedAccounts.remove(at: atIndex)
                    self.validate()
                    self.tblLinkedAccounts.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil, userInfo: nil)
                }
            }
         }
    }
}

// MARK: - Plaid Link
extension LinkedAccountsListVC {

    func configurePlaid(withToken: String) {

        // Create Plaid Link configuration..
        var configuration = LinkTokenConfiguration(
            token: withToken,
            onSuccess: { linkSuccess in
                // Send the linkSuccess.publicToken to your app server.
                debugPrint("success : \(linkSuccess)")
                let publicToken = linkSuccess.publicToken
                let plaidAccountId = linkSuccess.metadata.accounts[0].id

                self.submitPlaidPublicToken(publicToken: publicToken, plaidAccountId: plaidAccountId)
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

extension LinkedAccountsListVC: SkeletonTableViewDataSource {
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
