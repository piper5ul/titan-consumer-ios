//
//  AppDelegate.swift
//  Solid
//
//  Created by Solid iOS Team on 2/4/21.
//

import UIKit
import VGSShowSDK
import Reachability

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CheckJailBreak {
        
    var window: UIWindow?
    var greyView = UIView()
    var bannerView = Banner()
    let reachability = try? Reachability()
    var isreachable: Bool = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //CHECK FOR THE JAILBREAK DEVICE..
        assignJailBreakCheckType(type: .readAndWriteFiles)

        AppConfigurations.addAllAppConfigurations()
        Security.handleAppOnFirstInstall()
        addObserverForNotification()
        setVGSLogs()

        //TO GET BATTERY LEVEL..
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        //SSL PINNING..
        SSLPinning.startSSLPinning()
        
        //TO REMOVE TEMP FILE
        FileManager.default.clearTmpDirectory()

        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        showAutoLock()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        addGreyView()
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        window.rootViewController = vc
    }
    
    func sendTheStatusOfJailBreak(isJailBreak: Bool) {
        if isJailBreak {
            let jailbrokenVC = JailBrokenViewController(useNib: true)
            self.changeRootViewController(jailbrokenVC)
        }
    }
}

// MARK: - Auto lock / Biometric
extension AppDelegate {
    
    func showAutoLock() {
        if let data = AppGlobalData.getSessionData() {
            AppData.updateSession(idToken: data.idToken ?? "" as String, accessToken: data.accessToken ?? "" as String, refreshToken: data.refreshToken ?? "" as String)
            AppGlobalData.shared().storeSessionData()
            
            APIManager.networkEnviroment = NetworkEnvironment.getApiEnv(for: AppGlobalData.apiEnv)
            
            if let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window, let rootVC = window.rootViewController, let rootNavCtrl = rootVC as? UINavigationController, let vc = rootNavCtrl.visibleViewController {
                BiometricHelper.showAuth(sourceController: vc, withScreen: true) { (shouldMoveAhead) in
                    if shouldMoveAhead {
                        self.removeGreyView()
                    }
                }
            }
        }
    }
    
    func addGreyView() {
        if let _ = AppGlobalData.getSessionData(), let appDeleg = (UIApplication.shared.delegate) as? AppDelegate, let window = appDeleg.window, let rootVC = window.rootViewController, let rootNavCtrl = rootVC as? UINavigationController, let _ = rootNavCtrl.visibleViewController {
            let screenRect = UIScreen.main.bounds
            greyView.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
            greyView.backgroundColor = .gray
            greyView.tag = Constants.tagForGreyView
            
            if UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.viewWithTag(Constants.tagForGreyView) == nil {
                UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(greyView)
            }
        }
    }
    
    func removeGreyView() {
        greyView.removeFromSuperview()
    }
    
    func addObserverForNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let errorMessage = Utility.localizedString(forKey: "no_internet_message")
        let errorImage = UIImage(named: "error_icon")
        
        let  successMessage = Utility.localizedString(forKey: "connection_restored_message")
        let successImage = UIImage(named: "success_icon")
        
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi, .cellular:
            showSuccessBannerView(title: successMessage, image: successImage!)
        case .none, .unavailable:
            isreachable = false
            showBannerView(title: errorMessage, image: errorImage!)
        }
    }

    func showBannerView(title: String, image: UIImage) {
        bannerView = Banner(title: title, image: image, backgroundColor: .grayInternetContainerColor)
        bannerView.show()
    }
    
    func showSuccessBannerView(title: String, image: UIImage) {
        if !isreachable {
            bannerView.dismiss()
            bannerView = Banner(title: title, image: image, backgroundColor: .grayInternetContainerColor)
            bannerView.show()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                self.hideBanner()
            }
            isreachable = true
        }
    }
    
    func hideBanner() {
        bannerView.dismiss()
    }
}

// MARK: - VGS
extension AppDelegate {
    func setVGSLogs() {
        // *Setup loggers in AppDelegate -init as the earliest app stage.
        
        // Enable loggers only for debug!
        #if DEBUG
        // Setup VGS Show loggers:
        // Show warnings and errors.
        VGSLogger.shared.configuration.level = .info
        
        // Show network session for reveal requests.
        VGSLogger.shared.configuration.isNetworkDebugEnabled = true
        
        // *You can stop all VGS Show loggers in app:
        // VGSLogger.shared.disableAllLoggers()
        
        // Setup VGS Collect loggers:
        // Show warnings and errors.
        //VGSCollectLogger.shared.configuration.level = .info
        
        // Show network session for collect requests.
        //VGSCollectLogger.shared.configuration.isNetworkDebugEnabled = true
        
        // *You can stop all VGS Collect loggers in app:
        // VGSCollectLogger.shared.disableAllLoggers()
        #endif
    }
}
