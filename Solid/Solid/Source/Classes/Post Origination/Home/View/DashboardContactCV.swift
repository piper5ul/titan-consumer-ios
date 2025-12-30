//
//  DashboardContactCV.swift
//  Solid
//

import Foundation
import UIKit
import SkeletonView
class DashboardContactCV: UICollectionView {
	var originalContacts = [Any]()
	public func setup() {
		registerCell()
		delegate = self
		dataSource = self
		self.isSkeletonable = true
		self.reloadContacts()
	}

	func registerCell() {
		self.register(UINib(nibName: "DashboardContactCollectionCell", bundle: nil), forCellWithReuseIdentifier: "DashboardContactCollectionCell")
	}
}

// MARK: - API calls
extension DashboardContactCV {
	func reloadContactsList() {
		self.reloadData()
	}

	func reloadContacts() {
		self.reloadData()
	}
}
extension DashboardContactCV: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppGlobalData.shared().contactList.count 
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let height: CGFloat = 108
		let width: CGFloat = 95
		return CGSize(width: width, height: height)
	}

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = UICollectionViewCell()

		if AppGlobalData.shared().contactList.count > indexPath.row, let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardContactCollectionCell", for: indexPath) as? DashboardContactCollectionCell {
				let contactObject = AppGlobalData.shared().contactList[indexPath.row]
				aCell.configureCell(with: contactObject )
				return aCell
		}
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.contactClicked(forcontact: indexPath.row)
    }

	@objc func contactClicked(forcontact: Int) {
		let selectedContact = AppGlobalData.shared().contactList[forcontact] as ContactDataModel
		AppGlobalData.shared().selectedContactModel = selectedContact
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.selectContactFromDashboard), object: nil)
	}
	
}
extension DashboardContactCV: SkeletonCollectionViewDataSource {
	
	func numSections(in collectionSkeletonView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let screenRectHeight = UIScreen.main.bounds.height
		return Int(screenRectHeight/78)
	}
	
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
		return "AddAccountCollectionCell"
	}
}
