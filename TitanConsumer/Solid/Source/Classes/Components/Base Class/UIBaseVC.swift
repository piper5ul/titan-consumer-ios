//
//  UIBaseVC.swift
//  Solid
//
//  Created by Solid iOS Team on 23/06/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit

class UIBaseVC: UIViewController {

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var greyView: UIView = UIView()

}

// MARK: -
extension UIBaseVC {

    func identifyUser() {
        let userObj = AppGlobalData.shared().personData
        let id = userObj.id
        Segment.identify(userId: id, name: userObj.name)
    }
    
    func showAlertMessage(titleStr: String, messageStr: String) {
        let alertController = UIAlertController(title: titleStr,
                                                message: messageStr,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: Utility.localizedString(forKey: "ok"), style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func activityIndicatorBegin() {

        activityIndicatorEnd()

        let currentWindow: UIWindow? = UIApplication.shared.windows.filter({$0.isKeyWindow}).first // UIApplication.shared.keyWindow

        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        activityIndicator.center = currentWindow!.center
        activityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            // Fallback on earlier versions
            activityIndicator.style = .whiteLarge
        }
        // #warning("Remove target based code once flow is finalised")
        let indicatorColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.brandColor
        activityIndicator.color = indicatorColor
        activityIndicator.tag = 101
        currentWindow?.addSubview(activityIndicator)
		activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
		activityIndicator.startAnimating()
        // disableUserInteraction()

        greyView = UIView()
        let screenRect = UIScreen.main.bounds
        greyView.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        greyView.backgroundColor = .black
        greyView.alpha = 0.3
        greyView.tag = 102
        currentWindow?.addSubview(greyView)
		greyView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
		    }

    func activityIndicatorEnd() {
        self.activityIndicator.stopAnimating()
        // enableUserInteraction()
       // self.greyView.removeFromSuperview()

        let currentWindow: UIWindow? = UIApplication.shared.windows.filter({$0.isKeyWindow}).first // UIApplication.shared.keyWindow
        currentWindow?.viewWithTag(101)?.removeFromSuperview()
        currentWindow?.viewWithTag(102)?.removeFromSuperview()
    }
}

// MARK: - Navigation methods
extension UIBaseVC {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "GoToContactsListVC", let kycvc = segue.destination as? ContactsListVC {
            kycvc.checkStatusType = .checkDeposit
        }
    }

    func gotoKYCStatusScreen(aKycStatus: KYCStatus) {

        let storyboard: UIStoryboard = UIStoryboard(name: "KYC", bundle: nil)
        if let kycVC = storyboard.instantiateViewController(withIdentifier: "KYCStatusVC") as? KYCStatusVC {
            kycVC.kycStatus = aKycStatus
            self.show(kycVC, sender: self)
        }
    }

    func gotoLoginCreatedScreen() {

        if let viewController = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "LoginCreatedVC") as? LoginCreatedVC, let navigator = navigationController {
            navigator.pushViewController(viewController, animated: true)
        }
    }

    func gotoBusinessDetailScreen(businessData: BusinessDataModel?) {
        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let businessVC = storyboard.instantiateViewController(withIdentifier: "BusinessDetailsVC") as? BusinessDetailsVC {
            if let bData =  businessData {
                businessVC.businessData = bData
            }
            self.show(businessVC, sender: self)
        }
    }

    func gotoKYBStatusScreen(aKybStatus: KYBStatus, aBusinessData: BusinessDataModel) {

        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let kybVC = storyboard.instantiateViewController(withIdentifier: "KYBStatusVC") as? KYBStatusVC {
            kybVC.kybStatus = aKybStatus
            kybVC.businessData = aBusinessData
            self.show(kybVC, sender: self)
        }
    }
    
    func gotoAccountSetupScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Account", bundle: nil)
        if let accountVC = storyboard.instantiateViewController(withIdentifier: "AccountSetupVC") as? AccountSetupVC {
            self.show(accountVC, sender: self)
        }
    }

    func gotoAccountDetailScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "KYB", bundle: nil)
        if let accountDetailVC = storyboard.instantiateViewController(withIdentifier: "AccountDetailsVC") as? AccountDetailsVC {
            self.show(accountDetailVC, sender: self)
        }
    }

    func gotoAccountTypeSelectioncreen() {
        if let viewController = UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "SelectAccountTypeVC") as? SelectAccountTypeVC, let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
        }
    }
    
	func gotoAccountSelectioncreen() {
		if let viewController = UIStoryboard(name: "KYC", bundle: nil).instantiateViewController(withIdentifier: "SelectAccountTypeVC") as? SelectAccountTypeVC, let navigator = navigationController {
				navigator.pushViewController(viewController, animated: true)
		}
	}

    func gotoHomeScreen() {
		AppGlobalData.shared().appFlow = .PO
        let storyboard: UIStoryboard = UIStoryboard(name: "Account", bundle: nil)
        self.navigationController?.dismiss(animated: false, completion: {
            if let bankAccListVC = (storyboard.instantiateViewController(withIdentifier: "BankAccListVC") as? BankAccListVC), let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window {
                   // rootVC.show(dashboardVC, sender: self)
                    // appDeleg.changeRootViewController(dashboardNavCtrl)
					let navController = UINavigationController(rootViewController: bankAccListVC)
					window.rootViewController = navController
            }
        })

    }

    func popToHomeScreen() {
        self.navigationController?.dismiss(animated: false, completion: {
            if let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window, let rootVC = window.rootViewController, let rootNavCtrl = rootVC as? UINavigationController {
                if let dashboardObj = rootNavCtrl.viewControllers.filter({ $0.isKind(of: DashboardVC.self) }).first {
                    rootNavCtrl.popToViewController(dashboardObj, animated: true)

                    return
                }

                if let bankListObj = rootNavCtrl.viewControllers.filter({ $0.isKind(of: BankAccListVC.self) }).first {
                    rootNavCtrl.popToViewController(bankListObj, animated: true)

                    let storyboard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                    if let dashboardVC = (storyboard.instantiateViewController(withIdentifier: "DashboardVC") as? DashboardVC) {
                        bankListObj.navigationController?.pushViewController(dashboardVC, animated: false)
                    }
                }
            }
        })
    }

    func popToWelcomeScreen() {
        self.navigationController?.dismiss(animated: false, completion: {
            if let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window, let rootVC = window.rootViewController, let rootNavCtrl = rootVC as? UINavigationController {
                rootNavCtrl.popToRootViewController(animated: true)
            }
        })
    }

    func gotoWelcomeScreen() {
        let storyboard = UIStoryboard.init(name: "Auth", bundle: nil)
        if let welcomeVC = (storyboard.instantiateViewController(withIdentifier: "WelcomeVC") as? WelcomeVC) {
            let navController = UINavigationController(rootViewController: welcomeVC)
            if let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window {
                window.rootViewController = navController
            }
        }
    }

	func gotoKYBScreen(businessData: BusinessDataModel?) {
		let kybStoryboard = UIStoryboard.init(name: "KYB", bundle: nil)
		let businessDetailsVC: BusinessDetailsVC?

		if #available(iOS 13.0, *) {
			businessDetailsVC = kybStoryboard.instantiateViewController(identifier: "BusinessDetailsVC") as BusinessDetailsVC
		} else {
			businessDetailsVC = kybStoryboard.instantiateViewController(withIdentifier: "BusinessDetailsVC") as? BusinessDetailsVC
		}

		if let kybVC = businessDetailsVC {
			if let bData = businessData {
				kybVC.businessData = bData
			}
			self.navigationController?.pushViewController(kybVC, animated: true)
		}
	}
    
    func navigatetoCashDashboard() {
        if let viewController = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "DashboardVC") as? DashboardVC, let navigator = navigationController {
            navigator.pushViewController(viewController, animated: true)
        }
    }
    
    func handleNavigationForAccountSetup() {
        self.gotoAccountSetupScreen()
    }
}
