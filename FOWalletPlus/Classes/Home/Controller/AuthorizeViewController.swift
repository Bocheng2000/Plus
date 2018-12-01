//
//  AuthorizeViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/20.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol AuthorizeViewControllerDelegate: NSObjectProtocol {
    @objc optional func authorizeViewController(sender: AuthorizeViewController, cancel: Bool)
    @objc optional func authorizeViewController(sender: AuthorizeViewController, resp: TransactionResult)
}

class AuthorizeViewController: UIViewController {

    weak var delegate: AuthorizeViewControllerDelegate?
    open var model: AuthorizeModel!
    private var container: UIView!
    
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
        let padding: CGFloat = 20
        
        container = UIView(frame: CGRect(x: 0, y: 0, width: kSize.width - padding * 2, height: 0))
        container.backgroundColor = UIColor.white
        view.addSubview(container)
        
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
        
        let line = UIView(frame: CGRect(x: 0, y: titleLabel.bottom + 10, width: kSize.width, height: 0.5))
        line.backgroundColor = BORDER_COLOR
        container.addSubview(line)
        let font = UIFont.systemFont(ofSize: 15)
        let color = UIColor.colorWithHexString(hex: "#4C4D60")
        for i in (0...model.items.count - 1) {
            let item = model.items[i]
            let titleSize = item.title.getTextSize(font: font, lineHeight: 0, maxSize: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)))
            let label = UILabel(frame: CGRect(x: padding, y: line.bottom + CGFloat(i) * 44, width: titleSize.width, height: 44))
            label.font = font
            label.textColor = color
            label.text = item.title
            label.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
            
            let detailLabel = UILabel(frame: CGRect(x: label.right, y: label.top, width: kSize.width - padding - label.right, height: label.height))
            detailLabel.textAlignment = .right
            detailLabel.font = font
            detailLabel.textColor = color
            detailLabel.text = item.detail
            detailLabel.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
            container.addSubview(label)
            container.addSubview(detailLabel)
        }
        let confirmBtn = BaseButton(frame: CGRect(x: padding, y: line.bottom + CGFloat(model.items.count) * 44 + 20, width: kSize.width - padding * 2, height: 48))
        confirmBtn.layer.cornerRadius = 4
        confirmBtn.layer.masksToBounds = true
        confirmBtn.backgroundColor = BUTTON_COLOR
        confirmBtn.setTitle(LanguageHelper.localizedString(key: "Confirm"), for: .normal)
        container.addSubview(confirmBtn)
        confirmBtn.addTarget(self, action: #selector(doneBtnDidClick), for: .touchUpInside)
        container.frame = CGRect(x: 0, y: kSize.height, width: kSize.width, height: confirmBtn.bottom + 20 + safeBottom)
    }
    
    @objc private func closeBtnDidClick() {
        if delegate != nil {
            delegate?.authorizeViewController!(sender: self, cancel: true)
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
        let style = JCAlertStyle.share()!
        style.title.insets = UIEdgeInsetsMake(15, 10, 0, 10)
        style.title.backgroundColor = bjColor
        style.buttonNormal.textColor = BUTTON_COLOR
        style.buttonNormal.backgroundColor = bjColor
        style.buttonWarning.backgroundColor = bjColor
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
    
    /// 去除私钥
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
        invokeTransaction(pkString!)
    }

    /// 执行交易
    ///
    /// - Parameter pkString: 私钥
    private func invokeTransaction(_ pkString: String) {
        model.params.pkString = pkString
        PTLoadingHubView.show()
        switch model.type {
            case .transfer:
                ClientManager.shared.transfer(model.params as! ExTransferModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .exchange:
                ClientManager.shared.exchange(model.params as! ToExchangeModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .unlockToken:
                ClientManager.shared.unLockToken(model.params as! ToUnLockTokenModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .transferInLock:
                ClientManager.shared.transferInLock(model.params as! ToTransferInLockModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .rechargeWallet:
                ClientManager.shared.rechargeWallet(model.params as! ToContractWalletModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .withDrawWallet:
                ClientManager.shared.withDrawWallet(model.params as! ToContractWalletModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .createForPay:
                ClientManager.shared.createNewAccount(model.params as! ToCreateAccountModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .delegateRam:
                ClientManager.shared.delegateRam(model.params as! ToDelegateRamModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .undelegateRam:
                ClientManager.shared.unDelegateRam(model.params as! ToUnDelegateRamModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .delegateNet:
                ClientManager.shared.delegateNet(model.params as! ToDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .undelegateNet:
                ClientManager.shared.unDelegateNet(model.params as! ToUnDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .delegateCpu:
                ClientManager.shared.delegateCpu(model.params as! ToDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .undelegateCpu:
                ClientManager.shared.unDelegateCpu(model.params as! ToUnDelegateBWModel) { [weak self] (err, resp) in
                    self?.handlerTransferResult(err, resp: resp)
                }
                break
            case .vote:
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
            if delegate != nil {
                delegate?.authorizeViewController!(sender: self, resp: resp!)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
