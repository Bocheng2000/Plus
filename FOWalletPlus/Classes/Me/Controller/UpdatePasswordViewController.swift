//
//  UpdatePasswordViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/3.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: FatherViewController, UITextFieldDelegate, AuthorizeViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var newPwsLabel: UILabel!
    
    @IBOutlet weak var newPwdTextField: BaseTextField!
    
    @IBOutlet weak var confirmLabel: UILabel!
    
    @IBOutlet weak var confirmTextField: BaseTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        scrollView.backgroundColor = UIColor.clear
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        newPwsLabel.text = LanguageHelper.localizedString(key: "NewPwd")
        confirmLabel.text = LanguageHelper.localizedString(key: "RepeatPwd")
        newPwdTextField.placeholder = LanguageHelper.localizedString(key: "YourNewPwd")
        confirmTextField.placeholder = LanguageHelper.localizedString(key: "RepeatYourPwd")
        newPwdTextField.delegate = self
        confirmTextField.delegate = self
        doneButton.backgroundColor = BUTTON_COLOR
        doneButton.setTitle(LanguageHelper.localizedString(key: "Done"), for: .normal)
    }

    @IBAction func doneBtnDidClick(_ sender: BaseButton) {
        if checkParamsIsOK() {
            let newPwd = newPwdTextField.text ?? ""
            let newModel = AuthorizeItemModel(LanguageHelper.localizedString(key: "NewPwd"), _detail: newPwd)
            let model = AuthorizeModel(LanguageHelper.localizedString(key: "ResetPwd"), _items: [newModel], _type: .exportPk, _params: PkStringModel())
            let auth = AuthorizeViewController(model)
            auth.delegate = self
            auth.show(source: self)
        }
    }
    
    private func checkParamsIsOK() -> Bool {
        let newPwd = newPwdTextField.text ?? ""
        let confirmPwd = confirmTextField.text ?? ""
        if newPwd == "" {
            showError(key: "PasswrodNotNull")
            return false
        }
        if !newPwd.match(regex: passwordRegex) {
            showError(key: "PasswordInvalid")
            return false
        }
        if confirmPwd == "" {
            showError(key: "PasswrodNotNull")
            return false
        }
        if !confirmPwd.match(regex: passwordRegex) {
            showError(key: "PasswordInvalid")
            return false
        }
        if newPwd != confirmPwd {
            showError(key: "PasswordNotSame")
            return false
        }
        return true
    }
    
    private func showError(key: String) {
        let error = LanguageHelper.localizedString(key: key)
        ZSProgressHUD.showDpromptText(error)
    }
    
    // MARK: ============= UITextField Delegate ===========
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text ?? ""
        if value != "" {
            if !value.match(regex: passwordRegex) {
                textField.textColor = ERROR_COLOR
                showError(key: "PasswordInvalid")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.textColor = FONT_COLOR
        return true
    }
    
    // MARK: =========== AuthorizeViewControllerDelegate ============
    func exportPkString(sender: AuthorizeViewController, pkString: String) {
        let manager = WalletManager.shared
        let current = WalletManager.shared.getCurrent()!
        let wallet = manager.getWallet(pubKey: current.pubKey, account: current.account)
        if wallet == nil {
            showError(key: "WalletNotExist")
            return
        }
        let newPwd = newPwdTextField.text ?? ""
        let nextWallet = Wallet(wallet!.account, _prompt: wallet!.prompt, _pubKey: wallet!.pubKey, _password: newPwd, _priKey: pkString, isEncode: false)
        manager.appendWallet(wallets: [nextWallet])
        manager.setCurrent(pubKey: nextWallet.pubKey, account: nextWallet.account)
        let success = LanguageHelper.localizedString(key: "UpdateSuccess")
        ZSProgressHUD.showSuccessfulAnimatedText(success)
        navigationController?.popViewController(animated: true)
    }
    
}
