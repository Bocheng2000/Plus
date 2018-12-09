//
//  ReceiveViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/23.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ReceiveViewController: FatherViewController, UITextFieldDelegate, FSActionSheetDelegate {

    open var model: BaseTokenModel!
    private var assetModel: AccountAssetModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var amountTextField: BaseTextField!
    
    @IBOutlet weak var tokenImageView: TokenImage!
    
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBOutlet weak var copyBtn: UIButton!
    
    
    private var y: CGFloat = 0
    
    lazy var precision: Int = {
        let quantity = HomeUtils.getQuantity(assetModel.quantity)
        let precision = HomeUtils.getTokenPrecision(quantity)
        return precision
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadLocalData()
        makeUI()
        setQrCode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(note:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
            accountLabel.text = current?.account
        }
    }
    
    private func makeUI() {
        navBar?.setBorderLine(position: .bottom, number: 0.5, color: BORDER_COLOR)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        maskView.layer.borderWidth = 1
        maskView.layer.borderColor = BORDER_COLOR.cgColor
        maskView.layer.cornerRadius = 3
        maskView.layer.masksToBounds = true
        
        label.text = LanguageHelper.localizedString(key: "ReceiveQuantity")
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(setQrCode), for: .editingChanged)
        amountTextField.placeholder = LanguageHelper.localizedString(key: "InputReceiveQuantity")
        tokenImageView.model = TokenImageModel(model.symbol, _contract: model.contract, _isSmart: false, _wh: 24)
        copyBtn.setTitle(LanguageHelper.localizedString(key: "CopyAccount"), for: .normal)
        copyBtn.layer.borderColor = BORDER_COLOR.cgColor
        copyBtn.layer.borderWidth = 1
        copyBtn.layer.cornerRadius = 3
        copyBtn.layer.masksToBounds = true
    }
    
    override func rightBtnDidClick() {
        let saveQR = LanguageHelper.localizedString(key: "SaveQRCode")
        FSActionSheet(title: nil, delegate: self, cancelButtonTitle: LanguageHelper.localizedString(key: "Cancel"), highlightedButtonTitle: nil, otherButtonTitles: [saveQR]).show()
    }
    
    // MARK: ======== FSActionSheet Delegate =======
    func fsActionSheet(_ actionSheet: FSActionSheet!, selectedIndex: Int) {
        if selectedIndex == 0 {
            let helper = PermissionHelper()
            helper.checkLibraryIsAllow { [weak self] (isAllow) in
                if isAllow {
                    self?.saveQRCode()
                } else {
                    let title = LanguageHelper.localizedString(key: "UnableSaveQRCode")
                    let msg = LanguageHelper.localizedString(key: "OpenAlbumPermission")
                    self?.presentAlert(title: title, msg: msg, helper: helper)
                }
            }
        }
    }
    
    // MARK: ===== 保存二维码 ========
    private func saveQRCode() {
        let size = maskView.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        maskView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image!)
        }, completionHandler: { (ok, error) in
            DispatchQueue.main.async(execute: {
                if ok {
                    let txtStr = LanguageHelper.localizedString(key: "SaveQRSuccess")
                    ZSProgressHUD.showSuccessfulAnimatedText(txtStr)
                } else {
                    let txtStr = LanguageHelper.localizedString(key: "SaveQRFail")
                    ZSProgressHUD.showErrorAnimatedText(txtStr)
                }
            })
        })
    }
    
    private func presentAlert(title: String, msg: String, helper: PermissionHelper) {
        let style = JCAlertStyle.share()!
        style.title.insets = UIEdgeInsetsMake(15, 10, 0, 10)
        style.buttonNormal.textColor = BUTTON_COLOR
        let alert = JCAlertController.alert(withTitle: title, message: msg)
        alert?.addButton(withTitle: LanguageHelper.localizedString(key: "Cancel"), type: JCButtonType(rawValue: 0), clicked: nil)
        alert?.addButton(withTitle: LanguageHelper.localizedString(key: "Go"), type: JCButtonType(rawValue: 0), clicked: {
            helper.toAppSetting()
        })
        present(alert!, animated: true, completion: nil)
    }
    
    // MARK: ======== 复制按钮点击事件 ============
    @IBAction func copyBtnDidClick(_ sender: UIButton) {
        UIPasteboard.general.string = accountLabel.text ?? ""
        ZSProgressHUD.showDpromptText(LanguageHelper.localizedString(key: "CopySuccess"))
    }
    
    // MARK: ======== 生成二维码 ===============
    @objc private func setQrCode() {
        let current = WalletManager.shared.getCurrent()!
        let amount: String = (amountTextField.text ?? "").toDecimal().toFixed(precision)
        let payModel = SimpleWalletPayModel()
        payModel.protocol = "SimpleWallet"
        payModel.version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        payModel.action = "transfer"
        payModel.expired = Date.now() + 300000
        payModel.to = current.account
        payModel.amount = amount
        payModel.contract = model.contract
        payModel.symbol = model.symbol
        payModel.precision = precision
        DispatchQueue.global().async {
            let image = HomeUtils.generateQRCode(payModel.toJSONString()!, size: CGSize(width: 160, height: 160), color: UIColor.black)
            DispatchQueue.main.async(execute: {
                [weak self] in
                self?.qrImageView.image = image
            })
        }
    }
    
    //MARK: ========== UITextField Delegate ==================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let value = (textField.text ?? "") + string
        let split = value.split(separator: ".")
        if split.count == 0 {
            return true
        }
        if split.count == 1 {
            return true
        }
        if split.count == 2 {
            return String(split[1]).count <= precision
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let rect = textField.convert(textField.bounds, to: view)
        y = rect.origin.y + rect.size.height
        return true
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
    
}
