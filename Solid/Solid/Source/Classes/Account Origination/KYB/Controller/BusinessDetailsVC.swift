//
//  BusinessDetailsVC.swift
//  Solid
//
//  Created by Solid iOS Team on 12/02/21.
//

import UIKit

class BusinessDetailsVC: BaseVC, FormDataCellDelegate {
    var arrTitles = [String]()
    var arrFieldTypes = [String]()
    var arrBusinessData = [String]()
    var businessDataModel = BusinessDetailsModel()
	var businessData = BusinessDataModel()

    //FOR NAICS CODE..
    var businessSectors = [BusinessSectorType]()
    var businessSectorListIems = [ListItems]()
    var sectorGroupListIems = [ListItems]()
    var nationalIndustryListIems = [ListItems]()
    var selectedSectorCode: Int = 0
    var selectedSectorGroupCode: Int = 0
    var selectedBusinessSector: BusinessSectorType = BusinessSectorType()
    var selectedSectorGroup: IndustryGroupType = IndustryGroupType()
    var selectedIndustry: IndustryType = IndustryType()
    ///
    ///
    @IBOutlet weak var tblKYBDetails: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!

    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()
        
        registerCellsAndHeaders()
        
        self.tblKYBDetails.backgroundColor = .clear
        
        self.getBusinessSectors()
        self.setData()
        self.setBusinessData()
        
        self.setFooterUI()
        
        addProgressbar(percentage: 50)
        
        validate()
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            tblBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : 90
        }
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(checkNavigation), for: .touchUpInside)
    }

    func setData() {
        arrTitles = ["businessName", "dbaName", "entityType", "ein", "naicsCode", "selectIndustryGroup", "selectNationalIndustry" ]
        arrFieldTypes = ["alphaNumeric", "alphaNumeric", "stringPicker", "ein", "stringPicker", "stringPicker", "stringPicker"]
    }

	func setBusinessData() {
        let businessName = self.businessData.legalName ?? ""
        let dba = self.businessData.dba ?? ""
        
        var entityType = ""
        if let eType =  self.businessData.entityType {
            entityType =  BusinessEntityType.title(for: eType.rawValue)
            businessDataModel.entityType = BusinessEntityType(rawValue: BusinessEntityType.entityId(for: entityType))
        }
        
        let ein =  self.businessData.idNumber?.einFormat() ?? ""
        businessDataModel.businessName = businessName
        businessDataModel.dba = dba
        businessDataModel.ein = ein
        businessDataModel.naicsCode = self.businessData.naicsCode ?? ""
        
        getBusinessIndustry()
        
        var sector = ""
        if let name = selectedBusinessSector.name, let code = selectedSectorGroup.code {
            let strCode = String(code)
            sector = name + " (" + strCode + ")"
        }
        
        var group = ""
        if let name = selectedSectorGroup.name, let code = selectedSectorGroup.code {
            let strCode = String(code)
            group = name + " (" + strCode + ")"
        }
        
        var industry = ""
        if let name = selectedIndustry.name, let code = selectedIndustry.code {
            let strCode = String(code)
            industry = name + " (" + strCode + ")"
        }
        
        arrBusinessData = [businessName, dba, entityType, ein, sector, group, industry]
        
        self.tblKYBDetails.reloadData()
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
            self.tblKYBDetails.contentInset = contentInsets
            self.tblKYBDetails.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblKYBDetails.scrollIndicatorInsets = self.tblKYBDetails.contentInset
        }
    }
}

// MARK: - Navigationbar
extension BusinessDetailsVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true

        self.title = Utility.localizedString(forKey: "kyb_NavTitle")

        if AppGlobalData.shared().appFlow == AppFlow.PO {
            addBackNavigationbarButton()
        } else {
            self.navigationItem.setHidesBackButton(true, animated: true)
        }
    }

    @objc func checkNavigation() {
        if let bisunessID = self.businessData.id {
            self.updateBusiness(bId: bisunessID)
        } else {
            self.createBusiness()
        }
    }

    func validate() {
        if let bname = businessDataModel.businessName, !bname.isEmpty && !bname.isInvalidAddress(), let entity = businessDataModel.entityType, !entity.rawValue.isEmpty, let ein = businessDataModel.ein?.numberString, ein.count == Constants.einCodeLimit, let naics = businessDataModel.naicsCode, !naics.isEmpty, !(businessDataModel.dba?.isInvalidInput() ?? false) {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }

    func gotoETVScreen() {
        self.performSegue(withIdentifier: "GoToBusinessETVVC", sender: self)
    }
}

// MARK: - UITableView
extension BusinessDetailsVC {
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
        
        guard let indexPath = self.tblKYBDetails.indexPath(for: cell) else {return}
        
        self.scrollToIndexPath = indexPath
    }
    
    func cell (_ cell: CustomTableViewCell, editing: Any?, changed data: Any?) {
        guard let indexPath = self.tblKYBDetails.indexPath(for: cell), let text = data as? String else {return}
        
        switch indexPath.row {
        case 0: // Legal Business name
            businessDataModel.businessName = text.trim
            cell.validateEnteredAddressText(enteredText: text.trim)
            arrBusinessData[0] = text.trim
            
        case 1:// DBA name
            businessDataModel.dba = text.trim
            cell.validateEnteredText(enteredText: text.trim)
            arrBusinessData[1] = text.trim
            
        case 2:// Entity Type
            businessDataModel.entityType = BusinessEntityType(rawValue: BusinessEntityType.entityId(for: text.trim))
            arrBusinessData[2] = text.trim
            
        case 3:// EIN
            businessDataModel.ein = text.trim
            arrBusinessData[3] = text.trim
            
        default:break
        }
        
        validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func cell(shouldCelar cell: CustomTableViewCell) -> Bool {
        return false
    }
    
    //FOR NAICS CODE
    func cellWithListItem(_ cell: CustomTableViewCell, selected data: ListItems?) {
        guard let indexPath = self.tblKYBDetails.indexPath(for: cell), let selectedData = data else {return}
        
        switch indexPath.row {
        case 4:// BUSINESS SECTOR
            let code = selectedData.id
            let sectorCode: Int? = Int(code ?? "")
            selectedSectorCode = sectorCode ?? 0
            selectedSectorGroupCode = 0
            businessDataModel.naicsCode = ""
            arrBusinessData[4] = data?.title ?? ""
            arrBusinessData[5] = ""
            arrBusinessData[6] = ""
            self.setSelectedBusinessSector(sectorCode: sectorCode ?? 0)
            self.getIndustryGroupListItem()
            
        case 5:// INDUSTRY GROUP
            let code = selectedData.id
            let sectorGroupCode: Int? = Int(code ?? "")
            selectedSectorGroupCode = sectorGroupCode ?? 0
            businessDataModel.naicsCode = ""
            arrBusinessData[5] = data?.title ?? ""
            arrBusinessData[6] = ""
            self.setSelectedSectorGroup(sectorGroupCode: sectorGroupCode ?? 0)
            self.getNationalIndustryListItem()
            
        case 6:// NATIONAL INDUSTRY
            let selectedIndustryCode = selectedData.id
            businessDataModel.naicsCode = selectedIndustryCode
            arrBusinessData[6] = data?.title ?? ""
            tblKYBDetails.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
            tblKYBDetails.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .none)
            
        default:break
        }
        
        validate()
    }
}

// MARK: - UITableView
extension BusinessDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblKYBDetails.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell

        let strTitle = arrTitles[indexPath.row]
        cell.titleLabel?.text = Utility.localizedString(forKey: strTitle)
        cell.heightConstlblTitle.constant = 16.5

        cell.subTitleLabel?.isHidden = true
        cell.subTitleLabel?.text = ""
        cell.subTitleLabel?.textAlignment = .right

        cell.inputTextField?.text = arrBusinessData[indexPath.row]
		cell.inputTextField?.tag = indexPath.row
        
        cell.fieldType = arrFieldTypes[indexPath.row]

        cell.descLabel?.text = ""
        cell.inputTextField?.placeholderString = ""
        
        if strTitle == "entityType" {
            cell.arrPickerData = BusinessEntityType.dataNodes
        } else if strTitle == "naicsCode" {
            cell.arrPickerData = businessSectorListIems
            cell.inputTextField?.placeholderString = Utility.localizedString(forKey: strTitle)
            cell.subTitleLabel?.isHidden = false
            cell.subTitleLabel?.text = businessDataModel.naicsCode
            cell.subTitleLabel?.textAlignment = .right
            cell.heightConstlblTitle.constant = 55
            
            let naicsText = Utility.localizedString(forKey: "naicsCode") + Utility.localizedString(forKey: "naicsDesc") + Utility.localizedString(forKey: "naicsReadMore")
            cell.titleLabel?.text = naicsText
            let descText = Utility.localizedString(forKey: "naicsDesc")
            let readMoreText = Utility.localizedString(forKey: "naicsReadMore")
            let attriString = naicsText.getNAICSString(withDescText: descText, withLinkText: readMoreText)
            cell.titleLabel?.attributedText = attriString
            cell.titleLabel?.isUserInteractionEnabled = true
            cell.titleLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(readMore(gesture:))))
        } else if strTitle == "selectIndustryGroup" {
            cell.arrPickerData = sectorGroupListIems
            cell.inputTextField?.placeholderString = Utility.localizedString(forKey: strTitle)
            cell.titleLabel?.text = ""
            cell.heightConstlblTitle.constant = 0
        } else if strTitle == "selectNationalIndustry" {
            cell.arrPickerData = nationalIndustryListIems
            cell.inputTextField?.placeholderString = Utility.localizedString(forKey: strTitle)
            cell.titleLabel?.text = ""
            cell.heightConstlblTitle.constant = 0
        }
        
        if strTitle == "ein" {
            cell.descLabel?.text = Utility.localizedString(forKey: "ein_Message")
            if let _ = cell.bottomConstlblDesc {
                cell.bottomConstlblDesc.constant = 16
            }
        } else {
            if let _ = cell.bottomConstlblDesc {
                cell.bottomConstlblDesc.constant = 7
            }
        }
		
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 120
        }
        
        if indexPath.row == 4 {
            return 125
        }
        
        if indexPath.row == 6 || indexPath.row == 5 {
            return 70
        }
        
		let cheight: CGFloat = Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
		return cheight
    }
    
    @objc func readMore(gesture: UITapGestureRecognizer) {
        let naicsLabel = gesture.view as! UILabel
        let strNaics = naicsLabel.text! as NSString
        
        let readMoreText = Utility.localizedString(forKey: "naicsReadMore")
        let readMoreTextRange = strNaics.range(of: readMoreText)
        
        let readMoreRange = Utility.isDeviceIpad() ? NSRange.init(location: readMoreTextRange.location, length: readMoreTextRange.length) :  NSRange.init(location: readMoreTextRange.location, length: readMoreTextRange.length)
        if gesture.didTapAttributedTextInLabel(label: naicsLabel, inRange: readMoreRange) {
            self.openNAICSReadMore()
        }
    }
}

// MARK: - NAICS/Industry
extension BusinessDetailsVC {
    func getBusinessIndustry() {
        for businessSector in businessSectors {
            for sectorGroup in businessSector.industries ?? [IndustryGroupType]() {
                for businessIndustry in sectorGroup.nationalIndustries ?? [IndustryType]() {
                    if let code = businessIndustry.code {
                        if String(code) == self.businessData.naicsCode {
                            selectedIndustry = businessIndustry
                            selectedSectorGroup = sectorGroup
                            selectedBusinessSector = businessSector
                        }
                    }
                }
            }
        }
        
        self.getIndustryGroupListItem()
        self.getNationalIndustryListItem()
    }
    
    func setSelectedBusinessSector(sectorCode: Int) {
        let businessSector: BusinessSectorType = businessSectors.filter({ $0.code == sectorCode }).first ?? BusinessSectorType()
        selectedBusinessSector = businessSector
    }
    
    func setSelectedSectorGroup(sectorGroupCode: Int) {
        let sectorGroup: IndustryGroupType = selectedBusinessSector.industries?.filter({ $0.code == sectorGroupCode }).first ?? IndustryGroupType()
        selectedSectorGroup = sectorGroup
    }
    
    func getBusinessSectorListItem() {
        for sector in self.businessSectors {
            if let code = sector.code, let name = sector.name {
                let strCode = String(code)
                let strName = name + " (" + strCode + ")"
                businessSectorListIems.append(ListItems(title: strName, id: strCode))
            }
        }
    }
    
    func getIndustryGroupListItem() {
        if let sectorGroups = selectedBusinessSector.industries, sectorGroups.count > 0 {
            sectorGroupListIems = [ListItems]()
            nationalIndustryListIems = [ListItems]()

            for group in sectorGroups {
                if let code = group.code, let name = group.name {
                    let strCode = String(code)
                    let strName = name + " (" + strCode + ")"
                    sectorGroupListIems.append(ListItems(title: strName, id: strCode))
                }
            }
            
            tblKYBDetails.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .none)
            tblKYBDetails.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .none)
        }
    }
    
    func getNationalIndustryListItem() {
        if let nationalIndustries = selectedSectorGroup.nationalIndustries, nationalIndustries.count > 0 {
            nationalIndustryListIems = [ListItems]()
            
            for industry in nationalIndustries {
                if let code = industry.code, let name = industry.name {
                    let strCode = String(code)
                    let strName = name + " (" + strCode + ")"
                    nationalIndustryListIems.append(ListItems(title: strName, id: strCode))
                }
            }
            
            tblKYBDetails.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .none)
        }
    }
}

// MARK: - API CALLS
extension BusinessDetailsVC {
    func getBusinessSectors() {
        self.activityIndicatorBegin()
        
        KYBViewModel.shared.getNAICSCodesList { response, errorMessage in
            BaseVC().activityIndicatorEnd()
            if let errorData = errorMessage {
                self.showAlertMessage(titleStr: errorData.title, messageStr: errorData.body )
            } else {
                if let sectorsList = response, let sectorData = sectorsList.data, let totalCount = sectorsList.total, totalCount > 0 {
                    self.businessSectors = sectorData
                    self.getBusinessSectorListItem()
                    self.setBusinessData()
                }
            }
        }
    }
    
    func createBusiness() {
        var postBody = CreateBusinessPostBody()
        if let phone = AppGlobalData.shared().personData.phone, let email = AppGlobalData.shared().personData.email {
            if let etype =  businessDataModel.entityType {
                postBody.entityType =  etype
            }
                        
            postBody.phone = phone
            postBody.email = email
            postBody.idNumber = businessDataModel.ein?.plainNumberString
            postBody.idType = TaxType.ein.rawValue
            postBody.legalName = businessDataModel.businessName
            postBody.dba = businessDataModel.dba
            postBody.naicsCode = businessDataModel.naicsCode

            self.activityIndicatorBegin()
            KYBViewModel.shared.createNewBusiness(businessData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let businessResp = response {
                        self.businessData =  businessResp
                        AppGlobalData.shared().businessData = businessResp
                        self.gotoETVScreen()
                    }
                }
            }
        }
    }
    
    func updateBusiness(bId: String) {
        var postBody = CreateBusinessPostBody()
        if let phone = AppGlobalData.shared().personData.phone, let email = AppGlobalData.shared().personData.email {
            if let etype =  businessDataModel.entityType {
                postBody.entityType =  etype
            }
            
            postBody.phone = phone
            postBody.email = email
            postBody.idNumber = businessDataModel.ein?.plainNumberString
            postBody.idType = TaxType.ein.rawValue
            postBody.legalName = businessDataModel.businessName
            postBody.dba = businessDataModel.dba
            postBody.naicsCode = businessDataModel.naicsCode

            self.activityIndicatorBegin()
            KYBViewModel.shared.updateBusiness(businessId: bId, businessData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let businessData = response {
                        self.businessData =  businessData
                        AppGlobalData.shared().businessData = businessData
                        self.gotoETVScreen()
                    }
                }
            }
        }
    }
}
