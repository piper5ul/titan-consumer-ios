//
//  OwnersListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 23/02/21.
//

import UIKit

class OwnersListVC: BaseVC {
    @IBOutlet weak var tblOwners: UITableView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var descBottomConstraint: NSLayoutConstraint!

    var arrOwnersList = [OwnerDataModel]()
    var totalPercentage: Int = 0

    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var arrControlPersonData = [ControlPersonData]()
    var noOfSections = 1
    
    var shouldGetOwnershipDisclosureLink = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.registerCellsAndHeaders()
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            let bottomConst = Utility.isDeviceIpad() ? 110.0 : 75.0
            descBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : bottomConst
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.activityIndicatorBegin()
		self.getOwners { (_, _) in
			self.activityIndicatorEnd()
            self.setFooterUI()
			self.setUI()
            self.setData()
			self.tblOwners.reloadData()
		}
	}
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(btnDoneClicked(_:)), for: .touchUpInside)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblDesc.textColor = UIColor.secondaryColor
    }
    
    @objc override func handleKeyboardEvent(keyboardHeight: CGFloat) {
        var bdcFrame = footerView.frame
        var bdcY: CGFloat = footerView.frame.origin.y
        let navBarHeight = self.getNavigationbarHeight()
        UIView.animate(withDuration: 0.2) {
            bdcY = keyboardHeight > 0 ? UIScreen.main.bounds.size.height - keyboardHeight - navBarHeight - Constants.keyboardUpSpace : UIScreen.main.bounds.size.height - Constants.footerViewHeight - navBarHeight
            bdcFrame.origin.y = bdcY
            self.footerView.frame = bdcFrame
            self.view.layoutIfNeeded()
            
            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardHeight + Constants.footerViewHeight/1.5), right: 0.0)
            self.tblOwners.contentInset = contentInsets
            self.tblOwners.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblOwners.scrollIndicatorInsets = self.tblOwners.contentInset
        }
    }
}

// MARK: - Set UI and Data
extension OwnersListVC {
    func setUI() {
        arrOwnersList = AppGlobalData.shared().ownerList
        tblOwners.reloadData()

        let totalSum = arrOwnersList.map({Double($0.ownership ?? "0.0") ?? 0.0}).reduce(0, +)
        totalPercentage = Int(totalSum)

        let strTitle = Utility.localizedString(forKey: "next")
        footerView.btnApply.setTitle(strTitle, for: .normal)

        let descFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12
        lblDesc.font = descFont
        lblDesc.textColor = UIColor.secondaryColor
        lblDesc.textAlignment = .center
        lblDesc.text = Utility.localizedString(forKey: "addOwnerPercentage_Descriptions")

        showHideAddOwnerView()
    }

    func showHideAddOwnerView() {
        if totalPercentage > 75 || AppGlobalData.shared().businessData?.entityType?.isSoleSingleEntitiy ?? false {
            noOfSections = 1
        } else {
            noOfSections = 2
        }
    }
    
    func setData() {
        let controlPerson = AppGlobalData.shared().ownerList.filter({ $0.isControlPerson == true})

        arrControlPersonData = [ControlPersonData]()

        for owner in AppGlobalData.shared().ownerList {
            var isControlPerson = false
            if AppGlobalData.shared().businessData?.entityType?.isSoleSingleEntitiy ?? false {
                isControlPerson = true
            } else {
                isControlPerson = (controlPerson.count == 0 && (owner.id == AppGlobalData.shared().ownerData.id)) ? true : owner.isControlPerson ?? false
            }
            
            var controlPersonData = ControlPersonData()
            controlPersonData.ownerId = owner.id ?? ""
            controlPersonData.isControlPerson = isControlPerson
            controlPersonData.designation = owner.designation ?? OwnerDesignationType.unknown
            controlPersonData.title = owner.title ?? ""
            arrControlPersonData.append(controlPersonData)
        }
        
        validate()
    }
    
    func validate() {
        if self.isAllDesignationsSelected() {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
    
    func isAllDesignationsSelected() -> Bool {
        var isControlPersonChecked = false
        for owner in arrControlPersonData {
            if owner.isControlPerson ?? false {
                isControlPersonChecked = true
            }
        }
                
        for owner in arrControlPersonData {
            let designation = owner.designation ?? .unknown
            let title = owner.title ?? ""

            if designation == .unknown || (designation == .other && title.isEmpty) || !isControlPersonChecked {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Navigation
extension OwnersListVC {
    func setNavigationBar() {
        self.title = Utility.localizedString(forKey: "ownerList_NavTitle")
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

		addBackNavigationbarButton()
    }

    @objc override func backClick() {
        self.popVC()
    }

    func goToAdditionalOwnerDetailsVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AdditionalOwnerDetailsVC") as? AdditionalOwnerDetailsVC {
            self.show(vc, sender: self)
			self.modalPresentationStyle = .fullScreen
        }
    }
    
    func goToDocuSignVC(signUrl: String) {
        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DocuSignVC") as? DocuSignVC {
            vc.signUrl = signUrl
            self.show(vc, sender: self)
            self.modalPresentationStyle = .fullScreen
        }
    }
}

// MARK: - IBActions
extension OwnersListVC {
    @IBAction func btnDoneClicked(_:UIButton) {
        if shouldGetOwnershipDisclosureLink {
            getOwnershipDisclosureLink()
        } else {
            callUpdateOwnersAPI(isFromAddOwnerClick: false)
        }
    }
}

// MARK: - API
extension OwnersListVC {
    // Api call for update Owners
    func callUpdateOwnersAPI(isFromAddOwnerClick: Bool) {
        if self.arrOwnersList.count > 0 {
            let dispatchGroup = DispatchGroup()
            self.activityIndicatorBegin()
            for aOwner in self.arrControlPersonData {
                dispatchGroup.enter()
                let ownerID = aOwner.ownerId ?? ""

                var postBody = UpdateOwnerRequestbody()
                postBody.businessId = AppGlobalData.shared().businessData?.id ?? ""
                postBody.designation = aOwner.designation ?? .unknown
                postBody.title = aOwner.title ?? ""
                postBody.isControlPerson = aOwner.isControlPerson ?? false

                if AppGlobalData.shared().businessData?.entityType?.isSoleSingleEntitiy ?? false {
                    postBody.ownership = "100"
                }
                
                OwnerViewModel.shared.updateOwner(ownerId: ownerID, ownerData: postBody) { (_, errorMessage) in
                    DispatchQueue.main.async {
                        dispatchGroup.leave()
                        
                        if let error = errorMessage {
                            self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.activityIndicatorEnd()
                if isFromAddOwnerClick {
                    self.goToAdditionalOwnerDetailsVC()
                } else {
                    self.submitKYCForAdditionalOwners()
                }
            }
        }
    }
    
	func submitKYCForAdditionalOwners() {
		if self.arrOwnersList.count > 1 {
			let dispatchGroup = DispatchGroup()
			self.activityIndicatorBegin()
			for (_, aMember) in self.arrOwnersList.enumerated() {
				if aMember.person?.kyc?.status != .submitted && aMember.person?.kyc?.status != .approved {
					let postBody = KYCOwnerRequestbody()
					dispatchGroup.enter()
					OwnerViewModel.shared.submitOwnerKyc(ownerId: aMember.id!, ownerData: postBody) { (_, _) in
						DispatchQueue.main.async {
							dispatchGroup.leave()
						}
					}
				}
			}

			dispatchGroup.notify(queue: .main) {
			    self.activityIndicatorEnd()
                Segment.addSegmentEvent(name: .proceedSign)
                
                if AppGlobalData.shared().businessData?.entityType == .soleproprietor {
                    self.submitKYB()
                } else {
                    self.getOwnershipDisclosureLink()
                }
			}
		} else {
            Segment.addSegmentEvent(name: .proceedSign)
            if AppGlobalData.shared().businessData?.entityType == .soleproprietor {
                self.submitKYB()
            } else {
                self.getOwnershipDisclosureLink()
            }
		}
	}

    func getOwnershipDisclosureLink() {
        if let bId = AppGlobalData.shared().businessData?.id {
            self.activityIndicatorBegin()
            KYBViewModel.shared.getOwnershipDisclosureLink(businessId: bId) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let data = response, let disStatus = data.status {
                    if let disLink = data.url, !disLink.isEmpty {
                        self.shouldGetOwnershipDisclosureLink = (disStatus != .completed)
                        self.goToDocuSignVC(signUrl: disLink)
                    } else if disStatus == .pending {
                        self.generateOwnershipDisclosureLink()
                    }
                } else if let error = errorMessage {
                    if error.errorCode == "EC_BUSINESS_AGREEMENT_NOT_FOUND" {
                        self.generateOwnershipDisclosureLink()
                    } else {
                        self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                    }
                }
            }
        }
    }
    
    //To generate Disclosure document
    func generateOwnershipDisclosureLink() {
        if let bId = AppGlobalData.shared().businessData?.id {
            var disclosureRequestBody = OwnershipDisclosureRequestBody()
            disclosureRequestBody.action = "regenerate"
            disclosureRequestBody.redirectUri = "https://" + Config.DocuSign.docuSignHost + "/e-sign-mobile"
            disclosureRequestBody.frameancestor = "https://" + Config.DocuSign.docuSignHost
            
            self.activityIndicatorBegin()
            KYBViewModel.shared.generateOwnershipDisclosureLink(businessId: bId, disclosureRequest: disclosureRequestBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let data = response, let disStatus = data.status, let disLink = data.url, !disLink.isEmpty {
                    self.shouldGetOwnershipDisclosureLink = (disStatus != .completed)
                    self.goToDocuSignVC(signUrl: disLink)
                } else if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                }
            }
        }
    }
    
    //To submit KYB
    func submitKYB() {
        var postBody = SubmitBusinessPostBody()
        postBody.phone = AppGlobalData.shared().businessData?.phone
        postBody.email = AppGlobalData.shared().businessData?.email
        postBody.idNumber = AppGlobalData.shared().businessData?.idNumber
        postBody.idType = TaxType.ein.rawValue
        postBody.address = AppGlobalData.shared().businessData?.address
        
        self.activityIndicatorBegin()
        KYBViewModel.shared.submitKyb(businessId: AppGlobalData.shared().businessData?.id ?? "", businessData: postBody) { (_, errorMessage) in
            self.activityIndicatorEnd()
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                self.gotoKYBStatusScreen(aKybStatus: AppGlobalData.shared().businessData?.kyb?.status ?? .unknown, aBusinessData: AppGlobalData.shared().businessData ?? BusinessDataModel())
            }
        }
    }
}

// MARK: - OwnerListCellDelegate
extension OwnersListVC: OwnerListCellDelegate {
    func ownerListCell(cell: OwnerListCell, begin cd: BaseTextField?) {
        guard let indexPath = self.tblOwners.indexPath(for: cell) else {return}
        
        self.scrollToIndexPath = indexPath
    }

    //FOR IS CONTROL PERSON CHECK
    func controlPersonCheck(forIndexPath: IndexPath, isSelected: Bool?) {
        arrControlPersonData[forIndexPath.row].isControlPerson = isSelected
        resetIsControlPersonForOthers(exceptIndex: forIndexPath.row)
        tblOwners.reloadData()
        
        validate()
    }
    
    //FOR DESIGNATION PICKER
    func selectedDesignation(forIndexPath: IndexPath, selectedData: ListItems?) {
        arrControlPersonData[forIndexPath.row].designation = OwnerDesignationType.entityType(for: selectedData?.id ?? "unknown")
        arrControlPersonData[forIndexPath.row].title = ""

        if arrControlPersonData[forIndexPath.row].designation != .other {
            arrControlPersonData[forIndexPath.row].title = OwnerDesignationType.title(for: selectedData?.id ?? "unknown")
        }

        tblOwners.reloadRows(at: [forIndexPath], with: .none)
        
        validate()
    }
    
    //FOR ENTERED TITLE
    func enteredTitle(forIndexPath: IndexPath, changed data: String?) {
        arrControlPersonData[forIndexPath.row].title = data
        
        validate()
    }
    
    //RESET isControlPerson TO FALSE FOR OTHER OWNERS
    func resetIsControlPersonForOthers(exceptIndex: Int) {
        for (atIndex, _) in arrControlPersonData.enumerated() {
            if atIndex != exceptIndex {
                arrControlPersonData[atIndex].isControlPerson = false
                arrControlPersonData[atIndex].title = ""
                arrControlPersonData[atIndex].designation = .unknown
            } else {
                arrControlPersonData[atIndex].title = ""
                arrControlPersonData[atIndex].designation = .unknown
            }
        }
        
        tblOwners.reloadData()
    }
}

// MARK: - UITableView
extension OwnersListVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblOwners.register(UINib(nibName: "OwnerListCell", bundle: .main), forCellReuseIdentifier: "OwnerListCell")
        self.tblOwners.register(UINib(nibName: "DataActionCell", bundle: .main), forCellReuseIdentifier: "DataActionCell")
        self.tblOwners.register(UINib(nibName: "SectionHeader", bundle: .main), forHeaderFooterViewReuseIdentifier: "SectionHeader")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return noOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 1 : arrOwnersList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightValForOther = Utility.isDeviceIpad() ? 320.0 : 270.0
        let heightValForNonOther = Utility.isDeviceIpad() ? 225.0 : 195.0
        let section0RowHeight: CGFloat = arrControlPersonData[indexPath.row].designation == .other ? heightValForOther : heightValForNonOther
        return indexPath.section == 1 ? 70 : section0RowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath as IndexPath) as! DataActionCell
            
            cell.lblTitle.text = Utility.localizedString(forKey: "ownerList_AddNew_SubTitle")
            cell.lblValue.text = ""
            
            cell.showDetailIcon(shouldShow: true)

            let titleFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize18
            cell.lblTitle.font = titleFont
            cell.lblTitle.textColor = UIColor.primaryColor
            cell.titleBottomConstraint.constant = -10

            cell.innerView.cornerRadius = Constants.cornerRadiusThroughApp
            cell.innerView.layer.masksToBounds = true
            cell.innerView.borderColor = .customSeparatorColor
            cell.innerView.borderWidth = 1
            
            cell.detailIcon.image = UIImage(named: "Chevron-right")
            
            cell.selectionStyle = .none

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OwnerListCell", for: indexPath as IndexPath) as! OwnerListCell
            cell.delegate = self
            cell.indexPath = indexPath
            
            if let model = arrOwnersList[indexPath.row] as OwnerDataModel? {
                let arrDesignation = OwnerDesignationType.ownerDesignations
                let arrControlPersonDesignation = OwnerDesignationType.controlPersonDesignations
                
                let ownerDesignation = arrControlPersonData[indexPath.row].designation
                cell.titleView?.isHidden = (ownerDesignation != .other || ownerDesignation == .unknown)
                cell.txtDesignation?.text = OwnerDesignationType.title(for: ownerDesignation?.rawValue ?? "")
                
                let ownerTitle = arrControlPersonData[indexPath.row].title
                cell.txtTitle?.text = ownerTitle

                let ownerIsControlPerson = arrControlPersonData[indexPath.row].isControlPerson ?? false
                cell.isCheckboxSelected = ownerIsControlPerson
                if AppGlobalData.shared().businessData?.entityType?.isSoleSingleEntitiy ?? false {
                    cell.btnControlPersonCheck?.isUserInteractionEnabled = false
                    cell.btnControlPersonCheck?.alpha = 0.5
                }
                
                cell.arrPickerData = ownerIsControlPerson ? arrControlPersonDesignation : arrDesignation

                let strFName = model.person?.firstName ?? ""
                let strLName = model.person?.lastName ?? ""
                var strPercentage: String = ""
                
                if AppGlobalData.shared().businessData?.entityType?.isSoleSingleEntitiy ?? false {
                    strPercentage = "100" + "%"
                } else {
                    strPercentage = (model.ownership ?? "0") + "%"
                }

                cell.lblName?.text = "\(strFName) \(strLName)"
                cell.lblPercentage?.text = strPercentage
            }

            cell.selectionStyle = .none
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        sectionHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20)

        sectionHeader.lblSectionHeader.text = section == 0 ? Utility.localizedString(forKey: "ownerList_HeaderTitle") : Utility.localizedString(forKey: "ownerList_AddNew_HeaderTitle")
        sectionHeader.lblSectionHeader.font = Constants.commonFont
        
        sectionHeader.lblSectionHeader.leftAnchor.constraint(equalTo: sectionHeader.leftAnchor, constant: 0).isActive = true
        sectionHeader.lblSectionHeader.rightAnchor.constraint(equalTo: sectionHeader.rightAnchor).isActive = true
        sectionHeader.lblSectionHeader.topAnchor.constraint(equalTo: sectionHeader.topAnchor, constant: 0).isActive = true
        sectionHeader.lblSectionHeader.bottomAnchor.constraint(equalTo: sectionHeader.bottomAnchor).isActive = true

        sectionHeader.backgroundColor = .background
        sectionHeader.contentView.backgroundColor = .background
        
        sectionHeader.layoutIfNeeded()
        
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            callUpdateOwnersAPI(isFromAddOwnerClick: true)
        }
    }
}
