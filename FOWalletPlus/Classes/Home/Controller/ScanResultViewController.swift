//
//  ScanResultViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/28.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import WebKit

class ScanResultViewController: FatherViewController, WKUIDelegate, WKNavigationDelegate {

    open var result: String = ""
    
    @IBOutlet weak var webView: WKWebView!
    
    private var progressBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        if result.match(regex: netAddressRegex) {
            webView.load(URLRequest(url: URL(string: result)!))
        } else {
            webView.loadHTMLString(generateHTML(), baseURL: nil)
        }
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        progressBar = UIView(frame: CGRect(x: 0, y: (navBar?.bottom)! - 2, width: 0, height: 2))
        progressBar.backgroundColor = UIColor.RGBA(r: 2, g: 187, b: 0, a: 1)
        navBar?.addSubview(progressBar)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    private func generateHTML() -> String {
        return
            """
                <html>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
                    <meta name="MobileOptimized" content="240" />
                    <meta name="format-detection" content="telephone=no" />
                    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                    <body style="font-size: 15px;color: #333333; line-height: 20px; padding: 0; font-family: arial;">
                        \(result)
                    </body>
                </html>
            """
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            let estimatedProgress = CGFloat(webView.estimatedProgress)
            UIView.animate(withDuration: 0.1) {
                self.progressBar.width = estimatedProgress * kSize.width
            }
            if webView.estimatedProgress >= 1 {
                UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
                    self.progressBar.alpha = 0
                }) { (finish) in
                    self.progressBar.alpha = 1
                    self.progressBar.width = 0
                }
                return
            }
        } else if keyPath == "title" {
            if webView.title != nil {
                titleLabel?.text = webView.title
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressBar.width = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.width = 0
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
    }
}
