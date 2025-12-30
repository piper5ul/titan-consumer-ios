//
//  RCDTypeVC.swift
//  Solid
//
//  Created by Solid iOS Team on 8/6/21
//

import UIKit
import SkeletonView

class RCDTypeVC: BaseVC {

    @IBOutlet weak var tblType: UITableView!

    var arrTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialUI()
        setupInitialData()
    }
}

// MARK: - UI
extension RCDTypeVC {

    func setupInitialUI() {

        self.title = Utility.localizedString(forKey: "RCD_captureScreen_navTitle")

        setNavigationBar()
        registerCell()
    }

    func setupInitialData() {
        let strTitleDepositeCheck = Utility.localizedString(forKey: "RCD_depositCheck")
        let strTitleDepositeCheckStatus = Utility.localizedString(forKey: "RCD_depositedCheck_status")

        arrTitles = [strTitleDepositeCheck, strTitleDepositeCheckStatus]
        tblType.reloadData()
    }
}

// MARK: - Navigation
extension RCDTypeVC {

    func setNavigationBar() {
        self.isNavigationBarHidden = false
        // navigationController?.navigationBar.backgroundColor = UIColor.white
        addBackNavigationbarButton()
    }

    func gotoContactList() {

        BiometricHelper.showAuth(sourceController: self, withScreen: true, shouldLogout: false) { (shouldMoveAhead) in
            if shouldMoveAhead {
                let storyboard: UIStoryboard = UIStoryboard(name: "Contact", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "ContactsListVC") as? ContactsListVC {
                    vc.checkStatusType = .checkDeposit
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

    func gotoRCDStatusList() {
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "RCDStatusVC") as? RCDStatusVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UITableView
extension RCDTypeVC: UITableViewDelegate, UITableViewDataSource {

    func registerCell() {
        tblType.register(UINib(nibName: "DataActionCell", bundle: nil), forCellReuseIdentifier: "DataActionCell")
		tblType.register(UINib(nibName: "SkeletonLoaderCell", bundle: nil), forCellReuseIdentifier: "SkeletonLoaderCell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "DataActionCell", for: indexPath) as? DataActionCell {
            let strTitle = arrTitles[indexPath.row]
			let labelCenterFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize14
            cell.lblcenterValue.font = labelCenterFont
            cell.lblTitle.text = ""
            cell.lblcenterValue.isHidden = false
            cell.lblcenterValue.text = strTitle
            cell.showDetailIcon(shouldShow: true)
            cell.selectionStyle = .none

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {
            case 0:
                gotoContactList()
            case 1:
                gotoRCDStatusList()
			default:
                break
        }
    }
}
extension RCDTypeVC: SkeletonTableViewDataSource {
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
