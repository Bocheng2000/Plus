//
//  CpuViewController.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/15.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CpuViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    private var frame: CGRect!
    
    
    private var preview: NetCpuPreview!
    private var undelegatePreview: NetCpuUndelegateView!
    private var operate: NetCpuOperateView!
    private var foAsset: AccountAssetModel!
    
    convenience init(_ frame: CGRect) {
        self.init()
        self.frame = frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeUI()
        let current = WalletManager.shared.getCurrent()!
        foAsset = CacheHelper.shared.getOneAsset(current.account, symbol: "FO", contract: "eosio")!
        let accountInfo = CacheHelper.shared.getAccountInfo(current.account)
        if accountInfo != nil {
            setInfoInView(info: accountInfo!)
        }
        getAccountInfo()
    }
    
    private func makeUI() {
        view.frame = frame
        view.backgroundColor = BACKGROUND_COLOR
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        preview = NetCpuPreview(frame: CGRect(x: 15, y: 15, width: kSize.width - 30, height: 138.5))
        preview.titleLabel.text = LanguageHelper.localizedString(key: "Cpu")
        preview.delegateLabel.text = LanguageHelper.localizedString(key: "Delegate")
        scrollView.addSubview(preview)
        undelegatePreview = NetCpuUndelegateView(frame: CGRect(x: preview.x, y: preview.bottom + 15, width: preview.width, height: 80))
        scrollView.addSubview(undelegatePreview)
        operate = NetCpuOperateView(frame: CGRect(x: preview.x, y: undelegatePreview.bottom + 15, width: undelegatePreview.width, height: 210))
        scrollView.addSubview(operate)
    }

    private func setInfoInView(info: Account) {
        let availableString = LanguageHelper.localizedString(key: "Available")
        let availNumber = Double(info.cpuLimit?.available ?? 0) / 100.0
        let available = String(format: "%.2f", availNumber)
        let maxNumber = Double(info.cpuLimit?.max ?? 0) / 100.0
        let max = String(format: "%.2f", maxNumber)
        preview.previewLabel.text = "\(availableString): \(available) ms / \(max) ms"
        preview.selfDelegateLabel.text = "\(LanguageHelper.localizedString(key: "Self")): \(info.selfDelegatedBandwidth?.cpuWeight ?? "")"
        preview.delegateSumLabel.text = info.totalResources?.cpuWeight ?? "0.0000 FO"
        preview.progress = CGFloat(availNumber / maxNumber)
        let total = HomeUtils.getQuantity(info.totalResources?.cpuWeight ?? "0")
        let selfCpu = HomeUtils.getQuantity(info.selfDelegatedBandwidth?.cpuWeight ?? "0")
        preview.otherDelegateLabel.text = "\(LanguageHelper.localizedString(key: "Other")): \((total.toDecimal() - selfCpu.toDecimal()).toFixed(4)) FO"
        
        undelegatePreview.titleLabel.text = LanguageHelper.localizedString(key: "InUndelegate")
        undelegatePreview.detailLabel.text = "\(LanguageHelper.localizedString(key: "Cpu")) \(info.refundRequest?.cpuAmount ?? "0.0000 F0")"
        
        operate.balanceLabel.text = "\(LanguageHelper.localizedString(key: "AvailableBalance")): \(foAsset.quantity!)"
        operate.titleLabel.text = LanguageHelper.localizedString(key: "CpuDelegate")
        operate.textField.placeholder = LanguageHelper.localizedString(key: "InputFoQuantity")
    }
    
    private func getAccountInfo() {
        let current = WalletManager.shared.getCurrent()!
        ClientManager.shared.getAccount(account: current.account) { [weak self] (err, account) in
            if account != nil {
                CacheHelper.shared.saveAccountInfo(account!)
                self?.setInfoInView(info: account!)
            }
        }
    }
    
}
