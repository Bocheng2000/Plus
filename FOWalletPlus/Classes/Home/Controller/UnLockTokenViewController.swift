//
//  UnLockTokenViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/2.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class UnLockTokenViewController: FatherViewController, AuthorizeViewControllerDelegate {

    open var model: AssetsModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var unlockPreview: TokenInputPreview!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var tipLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var unlockBtn: BaseButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        let token = CacheHelper.shared.getOneToken(model.balance.symbol, contract: model.balance.contract)
        if token == nil {
            let err = LanguageHelper.localizedString(key: "NoAssetsFound")
            let btn = ModalButtonModel(LanguageHelper.localizedString(key: "OK"), _titleColor: nil, _titleFont: nil, _backgroundColor: nil, _borderColor: nil) {
                [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            let modalModel = ModalModel(false, _imageName: "error", _title: err, _message: nil, _buttons: [btn])
            ModalViewController(modalModel).show(source: self)
        } else {
            let max = caculateUnLockQuantity(token!)
            let text = "\(LanguageHelper.localizedString(key: "UnLockMax")): \(max)"
            let size = text.getTextSize(font: tipLabel.font, lineHeight: 0, maxSize: CGSize(width: kSize.width, height: CGFloat(MAXFLOAT)))
            tipLabel.text = text
            if size.height > 16 {
                tipLabelHeight.constant = size.height
                containerHeight.constant = containerHeight.constant + size.height - 16
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    private func caculateUnLockQuantity(_ token: TokenSummary) -> String {
        let t = HomeUtils.getQuantity(model.balance.quantity).toDecimal()
        let precision = HomeUtils.getTokenPrecisionFull(model.balance.quantity)
        let s = HomeUtils.getQuantity(token.supply).toDecimal() + HomeUtils.getQuantity(token.reserve_supply).toDecimal()
        let r = HomeUtils.getQuantity(token.connector_balance).toDecimal() + HomeUtils.getQuantity(token.reserve_connector_balance).toDecimal()
        let cw = token.connector_weight.toDecimal()
        let a = t / s
        let b = 1 / a
        let c = pow(b, ((1 / cw) as NSNumber).intValue)
        let d = 1 - c
        let e = r * d
        let h = e / r
        let i = 1 - h
        let j = pow(i, (cw as NSNumber).intValue)
        let k = 1 - j
        let unlock = s * k
        return min(unlock, t).toFixed(precision)
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        unlockPreview.inputField.keyboardType = .decimalPad
        let precision = HomeUtils.getTokenPrecisionFull(model.balance.quantity)
        unlockPreview.model = TokenInputModel(LanguageHelper.localizedString(key: "UnLockQuantity"), _desc: nil, _maxLength: nil, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "InputUnLockQuantity"), _detailValue: nil, _precision: precision)
        unlockBtn.backgroundColor = BUTTON_COLOR
        unlockBtn.setTitle(LanguageHelper.localizedString(key: "UnLockToken"), for: .normal)
    }
    
    @IBAction func unlockBtnDidClick(_ sender: BaseButton) {
        if checkParamsIsValid() {
            let amount = unlockPreview.inputField.text ?? ""
            let precision = HomeUtils.getTokenPrecisionFull(model.balance.quantity)
            let fmt = amount.toDecimal().toFixed(precision)
            let current = WalletManager.shared.getCurrent()!
            let fmted = HomeUtils.getFullQuantity(fmt, symbol: model.balance.symbol)
            let unlockModel = ToUnLockTokenModel(current.account, _quantity: fmted, _contract: model.balance.contract, _expiration: model.lock_timestamp!, _memo: "")
            
            let transType = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransactionType"), _detail: LanguageHelper.localizedString(key: "ToUnLockToken"))
            let fromItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferFrom"), _detail: current.account)
            let toItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferTo"), _detail: current.account)
            let count = AuthorizeItemModel(LanguageHelper.localizedString(key: "Quantity"), _detail: fmted)
            
            let authModel = AuthorizeModel(LanguageHelper.localizedString(key: "transactionInfo"), _items: [transType, fromItem, toItem, count], _type: .unlockToken, _params: unlockModel)
            let auth = AuthorizeViewController(authModel)
            auth.delegate = self
            auth.show(source: self)
        }
    }
    
    private func checkParamsIsValid() -> Bool {
        let amount = unlockPreview.inputField.text ?? ""
        if amount == "" {
            showError("QuantityNotNull")
            return false
        }
        let amountDecimal = amount.toDecimal()
        if amountDecimal.isNaN {
            showError("QuantityNotZero")
            return false
        }
        if amountDecimal.isZero {
            showError("QuantityNotZero")
            return false
        }
        if amountDecimal > HomeUtils.getQuantity(model.balance.quantity).toDecimal() {
            showError("LeakOfBalance")
            return false
        }
        return true
    }
    
    private func showError(_ key: String) {
        let error = LanguageHelper.localizedString(key: key)
        ZSProgressHUD.showDpromptText(error)
    }
    
    // MARK: =========== AuthorizeViewController Delegate ======
    func authorizeViewController(sender: AuthorizeViewController, cancel: Bool) {
        if cancel {
            ZSProgressHUD.showDpromptText(LanguageHelper.localizedString(key: "TransactionCancel"))
        }
    }
    
    func authorizeViewController(sender: AuthorizeViewController, resp: TransactionResult) {
        print(resp.transactionId)
    }
}
