//
//  CacheHelper.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CacheHelper: NSObject {
    open static var shared: CacheHelper = CacheHelper()
    private(set) var db: FMDatabase!
    
    private override init() {
        super.init()
        db = FMDatabase(path: cacheDB)
        print(cacheDB)
        if db.open() {
            createTables()
        }
    }
    
    private func createTables() {
        do {
            let path = Bundle.main.path(forResource: "tables", ofType: "sql") ?? ""
            let sqls = try String(contentsOfFile: path)
            let sqlArray = sqls.split(separator: ";")
            for i in 0...(sqlArray.count - 2) {
                try db.executeUpdate(String(sqlArray[i]), values: nil)
            }
        } catch {
            
        }
    }

    
    /// 保存钱包的数据
    ///
    /// - Parameter wallets: 钱包对象
    /// - Returns: 是否保存成功
    @discardableResult
    open func saveWallets(_ wallets: [Wallet]) -> Bool {
        db.beginTransaction()
        do {
            let sql = "REPLACE INTO TWallets (account, prompt, pubKey, password, priKey) VALUES (?,?,?,?,?)"
            for i in 0...(wallets.count - 1) {
                let wallet = wallets[i]
                try db.executeUpdate(sql, values: [
                        wallet.account,
                        wallet.prompt,
                        wallet.pubKey,
                        wallet.password,
                        wallet.priKeyEncode
                    ])
            }
            db.commit()
            return true
        } catch {
            db.rollback()
            return false
        }
        
    }

    
    /// 设置当前的账户
    ///
    /// - Parameter account: 当前账户的名称
    /// - Returns: 是否保存成功
    @discardableResult
    open func setCurrent(_ account: String) -> Bool {
        db.beginTransaction()
        do {
            let sql = "UPDATE TWallets SET current = ? WHERE account = ?"
            try db.executeUpdate(sql, values: [1, account])
            let sql2 = "UPDATE TWallets SET current = ? WHERE account <> ?"
            try db.executeUpdate(sql2, values: [0, account])
            db.commit()
            return true
        } catch {
            db.rollback()
            return false
        }
    }

    /// 移除钱包
    ///
    /// - Parameter wallets: 钱包数组
    /// - Returns: 是否删除成功
    @discardableResult
    open func removeWallets(_ wallets: [Wallet]) -> Bool {
        let accounts: [String] = wallets.map { (wallet) -> String in
            return wallet.account
        }
        do {
            let sql = "DELETE FROM TWallets WHERE account IN (\"\(accounts.joined(separator: ","))\")"
            try db.executeUpdate(sql, values: nil)
            return true
        } catch {
            return false
        }
    }

    
    /// 获取指定的钱包
    ///
    /// - Parameters:
    ///   - pubKey: 公钥
    ///   - account: 账户名
    /// - Returns: 钱包对象
    open func findWalletBy(pubKey: String, account: String) -> Wallet? {
        do {
            let sql = "SELECT * FROM TWallets WHERE account = ? AND pubKey = ?"
            let result = try db.executeQuery(sql, values: [account, pubKey])
            var resp: Wallet?
            while result.next() {
                resp = Wallet()
                resp?.account = result.string(forColumn: "account")
                resp?.prompt = result.string(forColumn: "prompt")
                resp?.pubKey = result.string(forColumn: "pubKey")
                resp?.password = result.string(forColumn: "password")
                resp?.priKeyEncode = result.string(forColumn: "priKey")
            }
            return resp
        } catch {
            return Optional.none
        }
    }
    
    
    /// 获取当前登录的账户
    ///
    /// - Returns: 当前登录的账户
    open func findCurrentAccount() -> AccountModel? {
        do {
            let sql = "SELECT * FROM TWallets WHERE current = ? LIMIT 1"
            let result = try db.executeQuery(sql, values: [1])
            var resp: AccountModel?
            while result.next() {
                resp = AccountModel()
                resp?.account = result.string(forColumn: "account")
                resp?.pubKey = result.string(forColumn: "pubKey")
                resp?.endPoint = result.string(forColumn: "endPoint")
                resp?.backUp = result.int(forColumn: "backUp") == 1
            }
            return resp
        } catch {
            return Optional.none
        }
    }
    
    /// 保存用户的通证资产
    ///
    /// - Parameter assets: 通证列表
    open func saveAccountAssets(_ assets: [AccountAssetModel]) {
        if assets.count == 0 {
            return
        }
        db.beginTransaction()
        do {
            let sql = "REPLACE INTO TAssets ('primary', belong, contract, hide, quantity, lockToken, contractWallet, isSmart, symbol, updateAt) VALUES (?,?,?,?,?,?,?,?,?,?)"
            for i in 0...(assets.count - 1) {
                let model = assets[i]
                try db.executeUpdate(sql, values: [
                        model.primary,
                        model.belong,
                        model.contract,
                        model.hide ? 1 : 0,
                        model.quantity,
                        model.lockToken,
                        model.contractWallet,
                        model.isSmart ? 1 : 0,
                        model.symbol,
                        Date().timeIntervalSince1970
                    ])
            }
            db.commit()
        } catch {
            db.rollback()
        }
    }

    /// 设置资产的隐藏
    ///
    /// - Parameters:
    ///   - model: model
    ///   - isHide: 是否隐藏
    open func setAssetStatus(_ model: AccountAssetModel, isHide: Bool) {
        let sql = "UPDATE TAssets SET hide = ?, updateAt = ? WHERE belong = ? AND symbol = ? AND contract = ?"
        do {
            try db.executeUpdate(sql, values: [
                isHide ? 1 : 0,
                Date().timeIntervalSince1970,
                model.belong,
                model.symbol,
                model.contract
                ])
        } catch {
            
        }
    }
    
    /// 获取指定用户的通证
    ///
    /// - Parameters:
    ///   - account: 用户名
    ///   - hide: 是否是隐藏状态的
    /// - Returns: 资产列表
    open func getAssetsByAccount(_ account: String, hide: Bool) -> [AccountAssetModel] {
        let sql = "SELECT * FROM TAssets WHERE belong = ? AND hide = ? ORDER BY updateAt ASC"
        var resp: [AccountAssetModel] = []
        do {
            let result = try db.executeQuery(sql, values: [account, hide ? 1 : 0])
            while result.next() {
                let primary = result.int(forColumn: "primary")
                let belong = result.string(forColumn: "belong")!
                let contract = result.string(forColumn: "contract")!
                let hide = result.int(forColumn: "hide") == 1
                let quantity = result.string(forColumn: "quantity")!
                let lockToken = result.string(forColumn: "lockToken")!
                let contractWallet = result.string(forColumn: "contractWallet")!
                let isSmart = result.int(forColumn: "isSmart") == 1
                let model = AccountAssetModel(primary, _belong: belong, _contract: contract, _hide: hide, _quantity: quantity, _lockToken: lockToken, _contractWallet: contractWallet, _isSmart: isSmart)
                resp.append(model)
            }
        } catch {
            
        }
        return resp
    }
    
    /// 获取账户的某一个资产
    ///
    /// - Parameters:
    ///   - account: 账户名
    ///   - symbol: 通证
    ///   - contract: 合约
    /// - Returns: model
    open func getOneAsset(_ account: String, symbol: String, contract: String) -> AccountAssetModel? {
        let sql = "SELECT * FROM TAssets WHERE belong = ? AND symbol = ? AND contract = ?"
        do {
            var resp: AccountAssetModel?
            let result = try db.executeQuery(sql, values: [account, symbol, contract])
            while result.next() {
                let primary = result.int(forColumn: "primary")
                let belong = result.string(forColumn: "belong")!
                let contract = result.string(forColumn: "contract")!
                let hide = result.int(forColumn: "hide") == 1
                let quantity = result.string(forColumn: "quantity")!
                let lockToken = result.string(forColumn: "lockToken")!
                let contractWallet = result.string(forColumn: "contractWallet")!
                let isSmart = result.int(forColumn: "isSmart") == 1
                resp = AccountAssetModel(primary, _belong: belong, _contract: contract, _hide: hide, _quantity: quantity, _lockToken: lockToken, _contractWallet: contractWallet, _isSmart: isSmart)
            }
            return resp
        } catch {
            return Optional.none
        }
    }

    /// 保存通证信息
    ///
    /// - Parameter tokens: 通证信息的概要
    open func saveTokens(_ tokens: [TokenSummary]) {
        db.beginTransaction()
        do {
            let sql = "REPLACE INTO TTokens (connector_balance, connector_weight, issuer, max_exchange, max_supply, reserve_connector_balance, reserve_supply, supply, symbol) VALUES (?,?,?,?,?,?,?,?,?)"
            for i in 0...(tokens.count - 1) {
                let model = tokens[i]
                try db.executeUpdate(sql, values: [
                        model.connector_balance,
                        model.connector_weight,
                        model.issuer,
                        model.max_exchange,
                        model.max_supply,
                        model.reserve_connector_balance,
                        model.reserve_supply,
                        model.supply,
                        model.symbol
                    ])
            }
            db.commit()
        } catch {
            db.rollback()
        }
    }

    /// 获取某一个通证的信息
    ///
    /// - Parameters:
    ///   - symbol: 通证
    ///   - contract: 合约
    /// - Returns: model
    open func getOneToken(_ symbol: String, contract: String) -> TokenSummary? {
        let sql = "SELECT * FROM TTokens WHERE symbol = ? AND issuer = ?"
        do {
            var resp: TokenSummary?
            let result = try db.executeQuery(sql, values: [symbol, contract])
            while result.next() {
                resp = TokenSummary()
                resp?.max_supply = result.string(forColumn: "max_supply")
                resp?.supply = result.string(forColumn: "supply")
                resp?.connector_balance = result.string(forColumn: "connector_balance")
                resp?.connector_weight = result.string(forColumn: "connector_weight")
                resp?.issuer = result.string(forColumn: "issuer")
                resp?.max_exchange = result.string(forColumn: "max_exchange")
                resp?.reserve_connector_balance = result.string(forColumn: "reserve_connector_balance")
                resp?.reserve_supply = result.string(forColumn: "reserve_supply")
            }
            return resp
        } catch {
            return Optional.none
        }
    }
}
