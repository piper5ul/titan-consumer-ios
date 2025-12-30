//
//  ATMInfoVC.swift
//  Solid
//
//  Created by Solid iOS Team on 14/12/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import SkeletonView
import UIKit

class ATMInfoVC: BaseVC {
    @IBOutlet weak var tblATMDetails: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var cardModel: CardModel?
    var cardDetailsModel: CardDetailsModel?
    var sectionCount = 2
    let defaultSectionHeight: CGFloat = 60.0
    var dataSource = [[ContactRowData]]()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.isNavigationBarTranslucent = true
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(callGetCardDetailsAPI), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)
    }
}

// MARK: - UI methods
extension ATMInfoVC {
    func setupInitialUI() {
        registerATMCell()
        tableViewTopConstraint.constant = Utility.getTopSpacing()
    }
    
    func setupInitialData() {
        callGetCardDetailsAPI()
    }
    
    func setNavigationBar() {
        addCustomNavigationBar()
    }
    
    func navigateToBack() {
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func showAlertForFreezeAction() {
        let title = isCardFreezed ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_title") : Utility.localizedString(forKey: "cardInfo_freeze_alert_title")
        let message = isCardFreezed ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_messsage") : Utility.localizedString(forKey: "cardInfo_freeze_alert_messsage")
        let firstBtn = isCardFreezed ? Utility.localizedString(forKey: "cardInfo_unfreeze_button") : Utility.localizedString(forKey: "cardInfo_freeze_button")
        let secondBtn = Utility.localizedString(forKey: "cancel")
        
        alert(src: self, title, message, firstBtn, secondBtn) { (button: Int) in
            if button == 1 {
                if let aCardModel = self.cardModel {
                    let aStatus = (aCardModel.cardStatus == CardStatus.inactive) ? CardStatus.active : CardStatus.inactive
                    self.callFreezeCardAPI(status: aStatus)
                }
            } else {
                self.tblATMDetails.reloadData()
            }
        }
    }
}

// MARK: - Other methods
extension ATMInfoVC {
    func createTableData() {
        dataSource = [[ContactRowData]]()
        
        let section3 = createActionsData()
        dataSource.append(section3)
    }
    
    func createActionsData() -> [ContactRowData] {
        var section = [ContactRowData]()
        
        var row2 = ContactRowData()
        row2.key = Utility.localizedString(forKey: "change_ATM_Pin")
        row2.iconName = "pay"
        row2.cellType = .detail
        section.append(row2)
        
        var row3 = ContactRowData()
        row3.key = Utility.localizedString(forKey: "find_ATM")
        row3.iconName = "pay"
        row3.cellType = .detail
        section.append(row3)
        
        return section
    }
}

// MARK: - API methods
extension ATMInfoVC {
    @objc func callGetCardDetailsAPI() {
        if let aCardModel = self.cardModel, let cardId = aCardModel.id {
            self.isloading = false
            self.tblATMDetails.showAnimatedGradientSkeleton()
            CardViewModel.shared.getcardDetails(cardId: cardId) { (response, errorMessage) in
                self.isloading = true
                self.tblATMDetails.hideSkeleton()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let respCardModel = response {
                        AppGlobalData.shared().cardData = respCardModel
                        self.cardModel = respCardModel
                        self.createTableData()
                        self.tblATMDetails.reloadData()
                    }
                }
            }
        }
    }
    
    func callFreezeCardAPI(status: CardStatus) {
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
                        self.tblATMDetails.reloadData()
                        self.reloadCardList()
                    }
                }
            }
        }
    }
    
    func reloadCardList() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)
    }
}

// MARK: - DataActionCellDelegate methods
extension ATMInfoVC: DataActionCellDelegate {
    func actionSwitchValueChanged(isOn: Bool) {
        showAlertForFreezeAction()
    }
}

// MARK: - Tableview methdos
extension ATMInfoVC: UITableViewDelegate, UITableViewDataSource {
    func registerATMCell() {
        tblATMDetails.register(UINib(nibName: "DataActionCell", bundle: .main), forCellReuseIdentifier: "DataActionCell")
        tblATMDetails.register(UINib(nibName: "InfoCardCell", bundle: .main), forCellReuseIdentifier: "InfoCardCell")
        tblATMDetails.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
        tblATMDetails.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var totalRows = 1
        
        if section ==  1 && self.cardModel?.cardType == CardType.physical {
            totalRows = 2
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCardCell", for: indexPath) as? InfoCardCell, let rowData = self.cardModel {
                cell.selectionStyle = .none
                
                cell.configureCard(frontData: rowData)
                cell.vwCardFront.switchCardState.tag = indexPath.row
                cell.vwCardFront.switchCardState.addTarget(self, action: #selector(actionSwitchValueChanged(isOn:)), for: .valueChanged)
                if rowData.cardType == CardType.virtual {
                    cell.vwCardFront.configureVirtualCardVGS(for: rowData)
                }
                if Utility.isDeviceIpad() {
                    cell.vwCardFront.cellWidth.constant = 342
                    
                } else {
                    cell.vwCardFront.cellWidth.constant = self.tblATMDetails.frame
                        .width
                    let aheight = self.tblATMDetails.frame.width /  1.64
                    cell.vwCardFront.cellHeight.constant = aheight
                    
                }
                return cell
            }
        case 1:
            let rows = dataSource[indexPath.section-1]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
                let rowData = rows[indexPath.row] as ContactRowData
                cell.configureCardInfoCell(forRow: rowData)
                
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        if section == 0 {
            headerCell.lblSectionHeader.text = Utility.localizedString(forKey: "info_ATM")
        } else {
            headerCell.lblSectionHeader.text = ""
        }
        headerCell.lblSectionHeader.font = Constants.commonFont
        headerCell.lblSectionHeader.leftAnchor.constraint(equalTo: headerCell.leftAnchor, constant: 5).isActive = true
        headerCell.lblSectionHeader.rightAnchor.constraint(equalTo: headerCell.rightAnchor).isActive = true
        headerCell.lblSectionHeader.topAnchor.constraint(equalTo: headerCell.topAnchor, constant: 10).isActive = true
        headerCell.lblSectionHeader.bottomAnchor.constraint(equalTo: headerCell.bottomAnchor).isActive = true
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return defaultSectionHeight
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                if isCardFreezed {
                    self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "set_pin_freezeCard_error") )
                } else {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "CardPinVC") as? CardPinVC {
                        vc.pinCardModel = self.cardModel
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case 1:
                let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "ATMLocationsVC") as? ATMLocationsVC {
                    vc.cardModel = self.cardModel
                    let locationcheck = LocationHelper.shared.isLocationEnable()
                    debugPrint(locationcheck)
                    debugPrint(LocationHelper.shared.isLocationEnable )
                    if locationcheck {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            default:
                break
            }
        }
    }
}

extension ATMInfoVC: SkeletonTableViewDataSource {
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
