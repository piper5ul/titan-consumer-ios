//
//  WebViewController.swift
//  Solid
//
//  Created by Solid iOS Team on 03/04/21.
//

import UIKit
import WebKit

class WebViewHelperVC: BaseVC {

    var webView: WKWebView!

    var webPath = ""

    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        self.view.addSubview(webView)

        self.activityIndicatorBegin()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.translatesAutoresizingMaskIntoConstraints = false
        let guide = self.view.safeAreaLayoutGuide
        webView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true

        /*
        var viewFrame = self.view.bounds
        viewFrame.origin.y = 20
        webView.frame = viewFrame
        */

        load()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activityIndicatorEnd()
    }

	override func viewDidAppear(_ animated: Bool) {
	    super.viewDidAppear(animated)
	}

    func load() {
        setCloseButtonAtRight()
        let url = URL(string: webPath)
        let req = URLRequest(url: url!)
        webView.navigationDelegate = self
        webView.load(req)
    }

    static func present(source: UIViewController, path: String, title: String) {
        let webVC = WebViewHelperVC(useNib: true)
        webVC.webPath = path
        webVC.title = title
        let nav = UINavigationController(rootViewController: webVC)
        source.present(nav, animated: true)
    }
}

extension WebViewHelperVC: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicatorEnd()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint(error)
    }

    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
