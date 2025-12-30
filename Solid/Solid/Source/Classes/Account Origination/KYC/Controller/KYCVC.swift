//
//  KYCVC.swift
//  Solid
//
//  Created by Solid iOS Team on 09/02/21.
//

import UIKit

class KYCVC: BaseVC, FormDataCellDelegate {
    var arrTitles = [String]()
    var arrFieldTypes = [String]()
	var arrPersonData = [String]()
    var detailsModel = KYCPersonDetailsModel()

    @IBOutlet var tbleKYCDetails: UITableView!
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setData()
		self.setPersonData()
        registerCellsAndHeaders()
		self.tbleKYCDetails.reloadData()
		addProgressbar(percentage: 30)
        self.setFooterUI()
        validate()
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(gotoNextScreen), for: .touchUpInside)
    }

    func setData(forType: String = TaxType.ssn.rawValue) {

        if forType == TaxType.passport.rawValue {
            arrTitles = ["fName", "lName", "email", "dob", "docType", "passport"]
            arrFieldTypes = ["fName", "lName", "email", "dob", "stringPicker", "passport"]
        } else {
            arrTitles = ["fName", "lName", "email", "dob", "docType", "ssnumber"]
            arrFieldTypes = ["fName", "lName", "email", "dob", "stringPicker", "ssnumber"]
        }
    }

	func setPersonData() {
		let firstName = AppGlobalData.shared().personData.firstName ?? ""
		let lastName = AppGlobalData.shared().personData.lastName ?? ""
		let email = AppGlobalData.shared().personData.email ?? ""
		var dateOfBirth = AppGlobalData.shared().personData.dateOfBirth ?? ""
		let ssn = AppGlobalData.shared().personData.idNumber ?? ""
        let idType = AppGlobalData.shared().personData.idType ?? TaxType.ssn.rawValue
        let strIdType = TaxType.title(for: idType)
		
        if let dateofb = AppGlobalData.shared().personData.dateOfBirth {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd"
			if let dob = dateFormatter.date(from: dateofb) {
				dateFormatter.dateFormat = "MM/dd/yyyy"
				let birthDate = dateFormatter.string(from: dob)
				dateOfBirth = birthDate
			}
		}

		detailsModel.firstName = firstName
		detailsModel.lastName = lastName
		detailsModel.dob = dateOfBirth
		detailsModel.email = email
        detailsModel.idType = TaxType(rawValue: TaxType.entityId(for: strIdType))
        detailsModel.ssn = ssn

        let idNumber = (detailsModel.idType == .passport) ? ssn : ssn.ssnFormat()
        arrPersonData = [firstName, lastName, email, dateOfBirth, strIdType, idNumber]
	}

    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {

        var cFrame = footerView.frame

        var kyccY: CGFloat = footerView.frame.origin.y

        let navBarHeight = self.getNavigationbarHeight()

        UIView.animate(withDuration: 0.2) {
			kyccY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
            cFrame.origin.y = kyccY
            self.footerView.frame = cFrame
            self.view.layoutIfNeeded()

            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/1.5), right: 0.0)
            self.tbleKYCDetails.contentInset = contentInsets
            self.tbleKYCDetails.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tbleKYCDetails.scrollIndicatorInsets = self.tbleKYCDetails.contentInset
        }
    }
}

// MARK: - Navigationbar
extension KYCVC {
    func setNavigationBar() {
        self.tbleKYCDetails.backgroundColor = .clear

        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        self.navigationItem.setHidesBackButton(true, animated: true)

        self.title = Utility.localizedString(forKey: "kyc_NavTitle")
    }

    func validate() {
        if let fname = detailsModel.firstName, !fname.isEmpty && !fname.isInvalidInput(),
           let lname = detailsModel.lastName, !lname.isEmpty && !lname.isInvalidInput(),
           let email = detailsModel.email, !email.isEmpty, email.isValidEmail,
           let dob = detailsModel.dob, !dob.isEmpty,
           let idType = detailsModel.idType, !idType.rawValue.isEmpty,
           let ownerSSN = detailsModel.ssn, !ownerSSN.isEmpty {
            if idType == TaxType.ssn && ownerSSN.plainNumberString.count == Constants.ssnCodeLimit {
                self.footerView.btnApply.isEnabled = true
            } else if idType == TaxType.passport && ownerSSN.isValidPassportNumber() {
                self.footerView.btnApply.isEnabled = true
            } else {
                self.footerView.btnApply.isEnabled = false
            }
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }

    @objc func gotoNextScreen() {
        gotoAddressScreen()
    }

    func gotoAddressScreen() {
        self.performSegue(withIdentifier: "GoToKYCAddressVC", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? KYCAddressVC {
			destinationVC.detailsModel = self.detailsModel
        }
    }
}

// MARK: - UITableView
extension KYCVC {
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
        guard let indexPath = self.tbleKYCDetails.indexPath(for: cell) else {return}

        self.scrollToIndexPath = indexPath
    }

    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {
        
        guard let indexPath = self.tbleKYCDetails.indexPath(for: cell), let text = data as? String else {return}
        cell.inputTextField?.tag = indexPath.row
        switch indexPath.row {
        case 0: // First name
            detailsModel.firstName = text.trim
            cell.validateEnteredText(enteredText: text.trim)
            
        case 1:// Last name
            detailsModel.lastName = text.trim
            cell.validateEnteredText(enteredText: text.trim)
            
        case 2:// Email
            detailsModel.email = text.trim
            
        case 3:// DOB
            detailsModel.dob = text.trim
            
        case 4:// doc type
            let idType = TaxType(rawValue: TaxType.entityId(for: text.trim))
            detailsModel.idType = idType
            setData(forType: idType?.rawValue ?? "")
            arrPersonData[indexPath.row + 1] = ""
            detailsModel.ssn = ""
            arrPersonData[indexPath.row] = text.trim
            tbleKYCDetails.reloadRows(at: [indexPath], with: .none)
            tbleKYCDetails.reloadRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: .none)

        case 5:// SSN/Passport
            detailsModel.ssn = text.trim
            
        default:break
        }
        
        arrPersonData[indexPath.row] = text.trim
        
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

// MARK: - FormDataCellDelegate
extension KYCVC: UITableViewDelegate, UITableViewDataSource {

    func registerCellsAndHeaders() {
        self.tbleKYCDetails.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let cheight: CGFloat
		cheight	= Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
		return cheight
	}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        let strTitle = arrTitles[indexPath.row]
        cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
        cell.arrPickerData = TaxType.dataNodes
		cell.inputTextField?.text = arrPersonData[indexPath.row]
        cell.fieldType = arrFieldTypes[indexPath.row]
		cell.inputTextField?.tag = indexPath.row

        cell.delegate = self
        
        return cell
    }
}
