//
//  PayViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class PayViewController: FatherViewController, TokenInputPreviewDelegate, AuthorizeViewControllerDelegate {

    open var model: BaseTokenModel!
    
    open var payInfo: PayModel?
    
    private var y: CGFloat = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var payButton: BaseButton!
    private var assetModel: AccountAssetModel!
    private var receiveAccount: TokenInputPreview!
    private var amount: TokenInputPreview!
    private var memo: TokenInputPreview!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadLocalData()
        makeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadLocalData() {
        let current = WalletManager.shared.getCurrent()
        if current == nil {
            navigationController?.popViewController(animated: true)
        } else {
            let asset = CacheHelper.shared.getOneAsset(current!.account, symbol: model.symbol, contract: model.contract)
            if asset == nil {
                let err = LanguageHelper.localizedString(key: "NoAssetsFound")
                let noticeBar = NoticeBar(title: err, defaultType: .error)
                noticeBar.show(duration: 1, completed: nil)
            } else {
                assetModel = asset!
            }
        }
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        
        let padding: CGFloat = 20
        let tokenPreview = TokenPreview(frame: CGRect(x: padding, y: padding, width: kSize.width - padding * 2, height: 75))
        tokenPreview.titleLabel.text = LanguageHelper.localizedString(key: "SymbolDesc")
        tokenPreview.tokenImageView.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: false, _wh: 30)
        if model.contract == "eosio" {
            tokenPreview.tokenLabel.text = model.symbol
        } else {
            tokenPreview.titleLabel.text = HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)
        }
        scrollView.addSubview(tokenPreview)
        
        receiveAccount = TokenInputPreview(frame: CGRect(x: padding, y: tokenPreview.bottom + 11, width: tokenPreview.width, height: tokenPreview.height))
        let receiveModel = TokenInputModel(LanguageHelper.localizedString(key: "ReceiveAccount"), _desc: nil, _maxLength: 12, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "ReceiveAccountName"), _detailValue: nil, _precision: nil)
        if payInfo != nil {
            receiveModel.defaultValue = payInfo!.account
        }
        receiveAccount.model = receiveModel
        receiveAccount.inputField.keyboardType = .emailAddress
        scrollView.addSubview(receiveAccount)
        
        amount = TokenInputPreview(frame: CGRect(x: padding, y: receiveAccount.bottom + 11, width: tokenPreview.width, height: tokenPreview.height))
        amount.inputField.keyboardType = .decimalPad
        let quantity = HomeUtils.getQuantity(assetModel.quantity)
        let amountModel = TokenInputModel(LanguageHelper.localizedString(key: "PayAmount"), _desc: LanguageHelper.localizedString(key: "AvailableBalance"), _maxLength: nil, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "InputPayAmount"), _detailValue: quantity, _precision: HomeUtils.getTokenPrecision(quantity))
        if payInfo != nil {
            amountModel.defaultValue = payInfo!.amount
        }
        amount.model = amountModel
        scrollView.addSubview(amount)
        
        memo = TokenInputPreview(frame: CGRect(x: padding, y: amount.bottom + 11, width: tokenPreview.width, height: tokenPreview.height))
        let memoModel = TokenInputModel(LanguageHelper.localizedString(key: "Memo"), _desc: nil, _maxLength: nil, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "Optional"), _detailValue: nil, _precision: nil)
        if payInfo != nil {
            memoModel.defaultValue = payInfo!.memo
        }
        memo.model = memoModel
        scrollView.addSubview(memo)
        scrollView.contentSize = CGSize(width: kSize.width, height: memo.bottom + 20)
        
        payButton.setTitle(LanguageHelper.localizedString(key: "PayToken"), for: .normal)
        payButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        payButton.backgroundColor = BUTTON_COLOR
        payButton.layer.cornerRadius = 4
        payButton.layer.masksToBounds = true
    }
    
    @IBAction func payButtonDidClick(_ sender: BaseButton) {
        view.endEditing(true)
        if checkParamsIsValid() {
            let receiver = (receiveAccount.inputField.text ?? "").trimAll()
            let amountValue = amount.inputField.text ?? ""
            let memoValue = memo.inputField.text ?? ""
            let current = WalletManager.shared.getCurrent()!
            
            let quantity = HomeUtils.getQuantity(assetModel.quantity)
            let precision = HomeUtils.getTokenPrecision(quantity)
            let quantityFmt = "\(amountValue.toFloat().toFixed(precision)) \(model.symbol!)"
            let transType = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransactionType"), _detail: LanguageHelper.localizedString(key: "Pay"))
            let fromItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferFrom"), _detail: current.account)
            let toItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferTo"), _detail: receiver)
            let count = AuthorizeItemModel(LanguageHelper.localizedString(key: "Quantity"), _detail: quantityFmt)
            let memoVal = AuthorizeItemModel(LanguageHelper.localizedString(key: "Memo"), _detail: memoValue)
            
            let extranferModel = ExTransferModel(quantityFmt, _from: current.account, _to: receiver, _memo: memoValue, _contract: model.contract)
            let authModel = AuthorizeModel(LanguageHelper.localizedString(key: "transactionInfo"), _items: [transType, fromItem, toItem, count, memoVal], _type: .transfer, _params: extranferModel)
            let auth = AuthorizeViewController(authModel)
            auth.delegate = self
            auth.show(source: self)
        }
    }
    
    private func checkParamsIsValid() -> Bool {
        let receiver = receiveAccount.inputField.text ?? ""
        if receiver.trim() == "" {
            showErrorWithKey("AccountNameNotNull")
            return false
        }
        let current = WalletManager.shared.getCurrent()!
        if current.account == receiver {
            showErrorWithKey("DisableTransferSelf")
            return false
        }
        let amountValue = amount.inputField.text ?? ""
        if amountValue == "" {
            showErrorWithKey("QuantityNotNull")
            return false
        }
        let amoutValueFloat = amountValue.toFloat()
        if amoutValueFloat == 0 {
            showErrorWithKey("QuantityNotZero")
            return false
        }
        if amoutValueFloat > HomeUtils.getQuantity(assetModel.quantity).toFloat() {
            showErrorWithKey("LeakOfBalance")
            return false
        }
        return true
    }
    
    private func showErrorWithKey(_ key: String) {
        let err = LanguageHelper.localizedString(key: key)
        ZSProgressHUD.showDpromptText(err)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(note:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
    
    // MARK: ===== TokenInputPreviewDelegate =====
    func tokenInputPreviewFocus(sender: TokenInputPreview) {
        let textField = sender.inputField
        let rect = textField?.convert((textField?.bounds)!, to: view)
        if rect != nil {
            y = rect!.origin.y + rect!.size.height
        }
    }
    
    func tokenInputPreviewBlur(sender: TokenInputPreview) {
        
    }
    
    func authorizeViewController(sender: AuthorizeViewController, cancel: Bool) {
        
    }
    
    func authorizeViewController(sender: AuthorizeViewController, resp: TransactionResult) {
        print(resp.transactionId)
    }
}
