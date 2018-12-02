//
//  LockPayViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/2.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class LockPayViewController: FatherViewController, PGDatePickerDelegate, AuthorizeViewControllerDelegate {

    open var model: AssetsModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tokenPreview: TokenPreview!
    
    @IBOutlet weak var receiveAccount: TokenInputPreview!
    
    @IBOutlet weak var payAmount: TokenInputPreview!
    
    @IBOutlet weak var lockTimeLabel: UILabel!
    
    @IBOutlet weak var lockToButton: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var tipHeight: NSLayoutConstraint!
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var payButton: BaseButton!
    
    private var customTs: String?
    
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
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        
        tokenPreview.titleLabel.text = LanguageHelper.localizedString(key: "SymbolDesc")
        tokenPreview.tokenImageView.model = TokenImageModel(model.balance.symbol, _contract: model.balance.contract, _isSmart: false, _wh: 24)
        tokenPreview.tokenLabel.text = HomeUtils.autoExtendSymbol(model.balance.symbol, contract: model.balance.contract)
        
        receiveAccount.inputField.keyboardType = .emailAddress
        receiveAccount.model = TokenInputModel(LanguageHelper.localizedString(key: "ReceiveAccount"), _desc: nil, _maxLength: 12, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "ReceiveAccountName"), _detailValue: nil, _precision: nil)
        
        let quantity = HomeUtils.getQuantity(model.balance.quantity)
        let precision = HomeUtils.getTokenPrecision(quantity)
        payAmount.inputField.keyboardType = .decimalPad
        payAmount.model = TokenInputModel(LanguageHelper.localizedString(key: "PayAmount"), _desc: LanguageHelper.localizedString(key: "AvailableBalance"), _maxLength: nil, _defaultValue: nil, _placeholder: LanguageHelper.localizedString(key: "InputPayAmount"), _detailValue: quantity, _precision: precision)
        
        lockTimeLabel.text = LanguageHelper.localizedString(key: "LockTime")
        let lockTo = (model.lock_timestamp! + ".000Z").utcTime2Local(format: "yyyy/MM/dd")
        lockToButton.setTitle(lockTo, for: .normal)
        
        let tip = LanguageHelper.localizedString(key: "UnLockTokenTips")
        let size = tip.getTextSize(font: tipLabel.font, lineHeight: 0, maxSize: CGSize(width: kSize.width - 40, height: CGFloat(MAXFLOAT)))
        tipLabel.text = tip
        if size.height > 18 {
            tipHeight.constant = size.height
            containerHeight.constant = containerHeight.constant + size.height - 18
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        let transfer = LanguageHelper.localizedString(key: "Transfer")
        payButton.backgroundColor = BUTTON_COLOR
        payButton.setTitle(transfer, for: .normal)
    }
    
    @IBAction func changeTimeBtnDidClick(_ sender: UIButton) {
        let datePickManager = PGDatePickManager()
        datePickManager.cancelButtonText = LanguageHelper.localizedString(key: "Cancel")
        datePickManager.cancelButtonFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        datePickManager.cancelButtonTextColor = UIColor.colorWithHexString(hex: "#999999")
        datePickManager.confirmButtonText = LanguageHelper.localizedString(key: "Confirm")
        datePickManager.confirmButtonFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        datePickManager.confirmButtonTextColor = BUTTON_COLOR
        datePickManager.isShadeBackgroud = true
        let datePicker = datePickManager.datePicker
        datePicker?.language = LanguageHelper.getUserLanguage()
        datePicker?.datePickerMode = .date
        let defaultDate = ("\(model.lock_timestamp!).000Z").utcTime2LocalDate()
        datePicker?.minimumDate = defaultDate
        datePicker?.setDate(defaultDate)
        datePicker?.delegate = self
        present(datePickManager, animated: false, completion: nil)
    }
    
    @IBAction func payButtonDidClick(_ sender: BaseButton) {
        if checkParamsIsValid() {
            let receiver = receiveAccount.inputField.text ?? ""
            let amount = payAmount.inputField.text ?? ""
            let precision = HomeUtils.getTokenPrecisionFull(model.balance.quantity)
            let current = WalletManager.shared.getCurrent()!
            let fmtQuantity = amount.toDecimal().toFixed(precision)
            let quantity = HomeUtils.getFullQuantity(fmtQuantity, symbol: model.balance.symbol)
            var exipreTs = model.lock_timestamp!
            if customTs != nil {
                let exipreTo = "\(customTs!) 23:59:59"
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
                exipreTs = (fmt.date(from: exipreTo)?.utcFormatter(formatter: "yyyy-MM-dd'T'HH:mm:ss"))!
            }
            let transType = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransactionType"), _detail: LanguageHelper.localizedString(key: "LockTransfer"))
            let fromItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferFrom"), _detail: current.account)
            let toItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferTo"), _detail: receiver)
            let count = AuthorizeItemModel(LanguageHelper.localizedString(key: "Quantity"), _detail: quantity)
            let lockTo = AuthorizeItemModel(LanguageHelper.localizedString(key: "LockTo"), _detail: "\(exipreTs).000Z".utcTime2Local(format: "yyyy/MM/dd"))
            
            let lockTransferModel = ToTransferInLockModel(current.account, _to: receiver, _quantity: quantity, _contract: model.balance.contract, _memo: "", _expiration: model.lock_timestamp!, _expiration_to: exipreTs)
            let authModel = AuthorizeModel(LanguageHelper.localizedString(key: "transactionInfo"), _items: [transType, fromItem, toItem, count, lockTo], _type: .transferInLock, _params: lockTransferModel)
            let auth = AuthorizeViewController(authModel)
            auth.delegate = self
            auth.show(source: self)
        }
    }
    
    // MARK: =========== 检测输入参数是否有效 =============
    private func checkParamsIsValid() -> Bool {
        let receiver = receiveAccount.inputField.text ?? ""
        if receiver.trim() == "" {
            showError("AccountNameNotNull")
            return false
        }
        let amount = payAmount.inputField.text ?? ""
        let current = WalletManager.shared.getCurrent()!
        if amount == current.account {
            showError("DisableTransferSelf")
            return false
        }
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
        let err = LanguageHelper.localizedString(key: key)
        ZSProgressHUD.showDpromptText(err)
    }
    
    // MARK: ======== DatePicker Delegate =========
    func datePicker(_ datePicker: PGDatePicker!, didSelectDate dateComponents: DateComponents!) {
        customTs = "\(dateComponents.year!)/\(dateComponents.month!)/\(dateComponents.day!)"
        lockToButton.setTitle(customTs, for: .normal)
    }
    
    // MARK: ======== AuthorizeViewController Deleagte ===========
    func authorizeViewController(sender: AuthorizeViewController, cancel: Bool) {
        if cancel {
            ZSProgressHUD.showDpromptText(LanguageHelper.localizedString(key: "TransactionCancel"))
        }
    }
    
    func authorizeViewController(sender: AuthorizeViewController, resp: TransactionResult) {
        print(resp.transactionId)
    }
}
