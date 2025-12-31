//
//  TransactionListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 10/03/21.
//

import UIKit
import SkeletonView

class TransactionListVC: BaseVC {
    @IBOutlet weak var transactionView: UIView!
    @IBOutlet weak var emptyTransactionView: UIView!
    @IBOutlet weak var lblEmptyTransaction: UILabel!
    
    @IBOutlet weak var lblEmptyFilterTransaction: UILabel!
    @IBOutlet weak var tblTransactions: UITableView!
    @IBOutlet weak var searchTextField: BaseTextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnFilter: BaseButton!

    public var isloading: Bool = false
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var searchbarContainer: UIView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var filterCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterCollectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterCollectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    let defaultSectionHeight: CGFloat = 45.0
    
    var mainTransactions = [TransactionModel]()
    var arrThisMonthTransactions = [TransactionModel]()
    var arrOlderTransactions = [TransactionModel]()
    var arrThisWeekTransactions = [TransactionModel]()
    var arrLastMonthTransactions = [TransactionModel]()
    
    var arrGroupedTransactions = [TransactionsGroup]()
    
    var searchResult = [TransactionModel]()
    var isSearchOn = false
    var selectedTransaction = TransactionModel()
    
    var listingType: TransactionListingType? = .transaction
    var transferType: TransferType?
    
    var queryString: String = ""
    var searchString: String = ""
    var contactId: String?
    var contactName: String?
    var cardId: String?
    var cardName: String?
    var strID: String = ""
    
    var filterData: FilterData? = FilterData()
    var arrFilterData: [String] = []
    var isFilterOn: Bool = false
    var isTransactionLoading: Bool = false
    
    var totalTransactionsCount = 0
    var fetchTransactionsWithLimit = Constants.fetchLimit
    var offset = 0
    var bottomSpinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setNavigationBar()
        registerCellsAndHeaders()
        registerFilterCollectionCell()
        configureSearchField()
        
        strID = AppGlobalData.shared().accountData?.id ?? ""
        
        if listingType == TransactionListingType.card {// CALL API FOR CARD TRANSACTIONS
            transferType = .card
            getCardTransactionList()
        } else if listingType == TransactionListingType.payment {// CALL API FOR PAYMENT TRANSACTIONS
            getPaymentTransactionList()
        } else {// CALL API FOR ALL TRANSACTIONS
            transferType = .ACH
            getTransactionList()
        }
        
        AppGlobalData.shared().setArrFilterIndex()
        //for pagination...
        bottomSpinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        bottomSpinner.color = UIColor.darkGray
        bottomSpinner.hidesWhenStopped = true
        tblTransactions.tableFooterView = bottomSpinner
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = true
        self.isNavigationBarTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isNavigationBarTranslucent = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.btnFilter.imageView?.tintColor = .brandColor
        lblTitle.textColor = UIColor.primaryColor
        lblEmptyTransaction.textColor = UIColor.secondaryColorWithOpacity
        lblEmptyFilterTransaction.textColor = UIColor.secondaryColorWithOpacity

        searchTextField.textColor = .primaryColor
        
        let searchPlaceholder = Utility.localizedString(forKey: "transaction_search_placeholder")
        let placeholderFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryColorWithOpacity, NSAttributedString.Key.font: placeholderFont])
        
        searchTextField?.leftViewMode = UITextField.ViewMode.always
        searchTextField?.backgroundColor = .background
        if let leftView  = searchTextField.leftView {
            let baseImg = leftView.viewWithTag(Constants.tagForSeachIconInSearchBar)
            baseImg?.tintColor = UIColor.secondaryColorWithOpacity
        }
    }
}

// MARK: - Set UI
extension TransactionListVC {
    func setUI() {
        lblTitle.text = Utility.localizedString(forKey: "transactions")
        lblTitle.font = Constants.commonFont
        lblTitle.textColor = UIColor.primaryColor
        
        filterCollectionViewHeightConstraint.constant = 0
        filterCollectionViewBottomConstraint.constant = 0
        filterCollectionViewTopConstraint.constant = 0
        
        transactionView.isHidden = false
        emptyTransactionView.isHidden = true
        
        let labelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        lblEmptyTransaction.text = Utility.localizedString(forKey: "noTransactions")
        lblEmptyTransaction.font = labelFont
        lblEmptyTransaction.textColor = UIColor.secondaryColorWithOpacity
        
        lblEmptyFilterTransaction.text = Utility.localizedString(forKey: "noTransactions")
        lblEmptyFilterTransaction.font = labelFont
        lblEmptyFilterTransaction.textColor = UIColor.secondaryColorWithOpacity
        
        btnFilter.backgroundColor = .background
        btnFilter.setImage(UIImage(named: "filter"), for: .normal)
        btnFilter.setImage(UIImage(named: "filter"), for: .selected)
        self.btnFilter.imageView?.tintColor = .brandColor
        
        searchTextField.fieldType = .search
        tableViewTopConstraint.constant = Utility.getTopSpacing() + 20
        
        searchTextField.textColor = .primaryColor
        searchTextField?.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setTransactionData() {
        arrThisMonthTransactions.removeAll()
        arrOlderTransactions.removeAll()
        arrThisWeekTransactions.removeAll()
        arrLastMonthTransactions.removeAll()
        arrGroupedTransactions.removeAll()
        
        for sortedTrans in mainTransactions {
            let strTxnDate = sortedTrans.txnDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let formattedTxnDate = dateFormatter.date(from: strTxnDate ?? "")! as Date
            let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            
            if (formattedTxnDate.isBetween(Date().startOfWeek!, and: Date().endOfWeek!)) && self.filterData?.periodType == .week {
                arrThisWeekTransactions.append(sortedTrans)
            } else if formattedTxnDate.month == Date().month  && self.filterData?.periodType == .month {
                arrThisMonthTransactions.append(sortedTrans)
            } else if formattedTxnDate.isBetween(Date().startOfWeek!, and: Date().endOfWeek!) {
                arrThisWeekTransactions.append(sortedTrans)
            } else if formattedTxnDate.month == Date().month && formattedTxnDate.year == Date().year {
                arrThisMonthTransactions.append(sortedTrans)
            } else if previousMonth!.month == formattedTxnDate.month && previousMonth!.year == formattedTxnDate.year {
                arrLastMonthTransactions.append(sortedTrans)
            } else {
                arrOlderTransactions.append(sortedTrans)
            }
        }
        
        if arrThisWeekTransactions.count > 0 {
            let trnsGrpThisWeek = TransactionsGroup()
            trnsGrpThisWeek.transactions = arrThisWeekTransactions
            trnsGrpThisWeek.groupTitle = Utility.localizedString(forKey: "this_week")
            arrGroupedTransactions.append(trnsGrpThisWeek)
        }
        
        if arrThisMonthTransactions.count > 0 {
            let trnsGrpThisMonth = TransactionsGroup()
            trnsGrpThisMonth.transactions = arrThisMonthTransactions
            trnsGrpThisMonth.groupTitle = Utility.localizedString(forKey: "this_month")
            arrGroupedTransactions.append(trnsGrpThisMonth)
        }
        
        if arrLastMonthTransactions.count > 0 {
            let trnsGrplastMonth = TransactionsGroup()
            trnsGrplastMonth.transactions = arrLastMonthTransactions
            trnsGrplastMonth.groupTitle = Utility.localizedString(forKey: "last_month")
            arrGroupedTransactions.append(trnsGrplastMonth)
        }
        
        if arrOlderTransactions.count > 0 {
            let arrOldTxns = getMonthWiseTransactions(from: arrOlderTransactions)
            
            let monthFormat = DateFormatter()
            monthFormat.dateFormat = "MMMM yyyy"
            let sortedByMonth = arrOldTxns
                .map { (monthFormat.date(from: $0.key)!, [$0.key: $0.value]) }
                .sorted { $0.0 > $1.0 }
                .map { $1 }
            
            for oldTrans in sortedByMonth {
                let trnsGrpOlder = TransactionsGroup()
                trnsGrpOlder.groupTitle = oldTrans.keys.first!
                trnsGrpOlder.transactions = oldTrans.values.first!
                
                arrGroupedTransactions.append(trnsGrpOlder)
            }
        }
        tblTransactions.reloadData()
    }
    
    func getMonthWiseTransactions(from arrayOfDates: [TransactionModel]) -> [String: [TransactionModel]] {
        return Dictionary(grouping: arrayOfDates) { txn -> String in
            let strDate = txn.txnDate
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            if let dt = dateFormatter.date(from: strDate ?? "") {
                let dateGrp = Calendar.current.dateComponents([.month, .year], from: dt)
                let monthName = DateFormatter().monthSymbols[(dateGrp.month ?? 0) - 1]
                let yearName: String = dateGrp.year?.string ?? ""
                return "\(monthName) \(yearName)"
            }
            return ""
        }
    }
}

// MARK: - Navigationbar
extension TransactionListVC {
    func setNavigationBar() {
        addCustomNavigationBar()
    }
    
    func configureSearchField() {
        let placeholderFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
        let searchPlaceholder = Utility.localizedString(forKey: "transaction_search_placeholder")
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryColorWithOpacity, NSAttributedString.Key.font: placeholderFont])
        
        searchTextField?.leftViewMode = UITextField.ViewMode.always
        searchTextField?.backgroundColor = UIColor.background
        
        let imageSize = 24
        let viewPadding = 8
        
        let outerVw = UIView(frame: CGRect(x: 0, y: 0, width: (imageSize + (viewPadding*2)), height: imageSize) )
        
        let searchImgVw = BaseImageView(frame: CGRect(x: viewPadding, y: 0, width: imageSize, height: imageSize))
        searchImgVw.image = UIImage(named: "Ic_search")?.withTintColor(.secondaryColorWithOpacity, renderingMode: .alwaysOriginal)
        searchImgVw.tag = Constants.tagForSeachIconInSearchBar
        outerVw.addSubview(searchImgVw)
        searchTextField?.leftView = outerVw
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TransactionDetailsVC {
            destinationVC.transactionData = selectedTransaction
            destinationVC.transferType = transferType
        }
        if let destinationVC = segue.destination as? TransactionsFilterVC {
            destinationVC.filterDelegate = self
            destinationVC.listingType = self.listingType
        }
    }
    
    @IBAction func btnFilterClick(_ sender: UIButton) {
        goToFilterVC()
    }
    
    @IBAction func btnCancelSearchClick(_ sender: UIButton) {
        searchTextField.text = ""
        _ = searchTextField.resignFirstResponder()
        resetSearch(withSearchString: "", isSearch: false)
    }
    
    func goToFilterVC() {
        let storyboard = UIStoryboard.init(name: "Transaction", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TransactionsFilterVC") as? TransactionsFilterVC {
            vc.filterDelegate = self
            vc.listingType = self.listingType
            vc.filterData = self.filterData
            if Utility.isDeviceIpad() {
                vc.modalPresentationStyle = .formSheet
                let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC at the root of the navigation stack.
                self.present(navController, animated: true, completion: nil)
                
            } else {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Tableview delegate methods
extension TransactionListVC: UITableViewDelegate, UITableViewDataSource {
    func registerCellsAndHeaders() {
        self.tblTransactions.register(UINib(nibName: "TransactionCell", bundle: .main), forCellReuseIdentifier: "TransactionCell")
        self.tblTransactions.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
        self.tblTransactions.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SectionHeader")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrGroupedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrGroupedTransactions[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
            cell.selectionStyle = .none
            
            if let rowData = arrGroupedTransactions[indexPath.section].transactions[indexPath.row] as TransactionModel? {
                
                let shouldHide = indexPath.row >= (arrGroupedTransactions[indexPath.section].transactions.count-1)
                cell.configureTransactionCell(forRow: rowData, hideSeparator: shouldHide)
                
                //fetch next set of transactions..
                if indexPath.section >= arrGroupedTransactions.count - 4 && indexPath.row == (arrGroupedTransactions[indexPath.section].transactions.count) - 2 {
                    self.getNextTransactionList()
                }
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if arrGroupedTransactions.count > 0 {
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! SectionHeader
            headerCell.lblSectionHeader.text = arrGroupedTransactions[section].groupTitle
            headerCell.lblSectionHeader.font = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
            headerCell.lblSectionHeader.leftAnchor.constraint(equalTo: headerCell.leftAnchor).isActive = true
            headerCell.lblSectionHeader.rightAnchor.constraint(equalTo: headerCell.rightAnchor).isActive = true
            headerCell.lblSectionHeader.topAnchor.constraint(equalTo: headerCell.topAnchor).isActive = true
            headerCell.lblSectionHeader.bottomAnchor.constraint(equalTo: headerCell.bottomAnchor).isActive = true
            headerCell.lblSectionHeader.letterSpace = 0.28
            headerCell.backgroundColor = UIColor.grayBackgroundColor
            headerCell.contentView.backgroundColor = UIColor.grayBackgroundColor
            headerCell.layoutIfNeeded()
            return headerCell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultSectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppGlobalData.shared().selectedTransaction =  arrGroupedTransactions[indexPath.section].transactions[indexPath.row]
        self.performSegue(withIdentifier: "GoToTransactionDetailsVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }
}

// MARK: - Textfield delegate methods
extension TransactionListVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let completeText = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = completeText
        
        validateEnteredText(enteredText: completeText)
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchTransaction(strSearch: textField.text?.trim ?? "")
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearchOn = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            textField.resignFirstResponder()
        }
        searchTransaction(strSearch: "")
        return true
    }
}

// MARK: - UICollectionView methods
extension TransactionListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func registerFilterCollectionCell() {
        self.filterCollectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFilterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        
        cell.titleLabel.text = arrFilterData[indexPath.row].uppercased()
        cell.removeButton.addTarget(self, action: #selector(btnFilterCancelClicked(sender:)), for: .touchUpInside)
        cell.removeButton.tag = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return FilterCell.size(filter: arrFilterData[indexPath.row], indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    @objc func btnFilterCancelClicked(sender: UIButton) {
        let valueToRemove = arrFilterData[sender.tag]
        removeFilterDataFromModel(removeValue: valueToRemove)
        
        arrFilterData.remove(at: sender.tag)
        filterCollectionView.reloadData()
        
        if arrFilterData.count == 0 {
            self.filterData = FilterData()
            AppGlobalData.shared().resetArrFilterIndex()
            showHideCollectionView()
            
            searchTextField.isEnabled = true
            searchTextField.alpha = 1
        }
    }
}

// MARK: - APIs
extension TransactionListVC {
    func getTransactionList() {
        // getTransactionList for transactions only
        queryString = generateQueryString(withFilterData: FilterData())
        callTransactionListAPI(withQuery: queryString)
    }
    
    func getCardTransactionList() {
        // For Card transactions
        queryString = generateQueryString(withFilterData: FilterData())
        callTransactionListAPI(withQuery: queryString)
    }
    
    func getPaymentTransactionList() {
        // For payment transactions
        queryString = generateQueryString(withFilterData: FilterData())
        callTransactionListAPI(withQuery: queryString)
    }
    
    func searchTransaction(strSearch: String) {
        if strSearch.count > Constants.minimumSearchCharacter {
            validateAndSearchEnteredText(enteredText: strSearch)
        } else if strSearch.count == 0 {
            resetSearch(withSearchString: "", isSearch: false)
        }
    }
    
    func resetSearch(withSearchString: String, isSearch: Bool) {
        isSearchOn = isSearch
        btnFilter.isHidden = isSearch
        
        searchString = withSearchString
        queryString = generateQueryString(withFilterData: FilterData())
        callTransactionListAPI(withQuery: queryString)
    }
    
    func validateEnteredText(enteredText: String) {
        if enteredText.isInvalidInput() {
            self.searchTextField?.status = .error
            self.searchTextField?.linkedErrorLabel?.text = Utility.localizedString(forKey: "invalid_input")
            self.searchTextField?.layer.borderWidth = 1
            self.searchTextField?.layer.borderColor = UIColor.redMain.cgColor
        } else {
            self.searchTextField?.status = .normal
            self.searchTextField?.layer.borderWidth = 0
            self.searchTextField?.layer.borderColor = UIColor.background.cgColor
        }
    }
    
    func validateAndSearchEnteredText(enteredText: String) {
        validateEnteredText(enteredText: enteredText)
        
        if !enteredText.isInvalidInput() {
            let strSearchText = enteredText.replacingOccurrences(of: " ", with: "%20")
            resetSearch(withSearchString: strSearchText, isSearch: true)
        }
    }
    
    func generateQueryString(withFilterData: FilterData) -> String {
        var strQuery = ""
        if let ttype = withFilterData.txnType {
            switch ttype {
            case Utility.localizedString(forKey: "credits"):
                strQuery = "txnType=\(TransactionType.credit.rawValue)"
            case Utility.localizedString(forKey: "debits"):
                strQuery = "txnType=\(TransactionType.debit.rawValue)"
            case Utility.localizedString(forKey: "card_transaction"):
                strQuery = "transferType=\(TransactionType.card.rawValue)"
            default:
                break
            }
        }
        
        if let sDate = withFilterData.startDate {
            
            let qSDate = "startDate=\(sDate)"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qSDate)") : "\(qSDate)"
            
        }
        
        if let eDate = withFilterData.endDate {
            let qEDate = "endDate=\(eDate)"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qEDate)") : "\(qEDate)"
            
        }
        
        if let minAmt = withFilterData.minAmount {
            let amt = Double(minAmt) ?? 0
            let intAmt = Int(amt)
            
            let qMinAmt = "minAmount=\(intAmt)"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qMinAmt)") : "\(qMinAmt)"
            
        }
        
        if let maxAmt = withFilterData.maxAmount {
            let amt = Double(maxAmt) ?? 0
            let intAmt = Int(amt)
            
            let qMaxAmt = "maxAmount=\(intAmt)"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qMaxAmt)") : "\(qMaxAmt)"
        }
        
        if let cId = self.cardId {
            let qCardId = "cardId=\(cId)"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qCardId)") : "\(qCardId)"
        } else if let cardId = withFilterData.cardId {
            let qCardId = "cardId=\(cardId)"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qCardId)") : "\(qCardId)"
            
        }
        
        if let strCId = self.contactId {
            let qContactId = "contactId=\(strCId)"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qContactId)") : "\(qContactId)"
        }
        
        if let transType = transferType, (transType == TransferType.card || transType == TransferType.intrabank) {
            let strTransferType = transferType?.rawValue
            
            let qTType = "transferType=\(strTransferType ?? "")"
            strQuery = (strQuery.count > 0) ? (strQuery + "&\(qTType)") : "\(qTType)"
        }
        
        let tSearch = "query=\(searchString)"
        strQuery = (strQuery.count > 0) ? (strQuery + "&\(tSearch)") : "\(tSearch)"
        
        return strQuery
    }
    
    func callTransactionListAPI(withQuery: String) {
        offset = 0
        if !strID.isEmpty {
            self.isTransactionLoading = false
            self.view.showAnimatedGradientSkeleton()
            TransactionViewModel.shared.getTransactionList(strId: strID, queryString: withQuery) { (response, errorMessage) in
                self.isTransactionLoading = true
                self.view.hideSkeleton()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let transactionlist = response?.data, transactionlist.count > 0 {
                        self.lblEmptyFilterTransaction.isHidden = true
                        self.totalTransactionsCount = response?.total ?? 0
                        self.mainTransactions = transactionlist
                    } else {
                        if self.isFilterOn || self.isSearchOn {
                            self.lblEmptyFilterTransaction.isHidden = false
                            
                            if self.isSearchOn {
                                self.lblEmptyFilterTransaction.text = Utility.localizedString(forKey: "noSearchTransactions")
                            } else {
                                self.lblEmptyFilterTransaction.text = Utility.localizedString(forKey: "noTransactions")
                            }
                        } else {
                            self.lblEmptyFilterTransaction.isHidden = true
                            self.transactionView.isHidden = true
                            self.emptyTransactionView.isHidden = false
                        }
                        
                        self.mainTransactions = [TransactionModel]()
                    }
                    
                    self.setTransactionData()
                }
            }
        }
    }
    
    func getNextTransactionList() {
        if self.totalTransactionsCount > self.mainTransactions.count {
            self.bottomSpinner.startAnimating()
            
            offset += fetchTransactionsWithLimit
            
            queryString = generateQueryString(withFilterData: FilterData())
            
            let qOffset = "offset=\(offset)"
            queryString = (queryString.count > 0) ? (queryString + "&\(qOffset)") : "\(qOffset)"
            
            let qLimit = "limit=\(fetchTransactionsWithLimit)"
            queryString = (queryString.count > 0) ? (queryString + "&\(qLimit)") : "\(qLimit)"
            
            if !strID.isEmpty {
                TransactionViewModel.shared.getTransactionList(strId: strID, queryString: queryString) { (response, _) in
                    self.bottomSpinner.stopAnimating()
                    if let transactions = response?.data, transactions.count > 0 {
                        self.mainTransactions += transactions
                        self.setTransactionData()
                    }
                }
            }
        }
    }
}

// MARK: - FilterDelegate
extension TransactionListVC: FilterDelegate {
    func selectedFilterData(filter: FilterData) {
        isFilterOn = true
        self.filterData = filter
        generateFilterArray()

        queryString = generateQueryString(withFilterData: filter)
        callTransactionListAPI(withQuery: queryString)
    }
}

// MARK: - Set Filters
extension TransactionListVC {
    func generateFilterArray() {
        arrFilterData = []
        
        if let txnType = filterData?.txnType {
            arrFilterData.append(txnType)
        }
        
        if let periodType = filterData?.periodType {
            
            if periodType == .custom {
                if let sDate = filterData?.startDate, let eDate = filterData?.endDate {
                    let strDate = "\(sDate) to \(eDate)"
                    arrFilterData.append(strDate)
                } else if let sDate = filterData?.startDate {
                    let strDate = "\(sDate)"
                    arrFilterData.append(strDate)
                } else if let eDate = filterData?.endDate {
                    let strDate = "\(eDate)"
                    arrFilterData.append(strDate)
                }
            } else {
                arrFilterData.append(periodType.localizedDescription())
            }
        }
        
        if let minA = filterData?.minAmount, let maxA = filterData?.maxAmount {
            let strAmt = "$\(minA) to $\(maxA)"
            arrFilterData.append(strAmt)
        }
        
        if let cardName = filterData?.cardName {
            arrFilterData.append(cardName)
        }
        
        showHideCollectionView()
        
        if arrFilterData.count > 0 {
            searchTextField.isEnabled = false
            searchTextField.alpha = 0.5
            searchString = ""
            searchTextField.text = ""
            _ = searchTextField.resignFirstResponder()
        } else {
            searchTextField.isEnabled = true
            searchTextField.alpha = 1
        }
    }
    
    func showHideCollectionView() {
        if arrFilterData.count > 0 {
            filterCollectionViewHeightConstraint.constant = 40
            filterCollectionViewBottomConstraint.constant = 4
            filterCollectionViewTopConstraint.constant = 16
            filterView.layoutIfNeeded()
            filterView.isHidden = false
            filterCollectionView.reloadData()
        } else {
            filterView.isHidden = true
            filterCollectionViewHeightConstraint.constant = 0
            filterCollectionViewBottomConstraint.constant = 0
            filterCollectionViewTopConstraint.constant = 0
            filterView.layoutIfNeeded()
            filterCollectionView.reloadData()
        }
    }
    
    func removeFilterDataFromModel(removeValue: String) {
        if let value = filterData?.cardName, removeValue == value {
            filterData?.cardId = nil
            filterData?.cardName = nil
            filterData?.arrOfSelectedIndex?[2] = IndexPath()
            AppGlobalData.shared().arrFilterIndex[2] = IndexPath()
        } else if let value = filterData?.txnType, removeValue == value {
            filterData?.arrOfSelectedIndex?[0] = IndexPath()
            AppGlobalData.shared().arrFilterIndex[0] = IndexPath()
            filterData?.txnType = nil
        } else if let minA = filterData?.minAmount, let maxA = filterData?.maxAmount, (removeValue.contains(minA) || removeValue.contains(maxA)) {
            let strAmt = "$\(minA) to $\(maxA)"
            if removeValue == strAmt {
                filterData?.minAmount = nil
                filterData?.maxAmount = nil
            }
        } else if let _ = filterData?.periodType {
            
            filterData?.arrOfSelectedIndex?[1] = IndexPath()
            AppGlobalData.shared().arrFilterIndex[1] = IndexPath()
            
            if let _ = filterData?.startDate, let _ = filterData?.endDate {
                filterData?.startDate = nil
                filterData?.endDate = nil
                filterData?.periodType = nil
            } else if let _ = filterData?.startDate {
                filterData?.startDate = nil
                filterData?.periodType = nil
            } else if let _ = filterData?.endDate {
                filterData?.endDate = nil
                filterData?.periodType = nil
            }
        }
        
        if let fData = self.filterData {
            queryString = generateQueryString(withFilterData: fData)
            callTransactionListAPI(withQuery: queryString)
        }
    }
}

extension TransactionListVC: SkeletonTableViewDataSource {
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
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.orientationChangedViewController(tableview: self.tblTransactions, with: coordinator)
	}
}
