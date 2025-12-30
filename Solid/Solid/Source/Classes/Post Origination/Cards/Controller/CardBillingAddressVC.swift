//
//  CardBillingAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 08/03/21.
//

import UIKit

class CardBillingAddressVC: BaseAddressVC {
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var shippingAddressSwitch: UISwitch!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var lblHeaderDesc: UILabel!
    @IBOutlet weak var physicalCardHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var physicalCardHeaderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var placesTableToptConstraint: NSLayoutConstraint!
    
    let defaultSectionHeight: CGFloat = 50.0
    var cardData: CardModel?
    
    var isHavingSameShippingAddress = false {
        didSet {
            setRightButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setAddressData(address: cardData?.cardholder?.billingAddress ?? Address())
        
        self.title = cardData?.cardType == CardType.physical ?  Utility.localizedString(forKey: "physicalCard_Create_NavTitle") : Utility.localizedString(forKey: "virtualCard_Create_NavTitle")
        
        let strCountryCode = AppGlobalData.shared().personData.phone?.countryCode() ?? AppGlobalData.shared().selectedCountryCode
        let strCountry = Utility.getCountry(forCountryCode: strCountryCode)
        super.filter.country = cardData?.cardType == CardType.physical ? "US" : strCountry
        
        shippingAddressSwitch.isOn = false
        setUI()
        
        self.tblAddress.reloadData()
        
        self.setFooterUI()
        isHavingSameShippingAddress = false
        
        super.validate()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
    }
    
    func setUI() {
        setHeaderForBillingAddress()
        let yValue = self.getNavigationbarHeight() + defaultSectionHeight + 10
        placesTableToptConstraint.constant = yValue
    }
    
    func setRightButton() {
        var buttonTitle = Utility.localizedString(forKey: "next")
        
        if isHavingSameShippingAddress || cardData?.cardType == CardType.virtual {
            buttonTitle = Utility.localizedString(forKey: "create")
        }
        footerView.configureButtons(rightButtonTitle: buttonTitle)
        super.validate()
    }
    
    @IBAction func shippingAddressSwitchValueChanged(_ sender: Any) {
        isHavingSameShippingAddress = !isHavingSameShippingAddress
    }
}

// MARK: - Data Methods
extension CardBillingAddressVC {
    @objc func handleNavigation() {
        self.view.endEditing(true)
        
        setBillingAddressData()
        
        if isHavingSameShippingAddress || cardData?.cardType == CardType.virtual {
            createCard()
        } else {
            goToShippingAddressVC()
        }
    }
    
    func goToShippingAddressVC() {
        self.performSegue(withIdentifier: "GoToCardShippingAddressVC", sender: self)
    }
    
    func goToCreateCardSuccessVC() {
        self.performSegue(withIdentifier: "GoToCreateCardSuccessVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CardShippingAddressVC {
            destinationVC.cardData = self.cardData
        } else if let destinationVC = segue.destination as? CreateCardSuccessVC {
            destinationVC.cardData = self.cardData
        }
    }
    
    func setBillingAddressData() {
        var billing = BillingAddressModel()
        billing.billingAddress = super.getPostAddressData(addressType: "billing")
        
        cardData?.billingAddress  = billing
        
        if isHavingSameShippingAddress {
            var shipping = ShippingAddressModel()
            shipping.shippingAddress = super.getPostAddressData(addressType: "shipping")
            cardData?.shipping = shipping
        }
    }
}

// MARK: - tableView
extension CardBillingAddressVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerViewHeight = cardData?.cardType == CardType.physical ? headerView.frame.size.height : defaultSectionHeight
        return tableView == placesTableView ? 0 : headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != placesTableView {
            if cardData?.cardType == CardType.physical {
                headerView.isHidden = false
                return self.headerView
            } else {
                headerView.isHidden = true
                physicalCardHeaderHeightConstraint.constant = 0
                
                let vCardHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: defaultSectionHeight))
                vCardHeaderView.backgroundColor = .background
                
                let lblTitle = UILabel(frame: CGRect(x: 15, y: 15, width: tableView.frame.size.width - 20, height: 25))
                let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
                lblTitle.font = labelFont
                lblTitle.textColor = .primaryColor
                lblTitle.text = Utility.localizedString(forKey: "card_BillingAddress_HeaderTitle")
                
                vCardHeaderView.addSubview(lblTitle)
                return vCardHeaderView
            }
        }
        
        return UIView()
    }
    
    func setHeaderForBillingAddress() {
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: headerView.frame.size.height)
        headerView.backgroundColor = .background
        
        lblHeaderTitle.text = Utility.localizedString(forKey: "card_BillingAddress_HeaderTitle")
        lblHeaderDesc.text = Utility.localizedString(forKey: "card_BillingAddress_HeaderDesc")
        
        let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize22 : Constants.regularFontSize14
        let headerFont = Utility.isDeviceIpad() ? Constants.mediumFontSize20: Constants.mediumFontSize14
        lblHeaderTitle.font = headerFont
        lblHeaderDesc.font = titleFont
        lblHeaderTitle.textColor = .primaryColor
        lblHeaderDesc.textColor = UIColor.secondaryColorWithOpacity
        
        physicalCardHeaderWidthConstraint.constant = self.view.frame.size.width
    }
}

// MARK: - API CALLS
extension CardBillingAddressVC {
    func createCard() {
        var postBody = CardCreateRequestBody()
        postBody.accountId = AppGlobalData.shared().accountData?.id
        postBody.label = cardData?.label
        postBody.limitAmount = cardData?.limitAmount
        postBody.cardType = cardData?.cardType
        postBody.limitInterval = cardData?.limitInterval
        postBody.currency =  "USD"
        
        if cardData?.cardType == .physical {
            postBody.embossingPerson = self.cardData?.embossingPerson
            postBody.embossingBusiness = self.cardData?.embossingBusiness
        }
        
        postBody.billingAddress = cardData?.billingAddress?.billingAddress
        
        let shippingModel = cardData?.shipping ?? ShippingAddressModel()
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
