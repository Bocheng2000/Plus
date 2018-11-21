//
//  PayViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class PayViewController: FatherViewController, TokenInputPreviewDelegate {

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
        print("dddd")
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
}
