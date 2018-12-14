//
//  DAppContainerViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/10.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import WebKit

class DAppContainerViewController: FatherViewController, WKUIDelegate, WKNavigationDelegate, ModalPanelViewControllerDelegate, CircleViewDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
    
    // MARK: ======= Props Start =========
    open var uri: String!
    private var kUserController: String = "FOWallet"
    @IBOutlet weak var supportLabel: UILabel!
    @IBOutlet weak var powerByLabel: UILabel!
    private var webView: WKWebView!
    private var progressBar: UIView!
    private var cpu: CircleView!
    private var cpuPercentLabel: UILabel!
    private var net: CircleView!
    private var netPercentLabel: UILabel!
    
    // MARK: ======= Life Circle =========
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        let url: URL = URL(string: uri)!
        webView.load(URLRequest(url: url))
        if url.host != nil {
            supportLabel.text = String.init(format: LanguageHelper.localizedString(key: "SupportBy"), url.host!)
        }
        powerByLabel.text = LanguageHelper.localizedString(key: "PoweredBy")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.configuration.userContentController.add(self, name: kUserController)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: kUserController)
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        powerByLabel.alpha = 0
        supportLabel.alpha = 0
        let config = WKWebViewConfiguration()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        config.mediaTypesRequiringUserActionForPlayback = .all
        config.userContentController = WKUserContentController()
        webView = WKWebView(frame: CGRect(x: 0, y: navHeight, width: kSize.width, height: kSize.height - navHeight), configuration: config)
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        view.addSubview(webView)
        progressBar = UIView(frame: CGRect(x: 0, y: (navBar?.bottom)! - 2, width: 0, height: 2))
        progressBar.backgroundColor = UIColor.RGBA(r: 2, g: 187, b: 0, a: 1)
        navBar?.addSubview(progressBar)
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        makeUIResourceWidget()
        setWidget()
    }

    // MARK: ======== 资源插件 ============
    private func makeUIResourceWidget() {
        cpu = CircleView(frame: CGRect(x: kSize.width - 40 - 70, y: statusHeight + 10, width: 30, height: 30))
        cpu.delegate = self
        cpu.circleColor = UIColor.colorWithHexString(hex: "#BC5671")
        cpuPercentLabel = UILabel(frame: CGRect(x: 0, y: 7, width: cpu.width, height: 8))
        cpuPercentLabel.textAlignment = .center
        cpuPercentLabel.font = UIFont.systemFont(ofSize: 7)
        cpuPercentLabel.textColor = FONT_COLOR
        cpuPercentLabel.text = ""
        
        let cpuTip = UILabel(frame: CGRect(x: 0, y: cpuPercentLabel.bottom, width: cpuPercentLabel.width, height: cpuPercentLabel.height))
        cpuTip.textAlignment = .center
        cpuTip.font = UIFont.systemFont(ofSize: 7)
        cpuTip.textColor = FONT_COLOR
        cpuTip.text = "cpu"
        cpu.addSubview(cpuPercentLabel)
        cpu.addSubview(cpuTip)
        
        net = CircleView(frame: CGRect(x: kSize.width - 40 - 35, y: statusHeight + 10, width: 30, height: 30))
        net.delegate = self
        netPercentLabel = UILabel(frame: CGRect(x: 0, y: 7, width: cpu.width, height: 8))
        netPercentLabel.textAlignment = .center
        netPercentLabel.font = UIFont.systemFont(ofSize: 7)
        netPercentLabel.textColor = FONT_COLOR
        netPercentLabel.text = ""
        let netTip = UILabel(frame: CGRect(x: 0, y: cpuPercentLabel.bottom, width: cpuPercentLabel.width, height: cpuPercentLabel.height))
        netTip.textAlignment = .center
        netTip.font = UIFont.systemFont(ofSize: 7)
        netTip.textColor = FONT_COLOR
        netTip.text = "net"
        net.addSubview(netPercentLabel)
        net.addSubview(netTip)
        navBar?.addSubview(cpu)
        navBar?.addSubview(net)
    }
    
    // MARK: ======== 资源插件赋值 =========
    private func setWidget() {
        let current = WalletManager.shared.getCurrent()
        if current != nil {
            if current!.resourceWidget ?? false {
                let account = CacheHelper.shared.getAccountInfo(current!.account)
                if account != nil {
                    let available_cpu = account!.cpuLimit?.available ?? 0
                    let max_cpu = account!.cpuLimit?.max ?? 1
                    let double_cpu = Decimal(available_cpu) / Decimal(max_cpu)
                    cpuPercentLabel.text = "\(double_cpu.toFixed(2))%"
                    cpu.value = CGFloat((double_cpu as NSNumber).floatValue)
                    let available_net = account!.netLimit?.available ?? 0
                    let max_net = account!.netLimit?.max ?? 1
                    let double_net = Decimal(available_net) / Decimal(max_net)
                    netPercentLabel.text = "\(double_net.toFixed(2))%"
                    net.value = CGFloat((double_net as NSNumber).floatValue)
                    cpu.isHidden = false
                    net.isHidden = false
                    return
                }
            }
        }
        cpu.isHidden = true
        cpu.value = 0
        net.isHidden = true
        net.value = 0
    }
    
    override func rightBtnDidClick() {
        let m = ModalPanelModel()
        let url = URL(string: uri)
        if url != nil {
            m.title = String.init(format: LanguageHelper.localizedString(key: "SupportBy"), (URL(string: uri)?.host)!)
        }
        m.top = [
            ItemOptModel(LanguageHelper.localizedString(key: "CopyLink"), _image: UIImage(named: "link")!),
            ItemOptModel(LanguageHelper.localizedString(key: "Refresh"), _image: UIImage(named: "refresh")!),
            ItemOptModel(LanguageHelper.localizedString(key: "OpenSafari"), _image: UIImage(named: "safari")!),
            ItemOptModel(LanguageHelper.localizedString(key: "GoBack"), _image: UIImage(named: "goback")!),
            ItemOptModel(LanguageHelper.localizedString(key: "ResourceWidget"), _image: UIImage(named: "resource")!),
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
    
    // MARK: ======== KVO ==========
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
    
    // MARK: ===== WebView 发消息 =======
    private func postMessage(_ error: String?, params: Any?, msgId: String) {
        do {
            let arguments: [Any?] = [error, params]
            let resp: [String : Any] = ["msgId": msgId, "args": arguments]
            let respData = try! JSONSerialization.data(withJSONObject: resp, options: .prettyPrinted)
            let respString = String.init(data: respData, encoding: .utf8)
            let data: [String: String] = ["data": respString!]
            let dataData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let dataString = String.init(data: dataData, encoding: .utf8)
            let js = "document.dispatchEvent(new MessageEvent(\"message\", \(dataString!)));"
            webView.evaluateJavaScript(js, completionHandler: nil)
        } catch {
        }
    }
    
    // MARK: ===== 注入JS =========
    private func injectScripts() {
        do {
            let fowallet = """
                "use strict";
                window.fowallet = {
                    version: "1.0.0",
                    evn: "\(LanguageHelper.getUserLanguage())"
                };
            """
            let promisePath = Bundle.main.path(forResource: "promise", ofType: "js")
            let promise = try String.init(contentsOfFile: promisePath!)
            let bridgePath = Bundle.main.path(forResource: "bridge", ofType: "js")
            let bridge = try String.init(contentsOfFile: bridgePath!)
            let sdkPath = Bundle.main.path(forResource: "sdk", ofType: "js")
            let sdk = try String.init(contentsOfFile: sdkPath!)
            let eccPath = Bundle.main.path(forResource: "eosjs-ecc", ofType: "js")
            let ecc = try String.init(contentsOfFile: eccPath!)
            webView.evaluateJavaScript("\(fowallet)\(promise)\(bridge)\(sdk)\(ecc)", completionHandler: nil)
        } catch {
            
        }
    }
    
    private func processJsHook(model: DAppContainerModel) {
        switch model.api {
        case "getInfo":
            DAppUtils().getChainInfo { [weak self] (err, info) in
                self?.postMessage(err, params: info, msgId: model.msgId)
            }
            break
        case "getAccount":
            DAppUtils().getAccount { [weak self] (err, info) in
                self?.postMessage(err, params: info, msgId: model.msgId)
            }
            break
        case "getCurrencyBalance":
            let resp = DAppUtils().getCurrencyBalance(options: model.data)
            postMessage(resp[0] as? String, params: resp[1], msgId: model.msgId)
            break
        case "getLockBalance":
            DAppUtils().getLockBalance(options: model.data) { [weak self] (err, resp) in
                self?.postMessage(err, params: resp, msgId: model.msgId)
            }
            break
        case "payRequest":
            DAppUtils(self).payRequest(options: model.data) { [weak self] (err, resp) in
                self?.postMessage(err, params: resp, msgId: model.msgId)
            }
            break
        case "getIdentity":
            let resp = DAppUtils().getIdentity()
            postMessage(resp[0] as? String, params: resp[1], msgId: model.msgId)
            break
        case "signProvider":
            let data = model.data as! Dictionary<String, Any>
            DAppUtils(self).signProvider(transaction: data["transaction"] as! Dictionary<String, Any>) { [weak self] (err, pkString) in
                if err != nil {
                    self?.postMessage(err, params: nil, msgId: model.msgId)
                    return
                }
                let buf = (data["buf"] as! NSDictionary)["data"] as! Array<NSNumber>
                self?.webView.evaluateJavaScript("function buffer(array) { var buf = new Uint8Array(array); buf.__proto__._isBuffer = true; return buf;};eosjs_ecc.Signature.sign(buffer(\(buf)), \"\(pkString!)\", true).toString()") { (signed, e) in
                    if e != nil {
                        self?.postMessage(e!.localizedDescription, params: nil, msgId: model.msgId)
                    } else {
                        self?.postMessage(nil, params: "23", msgId: model.msgId)
                    }
                }
            }
            break
        default:
            postMessage("error", params: nil, msgId: model.msgId)
            break
        }
    }
    
    // MARK: ======== WKWebView Delegate ===========
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressBar.width = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.width = 0
        injectScripts()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as! String
        let model = DAppContainerModel.deserialize(from: body)
        if model == nil {
            postMessage("unknow message", params: nil, msgId: "")
            return
        }
        processJsHook(model: model!)
    }
    
    // MARK: =========== WebView Alert 接管 ==========
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = JCAlertController.alert(withTitle: titleLabel?.text, message: message)
        let ok = LanguageHelper.localizedString(key: "OK")
        alert?.addButton(withTitle: ok, type: JCButtonType(rawValue: 0), clicked: {
            completionHandler()
        })
        present(alert!, animated: true, completion: nil)
    }
    
    // MARK: =========== WebView Confirm 接管 ==========
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = JCAlertController.alert(withTitle: titleLabel?.text, message: message)
        let cancel = LanguageHelper.localizedString(key: "Cancel")
        alert?.addButton(withTitle: cancel, type: JCButtonType(rawValue: 1), clicked: {
            completionHandler(false)
        })
        let ok = LanguageHelper.localizedString(key: "OK")
        alert?.addButton(withTitle: ok, type: JCButtonType(rawValue: 0), clicked: {
            completionHandler(true)
        })
        present(alert!, animated: true, completion: nil)
    }
    
    // MARK: =========== ScrollView Deleagte ========
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 && offsetY > -120 {
            if scrollView.isDragging {
                let alpha = abs(offsetY) / 120
                supportLabel.alpha = alpha
                powerByLabel.alpha = alpha
            }
        } else if offsetY >= 0 {
            supportLabel.alpha = 0
            powerByLabel.alpha = 0
        }
    }
    
    // MARK: ========== ModalPanelViewController Deleagte ==========
    func modalPanelCanceled(sender: ModalPanelViewController) {
        
    }
    
    func modalPanelClickAt(sender: ModalPanelViewController, section: Int, row: Int) {
        if section == 0 {
            if row < 4 {
                processSection1(row: row)
            } else {
                reosurceWidgetProcess()
            }
        } else {
            toShare(row: row)
        }
    }
    
    private func reosurceWidgetProcess() {
        let current = WalletManager.shared.getCurrent()!
        if current.resourceWidget! {
            current.resourceWidget = false
        } else {
            current.resourceWidget = true
        }
        WalletManager.shared.setCurrent(account: current)
        setWidget()
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
    
    // MARK: ======= CircleView Delegate =========
    func circleViewDidClick(sender: CircleView) {
        
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
    }
}
