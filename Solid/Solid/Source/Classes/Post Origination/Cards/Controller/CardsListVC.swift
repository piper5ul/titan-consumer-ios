//
//  CardsListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 3/9/21.
//

import Foundation
import UIKit
import SkeletonView

class CardsListVC: BaseVC {
    @IBOutlet weak var lblCardsTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchbarContainer: UIView!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var cardData: CardModel?
    var cardViewModel = CardViewModel()
    
    var originalCards = [CardModel]()
    var searchResult = [CardModel]()
    
    var allcards = [Character: [CardModel]]()
    var headerTitles = [Character]()
    var isSearchOn = false
    public var isCardsloading: Bool = false
    
    var totalCardsCount = 0
    var fetchCardsWithLimit = Constants.fetchLimit
    var offset = 0
    var bottomActivityIndiator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        self.getCardList()
        addObservers()
        self.view.showAnimatedSkeleton()
        
        //for pagination...
        bottomActivityIndiator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.midX - 15, y: self.view.frame.height - 70, width: 30, height: 30))
        bottomActivityIndiator?.style = UIActivityIndicatorView.Style.medium
        bottomActivityIndiator?.color = UIColor.white
        bottomActivityIndiator?.hidesWhenStopped = true
        self.view.addSubview(bottomActivityIndiator!)
        self.view.bringSubviewToFront(bottomActivityIndiator!)
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

        lblCardsTitle.textColor = UIColor.primaryColor
        let searchPlaceholder = Utility.localizedString(forKey: "card_search_placeholder")
        let searchPlaceholderFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryColorWithOpacity, NSAttributedString.Key.font: searchPlaceholderFont])
        
        searchTextField?.backgroundColor = .background
        if let leftView  = searchTextField.leftView {
            let baseImg = leftView.viewWithTag(Constants.tagForSeachIconInSearchBar)
            baseImg?.tintColor = UIColor.secondaryColorWithOpacity
        }
    }
}

// MARK: - Observer methods
extension CardsListVC {
    func addObservers() {
        removeObserver()
        
        addObservingCardAdd()
        addObservingCardEdit()
        addObservingCardStatusChange()
    }
    
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addObservingCardAdd() {
        NotificationCenter.default.addObserver(self, selector: #selector(getCardList), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterAdding), object: nil)
    }
    
    private func addObservingCardEdit() {
        NotificationCenter.default.addObserver(self, selector: #selector(getCardList), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterEdit), object: nil)
    }
    
    private func addObservingCardStatusChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(getCardList), name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterStatusChange), object: nil)
    }
}

// MARK: - Other methods
extension CardsListVC {
    @objc func getCardList() {
        clearSearchData()
        searchTextField?.leftView?.isHidden = true
        self.view.showAnimatedGradientSkeleton()
        offset = 0
        self.getCardsList(limit: "\(fetchCardsWithLimit)", offset: "\(offset)") { (cardsList, _) in
            if let cards = cardsList?.data {
                self.isCardsloading = true
                self.searchTextField?.leftView?.isHidden = false
                self.view.hideSkeleton()
                self.originalCards = cards
                self.totalCardsCount = cardsList?.total ?? 0
                self.collectionView.reloadData()
            }
        }
    }
    
    func getNextCardList() {
        if self.totalCardsCount > self.originalCards.count {
            self.bottomActivityIndiator?.startAnimating()
            self.view.bringSubviewToFront(bottomActivityIndiator!)
            
            offset += fetchCardsWithLimit
            
            self.getCardsList(limit: "\(fetchCardsWithLimit)", offset: "\(offset)") { (cardsList, _) in
                self.bottomActivityIndiator?.stopAnimating()
                
                if let cards = cardsList?.data, cards.count > 0 {
                    self.originalCards += cards
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func cardStateChanged(sender: UISwitch) {
        if isSearchOn {
            cardData = self.searchResult[sender.tag]
        } else {
            cardData = self.originalCards[sender.tag]
        }
        
        if self.cardData?.cardStatus ==  CardStatus.pendingActivation {
            activateCard()
        } else {
            showAlertForAction()
        }
    }
    
    func showAlertForAction() {
        let title = (cardData?.cardStatus == CardStatus.inactive) ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_title") : Utility.localizedString(forKey: "cardInfo_freeze_alert_title")
        let message = (cardData?.cardStatus == CardStatus.inactive) ? Utility.localizedString(forKey: "cardInfo_unfreeze_alert_messsage") : Utility.localizedString(forKey: "cardInfo_freeze_alert_messsage")
        let freezeBtn = (cardData?.cardStatus == CardStatus.inactive) ? Utility.localizedString(forKey: "cardInfo_unfreeze_button") : Utility.localizedString(forKey: "cardInfo_freeze_button")
        let cancelBtn = Utility.localizedString(forKey: "cancel")
        alert(src: self, title, message, freezeBtn, cancelBtn) { (button: Int) in
            if button == 1 {
                if let aCardModel = self.cardData {
                    let aStatus = (aCardModel.cardStatus == CardStatus.inactive) ? CardStatus.active : CardStatus.inactive
                    self.callAPIToFreezeCard(status: aStatus)
                }
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    func callAPIToFreezeCard(status: CardStatus) {
        if let aCardModel = self.cardData, let cardId = aCardModel.id {
            self.activityIndicatorBegin()
            
            var requestBody = CardUpdateRequestBody()
            requestBody.cardStatus = status
            
            CardViewModel.shared.updateCard(cardID: cardId, contactData: requestBody) { (response, errorMessage) in
                
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let _ = response {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.reloadCardAfterStatusChange), object: nil)
                    }
                }
            }
        }
    }
    
    func activateCard() {
        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "CardActivationVC") as? CardActivationVC {
                    vc.cardData = self.cardData
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func addCard() {
        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "CardTypeSelectionVC") as? CardTypeSelectionVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

// MARK: - UI methods
extension CardsListVC {
    func setupUI() {
        lblCardsTitle.text = Utility.localizedString(forKey: "card_title")
        lblCardsTitle.font = Constants.commonFont
        lblCardsTitle.textColor = UIColor.primaryColor
        
        configureSearchField()
        addCustomNavigationBar()
        
        tableViewTopConstraint.constant = Utility.getTopSpacing() + 10
    }
    
    func configureSearchField() {
        let searchPlaceholder = Utility.localizedString(forKey: "card_search_placeholder")
        let searchPlaceholderFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryColorWithOpacity, NSAttributedString.Key.font: searchPlaceholderFont])
        
        searchTextField?.leftViewMode = UITextField.ViewMode.always
        searchTextField?.backgroundColor = .background
        searchTextField.cornerRadius = Constants.cornerRadiusThroughApp
        searchTextField.layer.masksToBounds = true
        
        let imgSize = 24
        let padding = 8
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: (imgSize + (padding*2)), height: imgSize) )
        let searchImageView = BaseImageView(frame: CGRect(x: padding, y: 0, width: imgSize, height: imgSize))
        searchImageView.image = UIImage(named: "Ic_search")?.withTintColor(.secondaryColorWithOpacity, renderingMode: .alwaysOriginal)
        searchImageView.tag = Constants.tagForSeachIconInSearchBar
        searchImageView.isSkeletonable = true
        outerView.addSubview(searchImageView)
        searchTextField?.leftView = outerView
    }
    
    func configureCollectionView() {
        self.registerCellsAndHeaders()
        cardViewModel.calculateCardWidth()
    }
    
    func adjustLayout() {
        guard  let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if Utility.isDeviceIpad() {
            cardViewModel.calculateCardWidth()
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Collectionview  methods
extension CardsListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func registerCellsAndHeaders() {
        self.collectionView.register(UINib(nibName: "CardlistCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CardlistCollectionCell")
        self.collectionView.register(UINib(nibName: "DashboardEmptyCard", bundle: nil), forCellWithReuseIdentifier: "DashboardEmptyCard")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 1
        if isSearchOn {
            count += searchResult.count
        } else {
            count += originalCards.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        if indexPath.item == 0 {
            if let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardEmptyCard", for: indexPath) as? DashboardEmptyCard {
                aCell.configureUI()
                aCell.cellWidth.constant = cardViewModel.cardWidth
                aCell.btnCreateCard.addTarget(self, action: #selector(addCard), for: .touchUpInside)
                return aCell
            }
        } else {
            if let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardlistCollectionCell", for: indexPath) as? CardlistCollectionCell {
                
                if isSearchOn {
                    let cardObject = searchResult[indexPath.row - 1]
                    aCell.configureCell(with: cardObject, shouldShowCardStatus: true)
                } else {
                    let cardObject = originalCards[indexPath.row - 1]
                    aCell.configureCell(with: cardObject, shouldShowCardStatus: true)
                }
                
                aCell.cardFrontView.switchCardState.tag = indexPath.row - 1
                aCell.cardFrontView.switchCardState.addTarget(self, action: #selector(cardStateChanged(sender:)), for: .valueChanged)
                
                if Utility.isDeviceIpad() {
                    aCell.cardFrontView.cellWidth.constant = cardViewModel.cardWidth - 32
                    aCell.cardFrontView.cellHeight.constant = cardViewModel.cardHeightRation
                    aCell.cardFrontView.imgVwCard.contentMode = .scaleToFill
                } else {
                    let itemSize = (collectionView.frame.width - 32 - (collectionView.contentInset.left + collectionView.contentInset.right + 10))
                    let aheight = itemSize /  1.64
                    aCell.cardFrontView.cellWidth.constant = itemSize
                    aCell.cardFrontView.cellHeight.constant = aheight
                }
                return aCell
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aWidth: CGFloat = cardViewModel.cardWidth
        let  aHeight: CGFloat = aWidth / cardViewModel.cardHeight
        if Utility.isDeviceIpad() {
            return CGSize(width: aWidth, height: aHeight + 110)
        } else {
            let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10))
            var aheight = itemSize /  1.64
            if indexPath.item != 0 {
                aheight += 90
            }
            
            return CGSize(width: itemSize, height: aheight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    // Cell Margin
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    @objc func cardClicked(sender: UIButton) {
        let itag = sender.tag
        let selectedCard = originalCards[itag] as CardModel
        
        AppGlobalData.shared().selectedCardModel = selectedCard
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.selectCardFromDashboard), object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addCard()
        } else {
            if isSearchOn {
                cardData = self.searchResult[indexPath.row - 1]
            } else {
                cardData = self.originalCards[indexPath.row - 1]
            }
            
            if let status = cardData?.cardStatus {
                if status ==  CardStatus.pendingActivation {
                    activateCard()
                } else {
                    BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
                        if shouldMoveAhead {
                            self.gotoCardInfo()
                        }
                    }
                }
            }
        }
    }
    
    //fetch next set of cards..
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            self.getNextCardList()
        }
    }
}

// MARK: - Navigation
extension CardsListVC {
    @objc func btnActivateClick(sender: UIButton) {
        cardData = originalCards[sender.tag]
        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                let storyboard: UIStoryboard = UIStoryboard(name: "Card", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "CardActivationVC") as? CardActivationVC {
                    vc.cardData = self.cardData
                    let navController = UINavigationController(rootViewController: vc)
                    self.present(navController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func gotoCardInfo() {
        self.performSegue(withIdentifier: "GoToCardInfoScreen", sender: self)
    }
    
    func gotoCardDetails() {
        self.performSegue(withIdentifier: "gotoCarddetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let infoVC = segue.destination as? CardInfoVC {
            infoVC.cardModel = self.cardData
        }
        
        if let destinationVC = segue.destination as? CardActivationVC {
            destinationVC.cardData = self.cardData
        }
    }
}

// MARK: - Textfield delegate methods
extension CardsListVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let completeText = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = completeText
        searchCardsFor(text: completeText)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearchOn = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            textField.resignFirstResponder()
        }
        searchCardsFor(text: "")
        return true
    }
}

// MARK: - Other methods
extension CardsListVC {
    func searchCardsFor(text search: String) {
        if search.count >= Constants.minimumSearchCharacter {
            isSearchOn = true
            searchResult.removeAll()
            var addToSearchResult: Bool?
            originalCards.forEach { (card) in
                addToSearchResult = false
                
                addToSearchResult = (card.label?.lowercased().contains(search.lowercased()))! || (card.limitAmount?.lowercased().contains(search.lowercased()))! || (card.last4?.lowercased().contains(search.lowercased()))!
                
                if addToSearchResult! {
                    searchResult.append(card)
                }
                collectionView.reloadData()
            }
        } else if search.count == 0 {
            clearSearchData()
            collectionView.reloadData()
        }
    }
    
    func clearSearchData() {
        searchTextField.resignFirstResponder()
        searchResult.removeAll()
        searchResult = [CardModel]()
        isSearchOn = false
    }
}

extension CardsListVC: SkeletonCollectionViewDataSource {
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let screenRectHeight = UIScreen.main.bounds.height
        return Int(screenRectHeight/78)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "CardlistCollectionCell"
    }
}
