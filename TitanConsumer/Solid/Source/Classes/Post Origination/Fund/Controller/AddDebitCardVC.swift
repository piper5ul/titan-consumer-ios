//
//  AddDebitCardVC.swift
//  Solid
//
//  Created by Solid iOS Team on 17/08/22.
//

import Foundation
import UIKit

class AddDebitCardVC: BaseVC {
	@IBOutlet weak var txtCardNumber: BaseTextField!
	@IBOutlet weak var txtexpirationDate: BaseTextField!

    @IBOutlet weak var lblCardNumber: UILabel!
    @IBOutlet weak var lblCardExpDate: UILabel!

	var cardData: CardModel?
    
	override func viewDidLoad() {
		super.viewDidLoad()
        setInitialUI()
		setNavigationBar()

        self.setFooterUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigationBarHidden = false
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "next"))
        footerView.btnApply.addTarget(self, action: #selector(addDebitCard), for: .touchUpInside)
        self.footerView.btnApply.isEnabled = false
    }

    func setInitialUI() {
        lblCardNumber.font = UIFont.sfProDisplayRegular(fontSize: 13)
        lblCardExpDate.font = UIFont.sfProDisplayRegular(fontSize: 13)

        lblCardNumber.textColor = UIColor.secondaryColorWithOpacity
        lblCardExpDate.textColor = UIColor.secondaryColorWithOpacity

        lblCardNumber.text = Utility.localizedString(forKey: "card_number")
        lblCardExpDate.text = Utility.localizedString(forKey: "expiry")
    }

	func setNavigationBar() {
        addBackNavigationbarButton()
		self.title = Utility.localizedString(forKey: "link_debitCard_title")
	}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ActivateCardSuccessScreen {
            destinationVC.cardData = self.cardData
        }
    }
    
    @objc func addDebitCard() {
        self.view.endEditing(true)
        createContact()
    }

    func goToActivateCardSuccessVC() {
        self.performSegue(withIdentifier: "gotoSuccesfulactivation", sender: self)
    }
}

extension AddDebitCardVC: UITextFieldDelegate {

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else {
			return false
		}
		var canChange = true
		let completeText = (text as NSString).replacingCharacters(in: range, with: string)
		 if textField == txtexpirationDate {
			canChange = completeText.count <= Constants.expiryCount
			if text.count == 2 && canChange && string.count > 0 {
				textField.text = text + "/"
            } else {
                textField.text = completeText
            }

			if completeText.count >= Constants.expiryCount && txtCardNumber.text!.count == Constants.cardNumberLimit {
                self.footerView.btnApply.isEnabled = true
			} else {
                self.footerView.btnApply.isEnabled = false
			}
		} else if textField == txtCardNumber {
			canChange = completeText.count <= Constants.cardNumberLimit
			canChange = canChange && completeText.isNumber()

			if completeText.count == Constants.cardNumberLimit && txtexpirationDate.text!.count >= Constants.expiryCount {
                self.footerView.btnApply.isEnabled = true
			} else {
                self.footerView.btnApply.isEnabled = false
			}
		}
		return canChange
	}

	func validate() {
		let strCardNo = txtCardNumber.text
		let strExpiry = txtexpirationDate.text
		let ecount = Constants.expiryCount - 1

		if strCardNo?.count == Constants.cardNumberLimit && strExpiry?.count == ecount {
            self.footerView.btnApply.isEnabled = true
		} else {
            self.footerView.btnApply.isEnabled = false
		}
	}
}

extension AddDebitCardVC {
    func createContact() {
        var postBody = ContactDataModel()
        postBody.accountId = AppGlobalData.shared().accountData?.id
        postBody.name = AppGlobalData.shared().personData.name
        postBody.phone = AppGlobalData.shared().personData.phone
        postBody.email = AppGlobalData.shared().personData.email
        
        var contactAddress = Contactaddress()
        var addressData = Address()
        addressData = AppGlobalData.shared().personData.address ?? Address()
        addressData.addressType = "card"
        contactAddress.address = addressData
        postBody.card = contactAddress
        
        self.activityIndicatorBegin()
        ContactViewModel.shared.createNewContact(contactData: postBody) { (response, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let contactRes = response {
                    self.getAddDebitCardToken(contactId: contactRes.id ?? "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil, userInfo: nil)
                }
            }
        }
    }
    
    func getAddDebitCardToken(contactId: String) {
        self.activityIndicatorBegin()

        FundViewModel.shared.getAddDebitCardToken(contactId: contactId) { (response, errorMessage) in
            self.activityIndicatorEnd()

            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body)
                self.deleteLinkedAccount(contactID: contactId)
            } else {
                if let token = response?.debitCardToken {
                    self.vgsAddDebitCard(withToken: token, contactId: contactId)
                }
            }
        }
    }
    
    func vgsAddDebitCard(withToken: String, contactId: String) {
        var vgsDebit = VGSDebitCardData()
        vgsDebit.cardNumber = self.txtCardNumber.text?.trim

        if let strExpiry = self.txtexpirationDate.text?.trim {
            let fullDateArr = strExpiry.components(separatedBy: "/")
            vgsDebit.expiryMonth = fullDateArr[0]
            vgsDebit.expiryYear = fullDateArr[1]
        }

        var addressData = Address()
        addressData = AppGlobalData.shared().personData.address ?? Address()
        addressData.addressType = ""
        vgsDebit.address = addressData
        
        self.activityIndicatorBegin()
        
        FundViewModel.shared.callVGSAddDebitCard(contactId: contactId, cardSdToken: withToken, cardData: vgsDebit) { result, error in
            self.activityIndicatorEnd()

            if let isSuccess = result, isSuccess {
                self.popVC()
            } else if let errorMsg = error {
                self.showAlertMessage(titleStr: "", messageStr: errorMsg)
                self.deleteLinkedAccount(contactID: contactId)
            }
        }
    }
    
    func deleteLinkedAccount(contactID: String) {
        self.activityIndicatorBegin()
        ContactViewModel.shared.deleteContact(contactId: contactID) { (_, _) in
            self.activityIndicatorEnd()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil, userInfo: nil)
         }
    }
}
