//
//  CreateViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/12.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CreateViewController: FatherViewController, InputItemDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    private var header: UIView!
    private var account: InputItem!
    private var password: InputItem!
    private var confirm: InputItem!
    private var prompt: InputItem!
    private var protocolView: UITextView!
    private var createBtn: BaseButton!
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
        scrollView.contentSize = CGSize(width: kSize.width, height: createBtn.bottom + 50)
    }
    
    private func makeUIHeader(padding: CGFloat) {
        header = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 0))
        let headerLabel = UILabel(frame: CGRect(x: padding, y: padding, width: kSize.width - padding * 2, height: 0))
        headerLabel.text = LanguageHelper.localizedString(key: "CreateNote")
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
        account = InputItem(frame: CGRect(x: padding, y: 11, width: kSize.width - padding * 2, height: 70))
        let accountModel = InputItemModel(
            LanguageHelper.localizedString(key: "InputAccountName"),
            _placeholder: LanguageHelper.localizedString(key: "AccountOops"),
            _defaultValue: nil,
            _regex: createAccountReg,
            _isSecureTextEntry: false)
        account.model = accountModel
        account.delegate = self
        container.addSubview(account)
        
        password = InputItem(frame: CGRect(x: account.x, y: account.bottom + 9, width: account.width, height: account.height))
        let passModel = InputItemModel(
            LanguageHelper.localizedString(key: "SetPassword"),
            _placeholder: LanguageHelper.localizedString(key: "SetPasswordPlaceholder"),
            _defaultValue: nil,
            _regex: passwordRegex,
            _isSecureTextEntry: true)
        password.delegate = self
        password.model = passModel
        container.addSubview(password)
        
        confirm = InputItem(frame: CGRect(x: account.x, y: password.bottom + 9, width: password.width, height: password.height))
        let confirmModel = InputItemModel(
            LanguageHelper.localizedString(key: "ConfirmPassword"),
            _placeholder: LanguageHelper.localizedString(key: "ConfirmPasswordHolder"),
            _defaultValue: nil,
            _regex: passwordRegex,
            _isSecureTextEntry: true)
        confirm.delegate = self
        confirm.model = confirmModel
        container.addSubview(confirm)
        
        prompt = InputItem(frame: CGRect(x: account.x, y: confirm.bottom + 9, width: confirm.width, height: confirm.height))
        let promptModel = InputItemModel(
            LanguageHelper.localizedString(key: "Prompt"),
            _placeholder: LanguageHelper.localizedString(key: "Optional"),
            _defaultValue: nil,
            _regex: nil,
            _isSecureTextEntry: false)
        prompt.delegate = self
        prompt.model = promptModel
        container.addSubview(prompt)
        
        protocolView = UITextView(frame: CGRect(x: account.x, y: prompt.bottom + 10, width: prompt.width, height: 0))
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
        createBtn = BaseButton(frame: CGRect(x: padding, y: header.bottom + protocolView.bottom + 30, width: kSize.width - padding * 2, height: 60))
        createBtn.backgroundColor = UIColor.lightGray
        createBtn.isUserInteractionEnabled = false
        createBtn.layer.cornerRadius = 4
        createBtn.layer.masksToBounds = true
        createBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        createBtn.setTitleColor(UIColor.white, for: .normal)
        createBtn.setTitle(LanguageHelper.localizedString(key: "Create"), for: .normal)
        createBtn.addTarget(self, action: #selector(createBtnDidClick), for: .touchUpInside)
        scrollView.addSubview(createBtn)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(note:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: ====== createBtnDidClick ======
    @objc private func createBtnDidClick() {
        view.endEditing(true)
        PTLoadingHubView.show()
        let accountName = account.textField.text ?? ""
        ClientManager.shared.getAccount(account: accountName) { [weak self] (err, info) in
            PTLoadingHubView.dismiss()
            if err != nil {
                if (err! as NSError).code == RPCErrorResponse.ErrorCode {
                   self?.pushToBackUp(account: accountName)
                } else {
                    let errText = LanguageHelper.localizedString(key: "NetworkError")
                    ZSProgressHUD.showDpromptText(errText)
                }
            } else {
                let errText = LanguageHelper.localizedString(key: "AccountExists")
                ZSProgressHUD.showDpromptText(errText)
            }
        }
    }
    
    private func pushToBackUp(account: String) {
        let pwd = password.textField.text ?? ""
        let promptTitle = prompt.textField.text ?? ""
        let model = BackModel(account, _password: pwd, _prompt: promptTitle)
        let title = LanguageHelper.localizedString(key: "BackUpPrivateKey")
        let backUp = BackUpViewController(left: "img|blackBack", title: title, right: nil)
        backUp.model = model
        navigationController?.pushViewController(backUp, animated: true)
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
    
    private func promptError(sender: InputItem) {
        if sender.isEqual(account) {
            let accountName = account.textField.text ?? ""
            if accountName.trim() == "" {
                let err = LanguageHelper.localizedString(key: "AccountNotNull")
                ZSProgressHUD.showDpromptText(err)
                return
            }
            if !accountName.match(regex: createAccountReg) {
                let err = LanguageHelper.localizedString(key: "AccountInvalid")
                ZSProgressHUD.showDpromptText(err)
                return
            }
        }
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
            if createBtn.isUserInteractionEnabled {
                createBtn.backgroundColor = UIColor.lightGray
                createBtn.isUserInteractionEnabled = false
            }
        } else {
            if !createBtn.isUserInteractionEnabled {
                createBtn.backgroundColor = BUTTON_COLOR
                createBtn.isUserInteractionEnabled = true
            }
        }
    }
    
    private func checkInputIsOk() -> Bool {
        if !isSelected {
            return false
        }
        let accountName = account.textField.text ?? ""
        if accountName.trim() == "" {
            return false
        }
        if !accountName.match(regex: createAccountReg) {
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
