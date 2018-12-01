//
//  WithdrawViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/29.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WithdrawViewController: FatherViewController, AuthorizeViewControllerDelegate {

    open var model: BaseTokenModel!
    
    private var assetModel: AccountAssetModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tokenPreview: TokenPreview!
    
    @IBOutlet weak var receiveAccount: TokenInputPreview!
    
    @IBOutlet weak var amountPreview: TokenInputPreview!
    
    @IBOutlet weak var memoPreview: TokenInputPreview!
    
    @IBOutlet weak var withDrawBtn: BaseButton!
    
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
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        tokenPreview.titleLabel.text = LanguageHelper.localizedString(key: "SymbolDesc")
        tokenPreview.tokenImageView.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: false, _wh: 30)
        tokenPreview.tokenLabel.text = HomeUtils.autoExtendSymbol(model.symbol, contract: model.contract)
        
        receiveAccount.model = TokenInputModel(LanguageHelper.localizedString(key: "TransferToAccount"), _desc: nil, _maxLength: nil, _defaultValue: fiboscouncil, _placeholder: nil, _detailValue: nil, _precision: nil)
        receiveAccount.inputField.isEnabled = false
        
        amountPreview.inputField.keyboardType = .decimalPad
        amountPreview.model = TokenInputModel(LanguageHelper.localizedString(key: "TransferOutQuantity"), _desc: LanguageHelper.localizedString(key: "AvailableBalance"), _maxLength: nil, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "InputTransferOutQuantity"), _detailValue: HomeUtils.getQuantity(assetModel.quantity), _precision: HomeUtils.getTokenPrecisionFull(assetModel.quantity))
        
        memoPreview.inputField.keyboardType = .emailAddress
        memoPreview.model = TokenInputModel("MEMO", _desc: nil, _maxLength: 12, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "InputEOSAccount"), _detailValue: nil, _precision: nil)
        
        withDrawBtn.backgroundColor = BUTTON_COLOR
        withDrawBtn.setTitle(LanguageHelper.localizedString(key: "ExportToken"), for: .normal)
    }
    
    // MARK: ========= 转出按钮点击事件  ==========
    @IBAction func withDrawDidClick(_ sender: BaseButton) {
        let amount = amountPreview.inputField.text ?? ""
        if amount == "" {
            showError("WithDrawInvalid")
            return
        }
        let amountDecimal = amount.toDecimal()
        if amountDecimal.isZero {
            showError("WithDrawNotZero")
            return
        }
        if amountDecimal > HomeUtils.getQuantity(assetModel.quantity).toDecimal() {
            showError("LeakOfBalance")
            return
        }
        let memo = memoPreview.inputField.text ?? ""
        if memo.trimAll().count == 0 {
            showError("InputMemo")
            return
        }
        showPreview(amountDecimal)
    }
    
    private func showError(_ key: String) {
        let error = LanguageHelper.localizedString(key: key)
        ZSProgressHUD.showDpromptText(error)
    }
    
    private func showPreview(_ amount: Decimal) {
        let precision = HomeUtils.getTokenPrecisionFull(assetModel.quantity)
        let quantityFixed = amount.toFixed(precision)
        let memo = memoPreview.inputField.text ?? ""
        let token = AuthorizeItemModel(LanguageHelper.localizedString(key: "TokenName"), _detail: HomeUtils.getExtendSymbol(model.symbol, contract: model.contract))
        let transferTo = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferToAccount"), _detail: fiboscouncil)
        let withDrawAmount = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferOutQuantity"), _detail: quantityFixed)
        let eos = AuthorizeItemModel(LanguageHelper.localizedString(key: "EOSReceiver"), _detail: memo)
        let current = WalletManager.shared.getCurrent()!
        let params = ExTransferModel(HomeUtils.getFullQuantity(quantityFixed, symbol: model.symbol), _from: current.account, _to: fiboscouncil, _memo: memo, _contract: model.contract)
        let authModel = AuthorizeModel(LanguageHelper.localizedString(key: "transactionInfo"), _items: [token, transferTo, withDrawAmount, eos], _type: .transfer, _params: params)
        let auth = AuthorizeViewController(authModel)
        auth.delegate = self
        auth.show(source: self)
    }
    
    func authorizeViewController(sender: AuthorizeViewController, cancel: Bool) {
        if cancel {
            ZSProgressHUD.showDpromptText(LanguageHelper.localizedString(key: "TransactionCancel"))
        }
    }
    
    func authorizeViewController(sender: AuthorizeViewController, resp: TransactionResult) {
        print(resp.transactionId)
    }
    
}
