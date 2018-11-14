//
//  StartViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/12.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class StartViewController: FatherViewController {

    @IBOutlet weak var createBtn: UIButton!
    
    @IBOutlet weak var importBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
//        let m = ModalViewController()
//        m.definesPresentationContext = true
//        m.modalPresentationStyle = .overCurrentContext
//        present(m, animated: false, completion: nil)
//        let (pk, pub) = generateRandomKeyPair(enclave: .Secp256k1)
//        let r = PrivateKey.literalValid(keyString: (pk?.rawPrivateKey())!)
//        print(r, (pk?.rawPrivateKey())!)
//        let w = Wallet("sleepiozjh34", _prompt: "hello", _pubKey: "FO7xNZpXXxN6HHUTsJVMvfdQgTLmUvgaBdZQzrqwqW7PWHxyT12x", _password: "1bbd886460827015e5d605ed44252251", _priKey: "U2FsdGVkX19YE38bYhh9UngUnkjgQzPPmbj00t71tPWFbrj2lV9eldA2YDl54EoxSFqGLKYDVjg3wT+t2Bt/hKSwzJItLkJBikfTe0sFL9I=", isEncode: true)
//        WalletManager.shared.appendWallet(wallets:[w])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: 创建UI
    private func makeUI() {
        makeBtnUI(createBtn)
        let createTitle = LanguageHelper.localizedString(key: "CreateAccount")
        createBtn.setTitle(createTitle, for: .normal)
        makeBtnUI(importBtn)
        let importTitle = LanguageHelper.localizedString(key: "ImportAccount")
        importBtn.setTitle(importTitle, for: .normal)
    }
    
    
    // MARK: 配置按钮的样式
    private func makeBtnUI(_ btn: UIButton) {
        btn.layer.cornerRadius = 3
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.masksToBounds = true
    }
    
    // MARK: 创建按钮的点击事件
    @IBAction func createBtnDidClick(_ sender: UIButton) {
        let createTitle = LanguageHelper.localizedString(key: "CreateAccount")
        let importTitle = LanguageHelper.localizedString(key: "Import")
        let create = CreateViewController(left: "img|blackBack", title: createTitle, right: "text|\(importTitle)")
        navigationController?.pushViewController(create, animated: true)
    }
    
    // MARK: 导入按钮的点击事件
    @IBAction func importBtnDidClick(_ sender: UIButton) {
        let importTitle = LanguageHelper.localizedString(key: "ImportAccount")
        let importVc = ImportViewController(left: "img|blackBack", title: importTitle, right: nil)
        navigationController?.pushViewController(importVc, animated: true)
    }
    
}
