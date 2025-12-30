//
//  UIViewController+Utility
//  Solid
//
//  Created by Solid iOS Team on 08/02/21.
//

import UIKit
import MessageUI

extension UIViewController {
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    public convenience init(useNib: Bool) {
        self.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    static func from<T>(storyboard: String) -> T {
        guard let controller = UIStoryboard(name: storyboard, bundle: nil).instantiateInitialViewController() as? T else {
            fatalError("unable to instantiate view controller")
        }
        
        return controller
    }
    
    static func from<T>(from storyboard: String, with identifier: String) -> T {
        guard let controller = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("unable to instantiate view controller")
        }
        
        return controller
    }
    
    func addBackNavigationbarButton() {
        let anAction = #selector(backClick)
        let img = UIImage(named: "navBack")
        let barButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: anAction)
        barButtonItem.tintColor = .primaryColor
        barButtonItem.tag = Constants.tagForRegulatBackButton
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func updateBackBtnColor() {
        self.navigationItem.leftBarButtonItem?.tintColor = .primaryColor
    }
    
    @objc func backClick() {
        self.popVC()
    }
    
    @objc func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setCloseButtonAtRight() {
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        closeButton.contentHorizontalAlignment = .right
        closeButton.tag = Constants.tagForNavRightCloseButton
        closeButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        closeButton.tintColor = .brandColor
        
        let barButton = UIBarButtonItem(customView: closeButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func dismissController() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setNavigationTitleUI() {
        let fontSize = Utility.isDeviceIpad() ? 24.0 : 20.0
      
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.background
        navigationController?.navigationBar.barTintColor = UIColor.background
        
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.sfProDisplayMedium(fontSize: fontSize), NSAttributedString.Key.foregroundColor: UIColor.brandColor]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func addNavigationbarButton(_ imageName: String = "", buttonTitle aTitle: String = "", buttonTextColor aColor: UIColor = UIColor.primaryColor, addSide atSide: NavigationButton = NavigationButton.rightButton) {
        var barButtonItem = UIBarButtonItem()
        let anAction = (atSide == .rightButton) ? #selector(rightButtonAction) : #selector(leftButtonAction)
        
        if !aTitle.isEmpty {
            
            let aFont = (atSide == .rightButton) ? UIFont.sfProDisplayRegular(fontSize: 14.0) : UIFont.sfProDisplayMedium(fontSize: 14.0)
            let aColorForDisable = (atSide == .rightButton) ? aColor.withAlphaComponent(0.25) : aColor
            
            barButtonItem = UIBarButtonItem(title: aTitle, style: .plain, target: self, action: anAction)
            barButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: aColor, NSAttributedString.Key.font: aFont], for: .normal)
            barButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: aColorForDisable, NSAttributedString.Key.font: aFont], for: .disabled)
            
        } else {
            let img = UIImage(named: imageName)
            barButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: anAction)
            
        }
        
        if atSide == .rightButton {
            self.navigationItem.rightBarButtonItem = barButtonItem
            self.enableRightBarButton(shouldEnable: false)
            
        } else {
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
    }
    
    @objc func rightButtonAction() {
        // This method is required. Override by child class
    }
    
    @objc func leftButtonAction() {
        // This method is required. Override by child class
    }
    
    func enableRightBarButton(shouldEnable: Bool) {
        if shouldEnable {
            self.navigationItem.rightBarButtonItem?.isEnabled =  true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled =  false
        }
    }
    
    func removeRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func registerKeyboardObserver() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didShowOrHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        nc.addObserver(self, selector: #selector(didShowOrHideKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func isDeviceIpad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
    }
    
    func deregisterKeyboardObserver() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func didShowOrHideKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let keyboardHeight = (notification.name == UIResponder.keyboardWillHideNotification) ? 0 : keyboardViewEndFrame.height
        self.handleKeyboardEvent(keyboardHeight: keyboardHeight)
        
    }
    
    @objc func handleKeyboardEvent(keyboardHeight: CGFloat) {
        // This method is required. Override by child class
    }
    
    func regiserForOrinetationChange() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func didOrientationChange(notif: Notification) {
        self.handleOrientationChange(notif: notif)
    }
    
    @objc func handleOrientationChange(notif: Notification) {
        // This method is required.
    }
    
    func alert(src: UIViewController, _ title: String?, _ message: String?, _ yesButton: String? = nil, _ noButton: String? = nil, _ onClick:((_ buttonIndex: Int) -> Void)? = nil ) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yes = UIAlertAction(title: yesButton ?? "OK", style: .default) { (_) in
            onClick?(1)
        }
        ac.addAction(yes)
        
        if let nobtnText = noButton {
            let no = UIAlertAction(title: nobtnText, style: .cancel) { (_) in
                onClick?(2)
            }
            ac.addAction(no)
        }
        
        src.present(ac, animated: true)
    }
    
    func getNavigationbarHeight() -> CGFloat {
        var statusBarHeight: CGFloat!
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        let navBarHeight = statusBarHeight + (navigationController?.navigationBar.frame.height ?? 0.0)
        
        return navBarHeight
    }
    
    func orientationChangedViewController(tableview: UITableView, with coordinator: UIViewControllerTransitionCoordinator) {
        let animationHandler: ((UIViewControllerTransitionCoordinatorContext) -> Void) = { (_) in
            tableview.reloadData()
        }
        
        let completionHandler: ((UIViewControllerTransitionCoordinatorContext) -> Void) = { (_) in
            tableview.reloadData()
        }
        coordinator.animate(alongsideTransition: animationHandler, completion: completionHandler)
    }
}

extension UINavigationController {
    func backToViewController(viewController: Swift.AnyClass) {
        for element in viewControllers as Array {
            if element.isKind(of: viewController) {
                self.popToViewController(element, animated: true)
                break
            }
        }
    }
}
