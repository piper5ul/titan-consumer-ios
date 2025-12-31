//
//  CheckPaymentVC.swift
//  Solid
//  Created by Solid iOS Team on 11/03/21.
//

import UIKit
import GooglePlaces

class CheckPaymentVC: BaseVC, FormDataCellDelegate {
	var fetcher: GMSAutocompleteFetcher?
	var placesClient = GMSPlacesClient.shared()
	var placePredictions =  [GMSAutocompletePrediction]()
	var filter = GMSAutocompleteFilter()
	var autoCompletionCounter = 0
	var showIndicatior = false
	var addressData = AddressModel()
	var originalAddressData  = AddressModel()
	var token: GMSAutocompleteSessionToken?

	var contactData: ContactDataModel?
	var arrPaymentData = [String]()
	var checkData = CheckAccount()
	var selectedPaymentMode: ContactAccountType?

	private let defaultAmount = "$0.00"
	var amount = 0.00
	var paymentAmount: Double = 0.0
	var paymentResponse: PaymentModel?
	var paymentRequestBody = PaymentModel()

	@IBOutlet weak var tblCheck: UITableView!
	@IBOutlet weak var placesContainer: UIView!
	@IBOutlet weak var placesView: UIView!
	@IBOutlet weak var placesTableView: UITableView!

	var arrTitles = [String]()
	var arrFieldTypes = [String]()

	var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        self.isScreenModallyPresented = true
        registerCellsAndHeaders()
        setForAddressLocation()
        addPlacesView()
        self.setFooter()
        selectedPaymentMode = self.contactData?.selectedPaymentMode
        switch selectedPaymentMode {
        case .check:
            setData()
            setPaymentData()
            validate()
        case .domesticWire:
            setDataForWire()
            setPaymentDataForWire()
            validateWireData()
        case .internationalWire:
            setDataForWire()
            setPaymentDataForInternationalWire()
            validateWireData()
        default:
            break
        }
        
        self.tblCheck.backgroundColor = .clear
    }

	func setFooter() {
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
            if selectedPaymentMode == ContactAccountType.check {
                self.makeCheckPayment()
            } else {
                self.navigateToWirePayment()
            }
        }
	}

	func checkForContactUpdate() -> Bool {
		if originalAddressData.streetAddress != addressData.streetAddress ||
            originalAddressData.addressLine2 != addressData.addressLine2 ||
            originalAddressData.city != addressData.city ||
            originalAddressData.state != addressData.state ||
            originalAddressData.country != addressData.country ||
            originalAddressData.postalCode != addressData.postalCode {
            
            if selectedPaymentMode == .check {
                return true
            } else if let wireData = contactData?.wire, let _ = wireData.domestic, selectedPaymentMode == ContactAccountType.domesticWire {
                return true
            } else if let wireData = contactData?.wire, let _ = wireData.international, selectedPaymentMode == ContactAccountType.internationalWire {
                return true
            } else {
                return false
            }
		}
        
        return false
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
		if let address1 = addressData.streetAddress,
           !address1.isEmpty && !address1.isInvalidAddress(),
           let city = addressData.city, !city.isEmpty && !city.isInvalidAddress(),
           let state = addressData.state, !state.isEmpty && !state.isInvalidAddress(),
           let zipcode = addressData.postalCode, !zipcode.isEmpty && zipcode.isValidUSZipcode,
           self.paymentAmount > 0, let desc = checkData.description, !desc.isEmpty {
			self.footerView.btnApply.isEnabled = true
		} else {
			self.footerView.btnApply.isEnabled = false
		}
	}

	func validateWireData() {
		if let address1 = addressData.streetAddress,
           !address1.isEmpty && !address1.isInvalidAddress(),
           let city = addressData.city, !city.isEmpty && !city.isInvalidAddress(),
           let state = addressData.state, !state.isEmpty && !state.isInvalidAddress(),
           let zipcode = addressData.postalCode, !zipcode.isEmpty && zipcode.isValidUSZipcode {
			self.footerView.btnApply.isEnabled = true
		} else {
			self.footerView.btnApply.isEnabled = false
		}
	}

	@objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {

		var cFrame = footerView.frame

		var cY: CGFloat = footerView.frame.origin.y

		let navBarHeight = self.getNavigationbarHeight()

		UIView.animate(withDuration: 0.2) {
			cY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
			cFrame.origin.y = cY
			self.footerView.frame = cFrame
			self.view.layoutIfNeeded()

			var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/2), right: 0.0)
			self.tblCheck.contentInset = contentInsets
			self.tblCheck.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
		}
	}
}

// MARK: - Data Methods
extension CheckPaymentVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        
        addBackNavigationbarButton()
        
        let selectedPaymentMode = self.contactData?.selectedPaymentMode
        switch selectedPaymentMode {
        case .check:
            self.title = Utility.localizedString(forKey: "payment_check_title")
        case .domesticWire:
            self.title = Utility.localizedString(forKey: "payment_domesticwire_title")
        case .internationalWire:
            self.title = Utility.localizedString(forKey: "payment_internationalwire_title")
        default:
            break
        }
    }

	func setData() {
		arrTitles = ["payment_name", "address_1", "address_2", "address_City", "address_State", "address_Zipcode", "payment_amount", "payment_purpose"]
		arrFieldTypes = ["contactname", "address_1", "address_2", "address_City", "address_State", "address_Zipcode", "currency", "purpose"]
	}

	func setDataForWire() {
		arrTitles = ["payment_name", "address_1", "address_2", "address_City", "address_State", "address_Zipcode"]
		arrFieldTypes = ["contactname", "address_1", "address_2", "address_City", "address_State", "address_Zipcode"]
	}

	func setPaymentData() {
		let name = contactData?.name ?? ""
		self.addressData.streetAddress = contactData?.check?.address?.line1
		self.addressData.addressLine2 = contactData?.check?.address?.line2
		self.addressData.city = contactData?.check?.address?.city
		self.addressData.state = contactData?.check?.address?.state
		self.addressData.country = contactData?.check?.address?.country
		self.addressData.postalCode = contactData?.check?.address?.postalCode
		self.originalAddressData =  self.addressData
		arrPaymentData = [name, "", "", "", "", "", "", ""]
	}

	func setPaymentDataForWire() {
		let name = contactData?.name ?? ""
		self.addressData.streetAddress = contactData?.wire?.domestic?.address?.line1
		self.addressData.addressLine2 = contactData?.wire?.domestic?.address?.line2
		self.addressData.city = contactData?.wire?.domestic?.address?.city
		self.addressData.state = contactData?.wire?.domestic?.address?.state
		self.addressData.country = contactData?.wire?.domestic?.address?.country
		self.addressData.postalCode = contactData?.wire?.domestic?.address?.postalCode
		self.originalAddressData =  self.addressData
		arrPaymentData = [name, "", "", "", "", "", "", ""]
	}
    
    func setPaymentDataForInternationalWire() {
        let name = contactData?.name ?? ""
        self.addressData.streetAddress = contactData?.wire?.international?.beneficiaryAddress?.line1
        self.addressData.addressLine2 = contactData?.wire?.international?.beneficiaryAddress?.line2
        self.addressData.city = contactData?.wire?.international?.beneficiaryAddress?.city
        self.addressData.state = contactData?.wire?.international?.beneficiaryAddress?.state
        self.addressData.country = contactData?.wire?.international?.beneficiaryAddress?.country
        self.addressData.postalCode = contactData?.wire?.international?.beneficiaryAddress?.postalCode
        self.originalAddressData =  self.addressData
        arrPaymentData = [name, "", "", "", "", "", "", ""]
    }
}

// MARK: - Google Places
extension CheckPaymentVC: GMSAutocompleteFetcherDelegate {
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
		tblCheck.reloadRows(at: [indpath], with: .automatic)
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
extension CheckPaymentVC: UITableViewDelegate, UITableViewDataSource {
	func registerCellsAndHeaders() {
		self.tblCheck.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
		self.tblCheck.register(UINib(nibName: "CurrencyEntryCell", bundle: nil), forCellReuseIdentifier: "CurrencyEntryCell")
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if tableView == placesTableView {
			return placePredictions.count
		} else {
			return arrTitles.count
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat
        if tableView == placesTableView {
            rowHeight = Constants.placesTableViewCellHeight
        } else {
            rowHeight = Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
        }
        
        return rowHeight
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView == placesTableView {
			let cell = tableView.dequeueReusableCell(withIdentifier: "place_cell", for: indexPath)
			let prediction = placePredictions[indexPath.row]
			cell.textLabel?.text = prediction.attributedPrimaryText.string + " " + (prediction.attributedSecondaryText?.string ?? "")
			cell.selectionStyle = .none
			return cell
		} else {
			let strTitle = arrTitles[indexPath.row]
			if indexPath.row == 6 {
				if let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEntryCell", for: indexPath) as? CurrencyEntryCell {
					cell.delegate = self
					cell.lblTitle?.text = Utility.localizedString(forKey: strTitle)
					cell.selectionStyle = .none
					return cell
				}
			} else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? CustomTableViewCell {
                    cell.fieldType = arrFieldTypes[indexPath.row]
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
                    cell.inputTextField?.text = getAdderessData(forIndex: indexPath.row)
                    cell.inputTextField?.tag = indexPath.row
                    cell.delegate = self

                    if showIndicatior && indexPath.row == 1 {
                        cell.indicatorView?.isHidden = false
                        cell.indicatorView?.startAnimating()
                    } else {
                        cell.indicatorView?.isHidden = true
                        cell.indicatorView?.stopAnimating()
                    }

                    if cell.fieldType == "contactname" || cell.fieldType == "purpose" {
                        if cell.fieldType == "contactname" {
                            cell.isUserInteractionEnabled = false
                        }
                        cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
                        cell.inputTextField?.text  = arrPaymentData[indexPath.row]
                        cell.inputTextField?.tag = indexPath.row
                    }
                    cell.delegate = self
                    
                    return cell
                }
			}
            return UITableViewCell()
		}
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
                self.tblCheck.reloadData()

                if self.selectedPaymentMode == ContactAccountType.check {
                    self.validate()
                } else {
                    self.validateWireData()
                }
            }
		}
	}
}

// MARK: - FormDataCellDelegate
extension CheckPaymentVC {

	func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
		debugPrint(editing ?? "", cd ?? "")
		guard let indexPath = self.tblCheck.indexPath(for: cell) else {return}
		if indexPath.row != 0 {
			showPlaceList(false)
		}
		
        self.scrollToIndexPath = indexPath
	}

	func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {
        debugPrint(editing ?? "", data ?? "")

		guard let indexPath = self.tblCheck.indexPath(for: cell), let text = data as? String else {return}
		if indexPath.row == 1 {
			if text.count > 3 {
				autoCompletionCounter += 1
				scheduleDownloadWithCounter(counter: autoCompletionCounter, searchText: text)
			} else {
				showPlaceList(false)
			}
		}

		switch indexPath.row {
			case 1: // ADDRESS 1
				addressData.streetAddress = text.trim

			case 2:// ADDRESS 2
				addressData.addressLine2 = text.trim

			case 3:// CITY
				addressData.city = text.trim

			case 4:// STATE
				addressData.state = text.trim

			case 5:// ZIPCODE
				addressData.postalCode = text.trim

			case 7:// PURPOSE
				checkData.description = text.trim
				arrPaymentData[indexPath.row] = text.trim
			default: break
		}

		cell.validateEnteredAddressText(enteredText: text.trim)

		if selectedPaymentMode == ContactAccountType.check {
			validate()
		} else {
			validateWireData()
		}
	}

	func cell (shouldCelar cell: CustomTableViewCell) -> Bool {

		let indexPath = self.tblCheck.indexPath(for: cell)

		if indexPath!.row == 0 {
			showPlaceList(false)
		}
		return true
	}

	func getAdderessData(forIndex: Int) -> String {

		var strValue = ""

		switch forIndex {
			case 0:
				strValue = contactData?.name ?? ""
			case 1:
				strValue = addressData.streetAddress ?? ""
			case 2:
				strValue = addressData.addressLine2 ?? ""
			case 3:
				strValue = addressData.city ?? ""
			case 4:
				strValue = addressData.state ?? ""
			case 5:
				strValue = addressData.postalCode ?? ""
			default:
				break
		}

		return strValue
	}
}

extension CheckPaymentVC: CurrencyEntryCellDelegate {
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

// MARK: - API calls
extension CheckPaymentVC {
	func makeCheckPayment() {
		if let selectedAcc = AppGlobalData.shared().accountData, let accId = selectedAcc.id, let contact = contactData, let contactId = contact.id {
			self.view.endEditing(true)
			self.activityIndicatorBegin()
			var paymentRequestBody = PaymentModel()
			paymentRequestBody.accountId = accId
			paymentRequestBody.contactId = contactId
			paymentRequestBody.amount = self.paymentAmount.toString()
			paymentRequestBody.description = self.checkData.description
			paymentRequestBody.type = "physical"
			let selectedPaymentType =  ContactAccountType.check

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
        
        var postaddress = self.getAddressData()
        
        if let _ = contactData {
            var postBody = ContactDataModel()
            postBody.accountId = AppGlobalData.shared().accountData?.id
            
            if self.selectedPaymentMode == ContactAccountType.check {
                postaddress.addressType = "check"
                var address = Contactaddress()
                address.address = postaddress
                postBody.check = address
            } else {
                postaddress.addressType = "wire"
                var wire = WirePayment()
                if self.selectedPaymentMode == ContactAccountType.internationalWire {
                    var internationalpayment = InternationalWire()
                    internationalpayment.beneficiaryAddress = postaddress
                    internationalpayment.accountNumber = contactData?.wire?.international?.accountNumber
                    internationalpayment.bankIdentifierCode = contactData?.wire?.international?.bankIdentifierCode
                    internationalpayment.accountType = contactData?.wire?.international?.accountType
                    internationalpayment.bankIdentifierType = contactData?.wire?.international?.bankIdentifierType
                    internationalpayment.bankIdentifierCode = contactData?.wire?.international?.bankIdentifierCode
                    wire.international = internationalpayment
                } else {
                    var domesticpayment = DomesticWire()
                    domesticpayment.address = postaddress
                    domesticpayment.accountNumber = contactData?.wire?.domestic?.accountNumber
                    domesticpayment.routingNumber = contactData?.wire?.domestic?.routingNumber
                    domesticpayment.accountType = contactData?.wire?.domestic?.accountType
                    wire.domestic = domesticpayment
                }
                
                postBody.wire = wire
            }
            
            self.activityIndicatorBegin()
            ContactViewModel.shared.updateContact(contactId: contactID, contactData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        self.contactData = response
                        self.contactData?.selectedPaymentMode = self.selectedPaymentMode

                        if self.selectedPaymentMode == ContactAccountType.check {
                            self.makeCheckPayment()
                        } else {
                            self.navigateToWirePayment()
                        }
                    }
                }
            }
        }
    }

	 func navigateToWirePayment() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
		if let destinationVC = storyboard.instantiateViewController(withIdentifier: "WirePaymentVC") as? WirePaymentVC {
			
            var postaddress = self.getAddressData()

			postaddress.addressType = "wire"

            var wireData = WirePayment()
            
            if self.selectedPaymentMode == ContactAccountType.internationalWire {
                var internationalData = InternationalWire()
                internationalData.beneficiaryBank = contactData?.wire?.international?.beneficiaryBank
                internationalData.bankIdentifierCode = contactData?.wire?.international?.bankIdentifierCode
                internationalData.accountNumber = contactData?.wire?.international?.accountNumber
                internationalData.accountType =  contactData?.wire?.international?.accountType
                internationalData.beneficiaryAddress = postaddress
                internationalData.beneficiaryBankAddress = contactData?.wire?.international?.beneficiaryBankAddress

                wireData.international = internationalData
            } else {
                var domesticData = DomesticWire()
                domesticData.address = postaddress
                domesticData.bankName = contactData?.wire?.domestic?.bankName
                domesticData.routingNumber = contactData?.wire?.domestic?.routingNumber
                domesticData.accountNumber = contactData?.wire?.domestic?.accountNumber
                domesticData.accountType =  contactData?.wire?.domestic?.accountType
                wireData.domestic = domesticData
            }

            contactData?.wire = wireData

			destinationVC.contactData = self.contactData
            destinationVC.selectedPaymentMode = self.selectedPaymentMode
			self.show(destinationVC, sender: self)
			self.modalPresentationStyle = .fullScreen
		}
	}
}
