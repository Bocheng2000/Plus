//
//  ExchangeViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/28.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ExchangeViewController: FatherViewController, UITextFieldDelegate, AuthorizeViewControllerDelegate {

    open var model: TokenSummary!
    
    private var toModel: TokenSummary!
    private var foToken: TokenSummary!
    
    private var y: CGFloat = 0
    private var assetModel: AccountAssetModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tokenView: TokenInputPreview!
    
    @IBOutlet weak var tokenImageView: TokenImage!
    
    @IBOutlet weak var tokenNameLabel: UIButton!
    
    @IBOutlet weak var expectLabel: UILabel!
    
    @IBOutlet weak var exchangeLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var exchangeBtn: BaseButton!
    
    private var rate: Decimal = Decimal(0)
    
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
                let btn = ModalButtonModel(LanguageHelper.localizedString(key: "OK"), _titleColor: nil, _titleFont: nil, _backgroundColor: nil, _borderColor: nil) {
                    [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
                let modalModel = ModalModel(false, _imageName: "error", _title: err, _message: nil, _buttons: [btn])
                ModalViewController(modalModel).show(source: self)
            } else {
                assetModel = asset!
            }
        }
        foToken = CacheHelper.shared.getOneToken("FO", contract: "eosio")!
        if model.contract == "eosio" && model.symbol == "FO" {
            toModel = CacheHelper.shared.getOneToken("EOS", contract: "eosio")!
        } else {
            toModel = foToken
        }
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        
        let title: String = HomeUtils.autoExtendSymbol(model.symbol!, contract: model.contract!)
        let precision = HomeUtils.getTokenPrecision(HomeUtils.getQuantity(model.supply))
        tokenView.inputField.keyboardType = .decimalPad
        tokenView.inputField.delegate = self
        let quantity = HomeUtils.getQuantity(assetModel.quantity)
        tokenView.model = TokenInputModel("\(title) \(LanguageHelper.localizedString(key: "PayCount"))", _desc: LanguageHelper.localizedString(key: "AvailableBalance"), _maxLength: nil, _defaultValue: quantity, _placeholder: Decimal(0).toFixed(precision), _detailValue: quantity, _precision: precision)
        expectLabel.text = LanguageHelper.localizedString(key: "ExpectToExchange")
        exchangeBtn.backgroundColor = BUTTON_COLOR
        exchangeBtn.setTitle(LanguageHelper.localizedString(key: "ExchangeToken"), for: .normal)
        setExchangeTo()
        updateExchangeRate()
        updateExpectExchange()
    }

    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(note:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @IBAction func exchangeBtnDidClick(_ sender: BaseButton) {
        let amount = tokenView.inputField.text ?? ""
        if amount == "" {
            showError("ExchangeQuantityInvalid")
            return
        }
        let amountDecimal = amount.toDecimal()
        if amountDecimal.isZero {
            showError("ExchangeQuantityNotZero")
            return
        }
        let balance = HomeUtils.getQuantity(assetModel.quantity).toDecimal()
        if amountDecimal > balance {
            showError("LeakOfBalance")
            return
        }
        showPreview(amountDecimal)
    }
    
    private func showPreview(_ amount: Decimal) {
        let current = WalletManager.shared.getCurrent()!
        let fromSymbol: String = HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)
        let toSymbol: String = HomeUtils.getExtendSymbol(toModel.symbol, contract: toModel.contract)
        let amountString = amount.toFixed(HomeUtils.getTokenPrecisionFull(assetModel.quantity))
        let account = AuthorizeItemModel(LanguageHelper.localizedString(key: "Account"), _detail: current.account)
        let fromToken = AuthorizeItemModel(LanguageHelper.localizedString(key: "TokenName"), _detail: fromSymbol)
        let quantity = AuthorizeItemModel(LanguageHelper.localizedString(key: "ExchangeQuantity"), _detail: amountString)
        let toToken = AuthorizeItemModel(LanguageHelper.localizedString(key: "ExchangeToToken"), _detail: toSymbol)
        let expectRate = AuthorizeItemModel(LanguageHelper.localizedString(key: "ExchangeRate"), _detail: String((rate as NSNumber).floatValue))
        let expect = AuthorizeItemModel(LanguageHelper.localizedString(key: "ExpectExchange"), _detail: exchangeLabel.text ?? "")
        let memo = "exchange \(fromSymbol) to \(toSymbol)"
        let exchangeModel = ToExchangeModel(current.account, _memo: memo, _quantity: HomeUtils.getFullQuantity(amountString, symbol: model.symbol), _fromContract: model.contract, _toPrecision: HomeUtils.getTokenPrecisionFull(toModel.supply), _toSymbol: toModel.symbol, _toContract: toModel.contract)
        let authModel = AuthorizeModel(LanguageHelper.localizedString(key: "transactionInfo"), _items: [account, fromToken, quantity, toToken, expectRate, expect], _type: .exchange, _params: exchangeModel)
        let preview = AuthorizeViewController(authModel)
        preview.delegate = self
        preview.show(source: self)
    }
    
    private func showError(_ key: String) {
        let error = LanguageHelper.localizedString(key: key)
        ZSProgressHUD.showDpromptText(error)
    }
    
    // MARK: ===== 获取通证的价格 ==========
    private func getTokenPrice(token: TokenSummary) -> Decimal {
        if token.contract == "eosio" && token.symbol == "FO" {
            return Decimal(1)
        }
        if token.contract == "eosio" && token.symbol == "EOS" {
            return HomeUtils.getTokenPrice(foToken)
        }
        return Decimal(1) / HomeUtils.getTokenPrice(token)
    }
    
    private func setExchangeTo() {
        tokenImageView.model = TokenImageModel(toModel.symbol, _contract: toModel.contract, _isSmart: false, _wh: 24)
        tokenNameLabel.setTitle(HomeUtils.autoExtendSymbol(toModel.symbol!, contract: toModel.contract!), for: .normal)
    }
    
    private func updateExchangeRate() {
        let fromPrice = getTokenPrice(token: model)
        let toPrice = getTokenPrice(token: toModel)
        rate = toPrice / fromPrice
        let fromExtend: String = HomeUtils.autoExtendSymbol(model.symbol, contract: model.contract)
        let toExtend: String = HomeUtils.autoExtendSymbol(toModel.symbol, contract: toModel.contract)
        rateLabel.text = "\(fromExtend):\(toExtend) \(LanguageHelper.localizedString(key: "ExpectRate")) : 1:\((rate as NSNumber).floatValue)"
    }
    
    private func updateExpectExchange() {
        let amount = (tokenView.inputField.text ?? "").toDecimal()
        let toPrecision = HomeUtils.getTokenPrecision(HomeUtils.getQuantity(toModel.supply))
        let expectAmount = amount * rate
        exchangeLabel.text = expectAmount.isNaN ? "" : expectAmount.toFixed(toPrecision)
    }
    
    @IBAction func tokenNameDidClick(_ sender: UIButton) {
        let tokenList = TokenListViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "TakeToken"), right: nil)
        tokenList.takeTokenBlock = {
            [weak self] (asset: AccountAssetModel) in
            self?.setUIDataIfNeeded(asset)
        }
        navigationController?.pushViewController(tokenList, animated: true)
    }
    
    private func setUIDataIfNeeded(_ asset: AccountAssetModel) {
        if asset.symbol == model.symbol && asset.contract == model.contract {
            let error = LanguageHelper.localizedString(key: "TokenSameError")
            ZSProgressHUD.showDpromptText(error)
            return
        }
        if asset.symbol == toModel.symbol && asset.contract == toModel.contract {
            return
        }
        toModel = CacheHelper.shared.getOneToken(asset.symbol, contract: asset.contract)!
        setExchangeTo()
        updateExchangeRate()
        updateExpectExchange()
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
    
    // MARK: ====== AuthViewController Delegate ========
    func authorizeViewController(sender: AuthorizeViewController, cancel: Bool) {
        if cancel {
            ZSProgressHUD.showDpromptText(LanguageHelper.localizedString(key: "TransactionCancel"))
        }
    }
    
    func authorizeViewController(sender: AuthorizeViewController, resp: TransactionResult) {
        print(resp.transactionId)
    }
    
    // MARK: ========== UITextField Delegate =====
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        setExchangeTo()
        updateExchangeRate()
        updateExpectExchange()
        return true
    }
}
