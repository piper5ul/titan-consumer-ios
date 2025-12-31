//
//  SendPaymentOptionVC.swift
//  Solid
//  Created by Solid iOS Team on 3/25/21.

import Foundation
import SkeletonView

import UIKit
class SendPaymentOptionVC: BaseVC {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var lblTitle: UILabel!
	var dataSource = [[ContactRowData]]()
	var contactData: ContactDataModel?
	var accType: ContactAccountType?

	override func viewDidLoad() {
		super.viewDidLoad()
		//self.view.showAnimatedGradientSkeleton()
		setupInitialUI()
		setupInitialData()
	}

}

// MARK: - Navigationbar
extension SendPaymentOptionVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        addBackNavigationbarButton()
    }
    
    func setupInitialUI() {
        self.title = Utility.localizedString(forKey: "transfer_fund_title")
        lblTitle.font = Constants.commonFont
        lblTitle.textColor = UIColor.primaryColor
        lblTitle.text = Utility.localizedString(forKey: "payment_method_option")
        
        setNavigationBar()
        registerCell()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
    }
    
    func setupInitialData() {
        createTableData()
        tableView.reloadData()
    }
    
    func registerCell() {
        tableView.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
        tableView.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil), forCellReuseIdentifier: "SkeletonLoaderCell")
    }
    
    func createTableData() {
        if let _ = self.contactData {
            
            if let isSendMoneyIntraBankEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isSendMoneyIntraBankEnabled, isSendMoneyIntraBankEnabled {
                var section1 = [ContactRowData]()
                var row1 = ContactRowData()
                row1.key = ContactAccountType.intrabank.getTitleKey()
                row1.value = ""
                section1.append(row1)
                dataSource.append(section1)
            }
            
            if let isSendMoneyCheckEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isSendMoneyCheckEnabled, isSendMoneyCheckEnabled {
                var section2 = [ContactRowData]()
                var row2 = ContactRowData()
                row2.key = ContactAccountType.check.getTitleKey()
                row2.value = ""
                section2.append(row2)
                dataSource.append(section2)
            }
            
            if let isSendMoneyACHEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isSendMoneyACHEnabled, isSendMoneyACHEnabled {
                var section3 = [ContactRowData]()
                var row3 = ContactRowData()
                row3.key = ContactAccountType.ach.getTitleKey()
                row3.value = ""
                section3.append(row3)
                dataSource.append(section3)
            }
            
            if let isSendMoneyDomesticwireEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isSendMoneyDomesticwireEnabled, isSendMoneyDomesticwireEnabled {
                var section4 = [ContactRowData]()
                var domesticWire = ContactRowData()
                domesticWire.key = ContactAccountType.domesticWire.getTitleKey()
                domesticWire.value = ""
                section4.append(domesticWire)
                dataSource.append(section4)
            }
            
            var section5 = [ContactRowData]()
            var internationalWire = ContactRowData()
            internationalWire.key = ContactAccountType.internationalWire.getTitleKey()
            internationalWire.value = ""
            section5.append(internationalWire)
            dataSource.append(section5)
            
            if let isSendMoneyVisaCardEnabled = AppMetaDataHelper.shared.config?.validateFlag?.isSendMoneyVisaCardEnabled, isSendMoneyVisaCardEnabled {
                var section6 = [ContactRowData]()
                var sendVisaCard = ContactRowData()
                sendVisaCard.key = ContactAccountType.sendVisaCard.getTitleKey()
                sendVisaCard.value = ""
                section6.append(sendVisaCard)
                dataSource.append(section6)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableView
extension SendPaymentOptionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
            let rows = dataSource[indexPath.section]
            let rowData = rows[indexPath.row] as ContactRowData
            cell.configureAccountTypeCell(forRow: rowData, hideSeparator: true)
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedType = dataSource[indexPath.section][indexPath.row].key {
            if let _ = self.contactData {
                switch selectedType {
                case ContactAccountType.intrabank.getTitleKey():
                    self.contactData?.selectedPaymentMode = .intrabank
                    goToIntrabankPaymentVC()
                    
                case ContactAccountType.ach.getTitleKey():
                    self.contactData?.selectedPaymentMode = .ach
                    goToACHPaymentVC()
                    
                case ContactAccountType.check.getTitleKey():
                    self.contactData?.selectedPaymentMode = .check
                    goToCheckVC()
                    
                case ContactAccountType.domesticWire.getTitleKey():
                    self.contactData?.selectedPaymentMode = .domesticWire
                    goToCheckVC()
                    
                case ContactAccountType.internationalWire.getTitleKey():
                    self.contactData?.selectedPaymentMode = .internationalWire
                    goToCheckVC()
                    
                case ContactAccountType.sendVisaCard.getTitleKey():
                    self.contactData?.selectedPaymentMode = .sendVisaCard
                    goToSendCard()
                    
                default:
                    break
                }
            }
        }
    }
    
    func gotoIntrabankPay() {
        self.performSegue(withIdentifier: "openIntrabankoption", sender: self)
    }
    
    func goToACHPaymentVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "ACHPaymentVC") as? ACHPaymentVC {
            destinationVC.contactData = self.contactData
            self.show(destinationVC, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    func goToIntrabankPaymentVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "IntrabankPaymentVC") as? IntrabankPaymentVC {
            destinationVC.contactData = self.contactData
            self.show(destinationVC, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    func goToCheckVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "CheckPaymentVC") as? CheckPaymentVC {
            destinationVC.contactData = self.contactData
            self.show(destinationVC, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    func goToSendCard() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "SendCardPayment") as? SendCardPayment {
            destinationVC.contactData = self.contactData
            self.show(destinationVC, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    func goToContactDetailsVC() {
        let storyboard = UIStoryboard.init(name: "Contact", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ContactDetailsVC") as? ContactDetailsVC {
            vc.contactData = self.contactData
            vc.contactFlow = .edit
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }
}

extension SendPaymentOptionVC: SkeletonTableViewDataSource {
	func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "SkeletonLoaderCell"
	}
	func numSections(in collectionSkeletonView: UITableView) -> Int {
		return 1
	}
	func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let screenRectHeight = UIScreen.main.bounds.height
		return Int(screenRectHeight/78)
	}
}
