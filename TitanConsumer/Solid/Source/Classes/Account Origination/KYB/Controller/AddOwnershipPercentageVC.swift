//
//  AddOwnershipPercentageVC.swift
//  Solid
//
//  Created by Solid iOS Team on 22/02/21.
//

import UIKit

class AddOwnershipPercentageVC: BaseVC {
    @IBOutlet weak var switchContainer: UIView!
    @IBOutlet weak var textFieldContainer: UIView!
    
    @IBOutlet weak var percentageSwitch: UISwitch!
    @IBOutlet weak var txtPercentage: BaseTextField!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSwitchDesc: UILabel!
    @IBOutlet weak var lblPercentageTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var switchContainerHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var descBottomConstraint: NSLayoutConstraint!
    
    var ownerFlow: OwnerFlow = .mainOwner
    var signUrl: String!
    var additionalOwnerId: String = ""
    
    var isHavingPercentage = false {
        didSet {
            validate(text: txtPercentage.text?.trim ?? "")
        }
    }
    
    var detailsModel = KYCPersonDetailsModel()
    var addressData = Address()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.setFooterUI()
        addProgressbar(percentage: 80)
        self.setUI()
        
        txtPercentage.fieldType = .numeric
        txtPercentage.delegate = self
        
        self.percentageSwitch.isOn = false
        self.textFieldContainer.isHidden = true
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            let bottomConst = Utility.isDeviceIpad() ? 95.0 : 85.0
            descBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : bottomConst
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ownerFlow == .additionalOwner {
            self.setOwnerPrefillData()
        } else {
            self.activityIndicatorBegin()
            self.getOwners { (_, _) in
                self.setOwnerPrefillData()
                self.activityIndicatorEnd()
            }
        }
    }
    
    func setOwnerPrefillData() {
        if ownerFlow == .additionalOwner {
            isHavingPercentage = true
        } else {
            if let ownership = AppGlobalData.shared().ownerData.ownership, let ownerPercentage = Float(ownership), ownerPercentage > 0 {
                txtPercentage.text = ownership
                self.percentageSwitch.isOn = true
                self.textFieldContainer.isHidden = false
                isHavingPercentage = true
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblSwitchDesc.textColor = UIColor.secondaryColor
        lblDesc.textColor = UIColor.secondaryColor
        lblPercentageTitle.textColor = UIColor.secondaryColor
    }
}

// MARK: - Set UI
extension AddOwnershipPercentageVC {
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(btnNextClicked(_:)), for: .touchUpInside)
    }
    
    func setUI() {
        lblDesc.text = Utility.localizedString(forKey: "addOwnerPercentage_Descriptions")
        lblSwitchDesc.text = Utility.localizedString(forKey: "addOwnerPercentage_Switch_Descriptions")
        footerView.btnApply.setTitle(Utility.localizedString(forKey: "addOwnerPercentage_NextButton"), for: .normal)

        let strTitle = ownerFlow == .additionalOwner ? Utility.localizedString(forKey: "additionalOwnerPercentage_Title") : Utility.localizedString(forKey: "addOwnerPercentage_Title")
        let strPercentageTitle = ownerFlow == .additionalOwner ? Utility.localizedString(forKey: "additionalOwnerPercentage_TextField_Descriptions") : Utility.localizedString(forKey: "addOwnerPercentage_TextField_Descriptions")

        lblTitle.text = strTitle
        lblPercentageTitle.text = strPercentageTitle
        let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblTitle.font = labelFont
        lblTitle.textColor = UIColor.primaryColor

        let labelswitchfont = Utility.isDeviceIpad() ? Constants.regularFontSize18: Constants.regularFontSize14
        lblSwitchDesc.font = labelswitchfont
        lblSwitchDesc.textColor = UIColor.secondaryColor
        
        let font = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        lblDesc.font = font
        lblDesc.textColor = UIColor.secondaryColor

        lblPercentageTitle.font = font
        lblPercentageTitle.textColor = UIColor.secondaryColor

        footerView.btnApply.isEnabled = true

        if ownerFlow == .additionalOwner {
            switchContainer.isHidden = true
            switchContainerHeightContraint.constant = 50
        }

        txtPercentage.addDoneButtonOnKeyboard()
    }
}

// MARK: - Navigationbar
extension AddOwnershipPercentageVC {
    func setNavigationBar() {
        self.title = Utility.localizedString(forKey: "addOwnerPercentage_NavTitle")
		self.isScreenModallyPresented = true
        self.isNavigationBarHidden = false
		addBackNavigationbarButton()
    }

    func goToOwnersListVC() {
        self.performSegue(withIdentifier: "GoToOwnersListVC", sender: self)
    }
}

// MARK: - Textfield delegate method
extension AddOwnershipPercentageVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let theString = textField.text! as NSString
        let theNewString = theString.replacingCharacters(in: range, with: string).trim
        
        textField.text = theNewString.ownerPercentageString()
        
        self.validate(text: theNewString)
        
        return false
    }
    
    func validate(text: String) {
        let strPercentage = text as String
        let intPercentage = Float(strPercentage) ?? 0
        
        let totalSum = AppGlobalData.shared().ownerList.map({Float($0.ownership ?? "0.0") ?? 0.0}).reduce(0, +)
        let totalPercentage = Float(totalSum) + intPercentage
        
        if isHavingPercentage {
            self.textFieldContainer.isHidden = false
            if ownerFlow == .mainOwner {
                let ownerPercentage = Float(AppGlobalData.shared().ownerData.ownership ?? "0.0") ?? 0.0
                if totalSum == 100 {
                    if ownerPercentage > 0 {
                        let shouldEnable = intPercentage >= 25 && intPercentage <= ownerPercentage
                        footerView.btnApply.isEnabled = shouldEnable
                        if !shouldEnable && intPercentage >= 25 {
                            self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "exceeds_100%_error"))
                        }
                    } else {
                        footerView.btnApply.isEnabled = false
                        self.textFieldContainer.isHidden = true
                        self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "over_100%_error"))
                    }
                } else if totalSum == ownerPercentage {
                    let shouldEnable = intPercentage >= 25 && intPercentage <= 100
                    footerView.btnApply.isEnabled = shouldEnable
                } else {
                    if ownerPercentage > 0 {
                        let raimaining = totalSum - ownerPercentage
                        let shouldEnable = raimaining >= 25 && raimaining <= 100 && intPercentage >= 25 && intPercentage <= 100 && totalPercentage <= 100
                        footerView.btnApply.isEnabled = shouldEnable
                    } else {
                        let raimaining = totalSum - intPercentage
                        let shouldEnable = raimaining >= 25 && raimaining <= 100 && intPercentage >= 25 && intPercentage <= 100 && totalPercentage <= 100
                        footerView.btnApply.isEnabled = shouldEnable
                    }
                }
            } else {
                let shouldEnable = intPercentage >= 25 && intPercentage <= 100 && totalPercentage <= 100
                footerView.btnApply.isEnabled = shouldEnable
            }
        } else {
            self.txtPercentage.text = ""
            self.textFieldContainer.isHidden = true
            footerView.btnApply.isEnabled = true
        }
    }
}

// MARK: - IBActions
extension AddOwnershipPercentageVC {
    @IBAction func btnNextClicked(_:UIButton) {
		if ownerFlow == .additionalOwner {
			createOwner()
		} else {
			callUpdateOwnerAPI()
		}
    }

    @IBAction func percentageSwitchValueChanged(_ : Any) {
        isHavingPercentage = !isHavingPercentage
    }
}

// MARK: - API
extension AddOwnershipPercentageVC {
    func createOwner() {
        if let businessId = AppGlobalData.shared().businessData?.id {
            var postBody = CreateOwnerRequestbody()
            var person = PersonResponseBody()
            person.firstName = detailsModel.firstName
            person.lastName = detailsModel.lastName
            person.phone = detailsModel.phone
            
            if let dateofb = detailsModel.dob {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                if let dob = dateFormatter.date(from: dateofb) {
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let birthDate = dateFormatter.string(from: dob)
                    person.dateOfBirth = birthDate
                }
            }
            
            person.email = detailsModel.email
            person.idType = detailsModel.idType?.rawValue
            person.idNumber = (detailsModel.idType == .passport) ? detailsModel.ssn  : detailsModel.ssn?.plainNumberString
            person.address = addressData
            
            postBody.ownership = txtPercentage.text ?? "0"
            postBody.businessId = businessId
            postBody.person = person
            
            self.activityIndicatorBegin()
            OwnerViewModel.shared.createNewOwner(ownerData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let error = errorMessage {
                        self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                    } else {
                        if let oId = response?.id {
                            self.additionalOwnerId = oId
                            self.navigationController?.backToViewController(viewController: OwnersListVC.self)
                        }
                    }
                }
            }
        }
    }
    
    func callUpdateOwnerAPI() {
        // Api call for update Owner
        var postBody = UpdateOwnerRequestbody()
        if let _ = AppGlobalData.shared().businessData?.id, let ownerID = AppGlobalData.shared().ownerData.id {
            // postBody.businessId = businessId
            postBody.ownership = (percentageSwitch.isOn) ? txtPercentage.text : "0"
            self.activityIndicatorBegin()
            OwnerViewModel.shared.updateOwner(ownerId: ownerID, ownerData: postBody) { (_, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    self.goToOwnersListVC()
                }
            }
        }
    }
}
