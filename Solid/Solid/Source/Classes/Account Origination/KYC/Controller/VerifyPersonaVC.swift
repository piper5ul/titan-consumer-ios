//
//  VerifyPersonaVC.swift
//  Solid
//
//  Created by Solid iOS Team on 23/09/21.
//

import UIKit
import WebKit

class VerifyPersonaVC: BaseVC {
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var vwMainContainer: UIView!
    @IBOutlet weak var vwAnimationContainer: BaseAnimationView?
    
    var kycStatus: KYCStatus?
    var hostedURL: String = ""
    
    var personaWebView: WKWebView!
    let personaCallback = AppMetaDataHelper.shared.getPersonaCallback
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.setFooterUI()
        self.setData()
    }
    
    func setFooterUI() {
        shouldShowFooterView = true
        footerView.configureButtons()
        footerView.btnApply.addTarget(self, action: #selector(proceedIdentity(_:)), for: .touchUpInside)
    }
    
    @IBAction func proceedIdentity(_ sender: Any) {
        Segment.addSegmentEvent(name: .proceedIdentity)
        if !hostedURL.isEmpty {
            self.loadWebview(forHostedUrl: hostedURL)
        }
    }
}

// MARK: - Navigationbar
extension VerifyPersonaVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = true
        self.isScreenModallyPresented = true
    }
    
    func setData() {
        let titlefontsize = Utility.isDeviceIpad() ? Constants.regularFontSize28 : Constants.regularFontSize24
        let descfontsize = Utility.isDeviceIpad() ? Constants.regularFontSize20 : Constants.regularFontSize14
        
        lblTitle.font = titlefontsize
        lblDesc.font = descfontsize
        
        lblTitle.text = Utility.localizedString(forKey: "verifyOnfido_title")
        lblDesc.text = Utility.localizedString(forKey: "verifyOnfido_desc")
        footerView.btnApply.setTitle(Utility.localizedString(forKey: "verifyOnfido_buttonTitle"), for: .normal)
        
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
        
        vwAnimationContainer?.animationFile = "searching"
        self.addCloseButton()
    }
    
    func gotoKYCStatusScreen() {
        self.performSegue(withIdentifier: "GotoKYCStatusScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GotoKYCStatusScreen", let accVC = segue.destination as? KYCStatusVC {
            accVC.kycStatus = kycStatus
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lblTitle.textColor = UIColor.primaryColor
        lblDesc.textColor = UIColor.secondaryColor
    }
}

// MARK: - Webview methods
extension VerifyPersonaVC {
    func loadWebview(forHostedUrl: String) {
        // Create the web view and show it
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        if personaWebView == nil {
            personaWebView = WKWebView(frame: .zero, configuration: config)
            personaWebView.navigationDelegate = self
            personaWebView.allowsBackForwardNavigationGestures = false
            personaWebView.scrollView.bounces = false
            personaWebView.translatesAutoresizingMaskIntoConstraints = false
            personaWebView.backgroundColor = .white
            view.addSubview(personaWebView)
            
            NSLayoutConstraint.activate([
                personaWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                personaWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                personaWebView.topAnchor.constraint(equalTo: view.topAnchor),
                personaWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        self.activityIndicatorBegin()
        activityIndicator.color = .black
        
        let redirectURI = "&redirect-uri=\(personaCallback)"
        let strUrl  = forHostedUrl + redirectURI
        let hostedURL = URL(string: strUrl)
        let request = URLRequest(url: hostedURL!)
        personaWebView.load(request)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.activityIndicatorEnd()
        }
    }
}

extension VerifyPersonaVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicatorEnd()
        
        debugPrint("webview error : \(error)")
    }
    
    /// Handle navigation actions from the web view.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Check if we are being redirected to our `redirectUri`. This happens once verification is completed.
        guard let redirectUri = navigationAction.request.url?.absoluteString, redirectUri.starts(with: personaCallback) else {
            // We're not being redirected, so load the URL.
            decisionHandler(.allow)
            return
        }
        
        // At this point we're done, so we don't need to load the URL.
        // verification is success..
        decisionHandler(.cancel)
        
        //TO REMOVE TEMP FILE
        FileManager.default.clearTmpDirectory()
        
        self.callAPIToSubmitKYC()
    }
}

// MARK: - API calls
extension VerifyPersonaVC {
    func callAPIToSubmitKYC() {
        if let _ = AppGlobalData.shared().personId {
            self.activityIndicatorBegin()
            self.activityIndicator.color = .black
            
            KYCViewModel.shared.submitKYCCall { (kycResponse, errorMessage) in
                
                self.activityIndicatorEnd()
                if let error = errorMessage {
                    self.showAlertMessage(titleStr: error.title, messageStr: error.body )
                } else {
                    if let kycStatusResp = kycResponse {
                        self.kycStatus = kycStatusResp.status
                        self.gotoKYCStatusScreen()
                    }
                }
            }
        }
    }
}
