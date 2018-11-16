//
//  ImportViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ImportViewController: FatherViewController, InputItemDelegate, InputItemMulitDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    private var header: UIView!
    private var privateKey: InputItemMulit!
    private var password: InputItem!
    private var confirm: InputItem!
    private var prompt: InputItem!
    private var protocolView: UITextView!
    private var importBtn: BaseButton!
    private var isSelected: Bool = true
    private var y: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        makeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeUI() {
        let padding: CGFloat = 20
        scrollView.keyboardDismissMode = .onDrag
        scrollView.backgroundColor = UIColor.colorWithHexString(hex: "#EAE9EE")
        scrollView.alwaysBounceVertical = true
        makeUIHeader(padding: padding)
        makeUIContainer(padding: padding)
        makeUIBtn(padding: padding)
        scrollView.contentSize = CGSize(width: kSize.width, height: importBtn.bottom + 50)
    }
    
    private func makeUIHeader(padding: CGFloat) {
        header = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 0))
        let headerLabel = UILabel(frame: CGRect(x: padding, y: padding, width: kSize.width - padding * 2, height: 0))
        headerLabel.text = LanguageHelper.localizedString(key: "ImportNote")
        headerLabel.font = UIFont.systemFont(ofSize: 14)
        headerLabel.numberOfLines = 0
        headerLabel.textColor = UIColor.colorWithHexString(hex: "#666666")
        headerLabel.sizeToFit()
        header.addSubview(headerLabel)
        header.height = headerLabel.height + padding * 2
        scrollView.addSubview(headerLabel)
    }
    
    private func makeUIContainer(padding: CGFloat) {
        let container = UIView(frame: CGRect(x: 0, y: header.bottom, width: kSize.width, height: 0))
        container.backgroundColor = UIColor.white
        scrollView.addSubview(container)
        privateKey = InputItemMulit(frame: CGRect(x: padding, y: 0, width: kSize.width - padding * 2, height: 90))
        let privateKeyModel = InputItemModel(
            LanguageHelper.localizedString(key: "PrivateKey"),
            _placeholder: LanguageHelper.localizedString(key: "PrivateKeyHolder"),
            _defaultValue: nil,
            _regex: createAccountReg,
            _isSecureTextEntry: false)
        privateKey.model = privateKeyModel
        container.addSubview(privateKey)
        
        password = InputItem(frame: CGRect(x: privateKey.x, y: privateKey.bottom + 9, width: privateKey.width, height: 70))
        let passModel = InputItemModel(
            LanguageHelper.localizedString(key: "SetPassword"),
            _placeholder: LanguageHelper.localizedString(key: "SetPasswordPlaceholder"),
            _defaultValue: nil,
            _regex: passwordRegex,
            _isSecureTextEntry: true)
        password.delegate = self
        password.model = passModel
        container.addSubview(password)
        
        confirm = InputItem(frame: CGRect(x: privateKey.x, y: password.bottom + 9, width: password.width, height: password.height))
        let confirmModel = InputItemModel(
            LanguageHelper.localizedString(key: "ConfirmPassword"),
            _placeholder: LanguageHelper.localizedString(key: "ConfirmPasswordHolder"),
            _defaultValue: nil,
            _regex: passwordRegex,
            _isSecureTextEntry: true)
        confirm.delegate = self
        confirm.model = confirmModel
        container.addSubview(confirm)
        
        prompt = InputItem(frame: CGRect(x: privateKey.x, y: confirm.bottom + 9, width: confirm.width, height: confirm.height))
        let promptModel = InputItemModel(
            LanguageHelper.localizedString(key: "Prompt"),
            _placeholder: LanguageHelper.localizedString(key: "Optional"),
            _defaultValue: nil,
            _regex: nil,
            _isSecureTextEntry: false)
        prompt.delegate = self
        prompt.model = promptModel
        container.addSubview(prompt)
        
        protocolView = UITextView(frame: CGRect(x: privateKey.x, y: prompt.bottom + 10, width: prompt.width, height: 0))
        protocolView.textContainer.lineFragmentPadding = 0
        protocolView.textContainerInset = .zero
        protocolView.isEditable = false
        protocolView.isScrollEnabled = false
        initAttributeString(isSelected)
        protocolView.sizeToFit()
        container.height = protocolView.bottom + 14
        container.addSubview(protocolView)
    }
    
    private func initAttributeString(_ isSelect: Bool) {
        let protocolTip = LanguageHelper.localizedString(key: "册注册注册注册注册")
        let protocolService = LanguageHelper.localizedString(key: "协议协议协议")
        let protocolString = " \(protocolTip) \(protocolService)"
        let attribute = NSMutableAttributedString(string: protocolString)
        let range = (protocolString as NSString).range(of: protocolService)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attribute.addAttributes(
            [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),
                NSAttributedStringKey.foregroundColor: FONT_COLOR,
                NSAttributedStringKey.paragraphStyle: paragraphStyle
            ], range: NSRange.init(location: 0, length: protocolString.count))
        attribute.addAttribute(NSAttributedStringKey.link, value: "service://", range: range)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
        let img = UIImage(named: isSelect ? "selected" : "unSelect")
        let size = CGSize(width: 11.5, height: 11.5)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        img?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizeImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let textAttachment = NSTextAttachment()
        textAttachment.image = resizeImg
        let imgString = NSAttributedString(attachment: textAttachment)
        attribute.insert(imgString, at: 0)
        protocolView.attributedText = attribute
    }
    
    private func makeUIBtn(padding: CGFloat) {
        importBtn = BaseButton(frame: CGRect(x: padding, y: header.bottom + protocolView.bottom + 30, width: kSize.width - padding * 2, height: 60))
        importBtn.backgroundColor = UIColor.lightGray
        importBtn.isUserInteractionEnabled = false
        importBtn.layer.cornerRadius = 4
        importBtn.layer.masksToBounds = true
        importBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        importBtn.setTitleColor(UIColor.white, for: .normal)
        importBtn.setTitle(LanguageHelper.localizedString(key: "Import"), for: .normal)
        importBtn.addTarget(self, action: #selector(importBtnDidClick), for: .touchUpInside)
        scrollView.addSubview(importBtn)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(note:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func importBtnDidClick() {
        view.endEditing(true)
        PTLoadingHubView.show()
        let priKey = privateKey.textView.text
        do {
            let pri: PrivateKey = (try PrivateKey(keyString: priKey!))!
            let pubKey = PublicKey(privateKey: pri).rawPublicKey(prefix: nil)
            ClientManager.shared.getKeyAccount(pubKey: pubKey) { [weak self] (err, accounts) in
                if err != nil {
                    self?.showErrorTip("err")
                } else if (accounts?.count)! > 0 {
                    self?.showSuccess(priKey: priKey!, pubKey: pubKey, accounts: accounts!)
                } else {
                    self?.showErrorTip("none")
                }
            }
        } catch {
            showErrorTip("err")
        }
    }
    
    private func showSuccess(priKey: String, pubKey: String, accounts: [String]) {
        PTLoadingHubView.dismiss()
        let pwd = password.textField.text ?? ""
        let promptV = prompt.textField.text ?? ""
        if accounts.count > 1 {
            let back: BackModel = BackModel("", _password: pwd, _prompt: promptV, _pubKey: pubKey, _priKey: priKey)
            let selectAccount = SelectAccountViewController(left: "img|backBlack", title: LanguageHelper.localizedString(key: "SelectAccount"), right: nil)
            selectAccount.model = back
            selectAccount.accounts = accounts
            navigationController?.pushViewController(selectAccount, animated: true)
            return
        }
        let manager: WalletManager = WalletManager.shared
        manager.create(accounts, pubKey: pubKey, priKey: priKey, password: pwd, prompt: promptV)
        manager.setCurrent(pubKey: pubKey, account: accounts[0])
        let importSuccess = LanguageHelper.localizedString(key: "ImportSuccess")
        let button = ModalButtonModel(LanguageHelper.localizedString(key: "Confirm"), _titleColor: UIColor.white, _titleFont: UIFont.systemFont(ofSize: 14, weight: .medium), _backgroundColor: BUTTON_COLOR, _borderColor: BUTTON_COLOR) {
            ChangeRootVC().changeRootViewController(window: UIApplication.shared.keyWindow!)
        }
        let modalModel: ModalModel = ModalModel(false, _imageName: nil, _title: importSuccess, _message: nil, _buttons: [button])
        ModalViewController(modalModel).show(source: self)
    }
    
    private func showErrorTip(_ err: String) {
        PTLoadingHubView.dismiss()
        let errStr: String = LanguageHelper.localizedString(key: "AccountNotFound")
        ZSProgressHUD.showDpromptText(errStr)
    }
    
    // MARK: ====== 键盘变化 ============
    @objc private func keyboardWillChangeFrame(note: Notification) {
        let end = note.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        let begin = note.userInfo![UIKeyboardFrameBeginUserInfoKey] as! CGRect
        let moveY = begin.origin.y - end.origin.y
        if moveY > 0 { // 键盘上移
            let _y = view.height - y
            if _y < moveY {
                UIView.animate(withDuration: 0.25) {
                    self.scrollView.y = self.scrollView.y - (moveY - _y + 40)
                }
            }
        } else {
            if scrollView.y != navHeight {
                UIView.animate(withDuration: 0.25) {
                    self.scrollView.y = navHeight
                }
            }
        }
    }
    
    // MARK: ====== InputItem Delegate ==========
    func inputItemFocus(sender: InputItem) {
        let textField = sender.textField
        let rect = textField?.convert((textField?.bounds)!, to: view)
        if rect != nil {
            y = rect!.origin.y + rect!.size.height
        }
    }
    
    func inputItemBlur(sender: InputItem, isMatch: Bool) {
        setBtnIsUseful()
        promptError(sender: sender)
    }
    
    // MARK: ====== InputItemMulit Delegate ======
    func inputItemMulitBlur(sender: InputItemMulit, isMatch: Bool) {
        setBtnIsUseful()
        let priKey = privateKey.textView.text ?? ""
        if priKey.trim() != "" {
            if !PrivateKey.literalValid(keyString: priKey) {
                let err = LanguageHelper.localizedString(key: "PriKeyInvalid")
                ZSProgressHUD.showDpromptText(err)
            }
            return
        }
    }
    
    private func promptError(sender: InputItem) {
        if sender.isEqual(password) {
            let pwd = password.textField.text ?? ""
            if pwd.trim() == "" {
                let err = LanguageHelper.localizedString(key: "PasswrodNotNull")
                ZSProgressHUD.showDpromptText(err)
                return
            }
            if !pwd.match(regex: passwordRegex) {
                let err = LanguageHelper.localizedString(key: "PasswordInvalid")
                ZSProgressHUD.showDpromptText(err)
                return
            }
        }
        if sender.isEqual(confirm) {
            let confirmPwd = confirm.textField.text ?? ""
            let pwd = password.textField.text ?? ""
            if confirmPwd.trim() == "" {
                let err = LanguageHelper.localizedString(key: "PasswrodNotNull")
                ZSProgressHUD.showDpromptText(err)
                return
            }
            if confirmPwd != pwd {
                let err = LanguageHelper.localizedString(key: "PasswordNotSame")
                ZSProgressHUD.showDpromptText(err)
                return
            }
            if !confirmPwd.match(regex: passwordRegex) {
                let err = LanguageHelper.localizedString(key: "PasswordInvalid")
                ZSProgressHUD.showDpromptText(err)
                return
            }
        }
    }
    
    private func setBtnIsUseful() {
        if !checkInputIsOk() {
            if importBtn.isUserInteractionEnabled {
                importBtn.backgroundColor = UIColor.lightGray
                importBtn.isUserInteractionEnabled = false
            }
        } else {
            if !importBtn.isUserInteractionEnabled {
                importBtn.backgroundColor = BUTTON_COLOR
                importBtn.isUserInteractionEnabled = true
            }
        }
    }
    
    private func checkInputIsOk() -> Bool {
        if !isSelected {
            return false
        }
        let priKey = privateKey.textView.text ?? ""
        if priKey.trim() == "" {
            return false
        }
        if !PrivateKey.literalValid(keyString: priKey) {
            return false
        }
        let pwd = password.textField.text ?? ""
        if pwd.trim() == "" {
            return false
        }
        if !pwd.match(regex: passwordRegex) {
            return false
        }
        let confirmPwd = confirm.textField.text ?? ""
        if confirmPwd != pwd {
            return false
        }
        if !confirmPwd.match(regex: passwordRegex) {
            return false
        }
        return true
    }

}
