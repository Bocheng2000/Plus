//
//  BackUpViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class BackUpViewController: FatherViewController {

    var model: BackModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    private var tipLabel: UILabel!
    private var noteLabel: UILabel!
    private var privateKeyLabel: CopyLabel!
    private var doneBtn: BaseButton!
    private var checkTime: Int = 0
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let (pk, pub) = generateRandomKeyPair(enclave: .Secp256k1)
        model.priKey = (pk?.rawPrivateKey())!
        model.pubKey = (pub?.rawPublicKey(prefix: nil))!
        makeUI()
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        let padding: CGFloat = 20
        scrollView.alwaysBounceVertical = true
        makeUIHeader(padding: padding)
        makeUIPK(padding: padding)
        makeUINext(padding: padding)
        scrollView.contentSize = CGSize(width: kSize.width, height: doneBtn.bottom + 10)
    }
    
    private func makeUIHeader(padding: CGFloat) {
        tipLabel = UILabel(frame: CGRect(x: padding, y: 38, width: kSize.width - padding * 2, height: 25))
        tipLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        tipLabel.textColor = UIColor.black
        tipLabel.text = LanguageHelper.localizedString(key: "WritePK")
        tipLabel.textAlignment = .center
        scrollView.addSubview(tipLabel)
        
        noteLabel = UILabel(frame: CGRect(x: padding, y: tipLabel.bottom + 10, width: tipLabel.width, height: 0))
        noteLabel.font = UIFont.systemFont(ofSize: 14)
        noteLabel.text = LanguageHelper.localizedString(key: "WritePKNote")
        noteLabel.textColor = UIColor.colorWithHexString(hex: "#666666")
        noteLabel.numberOfLines = 0
        noteLabel.sizeToFit()
        scrollView.addSubview(noteLabel)
    }
    
    private func makeUIPK(padding: CGFloat) {
        privateKeyLabel = CopyLabel(frame: CGRect(x: padding, y: noteLabel.bottom + 20, width: kSize.width - padding * 2, height: 0))
        privateKeyLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        privateKeyLabel.textColor = FONT_COLOR
        privateKeyLabel.numberOfLines = 0
        privateKeyLabel.text = fmtPrikey()
        privateKeyLabel.sizeToFit()
        scrollView.addSubview(privateKeyLabel)
    }
    
    private func makeUINext(padding: CGFloat) {
        let contentHeihgt = kSize.height - navHeight - safeBottom
        doneBtn = BaseButton(frame: CGRect(x: padding, y: contentHeihgt - 70, width: kSize.width - padding * 2, height: 60))
        doneBtn.backgroundColor = BUTTON_COLOR
        doneBtn.layer.cornerRadius = 4
        doneBtn.layer.masksToBounds = true
        doneBtn.setTitle(LanguageHelper.localizedString(key: "Done"), for: .normal)
        doneBtn.addTarget(self, action: #selector(doneBtnDidClick), for: .touchUpInside)
        scrollView.addSubview(doneBtn)
    }
    
    @objc private func doneBtnDidClick() {
        PTLoadingHubView.show()
        ClientManager.shared.createAccunt(account: model.account, publicKey: model.pubKey) { [weak self] (err) in
            if err == nil {
                self?.checkAccountOnChain()
            } else if err == "in an hour" {
                PTLoadingHubView.dismiss()
                let errText = LanguageHelper.localizedString(key: "RegistInHour")
                ZSProgressHUD.showDpromptText(errText)
            } else {
                PTLoadingHubView.dismiss()
                let errText = LanguageHelper.localizedString(key: "NetWorkError")
                ZSProgressHUD.showDpromptText(errText)
            }
        }
    }
    
    // MARK: ===== 检测链上的账户信息 =========
    @objc private func checkAccountOnChain() {
        if checkTime > 5 {
            PTLoadingHubView.dismiss()
            let errText = LanguageHelper.localizedString(key: "RegistFailed")
            ZSProgressHUD.showDpromptText(errText)
            return
        }
        ClientManager.shared.getAccount(account: model.account) { [weak self] (err, info) in
            self?.checkTime += 1
            if err == nil && info != nil {
                self?.saveInfoInLocal()
            } else {
                if self?.timer != nil {
                    self?.timer?.invalidate()
                    self?.timer = nil
                }
                self?.timer = Timer(timeInterval: 3, target: self!, selector: #selector(self?.checkAccountOnChain), userInfo: nil, repeats: false)
                RunLoop.main.add((self?.timer)!, forMode: .commonModes)
                self?.timer?.fire()
            }
        }
    }
    
    private func saveInfoInLocal() {
        let manager: WalletManager = WalletManager.shared
        manager.create([model.account], pubKey: model.pubKey, priKey: model.priKey, password: model.password, prompt: model.prompt)
        manager.setCurrent(pubKey: model.pubKey, account: model.account)
        PTLoadingHubView.dismiss()
        ChangeRootVC().changeRootViewController(window: UIApplication.shared.keyWindow!)
    }
    
    // MARK: ====== 格式化私钥 =======
    private func fmtPrikey() -> String {
        let size = Int(ceil(Float(model.priKey.count) / 4.0))
        var fmtedPriKey: [String] = []
        let startIndex = model.priKey.startIndex
        for i in 0...(size - 1) {
            let start = model.priKey.index(startIndex, offsetBy: i * 4)
            var endIndex = (i + 1) * 4
            if endIndex > model.priKey.count {
                endIndex = model.priKey.count
            }
            let end = model.priKey.index(startIndex, offsetBy: endIndex)
            fmtedPriKey.append("\(model.priKey[start..<end])")
        }
        return fmtedPriKey.joined(separator: " ")
    }
    
}
