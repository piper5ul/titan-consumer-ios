//
//  DocuSignVC.swift
//  Solid
//
//  Created by Solid iOS Team on 30/01/24.
//

import UIKit
import WebKit
import JavaScriptCore

class DocuSignVC: BaseVC {
    enum DSStages: String {
        case willOpen = "WILL_OPEN"
        case ready = "ready"
        case success = "signing_complete"
        case error = "error"
    }

    var dsWebView: WKWebView!
    var integrationKey = Config.DocuSign.docuSignKey
    var signUrl: String!
    let callBackName = "docusignResultCallbackHandler"
    var businessId: String?
    let webUrlPathForDocuSign = "/e-sign-mobile"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
        self.setupWebview()
        self.businessId = AppGlobalData.shared().businessData?.id
    }
}

extension DocuSignVC {
    func setNavigationBar() {
        self.isNavigationBarHidden = false
        self.isScreenModallyPresented = true
        addNavigationbarButton(buttonTitle: Utility.localizedString(forKey: "cancel"), buttonTextColor: UIColor.secondaryColor, addSide: NavigationButton.leftButton)
    }

	override func leftButtonAction() {
        goBack()
	}

    func goBack() {
        self.view.endEditing(true)
        self.showAlertMessage(titleStr: Utility.localizedString(forKey: "generic_ErrorTitle"), messageStr: Utility.localizedString(forKey: "docuSignStatus_error"))
        self.popVC()
    }
    
    func goToDocuSignStatusVC() {
        self.performSegue(withIdentifier: "GoToDocuSignStatusVC", sender: self)
		self.modalPresentationStyle = .fullScreen
    }
}

// MARK: - Webview methods
extension DocuSignVC {
    func setupWebview() {
        let contentController = WKUserContentController()
        contentController.add(self, name: callBackName)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        if dsWebView == nil {
            dsWebView = WKWebView(frame: .zero, configuration: config)
            dsWebView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(dsWebView)
            dsWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            dsWebView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            dsWebView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            dsWebView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

            dsWebView.navigationDelegate = self
            dsWebView.scrollView.isScrollEnabled = false
        }

        loadWebPage()
    }

    func loadWebPage() {
        if self.signUrl != nil, self.signUrl.count > 0 {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = Config.DocuSign.docuSignHost
            urlComponents.path = webUrlPathForDocuSign
            urlComponents.queryItems = [
                URLQueryItem(name: "signurl", value: self.signUrl),
                URLQueryItem(name: "clientId", value: self.integrationKey),
                URLQueryItem(name: "device", value: "1") // Android = 0 and iOS = 1
            ]

            self.activityIndicatorBegin()

            guard let signURL = urlComponents.url else {
                print("Error")
                return
            }
            let dsRequest = URLRequest(url: signURL)
            dsWebView.load(dsRequest)
        }
    }
}

// MARK: - WebKit Calls
extension DocuSignVC: WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicatorEnd()

        debugPrint("docusign webview error : \(error)")
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("docusign rendering message : \(message)")
        
        self.activityIndicatorEnd()

        if message.name == callBackName, let body = message.body as? [String: String] {
            debugPrint("docusign response : \(body)")

            switch body["sessionEndType"] {
            case DSStages.success.rawValue:
                self.goToDocuSignStatusVC()
            default:
                self.goBack()
            }
        }
    }
}
