//
//  CardLimitScreenVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/8/21.
//

import Foundation
import UIKit

class CardLimitScreenVC: BaseVC, FormDataCellDelegate {
    @IBOutlet weak var tblCardLimit: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    var selectedindex: Int = 0
    var selectedSpendLimit: CardSpendLimitTypes? = .perMonth
    
    var cardData: CardModel?
    var amount = 0.00
    
    var isEditCard: Bool = false
    
    var arrTitles = [String]()
    var arrFieldTypes = [String]()
    var arrCardData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialData()
        setNavigationBar()
        prefillData()
        registerCell()
        self.setFooterUI()
        validate()
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            tblBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : 90
        }
    }
    
    func setInitialData() {
        if let card = self.cardData, let _ = card.id {
            isEditCard = true
        }
        
        if isEditCard || cardData?.cardType == CardType.virtual {
            // NO NEED TO ADD EXTRA FIELDS
            arrTitles = [Utility.localizedString(forKey: "card_label"), Utility.localizedString(forKey: "card_spendLimit_title")]
            arrFieldTypes = ["alphaNumeric", "currency"]
            arrCardData = ["", ""]
        } else if AppGlobalData.shared().selectedAccountType == .personalChecking || (cardData?.cardType == .physical && AppGlobalData.shared().selectedAccountType == .cardAccount) { //ADD "embossing_person_name" FIELD
            arrTitles = [Utility.localizedString(forKey: "card_label"), Utility.localizedString(forKey: "embossing_person_name"), Utility.localizedString(forKey: "card_spendLimit_title")]
            arrFieldTypes = ["alphaNumeric", "embossingPerson", "currency"]
            arrCardData = ["", "", ""]
        } else { //ADD "embossing_person_name" & "embossing_business_name" FIELDS
            arrTitles = [Utility.localizedString(forKey: "card_label"), Utility.localizedString(forKey: "embossing_person_name"), Utility.localizedString(forKey: "embossing_business_name"), Utility.localizedString(forKey: "card_spendLimit_title")]
            arrFieldTypes = ["alphaNumeric", "embossingPerson", "embossingBusiness", "currency"]
            arrCardData = ["", "", "", ""]
        }
        
        selectedindex = arrTitles.count
    }
    
    func setNavigationBar() {
        isNavigationBarHidden = false
        isScreenModallyPresented = true
        
        addBackNavigationbarButton()
        
        if isEditCard {// EDIT FLOW
            self.title = cardData?.cardType == CardType.physical ?  Utility.localizedString(forKey: "physicalCard_edit_NavTitle") : Utility.localizedString(forKey: "virtualCard_edit_NavTitle")
        } else {
            self.title = cardData?.cardType == CardType.physical ?  Utility.localizedString(forKey: "physicalCard_Create_NavTitle") : Utility.localizedString(forKey: "virtualCard_Create_NavTitle")
        }
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        
        var buttonTitle = Utility.localizedString(forKey: "next")
        
        if isEditCard {// EDIT FLOW
            buttonTitle = Utility.localizedString(forKey: "done")
        }
        
        footerView.configureButtons(rightButtonTitle: buttonTitle)
        footerView.btnApply.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
    }
    
    func prefillData() {
        if let card = self.cardData, let _ = card.id {
            selectedSpendLimit = card.limitInterval
            selectedindex = getSelectedIndex(type: selectedSpendLimit ?? .perMonth) + arrTitles.count
            self.amount = Double(card.limitAmount ?? "") ?? 0
            self.setData()
        }
    }
    
    func setData() {
        let strCardLable = cardData?.label ?? ""
        let strCardLimit = cardData?.limitAmount ?? ""
        let strEmbossingPerson = cardData?.embossingPerson ?? ""
        let strEmbossingBusiness = cardData?.embossingBusiness ?? ""
        
        if isEditCard || cardData?.cardType == CardType.virtual {
            arrCardData = [strCardLable, strCardLimit]
        } else if AppGlobalData.shared().selectedAccountType == .personalChecking || (cardData?.cardType == .physical && AppGlobalData.shared().selectedAccountType == .cardAccount){
            arrCardData = [strCardLable, strEmbossingPerson, strCardLimit]
        } else {
            arrCardData = [strCardLable, strEmbossingPerson, strEmbossingBusiness, strCardLimit]
        }
    }
    
    func getSelectedIndex(type: CardSpendLimitTypes) -> Int {
        switch type {
        case .perMonth:
            return 0
        case .perTransaction:
            return 1
        case .perWeek:
            return 2
        case .perYear:
            return 3
        case .perDay:
            return 4
        case .allTime:
            return 5
        case .unknown:
            return -1
        }
    }
    
    func validate() {
        if let cardLable = cardData?.label, cardLable.count >= 2 && !cardLable.isInvalidInput() {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
    
    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        var cardLimitFrame = footerView.frame
        var cardLimitcY: CGFloat = footerView.frame.origin.y
        let navBarHeight = self.getNavigationbarHeight()
        
        UIView.animate(withDuration: 0.2) {
            cardLimitcY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
            cardLimitFrame.origin.y = cardLimitcY
            self.footerView.frame = cardLimitFrame
            self.view.layoutIfNeeded()
            
            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
            self.tblCardLimit.contentInset = contentInsets
            self.tblCardLimit.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblCardLimit.scrollIndicatorInsets = self.tblCardLimit.contentInset
        }
    }
}

// MARK: - Currency
extension CardLimitScreenVC: CurrencyEntryCellDelegate {
    func amountEntered(amount: Double) {
        self.amount = amount
        cardData?.limitAmount = amount.toString()
        setData()
        validate()
    }
}

// MARK: - FormDataCellDelegate
extension CardLimitScreenVC {
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
        guard let indexPath = self.tblCardLimit.indexPath(for: cell) else {return}
        
        self.scrollToIndexPath = indexPath
    }
    
    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {
        guard let indexPath = self.tblCardLimit.indexPath(for: cell), let text = data as? String else {return}
        
        switch indexPath.row {
        case 0: // card lable
            cell.validateEnteredText(enteredText: text.trim)
            cardData?.label = text.trim
        case 1:
            if arrTitles.count == 2 {
                cardData?.limitAmount = text.trim
            } else {
                cell.validateEnteredText(enteredText: text.trim)
                cardData?.embossingPerson = text.trim
            }
        case 2:// card limit
            if arrTitles.count == 3 {
                cardData?.limitAmount = text.trim
            } else {
                cell.validateEnteredText(enteredText: text.trim)
                cardData?.embossingBusiness = text.trim
            }
        case 3:// card limit
            cardData?.limitAmount = text.trim
            
        default:break
        }
        
        setData()
        validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func cell(shouldCelar cell: CustomTableViewCell) -> Bool {
        return false
    }
}

// MARK: - DashboardCellDelegate methods
extension CardLimitScreenVC: UITableViewDelegate, UITableViewDataSource {
    func registerCell() {
        self.tblCardLimit.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        self.tblCardLimit.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
        self.tblCardLimit.register(UINib(nibName: "FilterRadiobuttonCell", bundle: nil), forCellReuseIdentifier: "FilterRadiobuttonCell")
        self.tblCardLimit.separatorStyle = .none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count + CardSpendLimitTypes.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < arrTitles.count {
            let strTitle = arrTitles[indexPath.row]
            
            if indexPath.row == arrTitles.count - 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
                    cell.delegate = self
                    cell.lblTitle?.text = Utility.localizedString(forKey: strTitle)
                    cell.txtFieldAmount.setDefault(value: arrCardData[arrTitles.count - 1])
                    cell.backgroundColor = .clear
                    cell.selectionStyle = .none
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {
                    cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
                    cell.fieldType = arrFieldTypes[indexPath.row]
                    cell.inputTextField?.text = arrCardData[indexPath.row]
                    cell.inputTextField?.tag = indexPath.row
                    cell.delegate = self
                    return cell
                }
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterRadiobuttonCell", for: indexPath) as? FilterRadiobuttonCell {
                
                var isSelected = false
                
                cell.radioDelegate = self
                
                if indexPath.row == selectedindex {
                    isSelected = true
                }
                
                let item = CardSpendLimitTypes.allValues[indexPath.row - arrTitles.count]
                cell.configureForSpendLimit(spendLimit: item, isSelected: isSelected)
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.row >= arrTitles.count {
            reloadTable(withIndex: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cheight: CGFloat = 40
        
        if indexPath.row < arrTitles.count {
            cheight    = Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
        }
        
        return cheight
    }
    
    func reloadTable(withIndex: Int) {
        selectedindex = withIndex
        selectedSpendLimit = CardSpendLimitTypes.allValues[selectedindex - arrTitles.count]
        tblCardLimit.reloadData()
    }
}

// MARK: - RadiobuttonCellDelegate
extension CardLimitScreenVC: RadiobuttonCellDelegate {
    func selectedRadioButton(cell: FilterRadiobuttonCell) {
        guard let indexPath = self.tblCardLimit.indexPath(for: cell) else {
            return
        }
        self.view.endEditing(true)
        self.reloadTable(withIndex: indexPath.row)
    }
}

// MARK: - Navigation method
extension CardLimitScreenVC {
    func gotoAddress() {
        self.performSegue(withIdentifier: "showbillingAddress", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CardBillingAddressVC {
            destinationVC.cardData = self.cardData
        }
    }
    
    @objc func handleNavigation() {
        self.view.endEditing(true)
        
        cardData?.limitInterval = selectedSpendLimit
        cardData?.limitAmount = self.amount.toString()
        
        if isEditCard {// EDIT FLOW
            updateCard()
        } else {
            self.gotoAddress()
        }
    }
}

// MARK: - API CALLS
extension CardLimitScreenVC {
    func updateCard() {
        var postBody = CardUpdateRequestBody()
        postBody.label = self.cardData?.label
        postBody.limitAmount = self.cardData?.limitAmount
        postBody.limitInterval = self.cardData?.limitInterval
        
        self.activityIndicatorBegin()
        
        CardViewModel.shared.updateCard(cardID: self.cardData?.id ?? "", contactData: postBody) { (response, errorMessage) in
            self.activityIndicatorEnd()
            
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let _ = response {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)
                    self.popVC()
                }
            }
        }
    }
}
