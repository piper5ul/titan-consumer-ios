//
//  CardInfoVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import Foundation
import SkeletonView
import PassKit
import UIKit

class CardInfoVC: BaseVC {
    @IBOutlet weak var tblDetails: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    var cardModel: CardModel?
    var cardDetailsModel: CardDetailsModel?
    var sectionCount = 3
    let defaultSectionHeight: CGFloat = 60.0
    var dataSource = [[ContactRowData]]()
    var finalCardNumber: String?
    
    public var isloading: Bool = false
    
    var isCardFreezed: Bool {
        if let aCardModel = self.cardModel {
            return aCardModel.cardStatus == CardStatus.inactive
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupInitialUI()
        setupInitialData()
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            tblBottomConstraint.constant = bottomPadding == 0 ? 65 : 45
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.isNavigationBarTranslucent = true
        if let isAddToWalletEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isAddToWalletEnabled, isAddToWalletEnabled {
            self.checkEligibility()
        }
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isNavigationBarTranslucent = false
    }
    
    @objc override func customBarBackClicked(sender: UIButton) {
        navigateToBack()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(callAPIToGetCardDetails), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tblDetails.reloadData()
    }
}

// MARK: - UI methods
extension CardInfoVC {
    func setupInitialUI() {
        registerCell()
        tableViewTopConstraint.constant = Utility.getTopSpacing()
    }
    
    func setupInitialData() {
        callAPIToGetCardDetails()
    }
    
    func setNavigationBar() {
        addCustomNavigationBar()
    }
    
    func navigateToBack() {
        NotificationCenter.default.removeObserver(self)
        if self.navigationController?.children.filter({ $0.isKind(of: CardsListVC.self)}).count != 0 {
            self.navigationController?.backToViewController(viewController: CardsListVC.self)
        } else {
            self.navigationController?.backToViewController(viewController: DashboardVC.self)
        }
    }
    
    func gotoCardDetailsScreen() {
        let storyboard = UIStoryboard.init(name: "Card", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CardLimitScreenVC") as? CardLimitScreenVC {
            vc.cardData = self.cardModel
            self.show(vc, sender: self)
        }
    }
    
    func showAlertForAction(isCancel: Bool) {
        var title = Utility.localizedString(forKey: "cardInfo_cancel_alert_title")
        var message = Utility.localizedString(forKey: "cardInfo_cancel_alert_messsage")
        var firstBtn = Utility.localizedString(forKey: "yes")
        var secondBtn = Utility.localizedString(forKey: "no")
        
        if !isCancel {
            
            title = isCardFreezed ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_title") : Utility.localizedString(forKey: "cardInfo_freeze_alert_title")
            message = isCardFreezed ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_messsage") : Utility.localizedString(forKey: "cardInfo_freeze_alert_messsage")
            firstBtn = isCardFreezed ? Utility.localizedString(forKey: "cardInfo_unfreeze_button") : Utility.localizedString(forKey: "cardInfo_freeze_button")
            secondBtn = Utility.localizedString(forKey: "cancel")
        }
        
        alert(src: self, title, message, firstBtn, secondBtn) { (button: Int) in
            if button == 1 {
                if isCancel {
                    self.callAPIToCancelCard()
                } else {
                    if let aCardModel = self.cardModel {
                        let aStatus = (aCardModel.cardStatus == CardStatus.inactive) ? CardStatus.active : CardStatus.inactive
                        self.callAPIToFreezeCard(status: aStatus)
                    }
                }
            } else {
                if !isCancel {
                    self.tblDetails.reloadData()
                }
            }
        }
    }
}

// MARK: - Other methods
extension CardInfoVC {
    func createTableData() {
        dataSource = [[ContactRowData]]()
        
        let section2 = createTransactionData()
        dataSource.append(section2)
        
        let section3 = createActionsData()
        dataSource.append(section3)
    }
    
    func createTransactionData() -> [ContactRowData] {
        var section = [ContactRowData]()
        
        if let aCardModel = cardModel {
            // Card Number
            var row1 = ContactRowData()
            row1.key = Utility.localizedString(forKey: "cardInfo_row_title_CardNo") + " : "
            row1.value = aCardModel.id
            row1.iconName = "copy_black"
            section.append(row1)
        }
        
        // Transactions
        var row2 = ContactRowData()
        row2.key = Utility.localizedString(forKey: "cardInfo_row_title_transactions")
        row2.iconName = "Chevron-right-grey"
        row2.cellType = .detail
        section.append(row2)
        
        return section
    }
    
    func createActionsData() -> [ContactRowData] {
        var section = [ContactRowData]()
        
        // Freeze card
        var row1 = ContactRowData()
        row1.key = Utility.localizedString(forKey: "cardInfo_row_title_freeze")
        row1.iconName = "Blocked"
        row1.cellType = .switched
        row1.isSwitchOn = self.isCardFreezed
        section.append(row1)
        
        // Card Label
        var row2 = ContactRowData()
        var strRow2Key = Utility.localizedString(forKey: "card_label")
        if cardModel?.label != nil {
            strRow2Key += " : " + (cardModel?.label ?? "")
        }
        row2.key = strRow2Key
        row2.cellType = .btn
        row2.title = Utility.localizedString(forKey: "Edit")
        section.append(row2)
        
        //Card Limit
        var row3 = ContactRowData()
        var strRow3Key = CardDetails.amountLimit.getTitleKey()
        if cardModel?.limitAmount != nil {
            strRow3Key += " : " + Utility.getFormattedAmount(amount: cardModel?.limitAmount ?? "")
        }
        row3.key = strRow3Key
        row3.cellType = .btn
        row3.title = Utility.localizedString(forKey: "Edit")
        section.append(row3)
        
        //ATM Info
        var row4 = ContactRowData()
        row4.key = Utility.localizedString(forKey: "info_ATM")
        row4.iconName = "pay"
        row4.cellType = .detail
        section.append(row4)
        
        // cancel card
        var row5 = ContactRowData()
        row5.key = Utility.localizedString(forKey: "cardInfo_row_title_cancel")
        row5.iconName = "pay"
        row5.cellType = .detail
        section.append(row5)
        
        // Get help
        var row6 = ContactRowData()
        row6.key = Utility.localizedString(forKey: "cardInfo_row_title_help")
        row6.iconName = "Allowed"
        row6.cellType = .detail
        section.append(row6)
        
        return section
    }
    
    func reloadActionData() {
        let actions = createActionsData()
        dataSource[1] = actions
        let sectionNumber = sectionCount - 1
        tblDetails.reloadSections(IndexSet(integersIn: sectionNumber...sectionNumber), with: .none)
    }
    
    func reloadCardsData() {
        tblDetails.reloadSections(IndexSet(integersIn: 0...1), with: .none)
    }
}

// MARK: - API methods
extension CardInfoVC {
    @objc func callAPIToGetCardDetails() {
        if let aCardModel = self.cardModel, let cardId = aCardModel.id {
            self.isloading = false
            self.tblDetails.showAnimatedGradientSkeleton()
            CardViewModel.shared.getcardDetails(cardId: cardId) { (response, errorMessage) in
                self.isloading = true
                self.tblDetails.hideSkeleton()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let respCardModel = response {
                        AppGlobalData.shared().cardData = respCardModel
                        self.cardModel = respCardModel
                        self.createTableData()
                        self.tblDetails.reloadData()
                    }
                }
            }
        }
    }
    
    func callAPIToFreezeCard(status: CardStatus) {
        if let aCardModel = self.cardModel, let cardId = aCardModel.id {
            self.activityIndicatorBegin()
            
            var requestBody = CardUpdateRequestBody()
            requestBody.cardStatus = status
            
            CardViewModel.shared.updateCard(cardID: cardId, contactData: requestBody) { (response, errorMessage) in
                
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let respCardModel = response {
                        self.cardModel = respCardModel
                        self.tblDetails.reloadData()
                        self.reloadCardList()
                    }
                }
            }
        }
    }
    
    func callAPIToCancelCard() {
        if let aCardModel = self.cardModel, let cardId = aCardModel.id {
            self.activityIndicatorBegin()
            
            CardViewModel.shared.deleteCard(cardId: cardId) { (response, errorMessage) in
                
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        self.reloadCardList()
                        if self.navigationController?.children.filter({ $0.isKind(of: CardsListVC.self)}).count != 0 {
                            self.navigationController?.backToViewController(viewController: CardsListVC.self)
                        } else {
                            self.navigationController?.backToViewController(viewController: DashboardVC.self)
                        }
                    }
                }
            }
        }
    }
    
    func reloadCardList() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterStatusChange), object: nil)
    }
}

// MARK: - DataActionCellDelegate methods
extension CardInfoVC: DataActionCellDelegate {
    func actionButtonClicked(for type: String) {
        if type == Utility.localizedString(forKey: "Edit") {
            gotoCardDetailsScreen()
        }
    }
    
    func actionSwitchValueChanged(isOn: Bool) {
        showAlertForAction(isCancel: false)
    }
}

// MARK: - Tableview methdos
extension CardInfoVC: UITableViewDelegate, UITableViewDataSource {
    func registerCell() {
        tblDetails.register(UINib(nibName: "DataActionCell", bundle: .main), forCellReuseIdentifier: "DataActionCell")
        tblDetails.register(UINib(nibName: "InfoCardCell", bundle: .main), forCellReuseIdentifier: "InfoCardCell")
        tblDetails.register(UINib(nibName: "CardNumberCell", bundle: .main), forCellReuseIdentifier: "CardNumberCell")
        tblDetails.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
        tblDetails.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var totalRows = 1
        switch section {
        case 1:
            totalRows = 2
        case 2:
            totalRows = 6
        default:
            break
        }
        return totalRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isloading {
            return Constants.skeletonCellHeight
        }
        return (indexPath.section == 0) ? 251.0 : 72.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !dataSource.isEmpty else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCardCell", for: indexPath) as? InfoCardCell {
                cell.selectionStyle = .none
                if let rowData = self.cardModel {
                    cell.configureCard(frontData: rowData)
                    cell.vwCardFront.switchCardState.tag = indexPath.row
                    cell.vwCardFront.switchCardState.addTarget(self, action: #selector(actionSwitchValueChanged(isOn:)), for: .valueChanged)
                    cell.vwCardFront.configureVirtualCardVGS(for: rowData)
                    
                    if Utility.isDeviceIpad() {
                        cell.vwCardFront.cellWidth.constant = 342
                        
                    } else {
                        cell.vwCardFront.cellWidth.constant = self.tblDetails.frame
                            .width
                        let aheight = self.tblDetails.frame.width /  1.64
                        cell.vwCardFront.cellHeight.constant = aheight
                        
                    }
                    return cell
                }
            }
        case 1 where (indexPath.row == 0 && dataSource[indexPath.section-1].count > 1) :
            let rows = dataSource[indexPath.section-1]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CardNumberCell", for: indexPath) as? CardNumberCell {
                let rowData = rows[indexPath.row] as ContactRowData
                cell.configureCell(forRow: rowData)
                cell.selectionStyle = .none
                return cell
            }
        default:
            let rows = dataSource[indexPath.section-1]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
                let rowData = rows[indexPath.row] as ContactRowData
                cell.configureCardInfoCell(forRow: rowData)
                
                cell.lockSwitch.isOn = cardModel?.cardStatus == CardStatus.inactive
                
                let description = rowData.key
                
                if description?.range(of: cardModel?.label ?? "") != nil {
                    let colorText =  cardModel?.label ?? ""
                    let colorAttriString = description?.getColoredText(forText: colorText, withColor: .secondaryColor)
                    cell.lblcenterValue.attributedText = colorAttriString
                } else if description?.range(of: Utility.localizedString(forKey: "card_spendLimit")) != nil {
                    let colorText = Utility.getFormattedAmount(amount: cardModel?.limitAmount ?? "")
                    let colorAttriString = description?.getColoredText(forText: colorText, withColor: UIColor.greenMain)
                    cell.tag = Constants.tagForSpendingLimit
                    cell.lblcenterValue.attributedText = colorAttriString
                } 
                
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        headerCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: defaultSectionHeight)
        headerCell.lblSectionHeader.text = Utility.localizedString(forKey: "contact_Details_Title")
        headerCell.lblSectionHeader.font = Constants.commonFont
        if section == 0 {
            headerCell.lblSectionHeader.text = Utility.localizedString(forKey: "details_title")
        } else if section == sectionCount-1 {
            headerCell.lblSectionHeader.text =  Utility.localizedString(forKey: "cardInfo_section_actions")
        } else {
            headerCell.lblSectionHeader.text = ""
        }
        
        headerCell.lblSectionHeader.leftAnchor.constraint(equalTo: headerCell.leftAnchor, constant: 5).isActive = true
        headerCell.lblSectionHeader.rightAnchor.constraint(equalTo: headerCell.rightAnchor).isActive = true
        headerCell.lblSectionHeader.topAnchor.constraint(equalTo: headerCell.topAnchor, constant: 10).isActive = true
        headerCell.lblSectionHeader.bottomAnchor.constraint(equalTo: headerCell.bottomAnchor).isActive = true
        
        headerCell.backgroundColor = .grayBackgroundColor
        headerCell.contentView.backgroundColor = .grayBackgroundColor
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return defaultSectionHeight
        } else if section == sectionCount-1 {
            return 40
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {         // navigate to card transaction list
            goToTransactionListVC()
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 3:
                let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "ATMInfoVC") as? ATMInfoVC {
                    vc.cardModel = self.cardModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 4:
                // cancel card
                showAlertForAction(isCancel: true)
            case 5:
                // Get in touch
                self.openEmail()
            default:
                break
            }
        }
    }
    
    func goToTransactionListVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Transaction", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TransactionListVC") as? TransactionListVC {
            vc.listingType = .card
            vc.cardId = cardModel?.id
            vc.cardName = cardModel?.label
            self.show(vc, sender: self)
        }
    }
}

extension CardInfoVC: PKAddPaymentPassViewControllerDelegate {
    func checkEligibility() {
        //Check eligibility
        let eligibility = PKAddPaymentPassViewController.canAddPaymentPass()
        let passLibrary = PKPassLibrary.init()
        
        if eligibility {
            let addPassButton = PKAddPassButton()
            addPassButton.addPassButtonStyle = .black
            addPassButton.addTarget(self, action: #selector(startApplePayProvisioning), for: .touchUpInside)
            self.view.addSubview(addPassButton)
            self.view.bringSubviewToFront(addPassButton)
            
            //Constraints
            addPassButton.translatesAutoresizingMaskIntoConstraints = false
            addPassButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
            addPassButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -25).isActive = true
            addPassButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        }
        
        let paymentPasses = passLibrary.passes(of: .payment) // get PKPass array of payment card
        for pass in paymentPasses {
            guard let paymentPass = pass.paymentPass else { return }
            // or check by suffix paymentPass.primaryAccountNumberSuffix
            if paymentPass.primaryAccountIdentifier == cardModel?.id {
                // do something
                let errorMessage = Utility.localizedString(forKey: "wallet_alreadyadded_message")
                self.showAlertMessage(titleStr: "", messageStr: errorMessage)
            }
        }
    }
    
    @objc func startApplePayProvisioning() {
        let request = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2)
        request?.cardholderName  = cardModel?.cardholder?.name
        request?.primaryAccountSuffix = cardModel?.last4 //6268
        request?.localizedDescription =  Utility.localizedString(forKey: "wallet_addcard_message")
        request?.primaryAccountIdentifier = cardModel?.id //Filters the device and attached devices that already have this card provisioned.(Maybe cardId);
        request?.paymentNetwork = PKPaymentNetwork.visa
        let vc = PKAddPaymentPassViewController(requestConfiguration: request!, delegate: self)
        self.present(vc!, animated: true, completion: nil)
    }
    
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
        //First you should get the certificates, nonce and nonceSignature to send to backend.
        //After, you get the response from backend and create an object using PKAddPaymentPassRequest and send by completionHandler.
        
        let certificateLeaf = certificates[0].base64EncodedString()
        let nonceString = nonce.base64EncodedString()
        let nonceSignatureVal = nonceSignature.base64EncodedString()
        let paymentPassRequest = PKAddPaymentPassRequest.init()
        
        var postBody = CardWalletRequestBody()
        
        var aPay = Applepay()
        aPay.nonce = nonceString
        aPay.nonceSignature = nonceSignatureVal
        aPay.deviceCert = certificateLeaf
        postBody.wallet = "applePay"
        postBody.applePay = aPay
        
        if let cId = cardModel?.id {
            CardViewModel.shared.enrollCard(cardId: cId, walletData: postBody) { response, errorMessage in
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let respCardModel = response {
                        let payloadData = respCardModel.applePay?.encryptedPassData
                        let activationcode = respCardModel.applePay?.activationData
                        let ephemeralkey = respCardModel.applePay?.ephemeralPublicKey
                        
                        let encryptedPassData =  Data(base64Encoded: payloadData ?? "", options: [])
                        let ephemeralPublicKey  = Data(base64Encoded: ephemeralkey ?? "", options: [])
                        let activationData = Data(base64Encoded: activationcode ?? "", options: [])
                        
                        paymentPassRequest.activationData = activationData
                        paymentPassRequest.encryptedPassData = encryptedPassData
                        paymentPassRequest.ephemeralPublicKey = ephemeralPublicKey
                        handler(paymentPassRequest)
                    } else {
                    }
                }
            }
        }
    }
    
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension CardInfoVC: SkeletonTableViewDataSource {
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
		return 2
	}
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
}
