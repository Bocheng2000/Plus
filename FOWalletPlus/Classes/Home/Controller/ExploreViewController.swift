//
//  ExploreViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/1.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import WebKit

class ExploreViewController: FatherViewController, WKUIDelegate, WKNavigationDelegate, ModalPanelViewControllerDelegate, CircleViewDelegate, UIScrollViewDelegate {
    
    open var uri: String!
    
    @IBOutlet weak var serverByLabel: UILabel!
    
    @IBOutlet weak var powerByLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    private var progressBar: UIView!
    
    private var cpu: CircleView!
    private var cpuPercentLabel: UILabel!
    
    private var net: CircleView!
    private var netPercentLabel: UILabel!
    
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
        powerByLabel.alpha = 0
        serverByLabel.alpha = 0
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        webView.backgroundColor = UIColor.white
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
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
    
    private func setWidget() {
        let current = WalletManager.shared.getCurrent()
        if current != nil {
            if current!.resourceWidget ?? false {
                let account = CacheHelper.shared.getAccountInfo(current!.account)
                if account != nil {
                    let used_cpu = account!.cpuLimit?.used ?? 0
                    let max_cpu = account!.cpuLimit?.max ?? 1
                    let double_cpu = Decimal(used_cpu) / Decimal(max_cpu)
                    cpuPercentLabel.text = "\(double_cpu.toFixed(2))%"
                    cpu.value = CGFloat((double_cpu as NSNumber).floatValue)
                    let used_net = account!.netLimit?.used ?? 0
                    let max_net = account!.netLimit?.max ?? 1
                    let double_net = Decimal(used_net) / Decimal(max_net)
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
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.width = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            let offsetY = scrollView.contentOffset.y
            if offsetY < 0 && offsetY > -120 {
                let alpha = abs(offsetY) / 120
                serverByLabel.alpha = alpha
                powerByLabel.alpha = alpha
            }
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
    func circleViewDidClick() {
        
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
    }
}
