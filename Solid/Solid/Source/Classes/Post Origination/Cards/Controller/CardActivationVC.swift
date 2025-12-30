//
//  CardActivationVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/10/21.
//

import Foundation
import UIKit

class CardActivationVC: BaseVC {
    @IBOutlet weak var txtLast4: BaseTextField!
    @IBOutlet weak var txtexpirationDate: BaseTextField!
    
    @IBOutlet weak var lblCardLast4: UILabel!
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
        footerView.configureButtons(rightButtonTitle: Utility.localizedString(forKey: "card_activate"))
        footerView.btnApply.addTarget(self, action: #selector(activateCard), for: .touchUpInside)
        self.footerView.btnApply.isEnabled = false
    }
    
    func setInitialUI() {
        lblCardLast4.font = UIFont.sfProDisplayRegular(fontSize: 13)
        lblCardExpDate.font = UIFont.sfProDisplayRegular(fontSize: 13)
        
        lblCardLast4.textColor = UIColor.secondaryColorWithOpacity
        lblCardExpDate.textColor = UIColor.secondaryColorWithOpacity
        
        lblCardLast4.text = Utility.localizedString(forKey: "card_activate_last4_lable")
        lblCardExpDate.text = Utility.localizedString(forKey: "card_activate_expDate_lable")
    }
    
    func setNavigationBar() {
        addBackNavigationbarButton()
        self.title = Utility.localizedString(forKey: "card_activate_Title")
    }
    
    override func backClick() {
        if self.navigationController?.children.filter({ $0.isKind(of: CardsListVC.self)}).count != 0 {
            self.navigationController?.backToViewController(viewController: CardsListVC.self)
        } else {
            self.navigationController?.backToViewController(viewController: DashboardVC.self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ActivateCardSuccessScreen {
            destinationVC.cardData = self.cardData
        }
    }
    
    @objc func activateCard() {
        self.view.endEditing(true)
        var postBody = CardActivateRequestBody()
        if let dateText = txtexpirationDate.text {
            postBody.expiryMonth = String(dateText.prefix(2))
            postBody.expiryYear = String(dateText.suffix(4))
        }
        postBody.last4 = txtLast4.text
        if let cardId = cardData?.id {
            self.activityIndicatorBegin()
            CardViewModel.shared.activateCard(cardID: cardId, cardData: postBody) { (_, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    self.goToActivateCardSuccessVC()
                }
            }
        }
    }
    
    func goToActivateCardSuccessVC() {
        self.performSegue(withIdentifier: "gotoSuccesfulactivation", sender: self)
    }
}

extension CardActivationVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        var canChange = true
        let completeText = (text as NSString).replacingCharacters(in: range, with: string).trim
        
        if textField == txtexpirationDate {
            canChange = completeText.count <= Constants.expiryCount
            
            if text.count == 2 && canChange && string.count > 0 {
                textField.text = text + "/"
            } else if completeText.count <= Constants.expiryCount{
                textField.text = completeText
            }
        } else if textField == txtLast4 && completeText.isNumber() {
            textField.text = completeText.cardLast4String()
        }
        
        validate()
        
        return false
    }
    
    func validate() {
        if txtLast4.text?.count == Constants.last4Limit && txtexpirationDate.text?.count == Constants.expiryCount {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
}
