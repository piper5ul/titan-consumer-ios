//
//  CreateCardSuccessVC.swift
//  Solid
//
//  Created by Solid iOS Team on 08/03/21.
//

import UIKit

class CreateCardSuccessVC: BaseVC {

    @IBOutlet weak var imgV: UIImageView!
	@IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblCardDetails: UITableView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!

    var cardData: CardModel?
    var dataSource: [CardRowData]?
    let dataHandler = CardDataHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUI()
        setData()
        self.setFooterUI()
        self.addCloseButton()
    }

    func setUI() {
        isScreenModallyPresented = true
        self.isNavigationBarHidden = true

		vwAnimationContainer?.animationFile = "success"

        lblTitle.font = UIFont.sfProDisplayRegular(fontSize: 24)
        lblTitle.textColor = UIColor.primaryColor
        lblTitle.textAlignment = .center

		let descFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        lblDesc.font = descFont
        lblDesc.textColor = UIColor.secondaryColorWithOpacity
        lblDesc.textAlignment = .center

        if cardData?.cardType == CardType.physical {
            lblTitle.text = Utility.localizedString(forKey: "physicalCardSuccess_title")
            lblDesc.text = Utility.localizedString(forKey: "cardSuccess_desc")
        } else {
            lblTitle.text = Utility.localizedString(forKey: "virtualCardSuccess_title")
            lblDesc.text = ""
        }

        tblCardDetails.cornerRadius = Constants.cornerRadiusThroughApp
        tblCardDetails.layer.masksToBounds = true
        tblCardDetails.borderColor = .customSeparatorColor
        tblCardDetails.borderWidth = 1
    }

    func setData() {
        generateTableViewData()
    }

    func generateTableViewData() {
        if let card = cardData {
            dataHandler.dataSource.removeAll()
            dataHandler.createCardSuccessDataSource(card)
            self.tblCardDetails.reloadData()
        }
    }

    func setFooterUI() {
        shouldShowFooterView = true
        let btnTitle = cardData?.cardType == .physical ? Utility.localizedString(forKey: "card_activate_Title") : Utility.localizedString(forKey: "cardInfo_row_title_details")
        footerView.configureButtons(rightButtonTitle: btnTitle)
        footerView.btnApply.addTarget(self, action: #selector(doneClick(_:)), for: .touchUpInside)
    }
    
    @IBAction func doneClick(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterAdding), object: nil)
        self.isNavigationBarHidden = false

        let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)

        if cardData?.cardType == .physical {
            if let vc = storyboard.instantiateViewController(withIdentifier: "CardActivationVC") as? CardActivationVC {
                vc.cardData = self.cardData
                self.show(vc, sender: self)
            }
        } else {
            if let vc = storyboard.instantiateViewController(withIdentifier: "CardInfoVC") as? CardInfoVC {
                vc.cardModel = self.cardData
                self.show(vc, sender: self)
            }
        }
    }
    
    @objc override func closeClicked(sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterAdding), object: nil)

        self.isNavigationBarHidden = false
        
        if self.navigationController?.children.filter({ $0.isKind(of: CardsListVC.self)}).count != 0 {
            self.navigationController?.backToViewController(viewController: CardsListVC.self)
        } else {
            self.navigationController?.backToViewController(viewController: DashboardVC.self)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColorWithOpacity
    }
}

extension CreateCardSuccessVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        self.tblCardDetails.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataHandler.dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = dataHandler.dataSource
        return section < dataSource.count ? dataSource[section].count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell {
            let rowData = dataHandler.dataSource[indexPath.section][indexPath.row] as CardRowData
            cell.configureCardCell(forRow: rowData, hideSeparator: true)
            if indexPath.row == dataHandler.dataSource[indexPath.section].count - 1 {
                cell.imgSeperator.isHidden = true
            }
            
            cell.selectionStyle = .none
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tblHeightConstraint.constant = self.tblCardDetails.contentSize.height
    }
}
