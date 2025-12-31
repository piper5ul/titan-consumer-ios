//
//  WirePaymentVC.swift
//  Solid
//
//  Created by Solid iOS Team on 7/6/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import GooglePlaces

class WirePaymentVC: BaseVC, FormDataCellDelegate {
    var fetcher: GMSAutocompleteFetcher?
    var placesClient = GMSPlacesClient.shared()
    var placePredictions =  [GMSAutocompletePrediction]()
    var filter = GMSAutocompleteFilter()
    var autoCompletionCounter = 0
    var showIndicatior = false
    var addressData = AddressModel()
    var originalAddressData  = AddressModel()
    var token: GMSAutocompleteSessionToken?
    
	@IBOutlet weak var tblWire: UITableView!
	var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)
	var arrContactData = [String]()
	var arrTitles = [String]()
	var arrFieldTypes = [String]()
	var paymentResponse: PaymentModel?
	var paymentRequestBody = PaymentModel()
	var bankData = DomesticWire()
    var internationalBankData = InternationalWire()
	var wireData = WirePayment()
	var contactData: ContactDataModel?
	var originalData: ContactDataModel?
    var selectedPaymentMode: ContactAccountType?
    
	private let defaultAmount = "$0.00"
	var amount = 0.00
	var paymentAmount: Double = 0.0

    @IBOutlet weak var placesContainer: UIView!
    @IBOutlet weak var placesView: UIView!
    @IBOutlet weak var placesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.setUI()
    }

	func setUI() {
		self.setNavigationBar()
		self.setData()
		self.registerCellsAndHeaders()
        setForAddressLocation()
        addPlacesView()
		self.setContactData()
		self.tblWire.reloadData()
		self.setFooterUI()
		self.validate()
        
        self.tblWire.backgroundColor = .clear
	}

	@objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {

		var dwpcFrame = footerView.frame
		var dwpcY: CGFloat = footerView.frame.origin.y
		let navBarHeight = self.getNavigationbarHeight()

		UIView.animate(withDuration: 0.2) {
			dwpcY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
			dwpcFrame.origin.y = dwpcY
			self.footerView.frame = dwpcFrame
			self.view.layoutIfNeeded()

			var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
			self.tblWire.contentInset = contentInsets
			self.tblWire.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
			self.tblWire.scrollIndicatorInsets = self.tblWire.contentInset
		}
	}
}

extension WirePaymentVC {
	func setNavigationBar() {
		self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

		addBackNavigationbarButton()
        self.title = self.selectedPaymentMode == .internationalWire ? Utility.localizedString(forKey: "payment_internationalwire_title") : Utility.localizedString(forKey: "payment_domesticwire_title")
	}

    func setData() {
        arrTitles = self.selectedPaymentMode == .internationalWire ? ["payment_ach_accountnumber", "payment_swiftCode", "contact_Account_Type", "payment_sucess_bankname", "bankaddress_1", "bankaddress_2", "address_City", "address_State", "address_Zipcode", "contact_country_title", "payment_amount", "payment_purpose"] : ["payment_ach_accountnumber", "contact_Account_RoutingNo", "contact_Account_Type", "contact_Account_Bank", "payment_amount", "payment_purpose"]
        arrFieldTypes = self.selectedPaymentMode == .internationalWire ? ["alphaNumeric", "alphaNumeric", "stringPicker", "alphaNumeric", "address_1", "address_2", "address_City", "address_State", "address_Zipcode", "address_State", "currency", "alphaNumeric"] : ["accountNumber", "routingNumber", "stringPicker", "alphaNumeric", "currency", "alphaNumeric"]
    }

	func setFooterUI() {
		shouldShowFooterView = true
		footerView.configureButtons()
		footerView.btnApply.addTarget(self, action: #selector(handleNavigation), for: .touchUpInside)
	}

	@objc func handleNavigation() {
        if checkForContactUpdate() {
            if let contactId = self.contactData?.id {
                self.updateContact(contactID: contactId)
            }
        } else {
            self.makeWirePayment()
        }
	}

    func checkForContactUpdate() -> Bool {
        if self.selectedPaymentMode == .internationalWire {
            if originalData?.wire?.international?.accountNumber != contactData?.wire?.international?.accountNumber
                || originalData?.wire?.international?.bankIdentifierCode != contactData?.wire?.international?.bankIdentifierCode
                || originalData?.wire?.international?.beneficiaryBank != contactData?.wire?.international?.beneficiaryBank
                || originalAddressData.streetAddress != addressData.streetAddress
                || originalAddressData.addressLine2 != addressData.addressLine2
                || originalAddressData.city != addressData.city || originalAddressData.state != addressData.state ||
                originalAddressData.country != addressData.country || originalAddressData.postalCode != addressData.postalCode {
                return true
            } else {
                return false
            }
        } else {
            if originalData?.wire?.domestic?.accountNumber != contactData?.wire?.domestic?.accountNumber || originalData?.wire?.domestic?.routingNumber != contactData?.wire?.domestic?.routingNumber || originalData?.wire?.domestic?.bankName != contactData?.ach?.bankName {
                return true
            } else {
                return false
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
            placesContainer.frame = CGRect(x: self.view.frame.origin.x + 16, y: 125, width: 670, height: 200)
        } else {
            placesContainer.frame = CGRect(x: self.view.frame.origin.x + 16, y: 125, width: self.view.frame.size.width - 26, height: 200)
        }
    }

    func showPlaceList(_ value: Bool) {
        if value {
            placesContainer.isHidden = false
        } else {
            placesContainer.isHidden = true
        }
    }
    
	func validate() {
        if self.selectedPaymentMode == .internationalWire {
            // for name and number
            if  let accountNumber = contactData?.wire?.international?.accountNumber, !accountNumber.isEmpty,
                let bankIdentifierCode = contactData?.wire?.international?.bankIdentifierCode, !bankIdentifierCode.isEmpty,
                let beneficiaryBank = contactData?.wire?.international?.beneficiaryBank, !beneficiaryBank.isEmpty,
                self.paymentAmount > 0,
                let purpose = contactData?.wire?.international?.purpose, !purpose.isEmpty,
                let address1 = addressData.streetAddress,
                   !address1.isEmpty && !address1.isInvalidAddress(),
                   let city = addressData.city, !city.isEmpty && !city.isInvalidAddress(),
                   let state = addressData.state, !state.isEmpty && !state.isInvalidAddress(),
                   let zipcode = addressData.postalCode, !zipcode.isEmpty && zipcode.isValidUSZipcode,
                   let country = addressData.country, !country.isEmpty && !country.isInvalidAddress() {
                self.footerView.btnApply.isEnabled = true
            } else {
                self.footerView.btnApply.isEnabled = false
            }
        } else {
            // for name and number
            if  let accountNumber = contactData?.wire?.domestic?.accountNumber, accountNumber.isAccountNumberInLimit(), self.paymentAmount > 0,
                let purpose = contactData?.wire?.domestic?.purpose, !purpose.isEmpty,
                let routingNumber = contactData?.wire?.domestic?.routingNumber, !routingNumber.isEmpty,
                let bankName = contactData?.wire?.domestic?.bankName, !bankName.isEmpty {
                self.footerView.btnApply.isEnabled = true
            } else {
                self.footerView.btnApply.isEnabled = false
            }
        }
	}

	func setContactData() {
        let accNo = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.accountNumber ?? "" : contactData?.wire?.domestic?.accountNumber ?? ""
		let routingNo = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.bankIdentifierCode ?? "" : contactData?.wire?.domestic?.routingNumber ?? ""
		var type = ""
		let bankName = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.beneficiaryBank ?? "" : contactData?.wire?.domestic?.bankName ?? ""
        
        let amount = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.amount ?? "" : contactData?.wire?.domestic?.amount ?? ""
        let purpose  = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.purpose ?? "" : contactData?.wire?.domestic?.purpose ?? ""
        
        if self.selectedPaymentMode == .internationalWire {
            if let bType =  contactData?.wire?.international?.accountType {
                type =  InternationalWireAccountType.title(for: bType.rawValue)
                internationalBankData.accountType = bType
            }
            
            internationalBankData.accountNumber = accNo
            internationalBankData.bankIdentifierCode = routingNo
            internationalBankData.beneficiaryBank = bankName
            internationalBankData.beneficiaryAddress = contactData?.wire?.international?.beneficiaryAddress
            internationalBankData.beneficiaryBankAddress = contactData?.wire?.international?.beneficiaryBankAddress

            wireData.international = internationalBankData
            
            let line1 = contactData?.wire?.international?.beneficiaryBankAddress?.line1 ?? ""
            let line2 = contactData?.wire?.international?.beneficiaryBankAddress?.line2 ?? ""
            let city = contactData?.wire?.international?.beneficiaryBankAddress?.city ?? ""
            let state = contactData?.wire?.international?.beneficiaryBankAddress?.state ?? ""
            let zipcode = contactData?.wire?.international?.beneficiaryBankAddress?.postalCode ?? ""
            let country = contactData?.wire?.international?.beneficiaryBankAddress?.country ?? ""

            arrContactData = [accNo, routingNo, type, bankName, line1, line2, city, state, zipcode, country, amount, purpose]
            
            self.addressData.streetAddress = line1
            self.addressData.addressLine2 = line2
            self.addressData.city = city
            self.addressData.state = state
            self.addressData.postalCode = zipcode
            self.addressData.country = country
            
            self.originalAddressData =  self.addressData
        } else {
            if let bType =  contactData?.wire?.domestic?.accountType {
                type =  AccountType.title(for: bType.rawValue)
                bankData.accountType = bType
            }
            
            bankData.accountNumber = accNo
            bankData.routingNumber = routingNo
            bankData.bankName = bankName
            bankData.address = contactData?.wire?.domestic?.address

            wireData.domestic = bankData
            
            arrContactData = [accNo, routingNo, type, bankName, amount, purpose]
        }

		contactData?.wire = wireData

		self.originalData = contactData
	}
}

// MARK: - Google Places
extension WirePaymentVC: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        placePredictions = predictions
        self.showPlaceList(true)
        self.placesTableView.reloadData()
        self.setIndicator(shouldShow: false)
    }

    func didFailAutocompleteWithError(_ error: Error) {
        debugPrint(error.localizedDescription)
    }

    func scheduleDownloadWithCounter(counter: Int, searchText: String) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if counter == self.autoCompletionCounter {
                self.downloadPlacesPredictions(searchText: searchText)
            }
        }
    }

    func setIndicator(shouldShow: Bool) {
        showIndicatior = shouldShow

        let indpath: IndexPath = IndexPath(row: 1, section: 0)
        tblWire.reloadRows(at: [indpath], with: .automatic)
    }

    func downloadPlacesPredictions(searchText: String) {

        self.setIndicator(shouldShow: true)

        filter.country = "US"
        
        placesClient.findAutocompletePredictions(fromQuery: searchText, filter: filter, sessionToken: token) { (predictions, error) in
            guard error == nil else {
                self.setIndicator(shouldShow: false)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.setIndicator(shouldShow: false)

                if let aPredictions = predictions, aPredictions.count > 0 {
                    self.placePredictions = aPredictions
                    self.showPlaceList(true)
                    self.placesTableView.reloadData()
                } else {
                    self.showPlaceList(false)
                }
            }
        }
    }
}

// MARK: - UITableView
extension WirePaymentVC: UITableViewDelegate, UITableViewDataSource {
	func registerCellsAndHeaders() {
		self.tblWire.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
		self.tblWire.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == placesTableView {
            return placePredictions.count
        }
		return arrTitles.count
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cheight: CGFloat
        if tableView == placesTableView {
            cheight = Constants.placesTableViewCellHeight
        } else {
            cheight = Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
        }
		return cheight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let strTitle = arrTitles[indexPath.row]
        if tableView == placesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "place_cell", for: indexPath)
            let prediction = placePredictions[indexPath.row]
            cell.textLabel?.text = prediction.attributedPrimaryText.string + " " + (prediction.attributedSecondaryText?.string ?? "")
            cell.selectionStyle = .none
            return cell
        } else {
            if (indexPath.row == 4 && self.selectedPaymentMode == .domesticWire) || (indexPath.row == 10 && self.selectedPaymentMode == .internationalWire) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
                    cell.delegate = self
                    cell.lblTitle?.text = Utility.localizedString(forKey: strTitle)
                    cell.selectionStyle = .none
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {
                    cell.arrPickerData = self.selectedPaymentMode == .internationalWire ? InternationalWireAccountType.dataNodes : AccountType.dataNodes
                    cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
                    cell.fieldType = arrFieldTypes[indexPath.row]
                    cell.inputTextField?.text = getCellData(forIndex: indexPath.row)
                    cell.inputTextField?.tag = indexPath.row
                    cell.delegate = self
                    
                    if showIndicatior && indexPath.row == 4 {
                        cell.indicatorView?.isHidden = false
                        cell.indicatorView?.startAnimating()
                    } else {
                        cell.indicatorView?.isHidden = true
                        cell.indicatorView?.stopAnimating()
                    }
                    
                    return cell
                }
            }
        }
		
		return UITableViewCell()
	}
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if tableView == placesTableView {
            let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
            cell.textLabel?.font = labelFont
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == placesTableView {
            showPlaceList(false)
            let prediction = placePredictions[indexPath.row]
            self.autofillDataUsing(placeId: prediction.placeID)
        }
    }

    func autofillDataUsing(placeId: String) {
        placesClient.lookUpPlaceID(placeId) { (place, _) in
            if let aPlaceExist = place {
                var route = ""
                var streetNo = ""

                aPlaceExist.addressComponents?.forEach({ (component) in
                    if !component.types.isEmpty {
                        if component.types.contains("route") {
                            route = component.name
                        } else if component.types.contains("street_number") {
                            streetNo = component.shortName ?? ""
                        } else if component.types.contains("locality") || component.types.contains("sublocality_level_1") {
                            self.addressData.city = component.shortName ?? ""
                        } else if component.types.contains("administrative_area_level_1") {
                            self.addressData.state = component.shortName ?? ""
                        } else if component.types.contains("country") {
                            self.addressData.country = component.shortName ?? ""
                        } else if component.types.contains("postal_code") {
                            self.addressData.postalCode = component.shortName ?? ""
                        }
                    }
                })
                self.addressData.streetAddress = "\(streetNo) \(route)"
            }

            DispatchQueue.main.async {
                self.tblWire.reloadData()
                self.validate()
            }
        }
    }
}

// MARK: - FormDataCellDelegate
extension WirePaymentVC {

	func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
		debugPrint(editing ?? "", cd ?? "")
		guard let indexPath = self.tblWire.indexPath(for: cell) else {return}
		self.scrollToIndexPath = indexPath
        //if indexPath.row < 3 || indexPath.row > 8 {
            showPlaceList(false)
        //}
	}

    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {
        debugPrint(editing ?? "")
        guard let indexPath = self.tblWire.indexPath(for: cell), let text = data as? String else {return}
        
        if indexPath.row == 4 {
            if text.count > 3 {
                autoCompletionCounter += 1
                scheduleDownloadWithCounter(counter: autoCompletionCounter, searchText: text)
            } else {
                showPlaceList(false)
            }
        }

        cell.validateEnteredAddressText(enteredText: text.trim)
        
        switch indexPath.row {
            
        case 0: // Account Number
            if self.selectedPaymentMode == .internationalWire {
                contactData?.wire?.international?.accountNumber = text.trim
                internationalBankData.accountNumber = text.trim
            } else {
                contactData?.wire?.domestic?.accountNumber = text.trim
                bankData.accountNumber = text.trim
            }
            arrContactData[indexPath.row] = text.trim
            
        case 1:
            if self.selectedPaymentMode == .internationalWire {//BIC CODE
                internationalBankData.bankIdentifierCode = text.trim
            } else {// Routing Number
                bankData.routingNumber = text.trim
            }
            
            arrContactData[indexPath.row] = text.trim
            
        case 2:// Account Type
            if self.selectedPaymentMode == .internationalWire {
                internationalBankData.accountType = InternationalWireAccountType(rawValue: InternationalWireAccountType.entityId(for: text.trim))
            } else {
                bankData.accountType = AccountType(rawValue: AccountType.entityId(for: text.trim))
            }

            arrContactData[indexPath.row] = text.trim
          
        case 3://BANK NAME
            if self.selectedPaymentMode == .internationalWire {
                internationalBankData.beneficiaryBank = text.trim
            } else {
                bankData.bankName = text.trim
            }
            arrContactData[indexPath.row] = text.trim
        case 4:
            if self.selectedPaymentMode == .internationalWire { // ADDRESS 1
                addressData.streetAddress = text.trim
                cell.validateEnteredAddressText(enteredText: text.trim)
                arrContactData[indexPath.row] = text.trim
            }
        case 5:
            if self.selectedPaymentMode == .internationalWire { // ADDRESS 2
                addressData.addressLine2 = text.trim
                arrContactData[indexPath.row] = text.trim
                cell.validateEnteredAddressText(enteredText: text.trim)
            } else {//PURPOSE
                bankData.purpose = text.trim
            }
        case 6:
            addressData.city = text.trim
            cell.validateEnteredAddressText(enteredText: text.trim)
            arrContactData[indexPath.row] = text.trim

        case 7:// STATE
            addressData.state = text.trim
            cell.validateEnteredAddressText(enteredText: text.trim)
            arrContactData[indexPath.row] = text.trim

        case 8:// ZIPCODE
            addressData.postalCode = text.trim
            cell.validateEnteredAddressText(enteredText: text.trim)
            arrContactData[indexPath.row] = text.trim
           
        case 9:// COUNTRY
            addressData.country = text.trim
            cell.validateEnteredAddressText(enteredText: text.trim)
            arrContactData[indexPath.row] = text.trim
            
        case 11:
            internationalBankData.purpose = text.trim
            arrContactData[indexPath.row] = text.trim
        default: break
        }
        
        if self.selectedPaymentMode == .internationalWire {
            self.contactData?.wire?.international = internationalBankData
        } else {
            self.contactData?.wire?.domestic = bankData
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
    
    func getCellData(forIndex: Int) -> String {
        
        var strValue = ""
        
        switch forIndex {
        case 0:
            strValue = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.accountNumber ?? "" : contactData?.wire?.domestic?.accountNumber ?? ""
        case 1:
            strValue = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.bankIdentifierCode ?? "" : contactData?.wire?.domestic?.routingNumber ?? ""
        case 2:
            strValue = self.selectedPaymentMode == .internationalWire ? InternationalWireAccountType.title(for: contactData?.wire?.international?.accountType?.rawValue ?? InternationalWireAccountType.unknown.rawValue) : AccountType.title(for: contactData?.wire?.domestic?.accountType?.rawValue ?? AccountType.unknown.rawValue)
           
        case 3:
            strValue = self.selectedPaymentMode == .internationalWire ? contactData?.wire?.international?.beneficiaryBank ?? "" : contactData?.wire?.domestic?.bankName ?? ""
        case 4:
            if self.selectedPaymentMode == .internationalWire { // ADDRESS 1
                strValue = addressData.streetAddress ?? ""
            }
        case 5:
            strValue =  self.selectedPaymentMode == .internationalWire ? addressData.addressLine2 ?? "" : contactData?.wire?.domestic?.purpose ?? ""
        case 6:
            strValue = addressData.city ?? ""
        case 7:// STATE
            strValue = addressData.state ?? ""
        case 8:// ZIPCODE
            strValue =  addressData.postalCode ?? ""
        case 9:// COUNTRY
            strValue = addressData.country ?? ""
        case 11:
            strValue = contactData?.wire?.international?.purpose ?? ""
        default:
            break
        }
        
        return strValue
    }
}

extension WirePaymentVC: CurrencyEntryCellDelegate {
	func amountEntered(amount: Double) {
		self.paymentAmount = amount
		validate()
	}

	func gotoPaymentSuccess() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Pay", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "PaymentSuccessVC") as? PaymentSuccessVC {
			vc.contactData = self.contactData
			vc.paymentData = self.paymentResponse
			self.show(vc, sender: self)
			self.modalPresentationStyle = .fullScreen
		}
	}
}
//"routingNumber\":\"084106768\", \"accountNumber\":\"9870001240556824
// MARK: - API calls
extension WirePaymentVC {
	func makeWirePayment() {
		if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = contactData, let contactId = contact.id {
			self.view.endEditing(true)
			self.activityIndicatorBegin()
			var paymentRequestBody = PaymentModel()
			paymentRequestBody.accountId = accId
			paymentRequestBody.contactId = contactId
			paymentRequestBody.amount = self.paymentAmount.toString()
            paymentRequestBody.description = self.selectedPaymentMode == .internationalWire ? self.contactData?.wire?.international?.purpose : self.contactData?.wire?.domestic?.purpose
            paymentRequestBody.type = self.selectedPaymentMode == .internationalWire ? "international" : "domestic"
            let selectedPaymentType =  self.selectedPaymentMode ?? .unknown

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

    func getAddressData() -> Address {
        var postaddress = Address()
        postaddress.line1 = addressData.streetAddress
        postaddress.line2 = addressData.addressLine2
        postaddress.city = addressData.city
        postaddress.state = addressData.state
        postaddress.country = addressData.country ?? AppGlobalData.shared().personData.address?.country
        postaddress.postalCode = addressData.postalCode
        
        return postaddress
    }
    
	func updateContact(contactID: String) {
		if let data = contactData {
			var postBody = ContactDataModel()
			postBody.accountId = AppGlobalData.shared().accountData?.id
            
            postBody.wire = data.wire ?? WirePayment()
            postBody.wire?.international?.amount = nil
            postBody.wire?.international?.purpose = nil
            postBody.wire?.domestic?.amount = nil
            postBody.wire?.domestic?.purpose = nil

            if self.selectedPaymentMode == .internationalWire {
                var postaddress = self.getAddressData()
                postaddress.addressType = "wire"
                postBody.wire?.international?.beneficiaryBankAddress = postaddress
                postBody.wire?.international?.bankIdentifierType = "swift"
            }
            
			self.activityIndicatorBegin()

			ContactViewModel.shared.updateContact(contactId: contactID, contactData: postBody) { (response, errorMessage) in
				self.activityIndicatorEnd()
				if let error = errorMessage {
					self.showAlertMessage(titleStr: error.title, messageStr: error.body )
				} else {
					if let _ = response {
						self.makeWirePayment()
					}
				}
			}
		}
	}
}
