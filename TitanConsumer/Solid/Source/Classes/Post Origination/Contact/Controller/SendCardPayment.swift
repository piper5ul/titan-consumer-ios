//
//  SendCardPayment.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import UIKit
import GooglePlaces

class SendCardPayment: BaseVC, FormDataCellDelegate {
    var arrTitles = [String]()
    var arrFieldTypes = [String]()
    var arrContactData = [String]()
    var contactData: ContactDataModel?
    var sholudEditContact: Bool = false
    var originalData: ContactDataModel?
    var paymentDescription: String = ""
    
    @IBOutlet weak var placesContainer: UIView!
    @IBOutlet weak var placesView: UIView!
    @IBOutlet weak var placesTableView: UITableView!
    
    var fetcher: GMSAutocompleteFetcher?
    var placesClient = GMSPlacesClient.shared()
    var placePredictions =  [GMSAutocompletePrediction]()
    var filter = GMSAutocompleteFilter()
    var autoCompletionCounter = 0
    var showIndicatior = false
    var token: GMSAutocompleteSessionToken?
    var codeTextField: UITextField?
    let codePickerView = UIPickerView()
    var address = AddressModel()
    var paymentResponse: PaymentModel?
    var paymentRequestBody = PaymentModel()
    
    private let defaultAmount = "$0.00"
    var amount = 0.00
    var paymentAmount: Double = 0.0
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    @IBOutlet weak var tblSendCard: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setCardData()
        self.registerCellsAndHeaders()
        self.setUserContactData()
        setForAddressLocation()
        addPlacesView()
        
        self.tblSendCard.reloadData()
        self.setFooter()
        self.validate()
        
        self.tblSendCard.backgroundColor = .clear
    }
}

extension SendCardPayment {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        
        addBackNavigationbarButton()
        self.title = Utility.localizedString(forKey: "payment_card_title")
    }
    
    func setCardData() {
        arrTitles = ["payment_name", "email", "payment_phonenumber", "address_1", "address_2", "address_City", "address_State", "address_Zipcode", "payment_amount", "payment_purpose"]
        arrFieldTypes = ["alphaNumeric", "email", "phone", "address_1", "address_2", "address_City", "address_State", "address_Zipcode", "currency", "alphaNumeric"]
    }
    
    func setFooter() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "send"))
        footerView.btnApply.addTarget(self, action: #selector(handleCardNavigation), for: .touchUpInside)
    }
    
    @objc func handleCardNavigation() {
        if checkForContactUpdate() {
            if let contactId = self.contactData?.id {
                self.updateContact(contactID: contactId)
            }
        } else {
            makeCardPayment()
        }
    }
    
    func validate() {
        // for name and number
        if let name = contactData?.name, !name.isEmpty, let phone = contactData?.phone, !phone.isEmpty, phone != Constants.countryCodeUS,
           let address1 = address.streetAddress, !address1.isEmpty && !address1.isInvalidAddress(),
           let city = address.city, !city.isEmpty && !city.isInvalidAddress(),
           let state = address.state, !state.isEmpty && !state.isInvalidAddress(),
           let zipcode = address.postalCode, !zipcode.isEmpty && zipcode.isValidUSZipcode,
           !self.paymentDescription.isEmpty,
           self.paymentAmount > 0, self.paymentAmount > 0 {
            let selectedCountryCode = phone.countryCode()
            let contactPhone = phone.phoneStringWithoutCode(countryCode: selectedCountryCode)
            if contactPhone.isEmpty || contactPhone.count != Constants.phoneNumberLimit {
                self.footerView.btnApply.isEnabled = false
            } else if let email = contactData?.email, !email.isEmpty && !email.isValidEmail {
                self.footerView.btnApply.isEnabled = false
            } else {
                self.footerView.btnApply.isEnabled = true
            }
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
    
    func setUserContactData() {
        let uname = contactData?.name ?? ""
        let uamount = contactData?.intrabank?.amount ?? ""
        let upurpose  = contactData?.intrabank?.description ?? ""
        let uemail = contactData?.email ?? ""
        var uphone = ""
        if let uphoneNo = contactData?.phone, !uphoneNo.isEmpty {
            let selectedCountryCode = uphoneNo.countryCode()
            let phoneLimit = uphoneNo.phoneNumberLimit()
            let formatedNumber = Utility.getFormattedPhoneNumber(forCountryCode: selectedCountryCode, phoneNumber: uphoneNo, withMaxLimit: phoneLimit)
            uphone = formatedNumber
        }
        
        arrContactData = [uname, uemail, uphone, "", "", "", "", "", "", "", uamount, upurpose]
        if let _ = contactData?.intrabank {
            self.sholudEditContact = false
        } else {
            self.sholudEditContact = true
        }
        originalData = contactData
    }
    
    func checkForContactUpdate() -> Bool {
        return true
    }
}

// MARK: - Google Places
extension SendCardPayment: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        placePredictions = predictions
        self.showPlacesList(true)
        self.placesTableView.reloadData()
        self.setplaceIndicator(shouldShow: false)
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    func scheduleDownloadWithCounter(counter: Int, searchText: String) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if counter == self.autoCompletionCounter {
                self.downloadPredictions(searchText: searchText)
            }
        }
    }
    
    func setplaceIndicator(shouldShow: Bool) {
        showIndicatior = shouldShow
        
        let indpath: IndexPath = IndexPath(row: 1, section: 0)
        tblSendCard.reloadRows(at: [indpath], with: .automatic)
    }
    
    func downloadPredictions(searchText: String) {
        
        self.setplaceIndicator(shouldShow: true)
        
        filter.country = "US"
        
        placesClient.findAutocompletePredictions(fromQuery: searchText, filter: filter, sessionToken: token) { (predictions, error) in
            guard error == nil else {
                self.setplaceIndicator(shouldShow: false)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.setplaceIndicator(shouldShow: false)
                
                if let placesPredictions = predictions, placesPredictions.count > 0 {
                    self.placePredictions = placesPredictions
                    self.showPlacesList(true)
                    self.placesTableView.reloadData()
                } else {
                    self.showPlacesList(false)
                }
            }
        }
    }
}

// MARK: - UITableView
extension SendCardPayment: UITableViewDelegate, UITableViewDataSource {
    
    func registerCellsAndHeaders() {
        self.tblSendCard.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        self.tblSendCard.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == placesTableView {
            return placePredictions.count
        } else {
            return arrTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightv: CGFloat
        if tableView == placesTableView {
            heightv = Constants.placesTableViewCellHeight
        } else {
            heightv = Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
        }
        return heightv
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strTitle = arrTitles[indexPath.row]
        if tableView == placesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "place_cell", for: indexPath)
            let prediction = placePredictions[indexPath.row]
            cell.textLabel?.text = prediction.attributedPrimaryText.string + " " + (prediction.attributedSecondaryText?.string ?? "")
            cell.textLabel?.font = Utility.isDeviceIpad() ? Constants.regularFontSize14 : Constants.regularFontSize12
            cell.selectionStyle = .none
            return cell
        } else {
            if indexPath.row == 8 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
                    cell.delegate = self
                    cell.lblTitle?.text = Utility.localizedString(forKey: strTitle)
                    cell.selectionStyle = .none
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {
                    cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
                    cell.fieldType = arrFieldTypes[indexPath.row]
                    cell.inputTextField?.text = arrContactData[indexPath.row]
                    cell.inputTextField?.tag = indexPath.row
                    cell.delegate = self
                    if let codeLabel = cell.inputTextField?.viewWithTag(Constants.tagForCountryCodeLabel) {
                        codeLabel.removeFromSuperview()
                    }
                    
                    if cell.fieldType  == "address_1" ||  cell.fieldType  == "address_2" ||  cell.fieldType  == "address_City" ||  cell.fieldType  == "address_State" || cell.fieldType  == "address_Zipcode" {
                        cell.inputTextField?.text = getAddressData(forIndex: indexPath.row)
                        cell.inputTextField?.tag = indexPath.row
                        cell.delegate = self
                        
                        if showIndicatior && indexPath.row == 3 {
                            cell.indicatorView?.isHidden = false
                            cell.indicatorView?.startAnimating()
                        } else {
                            cell.indicatorView?.isHidden = true
                            cell.indicatorView?.stopAnimating()
                        }
                    }
                    
                    if cell.fieldType  == "phone" {
                        let codeLabel = UILabel()
                        codeLabel.frame = CGRect(x: Constants.countryCodeLableXConst, y: Constants.countryCodeLableYConst, width: Constants.countryCodeLableWidthConst, height: Constants.countryCodeLableHeightConst)
                        codeLabel.text = Constants.countryCodeUS
                       
                        codeLabel.layer.cornerRadius = Constants.cornerRadiusThroughApp
                        codeLabel.layer.masksToBounds = Constants.cornerRadiusThroughApp > 0
                        
                        codeLabel.font = Constants.regularFontSize14
                        codeLabel.backgroundColor = UIColor.grayBackgroundColor
                        codeLabel.textColor = .primaryColor
                        codeLabel.textAlignment = .center
                        codeLabel.tag = Constants.tagForCountryCodeLabel
                        cell.strSelectedCountryCode = Constants.countryCodeUS
                        cell.maxPhoneNumberLength = Constants.phoneNumberLimit
                        cell.inputTextField?.addSubview(codeLabel)
                    }
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == placesTableView {
            showPlacesList(false)
            let prediction = placePredictions[indexPath.row]
            self.autofillDataUsing(placeId: prediction.placeID)
        }
    }
    
    func autofillDataUsing(placeId: String) {
        placesClient.lookUpPlaceID(placeId) { (place, _) in
            if let gplaceExist = place {
                var placeroute = ""
                var placestreetNo = ""
                
                gplaceExist.addressComponents?.forEach({ (component) in
                    if !component.types.isEmpty {
                        if component.types.contains("route") {
                            placeroute = component.name
                        } else if component.types.contains("street_number") {
                            placestreetNo = component.shortName ?? ""
                        } else if component.types.contains("locality") || component.types.contains("sublocality_level_1") {
                            self.address.city = component.shortName ?? ""
                        } else if component.types.contains("administrative_area_level_1") {
                            self.address.state = component.shortName ?? ""
                        } else if component.types.contains("country") {
                            self.address.country = component.shortName ?? ""
                        } else if component.types.contains("postal_code") {
                            self.address.postalCode = component.shortName ?? ""
                        }
                    }
                })
                self.address.streetAddress = "\(placestreetNo) \(placeroute)"
            }
            
            DispatchQueue.main.async {
                self.tblSendCard.reloadData()
            }
        }
    }
    
    func getAddressData(forIndex: Int) -> String {
        var strdata = ""
        switch forIndex {
        case 0:
            strdata = contactData?.name ?? ""
        case 3:
            strdata = address.streetAddress ?? ""
        case 4:
            strdata = address.addressLine2 ?? ""
        case 5:
            strdata = address.city ?? ""
        case 6:
            strdata = address.state ?? ""
        case 7:
            strdata = address.postalCode ?? ""
        default:
            break
        }
        
        return strdata
    }
}

// MARK: - FormDataCellDelegate
extension SendCardPayment {
    
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
        debugPrint(editing ?? "", cd ?? "")
        guard let indexPath = self.tblSendCard.indexPath(for: cell) else {return}
        if indexPath.row != 3 {
            showPlacesList(false)
        }
        self.scrollToIndexPath = indexPath
    }
    
    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {
        
        guard let indexPath = self.tblSendCard.indexPath(for: cell), let text = data as? String else {return}
        if indexPath.row == 3 {
            if text.count > 3 {
                autoCompletionCounter += 1
                scheduleDownloadWithCounter(counter: autoCompletionCounter, searchText: text)
            } else {
                showPlacesList(false)
            }
        }
        switch indexPath.row {
        case 0: // Name
            contactData?.name = text.trim
            cell.validateEnteredText(enteredText: text.trim)
            arrContactData[0] = text.trim
            
        case 1:// email
            contactData?.email = text.trim
            arrContactData[1] = text.trim
            
        case 2: // phone
            let mobileNumber = Constants.countryCodeUS + text.numberString
            contactData?.phone = mobileNumber
            arrContactData[2] = text.trim
            
        case 3: // ADDRESS 1
            address.streetAddress = text.trim
            arrContactData[3] = text.trim
            
        case 4:// ADDRESS 2
            address.addressLine2 = text.trim
            arrContactData[4] = text.trim
            
        case 5:// CITY
            address.city = text.trim
            arrContactData[5] = text.trim
            
        case 6:// STATE
            address.state = text.trim
            arrContactData[6] = text.trim
            
        case 7:// ZIPCODE
            address.postalCode = text.trim
            arrContactData[7] = text.trim
            
        case 8:// amount
            contactData?.intrabank?.amount = text.trim
            
        case 9: // purpose
            let description = text.trim
            arrContactData[9] = description
            paymentDescription = description
            
        default:break
        }
        validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func cell(shouldCelar _: CustomTableViewCell) -> Bool {
        return false
    }
}

// MARK: - API calls
extension SendCardPayment {
    
    func getuserAddress() -> Address {
        var postaddress = Address()
        postaddress.line1 = address.streetAddress
        postaddress.line2 = address.addressLine2
        postaddress.city = address.city
        postaddress.state = address.state
        postaddress.country = address.country ?? AppGlobalData.shared().personData.address?.country
        postaddress.postalCode = address.postalCode
        return postaddress
    }
    
    func updateContact(contactID: String) {
        if let data = contactData {
            var postBody = ContactDataModel()
           
            var ibank = IntrabankAccount()
            ibank.accountNumber = data.intrabank?.accountNumber
            
            let postaddress = self.getuserAddress()
            var card = Contactaddress()
            card.address = postaddress
            postBody.card = card
            
            postBody.phone = data.phone
            postBody.accountId = AppGlobalData.shared().accountData?.id

            self.activityIndicatorBegin()
            
            ContactViewModel.shared.updateContact(contactId: contactID, contactData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        self.contactData = response
                        self.makeCardPayment()
                    }
                }
            }
        }
    }
    
    func makeCardPayment() {
        if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = contactData, let contactId = contact.id {
            self.view.endEditing(true)
            self.activityIndicatorBegin()
            var paymentRequestBody = PaymentModel()
            paymentRequestBody.accountId = accId
            paymentRequestBody.contactId = contactId
            paymentRequestBody.type = "virtual"
            paymentRequestBody.description = self.paymentDescription
            paymentRequestBody.amount = self.paymentAmount.toString()
            let selectedPaymentType = ContactAccountType.sendVisaCard
            contactData?.selectedPaymentMode = ContactAccountType.sendVisaCard
            PaymentViewModel.shared.makePayment(payRequestBody: paymentRequestBody, paymentType: selectedPaymentType) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let resp = response {
                        self.getAccountDetails(for: accId) { (_, _) in
                            self.paymentResponse = resp
                            self.gotoPaymentSuccess()
                        }
                    }
                }
            }
        }
    }
    
    func setForAddressLocation() {
        filter.type = .address
        
        // Create a new session token.
        token = GMSAutocompleteSessionToken.init()
        
        // Create the fetcher.
        fetcher = GMSAutocompleteFetcher()
        fetcher?.delegate = self
        fetcher?.provide(token)
        placesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "place_cell")
    }
    
    func addPlacesView() {
        setPlacesViewFrame()
        self.view.addSubview(placesContainer)
    }
    
    func setPlacesViewFrame() {
        if Utility.isDeviceIpad() {
            placesContainer.frame = CGRect(x: self.view.frame.origin.x + 16, y: 95, width: self.view.frame.size.width - 30, height: 200)
        } else {
            placesContainer.frame = CGRect(x: self.view.frame.origin.x + 16, y: 95, width: self.view.frame.size.width - 26, height: 200)
        }
    }
    
    func showPlacesList(_ value: Bool) {
        if value {
            placesContainer.isHidden = false
        } else {
            placesContainer.isHidden = true
        }
    }
    
    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        var fvFrame = footerView.frame
        var fvY: CGFloat = footerView.frame.origin.y
        let nvBarHeight = self.getNavigationbarHeight()
        UIView.animate(withDuration: 0.2) {
            fvY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - nvBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - nvBarHeight
            fvFrame.origin.y = fvY
            self.footerView.frame = fvFrame
            self.view.layoutIfNeeded()
            var cntInsets: UIEdgeInsets
            cntInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
            self.tblSendCard.contentInset = cntInsets
            self.tblSendCard.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
        }
    }
}

extension SendCardPayment: CurrencyEntryCellDelegate {
    func amountEntered(amount: Double) {
        self.paymentAmount = amount
        validate()
    }
    
    func gotoPaymentSuccess() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Pay", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentSuccessVC") as? PaymentSuccessVC {
            vc.contactData = self.contactData
            vc.paymentData = self.paymentResponse
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
