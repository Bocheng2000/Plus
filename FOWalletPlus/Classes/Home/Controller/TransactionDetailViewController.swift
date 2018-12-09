//
//  TransactionDetailViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/30.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class TransactionDetailViewController: FatherViewController, FSActionSheetDelegate {

    open var model: TransactionDetailModel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var line1: UIView!
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBOutlet weak var tokenTextLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var fromButton: CopyButton!
    
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var toButton: CopyButton!
    
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var memoTextLabel: UILabel!
    
    @IBOutlet weak var line2: UIView!
    
    @IBOutlet weak var trxidLabel: UILabel!
    
    @IBOutlet weak var trxidTextLabel: UIButton!
    
    @IBOutlet weak var blockLabel: UILabel!
    
    @IBOutlet weak var blockHeightLabel: UILabel!
    
    @IBOutlet weak var createLabel: UILabel!
    
    @IBOutlet weak var createAtLabel: UILabel!
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    @IBOutlet weak var linkButton: UIButton!
    
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
        scrollView.backgroundColor = UIColor.white
        scrollView.alwaysBounceVertical = true
        quantityLabel.frame = CGRect(x: 20, y: 25, width: kSize.width - 40, height: 34)
        quantityLabel.textAlignment = .center
        quantityLabel.text = (model.isReceive ? "+" : "-") + model.quantity
        descLabel.frame = CGRect(x: quantityLabel.x, y: quantityLabel.bottom + 8, width: quantityLabel.width, height: 18)
        descLabel.textAlignment = .center
        descLabel.text = model.transactionDesc
        line1.frame = CGRect(x: descLabel.x, y: descLabel.bottom + 25, width: descLabel.width, height: 1)
        tokenLabel.frame = CGRect(x: line1.x, y: line1.bottom + 20, width: line1.width, height: descLabel.height)
        tokenLabel.text = LanguageHelper.localizedString(key: "SymbolDesc")
        tokenTextLabel.frame = CGRect(x: tokenLabel.x, y: tokenLabel.bottom + 2, width: tokenLabel.width, height: 18)
        tokenTextLabel.text = HomeUtils.autoExtendSymbol(model.symbol, contract: model.contract)
        fromLabel.frame = CGRect(x: tokenTextLabel.x, y: tokenTextLabel.bottom + 10, width: tokenTextLabel.width, height: descLabel.height)
        fromLabel.text = LanguageHelper.localizedString(key: "SenderAccount")
        fromButton.frame = CGRect(x: fromLabel.x, y: fromLabel.bottom + 2, width: fromLabel.width, height: tokenTextLabel.height)
        fromButton.setTitle(model.fromAccount, for: .normal)
        toLabel.frame = CGRect(x: fromLabel.x, y: fromButton.bottom + 10, width: fromButton.width, height: fromLabel.height)
        toLabel.text = LanguageHelper.localizedString(key: "ToAccount")
        toButton.frame = CGRect(x: toLabel.x, y: toLabel.bottom + 2, width: toLabel.width, height: fromButton.height)
        toButton.setTitle(model.toAccount, for: .normal)
        memoLabel.frame = CGRect(x: toLabel.x, y: toButton.bottom + 15, width: toLabel.width, height: toLabel.height)
        memoLabel.text = LanguageHelper.localizedString(key: "Memo")
        let size = model.memo.getTextSize(font: memoTextLabel.font, lineHeight: 0, maxSize: CGSize(width: toLabel.width, height: CGFloat(MAXFLOAT)))
        memoTextLabel.frame = CGRect(x: memoLabel.x, y: memoLabel.bottom + 2, width: memoLabel.width, height: size.height)
        memoTextLabel.text = model.memo
        line2.frame = CGRect(x: memoLabel.x, y: memoTextLabel.bottom + 20, width: memoLabel.width, height: 1)
        trxidLabel.frame = CGRect(x: line2.x, y: line2.bottom + 20, width: line2.width - 120, height: toLabel.height)
        trxidLabel.text = LanguageHelper.localizedString(key: "TransactionID")
        trxidTextLabel.frame = CGRect(x: trxidLabel.x, y: trxidLabel.bottom + 2, width: trxidLabel.width, height: fromButton.height)
        trxidTextLabel.titleLabel?.lineBreakMode = .byTruncatingMiddle
        trxidTextLabel.setTitle(model.trx_id, for: .normal)
        blockLabel.frame = CGRect(x: trxidTextLabel.x, y: trxidTextLabel.bottom + 10, width: trxidLabel.width, height: trxidLabel.height)
        blockLabel.text = LanguageHelper.localizedString(key: "BlockHeight")
        blockHeightLabel.frame = CGRect(x: blockLabel.x, y: blockLabel.bottom + 2, width: blockLabel.width, height: blockLabel.height)
        blockHeightLabel.text = String(model.block_num)
        createLabel.frame = CGRect(x: blockHeightLabel.x, y: blockHeightLabel.bottom + 10, width: blockHeightLabel.width, height: blockHeightLabel.height)
        createLabel.text = LanguageHelper.localizedString(key: "TransactionTime")
        createAtLabel.frame = CGRect(x: createLabel.x, y: createLabel.bottom + 10, width: createLabel.width, height: createLabel.height)
        createAtLabel.text = model.created.utcTime2Local(format: "yyyy/MM/dd HH:mm")
        qrImageView.frame = CGRect(x: kSize.width - 20 - 100, y: line2.bottom + 15, width: 100, height: 100)
        qrImageView.image = HomeUtils.generateQRCode("\(exploreUri)\(String(describing: model.trx_id))", size: CGSize(width: 100, height: 100), color: nil)
        linkButton.frame = CGRect(x: line2.x, y: createAtLabel.bottom + 40, width: line2.width, height: 30)
        linkButton.setTitle(LanguageHelper.localizedString(key: "ViewDetail"), for: .normal)
        scrollView.contentSize = CGSize(width: kSize.width, height: linkButton.bottom + 20)
    }
    
    @IBAction func linkBtnDidClick(_ sender: UIButton) {
        let explore = ExploreViewController(left: "img|blackBack", title: LanguageHelper.localizedString(key: "TransactionQuery"), right: "img|more")
        explore.uri = "\(exploreUri)\(model.trx_id!)"
        navigationController?.pushViewController(explore, animated: true)
    }
    
    override func rightBtnDidClick() {
        let save = LanguageHelper.localizedString(key: "SaveInfo")
        FSActionSheet(title: nil, delegate: self, cancelButtonTitle: LanguageHelper.localizedString(key: "Cancel"), highlightedButtonTitle: nil, otherButtonTitles: [save]).show()
    }
    
    // MARK: ======= FSActionSheet Delegate ===========
    func fsActionSheet(_ actionSheet: FSActionSheet!, selectedIndex: Int) {
        if selectedIndex == 0 {
            let helper = PermissionHelper()
            helper.checkLibraryIsAllow { [weak self] (isAllow) in
                if isAllow {
                    self?.saveTransactionInfo()
                } else {
                    let title = LanguageHelper.localizedString(key: "UnableSaveInfo")
                    let msg = LanguageHelper.localizedString(key: "OpenAlbumPermission")
                    self?.presentAlert(title: title, msg: msg, helper: helper)
                }
            }
        }
    }
    
    // MARK: ======== 生成交易信息的图片 并保存 ===========
    private func saveTransactionInfo() {
        var image: UIImage!
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, true, scale)
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        let savedContentSize = scrollView.contentSize
        scrollView.contentOffset = .zero
        scrollView.frame = CGRect(x: 0, y: 0, width: savedContentSize.width, height: savedContentSize.height)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
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
}
