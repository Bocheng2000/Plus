//
//  ExploreViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/1.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import WebKit

class ExploreViewController: FatherViewController, WKUIDelegate, WKNavigationDelegate, ModalPanelViewControllerDelegate {
    
    open var uri: String!
    
    @IBOutlet weak var serverByLabel: UILabel!
    
    @IBOutlet weak var powerByLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    private var progressBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        let url: URL = URL(string: uri)!
        webView.load(URLRequest(url: url))
        if url.host != nil {
            serverByLabel.text = String.init(format: LanguageHelper.localizedString(key: "SupportBy"), url.host!)
        }
        powerByLabel.text = LanguageHelper.localizedString(key: "PoweredBy")
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        webView.backgroundColor = UIColor.white
        progressBar = UIView(frame: CGRect(x: 0, y: (navBar?.bottom)! - 2, width: 0, height: 2))
        progressBar.backgroundColor = UIColor.RGBA(r: 2, g: 187, b: 0, a: 1)
        navBar?.addSubview(progressBar)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func rightBtnDidClick() {
        let m = ModalPanelModel()
        let url = URL(string: uri)
        if url != nil {
            m.title = String.init(format: LanguageHelper.localizedString(key: "SupportBy"), (URL(string: uri)?.host)!)
        }
        m.top = [
            ItemOptModel(LanguageHelper.localizedString(key: "CopyLink"), _image: UIImage(named: "link")!),
            ItemOptModel(LanguageHelper.localizedString(key: "Refresh"), _image: UIImage(named: "link")!),
            ItemOptModel(LanguageHelper.localizedString(key: "OpenSafari"), _image: UIImage(named: "link")!),
            ItemOptModel(LanguageHelper.localizedString(key: "GoBack"), _image: UIImage(named: "link")!),
        ]
        m.bottom = [
            ItemOptModel(LanguageHelper.localizedString(key: "WeChat"), _image: UIImage(named: "wechat")!),
            ItemOptModel(LanguageHelper.localizedString(key: "TimeLine"), _image: UIImage(named: "timeLine")!),
            ItemOptModel("QQ", _image: UIImage(named: "qq")!),
            ItemOptModel(LanguageHelper.localizedString(key: "Zone"), _image: UIImage(named: "zone")!),
            ItemOptModel(LanguageHelper.localizedString(key: "Sina"), _image: UIImage(named: "sina")!),
        ]
        let panel = ModalPanelViewController(m)
        panel.delegate = self
        panel.show(source: self)
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
        }
    }
    
    // MARK: ======== WKWebView Delegate ===========
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressBar.width = 0
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.width = 0
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
    }
   
    // MARK: ========== ModalPanelViewController Deleagte ==========
    func modalPanelCanceled(sender: ModalPanelViewController) {
        
    }
    
    func modalPanelClickAt(sender: ModalPanelViewController, section: Int, row: Int) {
        if section == 0 {
            processSection1(row: row)
        } else {
            toShare(row: row)
        }
    }
    
    // MARK: ======= webView 处理相关行为 ===========
    private func processSection1(row: Int) {
        switch row {
            case 0:
                UIPasteboard.general.string = uri
                let success = LanguageHelper.localizedString(key: "CopySuccess")
                ZSProgressHUD.showDpromptText(success)
                break
            case 1:
                webView.reload()
                break
            case 2:
                let url = URL(string: uri)
                if uri != nil {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    let err = LanguageHelper.localizedString(key: "UnableOpenSafari")
                    ZSProgressHUD.showDpromptText(err)
                }
                break
            case 3:
                if webView.canGoBack {
                    webView.goBack()
                }
                break
            default:
                break
        }
    }
    
    // MARK: ======= 分享第三方软件 ================
    private func toShare(row: Int) {
        
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
    }
}
