//
//  BaseAddressVC.swift
//  Solid
//
//  Created by Solid iOS Team on 26/02/21.
//

import UIKit
import GooglePlaces

class BaseAddressVC: BaseVC, FormDataCellDelegate {

    var fetcher: GMSAutocompleteFetcher?
    var placesClient = GMSPlacesClient.shared()
    var placePredictions =  [GMSAutocompletePrediction]()
    var filter = GMSAutocompleteFilter()
    var autoCompletionCounter = 0
    var showIndicatior = false
    var addressData = AddressModel()
    var token: GMSAutocompleteSessionToken?
    var strPhoneNumber = ""

    @IBOutlet weak var tblAddress: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var placesContainer: UIView!
    @IBOutlet weak var placesView: UIView!
    @IBOutlet weak var placesTableView: UITableView!

    var arrTitles = [String]()
    var arrAddressData = [String]()

    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblAddress.backgroundColor = .clear

        setData()
        setNavigationBar()
        registerCellsAndHeaders()

        setForLocation()
        addPlacesView()
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            tblBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : 90
        }
    }

    func setForLocation() {
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
            placesContainer.frame = CGRect(x: self.view.frame.origin.x + 16, y: 85, width: self.view.frame.size.width - 26, height: 200)
        } else {
            placesContainer.frame = CGRect(x: self.view.frame.origin.x + 16, y: 85, width: self.view.frame.size.width - 26, height: 200)
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
        var postalCode = ""
        var shouldEnable = false
        
        if let zipcode = addressData.postalCode {
            postalCode = Utility.isNonUS(forPhoneNumber: self.strPhoneNumber) ? zipcode.replacingOccurrences(of: "-", with: "") : zipcode
        }
        
        if let address1 = addressData.streetAddress,
           !address1.isEmpty && !address1.isInvalidAddress(), !postalCode.isEmpty && ((Utility.isNonUS(forPhoneNumber: self.strPhoneNumber) && postalCode.isValidNonUSZipcode) || postalCode.isValidUSZipcode) {
            
            if postalCode.isValidUSZipcode {
                if  let city = addressData.city, !city.isEmpty && !city.isInvalidAddress(),
                    let state = addressData.state, !state.isEmpty && !state.isInvalidAddress() {
                    shouldEnable = true
                } else {
                    shouldEnable = false
                }
            } else {
                if  let city = addressData.city, !city.isEmpty && city.isInvalidAddress() {
                    shouldEnable = false
                } else if let state = addressData.state, !state.isEmpty && state.isInvalidAddress() {
                      shouldEnable = false
                } else {
                    shouldEnable = true
                }
            }
        } else {
            shouldEnable = false
        }
        
        if self.shouldShowFooterView {
            self.footerView.btnApply.isEnabled = shouldEnable
        } else {
            self.enableRightBarButton(shouldEnable: shouldEnable)
        }
    }

    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {

        var addresscFrame = footerView.frame
        var addresscY: CGFloat = footerView.frame.origin.y
        let navBarHeight = self.getNavigationbarHeight()

        UIView.animate(withDuration: 0.2) {
            addresscY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
            addresscFrame.origin.y = addresscY
            self.footerView.frame = addresscFrame
            self.view.layoutIfNeeded()

            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/1.5), right: 0.0)
            self.tblAddress.contentInset = contentInsets
            self.tblAddress.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblAddress.scrollIndicatorInsets = self.tblAddress.contentInset
        }
    }
    
    func setAddressData(address: Address) {
        let streetAddress = address.line1 ?? ""
        let addressLine2 = address.line2 ?? ""
        let city = address.city ?? ""
        let postalCode = address.postalCode ??  ""
        let state = address.state ?? " "
        
        addressData.streetAddress = streetAddress
        addressData.addressLine2 = addressLine2
        addressData.city = city
        addressData.postalCode = postalCode
        addressData.state = state
        
        arrAddressData = [streetAddress, addressLine2, city, state, postalCode]
    }
}

// MARK: - Data Methods
extension BaseAddressVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        addBackNavigationbarButton()
    }

    func setData() {
        arrTitles = ["address_1", "address_2", "address_City", "address_State", "address_Zipcode"]
    }
    
    func getPostAddressData(addressType: String = "mailing") -> Address {
        var postaddress = Address()
        postaddress.addressType = addressType
        postaddress.line1 = addressData.streetAddress
        postaddress.line2 = addressData.addressLine2
        postaddress.city = addressData.city
        postaddress.state = addressData.state
        
        if let addressCountry =  addressData.country {
            postaddress.country = addressCountry
        } else if let userCountry =  AppGlobalData.shared().personData.address?.country {
            postaddress.country = userCountry
        } else if let userPhone = AppGlobalData.shared().personData.phone {
            let countryCode = userPhone.countryCode()
            postaddress.country = Utility.getCountry(forCountryCode: countryCode)
        }
        
        postaddress.postalCode = addressData.postalCode
        
        return postaddress
    }
}

// MARK: - Google Places
extension BaseAddressVC: GMSAutocompleteFetcherDelegate {

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
        tblAddress.reloadData()
    }

    func downloadPlacesPredictions(searchText: String) {

        self.setIndicator(shouldShow: true)
        
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

    func autofillDataUsing(placeId: String) {

        placesClient.lookUpPlaceID(placeId) { (place, error) in
            if let error = error {
                debugPrint("lookup place id query error: \(error.localizedDescription)")
                return
            }

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
            } else {
                debugPrint("No place details for \(placeId)")
            }
            DispatchQueue.main.async {
                self.tblAddress.reloadData()
                self.validate()
            }
        }

    }
}

// MARK: - UITableView
extension BaseAddressVC: UITableViewDelegate, UITableViewDataSource {

    func registerCellsAndHeaders() {
        self.tblAddress.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
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
        // Configure the cell...

        if tableView == placesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "place_cell", for: indexPath)
            let prediction = placePredictions[indexPath.row]
            cell.textLabel?.text = prediction.attributedPrimaryText.string + " " + (prediction.attributedSecondaryText?.string ?? "")
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell

            let strTitle = arrTitles[indexPath.row]
            cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
            cell.fieldType = strTitle

            cell.inputTextField?.text = getAdderessData(forIndex: indexPath.row)
            cell.inputTextField?.tag = indexPath.row
            cell.delegate = self

            if showIndicatior && indexPath.row == 0 {
                cell.indicatorView?.isHidden = false
                cell.indicatorView?.startAnimating()
            } else {
                cell.indicatorView?.isHidden = true
                cell.indicatorView?.stopAnimating()
            }

            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if tableView == placesTableView {
            cell.textLabel?.font = UIFont.sfProDisplayRegular(fontSize: 12)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView == placesTableView {

            showPlaceList(false)

            let prediction = placePredictions[indexPath.row]

            self.autofillDataUsing(placeId: prediction.placeID)

        }
    }
}

// MARK: - FormDataCellDelegate
extension BaseAddressVC {

    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {

        guard let indexPath = self.tblAddress.indexPath(for: cell) else {return}

        if indexPath.row != 0 {
            showPlaceList(false)
        }

        self.scrollToIndexPath = indexPath
    }

    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {

        guard let indexPath = self.tblAddress.indexPath(for: cell), let text = data as? String else {return}

        if indexPath.row == 0 {
            if text.count > 3 {
                autoCompletionCounter += 1
                scheduleDownloadWithCounter(counter: autoCompletionCounter, searchText: text)
            } else {
                showPlaceList(false)
            }
        }

        switch indexPath.row {
              case 0: // ADDRESS 1
                addressData.streetAddress = text.trim

              case 1:// ADDRESS 2
                addressData.addressLine2 = text.trim

              case 2:// CITY
                addressData.city = text.trim

              case 3:// STATE
                addressData.state = text.trim

              case 4:// ZIPCODE
                addressData.postalCode = text.trim

              default:break
       }

        cell.validateEnteredAddressText(enteredText: text.trim)

        validate()
    }

    func cell (shouldCelar cell: CustomTableViewCell) -> Bool {

        let indexPath = self.tblAddress.indexPath(for: cell)

        if indexPath!.row == 0 {
            showPlaceList(false)
        }
        return true
    }

    func getAdderessData(forIndex: Int) -> String {

        var strValue = ""

        switch forIndex {
        case 0:
            strValue = addressData.streetAddress ?? ""
        case 1:
            strValue = addressData.addressLine2 ?? ""
        case 2:
            strValue = addressData.city ?? ""
        case 3:
            strValue = addressData.state ?? ""
        case 4:
            strValue = addressData.postalCode ?? ""
        default:
            break
        }

        return strValue
    }
}

// MARK: - UpdatePersonPostBody
//common code for KYC and User Address request body..
extension BaseAddressVC {
    func getUpdatePersonPostBody(detailsModel: KYCPersonDetailsModel) -> UpdatePersonPostBody {
        var postBody = UpdatePersonPostBody()
        postBody.firstName = detailsModel.firstName
        postBody.lastName = detailsModel.lastName

        if let dateofb = detailsModel.dob {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if let dob = dateFormatter.date(from: dateofb) {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let birthDate = dateFormatter.string(from: dob)
                postBody.dateOfBirth = birthDate
            }
        }

        postBody.email = detailsModel.email
        postBody.idType = detailsModel.idType?.rawValue
        postBody.idNumber = (detailsModel.idType == .passport) ? detailsModel.ssn  : detailsModel.ssn?.plainNumberString
        postBody.address = self.getPostAddressData()
        
        return postBody
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.orientationChangedViewController(tableview: self.placesTableView, with: coordinator)
    }
}
