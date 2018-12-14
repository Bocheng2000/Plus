//
//  AuthorizeViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/20.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc enum AuthorizeResult: Int {
    case denied
    case authorized
}

@objc protocol AuthorizeViewControllerDelegate: NSObjectProtocol {
    @objc optional func authorizeViewController(sender: AuthorizeViewController, cancel: Bool)
    @objc optional func authorizeViewController(sender: AuthorizeViewController, resp: TransactionResult)
    @objc optional func exportPkString(sender: AuthorizeViewController, pkString: String)
    @objc optional func authGetAccountInfo(result: AuthorizeResult)
}

class AuthorizeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: AuthorizeViewControllerDelegate?
    open var cancelBlock: (() -> Void)?
    open var transactionRespBlock: ((TransactionResult) -> Void)?
    open var exportPkStringBlock: ((String) -> Void)?
    open var authorizeBlock: ((AuthorizeResult) -> Void)?
    
    open var model: AuthorizeModel!
    private var container: UIView!
    private var maxHeight: CGFloat = 300
    private var cellHeights: [CGFloat] = []
    
    convenience init(_ _model: AuthorizeModel) {
        self.init()
        model = _model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
    }
    
    open func show(source: UIViewController) {
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        source.present(self, animated: false) {
            UIView.animate(withDuration: 0.2, animations: {
                self.container.y = kSize.height - self.container.height
            })
        }
    }
    
    private func makeUI() {
        view.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.5)
        container = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width, height: 0))
        container.backgroundColor = UIColor.white
        view.addSubview(container)
        createHeader()
        var _h: CGFloat = 0
        if model.items.count > 0 {
            let font = UIFont.systemFont(ofSize: 15)
            cellHeights = model.items.map { (item) -> CGFloat in
                let valueHeight = item.detail.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: kSize.width - 110 - 40, height: CGFloat(MAXFLOAT)))
                let h = max(valueHeight.height + 20, 44)
                _h += h
                return h
            }
            let tableView = UITableView(frame: CGRect(x: 0, y: 50, width: kSize.width, height: min(maxHeight, _h)))
            tableView.register(UINib(nibName: "AuthorizeTableViewCell", bundle: nil), forCellReuseIdentifier: "AuthorizeTableViewCell")
            tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
            tableView.separatorColor = SEPEAT_COLOR
            tableView.delegate = self
            tableView.dataSource = self
            container.addSubview(tableView)
        }
        let bottom = 50 + min(maxHeight, _h)
        createButton(top: bottom)
        container.frame = CGRect(x: 0, y: kSize.height, width: kSize.width, height: bottom + 48 + safeBottom)
    }
    
    private func createHeader() {
        let titleLabel = UILabel(frame: CGRect(x: 45, y: 10, width: kSize.width - 90, height: 30))
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = FONT_COLOR
        titleLabel.textAlignment = .center
        titleLabel.text = model.title
        container.addSubview(titleLabel)
        let closeBtn = UIButton(frame: CGRect(x: kSize.width - 45, y: titleLabel.top, width: 30, height: 30))
        closeBtn.setImage(UIImage(named: "close"), for: .normal)
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
        closeBtn.addTarget(self, action: #selector(closeBtnDidClick), for: .touchUpInside)
        container.addSubview(closeBtn)
        let line = UIView(frame: CGRect(x: 0, y: titleLabel.bottom + 9.5, width: kSize.width, height: 0.5))
        line.backgroundColor = BORDER_COLOR
        container.addSubview(line)
    }
    
    private func createButton(top: CGFloat) {
        let confirmBtn = BaseButton(frame: CGRect(x: 0, y: top, width: kSize.width, height: 48))
        confirmBtn.backgroundColor = BUTTON_COLOR
        confirmBtn.setTitle(LanguageHelper.localizedString(key: "Confirm"), for: .normal)
        container.addSubview(confirmBtn)
        confirmBtn.addTarget(self, action: #selector(doneBtnDidClick), for: .touchUpInside)
    }
    
    @objc private func closeBtnDidClick() {
        if model.type == .authGetAccount {
            if authorizeBlock != nil {
                authorizeBlock!(.denied)
            }
            if delegate != nil && delegate?.responds(to: #selector(AuthorizeViewControllerDelegate.authGetAccountInfo(result:))) ?? false {
                delegate?.authGetAccountInfo!(result: .denied)
            }
        } else {
            if cancelBlock != nil {
                cancelBlock!()
            }
            if delegate != nil && (delegate?.responds(to: #selector(AuthorizeViewControllerDelegate.authorizeViewController(sender:cancel:))) ?? false) {
                delegate?.authorizeViewController!(sender: self, cancel: true)
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.container.y = kSize.height
        }) { (finish) in
            if finish {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func doneBtnDidClick() {
        if model.type == .authGetAccount {
            if authorizeBlock != nil {
                authorizeBlock!(.authorized)
            }
            if delegate != nil && delegate?.responds(to: #selector(AuthorizeViewControllerDelegate.authGetAccountInfo(result:))) ?? false {
                delegate?.authGetAccountInfo!(result: .authorized)
            }
        } else {
            createConfirmAlert()
        }
    }
    
    private func createConfirmAlert() {
        let style = JCAlertStyle.share()!
        let width = style.alertView.width
        let bjColor = UIColor.colorWithHexString(hex: "#E7E7E7")
        let textField = createTextView(bjColor, width: width)
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 65))
        contentView.backgroundColor = bjColor
        contentView.addSubview(textField)
        let alert = JCAlertController.alert(withTitle: LanguageHelper.localizedString(key: "VerifyPassword"), contentView: contentView)
        alert?.addButton(withTitle: LanguageHelper.localizedString(key: "Cancel"), type: JCButtonType(rawValue: 0), clicked: {
            textField.resignFirstResponder()
        })
        alert?.addButton(withTitle: LanguageHelper.localizedString(key: "Confirm"), type: JCButtonType(rawValue: 2), clicked: {
            [weak self] in
            textField.resignFirstResponder()
            let value = textField.text
            self?.confirmDidClick(value: value)
        })
        weak var weakAlert = alert
        alert?.monitorKeyboardShowed({ (alertHeight, keyboardHeight) in
            weakAlert?.moveAlertView(toCenterY: alertHeight / 2 + 120, animated: true)
        })
        alert?.monitorKeyboardHided({
            weakAlert?.moveAlertViewToScreenCenter(animated: true)
        })
        present(alert!, animated: true) {
            textField.becomeFirstResponder()
        }
    }
    
    private func createTextView(_ bjColor: UIColor, width: CGFloat) -> BaseTextField {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        paddingView.backgroundColor = UIColor.white
        let textField = BaseTextField(frame: CGRect(x: 2, y: 2, width: width - 20, height: paddingView.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        textField.placeholder = LanguageHelper.localizedString(key: "WalletPassword")
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.contentVerticalAlignment = .center
        textField.isSecureTextEntry = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = BORDER_COLOR.cgColor
        textField.layer.cornerRadius = 2
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor.white
        textField.center = CGPoint(x: width / 2, y: 34)
        return textField
    }
    
    /// 去取私钥
    ///
    /// - Parameter value: 密码
    private func confirmDidClick(value: String?) {
        if value == nil || value! == "" {
            let err = LanguageHelper.localizedString(key: "PasswordNotNull")
            ZSProgressHUD.showDpromptText(err)
            return
        }
        let current = WalletManager.shared.getCurrent()
        if current == nil {
            let err = LanguageHelper.localizedString(key: "Oops")
            ZSProgressHUD.showDpromptText(err)
            return
        }
        let wallet = WalletManager.shared.getWallet(pubKey: current!.pubKey, account: current!.account)
        if wallet == nil {
            let err = LanguageHelper.localizedString(key: "Oops")
            ZSProgressHUD.showDpromptText(err)
            return
        }
        if !wallet!.verifyPassword(value!) {
            let err = LanguageHelper.localizedString(key: "PasswordIsError")
            ZSProgressHUD.showDpromptText(err)
            return
        }
        let pkString = wallet!.getPriKey(value!)
        if pkString == nil || pkString == "" {
            let err = LanguageHelper.localizedString(key: "PasswordIsError")
            ZSProgressHUD.showDpromptText(err)
            return
        }
        if model.type == .exportPk {
            dismiss(animated: true, completion: nil)
            if exportPkStringBlock != nil {
                exportPkStringBlock!(pkString!)
            }
            if delegate != nil && (delegate?.responds(to: #selector(AuthorizeViewControllerDelegate.exportPkString(sender:pkString:))) ?? false) {
                delegate?.exportPkString!(sender: self, pkString: pkString!)
            }
        } else {
            invokeTransaction(pkString!)
        }
    }
    
    /// 执行交易
    ///
    /// - Parameter pkString: 私钥
    private func invokeTransaction(_ pkString: String) {
        model.params.pkString = pkString
        PTLoadingHubView.show()
        switch model.type {
        case .transfer?:
                ClientManager.shared.transfer(model.params as! ExTransferModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .exchange?:
                ClientManager.shared.exchange(model.params as! ToExchangeModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .unlockToken?:
                ClientManager.shared.unLockToken(model.params as! ToUnLockTokenModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .transferInLock?:
                ClientManager.shared.transferInLock(model.params as! ToTransferInLockModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .rechargeWallet?:
                ClientManager.shared.rechargeWallet(model.params as! ToContractWalletModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .withDrawWallet?:
                ClientManager.shared.withDrawWallet(model.params as! ToContractWalletModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .createForPay?:
                ClientManager.shared.createNewAccount(model.params as! ToCreateAccountModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .delegateRam?:
                ClientManager.shared.delegateRam(model.params as! ToDelegateRamModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .undelegateRam?:
                ClientManager.shared.unDelegateRam(model.params as! ToUnDelegateRamModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .delegateNet?:
                ClientManager.shared.delegateNet(model.params as! ToDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .undelegateNet?:
                ClientManager.shared.unDelegateNet(model.params as! ToUnDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .delegateCpu?:
                ClientManager.shared.delegateCpu(model.params as! ToDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .undelegateCpu?:
                ClientManager.shared.unDelegateCpu(model.params as! ToUnDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
        case .vote?:
                ClientManager.shared.vote(model.params as! ToVoteModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            default:
                PTLoadingHubView.dismiss()
        }
    }
    
    private func handlerTransferResult(_ error: Error?, resp: TransactionResult?) {
        PTLoadingHubView.dismiss()
        if error != nil {
            let err = LanguageHelper.localizedString(key: "TransactionFailed")
            ZSProgressHUD.showDpromptText(err)
        } else {
            if transactionRespBlock != nil {
                transactionRespBlock!(resp!)
            }
            if delegate != nil && (delegate?.responds(to: #selector(AuthorizeViewControllerDelegate.authorizeViewController(sender:resp:))) ?? false) {
                delegate?.authorizeViewController!(sender: self, resp: resp!)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: ======== UITableView DataSource And Delegate =======
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorizeTableViewCell") as! AuthorizeTableViewCell
        cell.titleLabel?.text = item.title
        cell.detailLabel?.text = item.detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
