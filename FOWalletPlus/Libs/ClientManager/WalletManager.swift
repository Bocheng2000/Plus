//
//  WalletManager.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class WalletManager: NSObject {
    open static var shared: WalletManager = WalletManager()
    private var current: AccountModel?
    
    private override init() {
        super.init()
    }
    
    /// 获取当前账户
    ///
    /// - Returns: model
    open func loadCurrent() -> AccountModel? {
        let account = CacheHelper.shared.findCurrentAccount()
        if account != nil {
            current = account
        }
        return account
    }
    
    /// 构建钱包
    ///
    /// - Parameters:
    ///   - accounts: 账户名
    ///   - pubKey: 公钥
    ///   - priKey: 私钥
    ///   - password: 密码
    ///   - prompt: 提示
    open func create(_ accounts: [String], pubKey: String, priKey: String, password: String, prompt: String) {
        var wallets: [Wallet] = []
        accounts.forEach { (account) in
            let wallet = Wallet(account, _prompt: prompt, _pubKey: pubKey, _password: password, _priKey: priKey, isEncode: false)
            wallets.append(wallet)
        }
        CacheHelper.shared.saveWallets(wallets)
    }
    
    /// 设置当前的账户
    ///
    /// - Parameters:
    ///   - pubKey: 公钥
    ///   - account: 账户名
    open func setCurrent(pubKey: String, account: String) {
        if current?.account != account {
            CacheHelper.shared.setCurrent(account)
            current = AccountModel(account, _pubKey: pubKey)
        }
    }
    
    /// 获取当前账户
    ///
    /// - Returns: 当前账户
    open func getCurrent() -> AccountModel? {
        return current
    }
    
    /// 添加钱包
    ///
    /// - Parameter wallet: 钱包对象
    open func appendWallet(wallets: [Wallet]) {
        CacheHelper.shared.saveWallets(wallets)
    }
    
    /// 移除钱包
    ///
    /// - Parameter wallets: 钱包对象
    open func removeWallet(wallets: [Wallet]) {
        CacheHelper.shared.removeWallets(wallets)
    }
    
    /// 获取指定的钱包
    ///
    /// - Parameters:
    ///   - pubKey: 公钥
    ///   - account: 账户名
    /// - Returns: 钱包
    open func getWallet(pubKey: String, account: String) -> Wallet? {
        return CacheHelper.shared.findWalletBy(pubKey: pubKey, account: account)
    }
    
    /// 获取钱包列表
    ///
    /// - Returns: list
    open func walletList() -> [AccountListModel] {
        return CacheHelper.shared.findAllWallet()
    }
}
