//
//  ContactsListVC.swift
//  Solid
//
//  Created by Solid iOS Team on 02/03/21.
//

import UIKit
import SkeletonView

class ContactsListVC: BaseVC {
	@IBOutlet weak var tblContacts: UITableView!
	@IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblNoContactTitle: UILabel!

    @IBOutlet weak var topConstTitleLabelContainer: NSLayoutConstraint!
    @IBOutlet weak var hConstTitleLabelContainer: NSLayoutConstraint!
    @IBOutlet weak var vwTitleContainer: UIView!
	@IBOutlet weak var searchbarContainer: UIView!

    var originalContacts = [ContactDataModel]()
    var searchResult = [ContactDataModel]()
    var totalContactsCount = 0
    var fetchContactsWithLimit = Constants.fetchLimit
    var offset = 0
    var bottomLoading = UIActivityIndicatorView()

    var allContacts = [Character: [ContactDataModel]]()
	var headerTitles = [Character]()
	var isSearchOn = false
	var checkStatusType: FundType? = .unknown
	public var isContactListloading: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        if checkStatusType == .checkDeposit {
            addBackNavigationbarButton()
            self.title = Utility.localizedString(forKey: "cotacts_list_title")
            topConstTitleLabelContainer.constant = 24.0
            hConstTitleLabelContainer.constant = 0.0
            vwTitleContainer.isHidden = true
        } else {
            addCustomNavigationBar()
            topConstTitleLabelContainer.constant = Utility.getTopSpacing() + 10
            hConstTitleLabelContainer.constant = 40.0
            vwTitleContainer.isHidden = false
        }
        addObserverToReloadContacts()
		registerCellsAndHeaders()
		configureSearchField()
        getContacts()
		isContactListloading = true
		self.tblContacts.reloadData()
        
        //for pagination...
        bottomLoading = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        bottomLoading.color = UIColor.darkGray
        bottomLoading.hidesWhenStopped = true
        tblContacts.tableFooterView = bottomLoading
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isNavigationBarHidden = checkStatusType != .checkDeposit
        self.isNavigationBarTranslucent = checkStatusType != .checkDeposit
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        searchTextField.textColor = .primaryColor
        btnAdd.setTitleColor(UIColor.primaryColor, for: .normal)
        lblNoContactTitle.textColor = UIColor.secondaryColorWithOpacity
        lblTitle.textColor = UIColor.primaryColor
        let searchPlaceholder = Utility.localizedString(forKey: "cotacts_list_seach_placeholder")
        let pFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryColorWithOpacity, NSAttributedString.Key.font: pFont])
        
        if let leftView  = searchTextField.leftView {
            let baseImg = leftView.viewWithTag(Constants.tagForSeachIconInSearchBar)
            baseImg?.tintColor = UIColor.secondaryColorWithOpacity
        }

        tblContacts.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isNavigationBarTranslucent = false
    }

    func setUI() {
        lblTitle.font = Constants.commonFont
        lblTitle.textColor = UIColor.primaryColor
        lblTitle.text = Utility.localizedString(forKey: "cotacts_list_title")

        btnAdd.layer.cornerRadius = Constants.cornerRadiusThroughApp
        btnAdd.layer.masksToBounds = true
        btnAdd.backgroundColor = .background
        btnAdd.setTitleColor(UIColor.primaryColor, for: .normal)
        btnAdd.contentHorizontalAlignment = .center
        let btnTitle = Utility.localizedString(forKey: "cotacts_list_addContact")
        btnAdd.setAttributedTitle(btnTitle.getAttributedAddContactString(), for: .normal)
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        lblNoContactTitle.font = labelFont
        lblNoContactTitle.textAlignment = .center
        lblNoContactTitle.textColor = UIColor.secondaryColorWithOpacity
    }

    func addObserverToReloadContacts() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContactsAfterAddEdit), name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterAddEdit), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContactsAfterAddEdit), name: NSNotification.Name(rawValue: NotificationConstants.reloadContactsAfterDelete), object: nil)
    }

    @objc func reloadContactsAfterAddEdit(notification: NSNotification) {
        resetData()
        tblContacts.reloadData()
		getContacts()
    }

    func resetData() {
        originalContacts.removeAll()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.view.endEditing(true)
        }
        searchTextField.text = ""
        isSearchOn = false
        searchResult.removeAll()
    }

	// Get Contact List Data
    func getContacts() {
        self.view.showAnimatedGradientSkeleton()
        self.getContactList(type: "others", limit: "\(fetchContactsWithLimit)", offset: "\(offset)") { (response, _) in
            self.isContactListloading = true
            self.view.hideSkeleton()
            if let contactlist = response?.data, contactlist.count > 0 {
                self.totalContactsCount = response?.total ?? 0
                self.originalContacts = contactlist.sorted(by: { $0.name?.lowercased() ?? ""  < $1.name?.lowercased()  ?? ""})
            } else {
                self.totalContactsCount = response?.total ?? 0
                self.originalContacts = [ContactDataModel]()
            }
            
            self.tblContacts.reloadData()
        }
    }
    
    func getNextContactsList() {
        if self.totalContactsCount > self.originalContacts.count {
            self.bottomLoading.startAnimating()
            
            offset += fetchContactsWithLimit
            self.getContactList(type: "others", limit: "\(fetchContactsWithLimit)", offset: "\(offset)") { (contactsList, _) in
                self.bottomLoading.stopAnimating()
                
                if let contacts = contactsList?.data, contacts.count > 0 {
                    self.originalContacts += contacts
                    self.originalContacts = self.originalContacts.sorted(by: { $0.name?.lowercased() ?? ""  < $1.name?.lowercased()  ?? ""})

                    self.tblContacts.reloadData()
                }
            }
        }
    }
}

// MARK: - Navigationbar
extension ContactsListVC {

	func configureSearchField() {
        let searchPlaceholder = Utility.localizedString(forKey: "cotacts_list_seach_placeholder")
		let pFont = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchPlaceholder,
																   attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryColorWithOpacity, NSAttributedString.Key.font: pFont])
		searchTextField?.leftViewMode = UITextField.ViewMode.always
        searchTextField?.backgroundColor = .background
        searchTextField.cornerRadius = Constants.cornerRadiusThroughApp
        searchTextField.layer.masksToBounds = true
        searchTextField.textColor = .primaryColor
		let imgSize = 24
		let padding = 8

		let outerView = UIView(frame: CGRect(x: 0, y: 0, width: (imgSize + (padding*2)), height: imgSize) )
		let searchImageView = BaseImageView(frame: CGRect(x: padding, y: 0, width: imgSize, height: imgSize))
        searchImageView.image = UIImage(named: "Ic_search")?.withTintColor(.secondaryColorWithOpacity, renderingMode: .alwaysOriginal)
        searchImageView.tag = Constants.tagForSeachIconInSearchBar
		outerView.addSubview(searchImageView)
		searchTextField?.leftView = outerView
	}
}

// MARK: - Navigation
extension ContactsListVC {

    func goToContactDetailsVC() {
        let storyboard = UIStoryboard.init(name: "Contact", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ContactDetailsVC") as? ContactDetailsVC {
            vc.contactFlow = .create
			if self.checkStatusType == FundType.checkDeposit {
				checkStatusType = .checkDeposit
                vc.checkStatusType = .checkDeposit
			}
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func btnAddContactClick(sender: UIButton) {
        goToContactDetailsVC()
    }

}

// MARK: - Textfield delegate methods
extension ContactsListVC: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else {
			return false
		}

		let completeText = (text as NSString).replacingCharacters(in: range, with: string)
		textField.text = completeText
		searchContactFor(text: completeText)
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
		searchContactFor(text: "")
		return true
	}
}

extension ContactsListVC {

	func searchContactFor(text search: String) {
		if search.count >= Constants.minimumSearchCharacter {
			isSearchOn = true
			searchResult.removeAll()
			var addToSearchResult: Bool?
			originalContacts.forEach { (contact) in
				addToSearchResult = false
				addToSearchResult = (contact.name?.lowercased().contains(search.lowercased()))

				if addToSearchResult! {
					searchResult.append(contact)
				}
				tblContacts.reloadData()
			}

		} else if search.count == 0 {
			searchTextField.resignFirstResponder()
			searchResult.removeAll()
			searchResult = [ContactDataModel]()
			isSearchOn = false
			tblContacts.reloadData()
		}
	}
}

extension ContactsListVC: UITableViewDelegate, UITableViewDataSource {
	func registerCellsAndHeaders() {
		self.tblContacts.register(UINib(nibName: "ContactCell", bundle: .main), forCellReuseIdentifier: "contactlistcell")
		self.tblContacts.register(UINib(nibName: "SkeletonLoaderCell", bundle: .main), forCellReuseIdentifier: "SkeletonLoaderCell")
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		var count = 0
		if isSearchOn {
			count = searchResult.count
		} else {
			count = originalContacts.count
		}
		return count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let cell = tableView.dequeueReusableCell(withIdentifier: "contactlistcell", for: indexPath) as? ContactCell {
			cell.selectionStyle = .none

            let rowData = isSearchOn ? searchResult[indexPath.row] : originalContacts[indexPath.row]
            cell.configureContactListCell(forRow: rowData)
            cell.imgSeperator.backgroundColor = .customSeparatorColor
            cell.imgSeperator.isHidden = true
			if isSearchOn {
                if searchResult.count > 1 && indexPath.row != searchResult.count - 1 {
                    cell.imgSeperator.isHidden = false
                }
			} else {
                if originalContacts.count > 1 && indexPath.row != originalContacts.count - 1 {
                    cell.imgSeperator.isHidden = false
                }
			}
            
            //fetch next set of contacts..
            if indexPath.row == originalContacts.count - 2 {
                self.getNextContactsList()
            }
            
            return cell
		}

		return UITableViewCell()
	}

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.drawCornersAroundSection(for: indexPath, willDisplay: cell)
    }

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
		let labelFont = Utility.isDeviceIpad() ? Constants.mediumFontSize16: Constants.mediumFontSize14
        label.font = labelFont
        label.textAlignment = .left
        label.textColor = UIColor.primaryColor

		if self.originalContacts.count > 0 {
            label.text = Utility.localizedString(forKey: "cotacts_list_header")
			label.textAlignment = .left
            lblNoContactTitle.isHidden = true
            lblNoContactTitle.text = ""
		} else {
            lblNoContactTitle.isHidden = false
			if isContactListloading {
				lblNoContactTitle.text = Utility.localizedString(forKey: "no_contact")
			}
		}

        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 2).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerView.layoutIfNeeded()

        containerView.backgroundColor = UIColor.grayBackgroundColor

        return containerView
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.originalContacts.count == 0 ? 1 : 40
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let heightV: CGFloat = isContactListloading ? 64 : 48
		return heightV
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if checkStatusType == FundType.checkDeposit {
			let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
			if let vc = storyboard.instantiateViewController(withIdentifier: "CaptureCheckViewController") as? CaptureCheckViewController {
				vc.paymentModel = RCModel()
				if isSearchOn {
					let rowData = searchResult[indexPath.row] as ContactDataModel
					vc.contactId = rowData.id
                    vc.contactName = rowData.name
				} else {
					let rowData = originalContacts[indexPath.row] as ContactDataModel
					vc.contactId = rowData.id
                    vc.contactName = rowData.name
				}
				self.navigationController?.pushViewController(vc, animated: true)
			}
		} else {
			let storyboard = UIStoryboard.init(name: "Contact", bundle: nil)
			if let vc = storyboard.instantiateViewController(withIdentifier: "ContactInfoVC") as? ContactInfoVC {
				if isSearchOn {
					let rowData = searchResult[indexPath.row] as ContactDataModel
					vc.contactData = rowData
				} else {
					let rowData = originalContacts[indexPath.row] as ContactDataModel
					vc.contactData = rowData
				}
				self.show(vc, sender: self)
			}
		  }
    }
}

extension ContactsListVC: SkeletonTableViewDataSource {
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
		self.orientationChangedViewController(tableview: self.tblContacts, with: coordinator)
	}
}
