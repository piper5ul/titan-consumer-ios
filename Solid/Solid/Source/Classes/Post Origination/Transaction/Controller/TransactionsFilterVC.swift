//
//  TransactionsFilterVC.swift
//  Solid
//
//  Created by Solid iOS Team on 16/03/21.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func selectedFilterData(filter: FilterData)
}

class TransactionsFilterVC: BaseVC {

    @IBOutlet weak var tblTransFilter: UITableView!

    var listingType: TransactionListingType? = .transaction
    var filterData: FilterData? = FilterData()

    var arrHeaderTitle: [String] = []
    var arrExpandedSection: [Bool] = []

    var noOfSection: Int? = 0

    weak var filterDelegate: FilterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationBar()

        if (self.listingType == TransactionListingType.transaction) && (AppGlobalData.shared().cardList.count > 0) {
            noOfSection = 4
        } else {
            noOfSection = 3
        }
        
        for _ in 0...(noOfSection ?? 0) {
            arrExpandedSection.append(false)
        }
		
		if Utility.isDeviceIpad() {
			let cancelButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(cancelAction))
			cancelButton.tintColor = .primaryColor
			self.navigationItem.rightBarButtonItem  = cancelButton
		}

        arrHeaderTitle = ["filterHeader_type", "filterHeader_period", "filterHeader_amount", "filterHeader_card"]
        registerCells()
        self.setFooterUI()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if Utility.isDeviceIpad() {
			self.isIpadFormsheet = true
			let footerYposition =  self.view.frame.size.height - Constants.footerViewHeight
			footerView.frame =  CGRect(x: 0, y: footerYposition, width: view.frame.size.width, height: Constants.footerViewHeight)
		}
	}
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tblTransFilter.reloadData()
    }

    func setupUI() {
        self.tblTransFilter.backgroundColor = .clear
    }

    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons(havingTwoButtons: true, leftButtonTitle: Utility.localizedString(forKey: "filter_clear"), rightButtonTitle: Utility.localizedString(forKey: "filter_apply"))
        footerView.btnApply.addTarget(self, action: #selector(applyButtonAction), for: .touchUpInside)
        footerView.btnClose.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
    }
	
}

// MARK: - Navigationbar
extension TransactionsFilterVC {

    func setNavigationBar() {
        self.isScreenModallyPresented = true
        self.isNavigationBarHidden = false
		if Utility.isDeviceIpad() {
			self.navigationItem.setHidesBackButton(true, animated: true)
		} else {
			addBackNavigationbarButton()
		}
        self.title = Utility.localizedString(forKey: "filter")
    }
	
	@objc func cancelAction() {
		self.dismissController()
	}

    @objc func applyButtonAction() {
        if isValidData() {
            filterDelegate?.selectedFilterData(filter: self.filterData ?? FilterData())
			if Utility.isDeviceIpad() {
				self.dismissController()
			} else {
				self.popVC()
			}
			
        }
    }

    @objc func clearButtonAction() {
        self.filterData = FilterData()
        AppGlobalData.shared().resetArrFilterIndex()
        self.tblTransFilter.reloadData()
    }
}

// MARK: - Validations
extension TransactionsFilterVC {
    func isValidData() -> Bool {

        if let _ = filterData?.periodType {
            if let startDate = filterData?.startDate {

                if let endDate = filterData?.endDate {
                    return isValidDate(startDate: startDate, endDate: endDate)
                }

                return true
            }

            if let endDate = filterData?.endDate {

                if let startDate = filterData?.startDate {
                    return isValidDate(startDate: startDate, endDate: endDate)
                }

                return true
            }

            self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "date_validation"))

            return false
        }

        if let minAmt = filterData?.minAmount, minAmt != "0.0"{

            if let maxAmt = filterData?.maxAmount {
                return isValidAmount(minAmt: minAmt, maxAmt: maxAmt)
            }

            self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "enter_toAmount") )

            return false
        }

        if let maxAmt = filterData?.maxAmount {

            if let minAmt = filterData?.minAmount {
                return isValidAmount(minAmt: minAmt, maxAmt: maxAmt)
            }

            filterData?.minAmount = "0.00"

            return true
        }

        return true
    }

    func isValidDate(startDate: String, endDate: String) -> Bool {

        let sDate = startDate.getDate(format: "yyyy-MM-dd")
        let eDate = endDate.getDate(format: "yyyy-MM-dd")

        if sDate > eDate {
            // end date  should be greater
            self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "toDate_validation"))

            return false
        }

        return true
    }

    func isValidAmount(minAmt: String, maxAmt: String) -> Bool {
        let minAmt = Double(minAmt) ?? 0
        let maxAmt = Double(maxAmt) ?? 0

        if minAmt == 0 && maxAmt == 0 {
            filterData?.minAmount = nil
            filterData?.maxAmount = nil
        } else if minAmt > maxAmt || minAmt == maxAmt {
            // max amt should be greater
            self.showAlertMessage(titleStr: "", messageStr: Utility.localizedString(forKey: "amount_validation") )

            return false
        }

        return true
    }
}

// MARK: - UITableView
extension TransactionsFilterVC: UITableViewDelegate, UITableViewDataSource {

    func registerCells() {
        self.tblTransFilter.register(UINib(nibName: "FilterRadiobuttonCell", bundle: .main), forCellReuseIdentifier: "FilterRadiobuttonCell")
        self.tblTransFilter.register(UINib(nibName: "FilterPeriodCell", bundle: .main), forCellReuseIdentifier: "FilterPeriodCell")
        self.tblTransFilter.register(UINib(nibName: "FilterAmountCell", bundle: .main), forCellReuseIdentifier: "FilterAmountCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.noOfSection ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var count = 0
        var isSectionExpanded = false

        if arrExpandedSection[section] {
            isSectionExpanded = true
        }

        switch section {
        case 0:
            let rowCount = 3
            count = isSectionExpanded ? rowCount : count
        case 1:
            count = isSectionExpanded ? 4 : count
        case 2:
            count = isSectionExpanded ? 1 : count
        case 3:
            count = isSectionExpanded ? AppGlobalData.shared().cardList.count : count
        default:
            break
        }

        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
            case 0:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterRadiobuttonCell", for: indexPath) as? FilterRadiobuttonCell {
                    var titleLabel: String
                    if indexPath.row == 0 {
                        titleLabel = Utility.localizedString(forKey: "credits")
                    } else if indexPath.row == 1 {
                        titleLabel = Utility.localizedString(forKey: "debits")
                    } else {
                        titleLabel =  Utility.localizedString(forKey: "card_transaction")
                    }
                    cell.titleLabel.text = titleLabel
                    cell.radioDelegate = self
                    cell.isRadiobuttonSelected = false

                    if filterData?.arrOfSelectedIndex?[0] == indexPath {
                        cell.isRadiobuttonSelected = true
                    }
                    return cell
                }
            case 1 :
                if indexPath.row == 3 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterPeriodCell", for: indexPath) as? FilterPeriodCell {
                        cell.indexPath = indexPath
                        cell.isRadiobuttonSelected = false
                        cell.periodDelegate = self

                        cell.txtTo.isEnabled = false
                        cell.txtFrom.isEnabled = false

                        cell.txtFrom.text = ""
                        cell.txtTo.text = ""

                        cell.isStackViewHidden = true

                        if filterData?.arrOfSelectedIndex?[1] == indexPath {
                            cell.isRadiobuttonSelected = true
                            cell.txtTo.isEnabled = true
                            cell.txtFrom.isEnabled = true

                            cell.txtFrom.text = filterData?.startDate
                            cell.txtTo.text = filterData?.endDate

                            cell.isStackViewHidden = false
                        }
                        
                        cell.txtFrom.layer.borderWidth = 0.5
                        cell.txtFrom.layer.borderColor = UIColor.customSeparatorColor.withAlphaComponent(0.5).cgColor
                        
                        cell.txtTo.layer.borderWidth = 0.5
                        cell.txtTo.layer.borderColor = UIColor.customSeparatorColor.withAlphaComponent(0.5).cgColor

                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterRadiobuttonCell", for: indexPath) as? FilterRadiobuttonCell {
                        switch indexPath.row {
                            case 0:
                                cell.titleLabel.text = Utility.localizedString(forKey: "this_week")
                            case 1:
                                cell.titleLabel.text = Utility.localizedString(forKey: "this_month")
                            default:
                                cell.titleLabel.text = Utility.localizedString(forKey: "last_month")
                        }

                        cell.radioDelegate = self

                        cell.isRadiobuttonSelected = false

                        if filterData?.arrOfSelectedIndex?[1] == indexPath {
                            cell.isRadiobuttonSelected = true
                        }

                        return cell
                    }
                }
            case 2:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterAmountCell", for: indexPath) as? FilterAmountCell {
                    cell.txtFrom.setDefault(value: filterData?.minAmount ?? "")
                    cell.txtTo.setDefault(value: filterData?.maxAmount ?? "")

                    cell.amountCellDelegate = self
                    
                    cell.txtFrom.layer.borderWidth = 0.5
                    cell.txtFrom.layer.borderColor = UIColor.customSeparatorColor.withAlphaComponent(0.5).cgColor
                    
                    cell.txtTo.layer.borderWidth = 0.5
                    cell.txtTo.layer.borderColor = UIColor.customSeparatorColor.withAlphaComponent(0.5).cgColor
                    
                    return cell
                }

            default:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterRadiobuttonCell", for: indexPath) as? FilterRadiobuttonCell {
                    let cardData = AppGlobalData.shared().cardList[indexPath.row]
                    let strTitle = cardData.label
                    cell.titleLabel.text = strTitle

                    cell.radioDelegate = self

                    cell.isRadiobuttonSelected = false

                    if filterData?.arrOfSelectedIndex?[2] == indexPath {
                        cell.isRadiobuttonSelected = true
                    }

                    return cell
                }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.reloadTable(withIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        headerView.backgroundColor = .background

        let lblTitle = UILabel(frame: CGRect(x: 20, y: 25, width: tableView.frame.size.width - 80, height: 20))
        lblTitle.font = UIFont.sfProDisplayMedium(fontSize: 16)

        lblTitle.textAlignment = .left
        lblTitle.textColor = UIColor.primaryColor

        let imgV = BaseImageView(frame: CGRect(x: (lblTitle.frame.origin.x + lblTitle.frame.size.width + 10), y: 25, width: 20, height: 20))
        imgV.image = arrExpandedSection[section] ?  UIImage(named: "expand_minus") :  UIImage(named: "expand_plus")
        imgV.customTintColor = .primaryColor
        
        let button = UIButton(frame: headerView.frame)
        button.addTarget(self, action: #selector(sectionExpand(sender:)), for: .touchUpInside)
        button.tag = section

        let strTitle = arrHeaderTitle[section]
        lblTitle.text = Utility.localizedString(forKey: strTitle)

        if section == 3 && AppGlobalData.shared().cardList.count == 0 {
            lblTitle.text = ""
        }

        headerView.addSubview(lblTitle)
        headerView.addSubview(imgV)
        headerView.addSubview(button)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let seperatorView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        let seperatorImgV = UIImageView(frame: CGRect(x: 0, y: seperatorView.frame.size.height - 2, width: seperatorView.frame.size.width, height: 0.5))
        seperatorImgV.backgroundColor = UIColor.secondaryColorWithOpacity

        seperatorView.backgroundColor = .clear
        seperatorView.addSubview(seperatorImgV)
        return seperatorView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    @objc func sectionExpand(sender: UIButton) {
        arrExpandedSection[sender.tag] = !arrExpandedSection[sender.tag]
        tblTransFilter.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
    }

    func reloadTable(withIndexPath: IndexPath) {
        var selectedTimePeriod: TransactionTimePeriod? = .NA

        if  withIndexPath.section == 0 {// CREDIT OR DEBIT...
            self.selectedRadioType(type: "type", withIndex: withIndexPath, cardId: "", cardName: "")
        } else if withIndexPath.section == 1 {// PERIOD TYPE...

            if withIndexPath.row == 3 {// CUSTOM PERIOD TYPE
                self.selectedCustomPeriodType(withIndex: withIndexPath)
            } else {
                if withIndexPath.row == 0 {
                    selectedTimePeriod = .week
                } else if withIndexPath.row == 1 {
                    selectedTimePeriod = .month
                } else {
                    selectedTimePeriod = .lastMonth
                }

                let startEndDate  = Utility.getDateRange(dateOption: selectedTimePeriod ?? .month)

                self.selectedPeriodRadioType(type: "period", withIndex: withIndexPath, startDate: startEndDate[0].getDateString(), endDate: startEndDate[1].getDateString(), selectedPeriod: selectedTimePeriod ?? .month)
            }
        } else {// CARD SELECTION...

            let cardId = AppGlobalData.shared().cardList[withIndexPath.row].id ?? ""
            let cardName = AppGlobalData.shared().cardList[withIndexPath.row].label ?? ""

            self.selectedRadioType(type: "card", withIndex: withIndexPath, cardId: cardId, cardName: cardName)
        }
    }
}

// MARK: - PeriodCellDelegate
extension TransactionsFilterVC: PeriodCellDelegate {

    func selectedPeriodRadioButton(cell: FilterPeriodCell) {
        guard let indexPath = self.tblTransFilter.indexPath(for: cell) else {
            return
        }

        self.reloadTable(withIndexPath: indexPath)
    }

    func selectedCustomPeriodType(withIndex: IndexPath) {

        filterData?.startDate = nil
        filterData?.endDate = nil

        AppGlobalData.shared().arrFilterIndex[1] = withIndex
        filterData?.arrOfSelectedIndex = AppGlobalData.shared().arrFilterIndex

        filterData?.periodType = .custom
        self.tblTransFilter.reloadSections(IndexSet(integer: 1), with: .none)
    }

    func periodFrom(startDate: Date) {
        filterData?.startDate = startDate.getDateString()
    }

    func periodTo(endDate: Date) {
        filterData?.endDate = endDate.getDateString()
    }
}

// MARK: - AmountCellDelegate
extension TransactionsFilterVC: AmountCellDelegate {
    func fromAmount(amount: String) {
        filterData?.minAmount = amount
    }

    func toAmount(amount: String) {
        filterData?.maxAmount = amount
    }
}

// MARK: - RadiobuttonCellDelegate
extension TransactionsFilterVC: RadiobuttonCellDelegate {

    func selectedRadioButton(cell: FilterRadiobuttonCell) {
        guard let indexPath = self.tblTransFilter.indexPath(for: cell) else {
            return
        }

        self.reloadTable(withIndexPath: indexPath)
    }

    func selectedRadioType(type: String, withIndex: IndexPath, cardId: String, cardName: String) {

        if type == "type" {
            var ttype: String = ""
            switch withIndex.row {
                case 0:
                    ttype = Utility.localizedString(forKey: "credits")
                case 1:
                    ttype = Utility.localizedString(forKey: "debits")
                case 2:
                    ttype = Utility.localizedString(forKey: "card_transaction")
                default:
                    break
            }
            filterData?.txnType = ttype

            AppGlobalData.shared().arrFilterIndex[0] = withIndex
            filterData?.arrOfSelectedIndex = AppGlobalData.shared().arrFilterIndex
            self.tblTransFilter.reloadSections(IndexSet(integer: 0), with: .none)
        } else {
            filterData?.cardId = cardId
            filterData?.cardName = cardName

            AppGlobalData.shared().arrFilterIndex[2] = withIndex
            filterData?.arrOfSelectedIndex = AppGlobalData.shared().arrFilterIndex
            UIView.performWithoutAnimation {
                self.tblTransFilter.reloadSections(IndexSet(integer: 3), with: .none)
            }
        }
    }

    func selectedPeriodRadioType(type: String, withIndex: IndexPath, startDate: String, endDate: String, selectedPeriod: TransactionTimePeriod) {

        if type == "period" {
            filterData?.periodType = selectedPeriod

            filterData?.startDate = startDate
            filterData?.endDate = endDate

            AppGlobalData.shared().arrFilterIndex[1] = withIndex
            filterData?.arrOfSelectedIndex = AppGlobalData.shared().arrFilterIndex
            self.tblTransFilter.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
}
