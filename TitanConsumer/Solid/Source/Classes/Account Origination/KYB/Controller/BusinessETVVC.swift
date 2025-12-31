//
//  BusinessETVVC.swift
//  Solid
//
//  Created by Solid iOS Team on 12/24/23.
//

import UIKit

class BusinessETVVC: BaseVC, FormDataCellDelegate {
    var businessProjectionResponse = ProjectionModel()
    var arrBusinessProjectionData = [BusinessProjectionValues]()
    var arrSectionTitles = [String]()
    
    let dataSource = ETVRowData(type: "", valuePickerData: [ListItems](), countPickerData: [ListItems]())
    let dataHandler = BusinessDataHandler()
    
    var scrollToIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    @IBOutlet weak var tblETVDetails: UITableView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrSectionTitles = ["send", "receive", "incoming"]
        self.registerCellsAndHeaders()
        
        self.generateTableViewData()
        self.initialiseBusinessProjectionData()
        
        self.callGetProjectionAPI()
        
        self.tblETVDetails.backgroundColor = .clear
        
        self.setFooterUI()
        addProgressbar(percentage: 60)
        
        if let aKeywindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            let bottomPadding = aKeywindow.safeAreaInsets.bottom
            tblBottomConstraint.constant = bottomPadding == 0 ? Constants.footerViewHeight : 90
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(checkNavigation), for: .touchUpInside)
    }
    
    func callGetProjectionAPI() {
        if let bid = AppGlobalData.shared().businessData?.id {
            self.getProjectionData(bId: bid)
        }
    }
    
    func initialiseBusinessProjectionData() {
        var businessProjectionSendData = BusinessProjectionValues()
        businessProjectionSendData.type = "send"
        businessProjectionSendData.projectionData = [BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: "")]
        arrBusinessProjectionData.append(businessProjectionSendData)
        
        var businessProjectionReceiveData = BusinessProjectionValues()
        businessProjectionReceiveData.type = "receive"
        businessProjectionReceiveData.projectionData = [BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: "")]
        arrBusinessProjectionData.append(businessProjectionReceiveData)
        
        var businessProjectionIncomingData = BusinessProjectionValues()
        businessProjectionIncomingData.type = "incoming"
        businessProjectionIncomingData.projectionData = [BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: ""), BusinessProjectionValue(amountRange: "", countRange: "", amount: "", count: "")]
        arrBusinessProjectionData.append(businessProjectionIncomingData)
        
        tblETVDetails.reloadData()
        tblETVDetails.layoutIfNeeded()
    }
    
    func generateTableViewData() {
        dataHandler.etvDataSource.removeAll()
        dataHandler.createETVDataSource()
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
            self.tblETVDetails.contentInset = contentInsets
            self.tblETVDetails.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: true)
            self.tblETVDetails.scrollIndicatorInsets = self.tblETVDetails.contentInset
        }
    }
}

// MARK: - GET/SET PROJECTION DATA
extension BusinessETVVC {
    func getProjectionACHData(strAmount: String, strCount: String) -> BusinessProjectionValue {
        var selectedValues = BusinessProjectionValue()
        for sValue in AppGlobalData.shared().listETVACHValues["etvValues"] ?? [[:]] {
            let maxValue = sValue["maxValue"]
            if  maxValue == strAmount {
                selectedValues.amountRange = sValue["valueRange"]
                selectedValues.amount = sValue["maxValue"]
            }
        }
        
        for sCount in AppGlobalData.shared().listETVACHValues["etvCounts"] ?? [[:]] {
            let maxCount = sCount["maxCount"]
            if  maxCount == strCount {
                selectedValues.countRange = sCount["countRange"]
                selectedValues.count = sCount["maxCount"]
            }
        }
        
        return selectedValues
    }
    
    func getProjectionIACHData(strAmount: String, strCount: String) -> BusinessProjectionValue {
        var selectedValues = BusinessProjectionValue()
        for sValue in AppGlobalData.shared().listETVIACHValues["etvValues"] ?? [[:]] {
            let maxValue = sValue["maxValue"]
            if  maxValue == strAmount {
                selectedValues.amountRange = sValue["valueRange"]
                selectedValues.amount = sValue["maxValue"]
            }
        }
        
        for sCount in AppGlobalData.shared().listETVIACHValues["etvCounts"] ?? [[:]] {
            let maxCount = sCount["maxCount"]
            if  maxCount == strCount {
                selectedValues.countRange = sCount["countRange"]
                selectedValues.count = sCount["maxCount"]
            }
        }
        
        return selectedValues
    }
    
    func getProjectionDWireData(strAmount: String, strCount: String) -> BusinessProjectionValue {
        var selectedValues = BusinessProjectionValue()
        for sValue in AppGlobalData.shared().listETVDWireValues["etvValues"] ?? [[:]] {
            let maxValue = sValue["maxValue"]
            if  maxValue == strAmount {
                selectedValues.amountRange = sValue["valueRange"]
                selectedValues.amount = sValue["maxValue"]
            }
        }
        
        for sCount in AppGlobalData.shared().listETVDWireValues["etvCounts"] ?? [[:]] {
            let maxCount = sCount["maxCount"]
            if  maxCount == strCount {
                selectedValues.countRange = sCount["countRange"]
                selectedValues.count = sCount["maxCount"]
            }
        }
        
        return selectedValues
    }
    
    func getProjectionIWireData(strAmount: String, strCount: String) -> BusinessProjectionValue {
        var selectedValues = BusinessProjectionValue()
        for sValue in AppGlobalData.shared().listETVIWireValues["etvValues"] ?? [[:]] {
            let maxValue = sValue["maxValue"]
            if  maxValue == strAmount {
                selectedValues.amountRange = sValue["valueRange"]
                selectedValues.amount = sValue["maxValue"]
            }
        }
        
        for sCount in AppGlobalData.shared().listETVIWireValues["etvCounts"] ?? [[:]] {
            let maxCount = sCount["maxCount"]
            if  maxCount == strCount {
                selectedValues.countRange = sCount["countRange"]
                selectedValues.count = sCount["maxCount"]
            }
        }
        
        return selectedValues
    }
    
    func getProjectionCheckData(strAmount: String, strCount: String) -> BusinessProjectionValue {
        var selectedValues = BusinessProjectionValue()
        for sValue in AppGlobalData.shared().listETVCheckValues["etvValues"] ?? [[:]] {
            let maxValue = sValue["maxValue"]
            if  maxValue == strAmount {
                selectedValues.amountRange = sValue["valueRange"]
                selectedValues.amount = sValue["maxValue"]
            }
        }
        
        for sCount in AppGlobalData.shared().listETVCheckValues["etvCounts"] ?? [[:]] {
            let maxCount = sCount["maxCount"]
            if  maxCount == strCount {
                selectedValues.countRange = sCount["countRange"]
                selectedValues.count = sCount["maxCount"]
            }
        }
        
        return selectedValues
    }
    
    func setBusinessProjectionData() {
        //SEND....
        let pSAch = self.businessProjectionResponse.transactions?.annual?.send?.ach
        let pSIAch = self.businessProjectionResponse.transactions?.annual?.send?.internationalAch
        let pSDWire = self.businessProjectionResponse.transactions?.annual?.send?.domesticWire
        let pSIWire = self.businessProjectionResponse.transactions?.annual?.send?.internationalWire
        let pSCheck = self.businessProjectionResponse.transactions?.annual?.send?.physicalCheck
        
        //ACH DATA
        arrBusinessProjectionData[0].projectionData?[0] = getProjectionACHData(strAmount: pSAch?.amount ?? "", strCount: pSAch?.count ?? "")
        //INTERNATIONAL ACH DATA
        arrBusinessProjectionData[0].projectionData?[1] = getProjectionIACHData(strAmount: pSIAch?.amount ?? "", strCount: pSIAch?.count ?? "")
        //DOMESTIC WIRE DATA
        arrBusinessProjectionData[0].projectionData?[2] = getProjectionDWireData(strAmount: pSDWire?.amount ?? "", strCount: pSDWire?.count ?? "")
        //INTERNATIONAL WIRE DATA
        arrBusinessProjectionData[0].projectionData?[3] = getProjectionIWireData(strAmount: pSIWire?.amount ?? "", strCount: pSIWire?.count ?? "")
        //CHECK DATA
        arrBusinessProjectionData[0].projectionData?[4] = getProjectionCheckData(strAmount: pSCheck?.amount ?? "", strCount: pSCheck?.count ?? "")
        
        //RECEIVE....
        let pRAch = self.businessProjectionResponse.transactions?.annual?.receive?.ach
        let pRCheck = self.businessProjectionResponse.transactions?.annual?.receive?.physicalCheck
        
        //ACH DATA
        arrBusinessProjectionData[1].projectionData?[0] = getProjectionACHData(strAmount: pRAch?.amount ?? "", strCount: pRAch?.count ?? "")
        //CHECK DATA
        arrBusinessProjectionData[1].projectionData?[1] = getProjectionCheckData(strAmount: pRCheck?.amount ?? "", strCount: pRCheck?.count ?? "")
        
        //INCOMING....
        let pIAchPush = self.businessProjectionResponse.transactions?.annual?.incoming?.achPush
        let pIAchPull = self.businessProjectionResponse.transactions?.annual?.incoming?.achPull
        let pIIAch = self.businessProjectionResponse.transactions?.annual?.incoming?.internationalAch
        let pIDWire = self.businessProjectionResponse.transactions?.annual?.incoming?.domesticWire
        let pIIIWire = self.businessProjectionResponse.transactions?.annual?.incoming?.internationalWire
        
        //ACH PUSH DATA
        arrBusinessProjectionData[2].projectionData?[0] = getProjectionACHData(strAmount: pIAchPush?.amount ?? "", strCount: pIAchPush?.count ?? "")
        //ACH PULL DATA
        arrBusinessProjectionData[2].projectionData?[1] = getProjectionACHData(strAmount: pIAchPull?.amount ?? "", strCount: pIAchPull?.count ?? "")
        //INTERNATIONAL ACH DATA
        arrBusinessProjectionData[2].projectionData?[2] = getProjectionIACHData(strAmount: pIIAch?.amount ?? "", strCount: pIIAch?.count ?? "")
        //DOMESTIC WIRE DATA
        arrBusinessProjectionData[2].projectionData?[3] = getProjectionDWireData(strAmount: pIDWire?.amount ?? "", strCount: pIDWire?.count ?? "")
        //INTERNATIONAL WIRE DATA
        arrBusinessProjectionData[2].projectionData?[4] = getProjectionIWireData(strAmount: pIIIWire?.amount ?? "", strCount: pIIIWire?.count ?? "")
        
        tblETVDetails.reloadData()
        tblETVDetails.layoutIfNeeded()
    }
}

// MARK: - Navigationbar
extension BusinessETVVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        
        self.title = Utility.localizedString(forKey: "etv_Title")
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        addBackNavigationbarButton()
    }
    
    @objc func checkNavigation() {
        if let bisunessID = AppGlobalData.shared().businessData?.id {
            self.updateProjection(bId: bisunessID)
        }
    }
    
    func validate() {
        if self.isAllValuesFilled() {
            self.footerView.btnApply.isEnabled = true
        } else {
            self.footerView.btnApply.isEnabled = false
        }
    }
    
    func isAllValuesFilled() -> Bool {
        for pData in arrBusinessProjectionData {
            if let pValues = pData.projectionData {
                for pvalue in pValues {
                    if let rangeValue = pvalue.amountRange, let rangeCount = pvalue.countRange {
                        if rangeValue.isEmpty || rangeCount.isEmpty {
                            return false
                        }
                    } else {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    func gotoAddressScreen() {
        self.performSegue(withIdentifier: "GoToBusinessAddressVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? BusinessAddressVC {
            destinationVC.businessData =  AppGlobalData.shared().businessData ?? BusinessDataModel()
        }
    }
}

// MARK: - FormDataCellDelegate
extension BusinessETVVC {
    func cell (_ cell: CustomTableViewCell, editing: Any?, begin cd: BaseTextField?) {
        guard let indexPath = self.tblETVDetails.indexPath(for: cell) else {return}
        
        self.scrollToIndexPath = indexPath
    }
    
    func cellWithListItem(_ cell: CustomTableViewCell, selected data: ListItems?) {
        guard let indexPath = self.tblETVDetails.indexPath(for: cell), let selectedData = data else {return}
        
        let etvValue = selectedData.title ?? ""
        let etvCount = arrBusinessProjectionData[indexPath.section].projectionData?[indexPath.row].countRange ?? ""
        
        let selectedValues = dataHandler.getSelectedProjectionValues(selectedAmountRange: etvValue, selectedCountRange: etvCount, selectedProjectionData: arrBusinessProjectionData, forIndexPath: indexPath)
        arrBusinessProjectionData[indexPath.section].projectionData?[indexPath.row] = selectedValues
        
        tblETVDetails.reloadRows(at: [indexPath], with: .none)
        
        validate()
    }
    
    func cellETVCount(_ cell: CustomTableViewCell, selected data: ListItems?) {
        guard let indexPath = self.tblETVDetails.indexPath(for: cell), let selectedData = data else {return}
        
        let etvCount = selectedData.title ?? ""
        let etvValue = arrBusinessProjectionData[indexPath.section].projectionData?[indexPath.row].amountRange ?? ""
        
        let selectedValues = dataHandler.getSelectedProjectionValues(selectedAmountRange: etvValue, selectedCountRange: etvCount, selectedProjectionData: arrBusinessProjectionData, forIndexPath: indexPath)
        arrBusinessProjectionData[indexPath.section].projectionData?[indexPath.row] = selectedValues
        
        tblETVDetails.reloadRows(at: [indexPath], with: .none)
        
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

// MARK: - UITableView
extension BusinessETVVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblETVDetails.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
        self.tblETVDetails.register(UINib(nibName: "CustomTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataHandler.etvDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = dataHandler.etvDataSource
        return section < dataSource.count ? dataSource[section].count  : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CustomTableViewCell
        
        let rowData = dataHandler.etvDataSource[indexPath.section][indexPath.row] as ETVRowData
        let valueData = rowData.valuePickerData
        let countData = rowData.countPickerData
        
        let strTextFieldText = arrBusinessProjectionData[indexPath.section].projectionData?[indexPath.row].amountRange ?? ""
        let strTextFieldText2 = arrBusinessProjectionData[indexPath.section].projectionData?[indexPath.row].countRange ?? ""
        
        cell.arrPickerData = valueData
        cell.arrPickerData2 = countData
        
        cell.titleLabel?.text = rowData.type
        
        cell.subTitleLabel?.isHidden = false
        cell.subTitleLabel?.text = Utility.localizedString(forKey: "count")
        
        cell.fieldType = "stringPicker"
        cell.inputTextField?.text = strTextFieldText
        cell.inputTextField?.tag = indexPath.row
        
        cell.cellView2?.isHidden = false
        cell.leadingConstCellView2.constant = 10
        cell.widthConstCellView2.constant = 110
        
        cell.pickerTextField2?.isEnabled = strTextFieldText == "$0.00 - $0.00" ? false : true
        cell.pickerTextField2?.alpha = strTextFieldText == "$0.00 - $0.00" ? 0.5 : 1
        cell.pickerTextField2?.text = strTextFieldText2
        cell.pickerTextField2?.tag = indexPath.row
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cheight: CGFloat = Utility.isDeviceIpad() ? Constants.formCellHeightipad : Constants.formCellHeightiphone
        return cheight - 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
        sectionHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 20)
        sectionHeader.backgroundColor = .background
        sectionHeader.contentView.backgroundColor = .background
        
        sectionHeader.lblSectionHeader.text = Utility.localizedString(forKey: arrSectionTitles[section])
        sectionHeader.lblSectionHeader.leftAnchor.constraint(equalTo: sectionHeader.leftAnchor, constant: 16).isActive = true
        sectionHeader.lblSectionHeader.rightAnchor.constraint(equalTo: sectionHeader.rightAnchor).isActive = true
        sectionHeader.lblSectionHeader.topAnchor.constraint(equalTo: sectionHeader.topAnchor, constant: 0).isActive = true
        sectionHeader.lblSectionHeader.bottomAnchor.constraint(equalTo: sectionHeader.bottomAnchor).isActive = true
        
        sectionHeader.layoutIfNeeded()
        
        return sectionHeader
    }
}

// MARK: - API CALLS
extension BusinessETVVC {
    func getProjectionData(bId: String) {
        self.activityIndicatorBegin()
        
        KYBViewModel.shared.getProjection(businessId: bId) { (response, errorMessage) in
            self.activityIndicatorEnd()
            
            if let error = errorMessage {
                self.showAlertMessage(titleStr: error.title, messageStr: error.body )
            } else {
                if let projectionData = response, let transactions = projectionData.transactions, let _ = transactions.annual {
                    self.businessProjectionResponse = projectionData
                    self.setBusinessProjectionData()
                }
            }
            
            self.validate()
        }
    }
    
    func getProjectionPatchBody() -> ProjectionModel {
        var postBody = ProjectionModel()
        
        var pTrns = ProjectionTransactionsModel()
        var pAnn = ProjectionAnnualModel()
        
        //FOR SEND....
        var pSend = ProjectionSendModel()
        
        //ACH
        var pSAch = ProjectionDataModel()
        pSAch.count = arrBusinessProjectionData[0].projectionData?[0].count ?? ""
        pSAch.amount = arrBusinessProjectionData[0].projectionData?[0].amount ?? ""
        pSend.ach = pSAch
        
        //INTERNATIONAL ACH
        var pSIAch = ProjectionDataModel()
        pSIAch.count = arrBusinessProjectionData[0].projectionData?[1].count ?? ""
        pSIAch.amount = arrBusinessProjectionData[0].projectionData?[1].amount ?? ""
        pSend.internationalAch = pSIAch
        
        //WIRE
        var pSWire = ProjectionDataModel()
        pSWire.count = arrBusinessProjectionData[0].projectionData?[2].count ?? ""
        pSWire.amount = arrBusinessProjectionData[0].projectionData?[2].amount ?? ""
        pSend.domesticWire = pSWire
        
        //INTERNATIONAL WIRE
        var pIWire = ProjectionDataModel()
        pIWire.count = arrBusinessProjectionData[0].projectionData?[3].count ?? ""
        pIWire.amount = arrBusinessProjectionData[0].projectionData?[3].amount ?? ""
        pSend.internationalWire = pIWire
        
        //CHECK
        var pSChe = ProjectionDataModel()
        pSChe.count = arrBusinessProjectionData[0].projectionData?[4].count ?? ""
        pSChe.amount = arrBusinessProjectionData[0].projectionData?[4].amount ?? ""
        pSend.physicalCheck = pSChe
        
        pAnn.send = pSend
        ///..
        
        //FOR RECEIVE....
        var pReceive = ProjectionReceiveModel()
        
        //ACH
        var pRAch = ProjectionDataModel()
        pRAch.count = arrBusinessProjectionData[1].projectionData?[0].count ?? ""
        pRAch.amount = arrBusinessProjectionData[1].projectionData?[0].amount ?? ""
        pReceive.ach = pRAch
        
        //CHECK
        var pRChe = ProjectionDataModel()
        pRChe.count = arrBusinessProjectionData[1].projectionData?[1].count ?? ""
        pRChe.amount = arrBusinessProjectionData[1].projectionData?[1].amount ?? ""
        pReceive.physicalCheck = pRChe
        
        pAnn.receive = pReceive
        ///..
        
        //FOR INCOMING....
        var pIncoming = ProjectionIncomingModel()
        
        //ACH PUSH
        var pAchPush = ProjectionDataModel()
        pAchPush.count = arrBusinessProjectionData[2].projectionData?[0].count ?? ""
        pAchPush.amount = arrBusinessProjectionData[2].projectionData?[0].amount ?? ""
        pIncoming.achPush = pAchPush
        
        //ACH PULL
        var pAchPull = ProjectionDataModel()
        pAchPull.count = arrBusinessProjectionData[2].projectionData?[1].count ?? ""
        pAchPull.amount = arrBusinessProjectionData[2].projectionData?[1].amount ?? ""
        pIncoming.achPull = pAchPull
        
        //INTERNATIONAL ACH
        var pIIAch = ProjectionDataModel()
        pIIAch.count = arrBusinessProjectionData[2].projectionData?[2].count ?? ""
        pIIAch.amount = arrBusinessProjectionData[2].projectionData?[2].amount ?? ""
        pIncoming.internationalAch = pIIAch
        
        //DOMESTIC WIRE
        var pDWire = ProjectionDataModel()
        pDWire.count = arrBusinessProjectionData[2].projectionData?[3].count ?? ""
        pDWire.amount = arrBusinessProjectionData[2].projectionData?[3].amount ?? ""
        pIncoming.domesticWire = pDWire
        
        //INTERNATIONAL WIRE
        var pIIWire = ProjectionDataModel()
        pIIWire.count = arrBusinessProjectionData[2].projectionData?[4].count ?? ""
        pIIWire.amount = arrBusinessProjectionData[2].projectionData?[4].amount ?? ""
        pIncoming.internationalWire = pIIWire
        
        pAnn.incoming = pIncoming
        ///..
        
        pTrns.annual = pAnn
        
        postBody.transactions = pTrns
        
        return postBody
    }
    
    func updateProjection(bId: String) {
        if let _ = AppGlobalData.shared().personData.phone, let _ = AppGlobalData.shared().personData.email {
            let postBody = getProjectionPatchBody()
            
            self.activityIndicatorBegin()
            
            KYBViewModel.shared.updateProjection(businessId: bId, projectionData: postBody) { (response, errorMessage) in
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        self.gotoAddressScreen()
                    }
                }
            }
        }
    }
}
