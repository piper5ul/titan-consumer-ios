//
//  CardShippingAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 09/03/21.
//

import UIKit

class CardShippingAddressVC: BaseAddressVC {
    let defaultSectionHeight: CGFloat = 50.0
    
    var cardData: CardModel?
    
    @IBOutlet weak var placesTableTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.filter.country = "US"
        super.setAddressData(address: cardData?.shipping?.shippingAddress ?? Address())
        
        self.title = Utility.localizedString(forKey: "physicalCard_Create_NavTitle")
        
        let yValue = self.getNavigationbarHeight() + 40
        placesTableTopConstraint.constant = yValue
        
        self.tblAddress.reloadData()
        
        self.setFooterUI()
        super.validate()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "create"))
        footerView.btnApply.addTarget(self, action: #selector(createButtonAction), for: .touchUpInside)
    }
}

// MARK: - Data Methods
extension CardShippingAddressVC {
    @objc func createButtonAction() {
        self.view.endEditing(true)
        
        setShippingddressData()
        createCard()
    }
    
    func goToCreateCardSuccessVC() {
        self.performSegue(withIdentifier: "GoToCreateCardSuccessVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CreateCardSuccessVC {
            destinationVC.cardData = self.cardData
        }
    }
    
    func setShippingddressData() {
        var shipping = ShippingAddressModel()
        shipping.shippingAddress = super.getPostAddressData(addressType: "shipping")
        
        cardData?.shipping = shipping
    }
}

// MARK: - tableView
extension CardShippingAddressVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == placesTableView ? 0 : defaultSectionHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != placesTableView {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: defaultSectionHeight))
            headerView.backgroundColor = .background
            
            let lblTitle = UILabel(frame: CGRect(x: 15, y: 15, width: tableView.frame.size.width - 20, height: 25))
            let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize20: Constants.mediumFontSize14
            lblTitle.font = labelFont
            lblTitle.textColor = .primaryColor
            lblTitle.text = Utility.localizedString(forKey: "card_ShippingAddress_HeaderTitle")
            
            headerView.addSubview(lblTitle)
            return headerView
        }
        
        return UIView()
    }
}

// MARK: - API CALLS
extension CardShippingAddressVC {
    func createCard() {
        var postBody = CardCreateRequestBody()
        postBody.accountId = AppGlobalData.shared().accountData?.id
        postBody.label = cardData?.label
        postBody.limitAmount = cardData?.limitAmount
        postBody.cardType = cardData?.cardType
        postBody.limitInterval = cardData?.limitInterval
        postBody.embossingPerson = self.cardData?.embossingPerson
        postBody.embossingBusiness = self.cardData?.embossingBusiness
        
        let billingAddress = cardData?.billingAddress?.billingAddress ?? Address()
        let shippingModel = cardData?.shipping ?? ShippingAddressModel()
        
        postBody.billingAddress = billingAddress
        postBody.shipping = shippingModel
        
        self.activityIndicatorBegin()
        
        CardViewModel.shared.createNewCard(cardData: postBody) { (response, errorMessage) in
            
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let _ = response {
                    self.cardData = response
                    self.goToCreateCardSuccessVC()
                }
            }
        }
    }
}
