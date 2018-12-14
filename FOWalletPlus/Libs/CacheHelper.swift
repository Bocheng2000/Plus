//
//  CacheHelper.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class CacheHelper: NSObject {
    public static var shared: CacheHelper = CacheHelper()
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
        if wallets.count == 0 {
            return true
        }
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

    /// 设置用户是否显示资源
    ///
    /// - Parameter account: 当前账户的名称
    /// - Parameter show: 是否显示
    open func updateAccountWidget(account: String, show: Bool) {
        do {
            let sql = "UPDATE TWallets SET resourceWeidge = ? WHERE account = ?"
            try db.executeUpdate(sql, values: [show ? 1 : 0, account])
        } catch {
            
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

    /// 获取本地所有的钱包
    ///
    /// - Returns: list
    open func findAllWallet() -> [AccountListModel] {
        do {
            let sql = "SELECT t1.account, t1.pubKey, t2.quantity, t2.lockToken, t2.contractWallet FROM TWallets t1 LEFT JOIN TAssets t2 ON t1.account = t2.belong WHERE ((t2.symbol = 'FO' AND t2.contract = 'eosio') OR t2.symbol IS NULL) ORDER BY t1.current DESC"
            let result = try db.executeQuery(sql, values: nil)
            var resp: [AccountListModel] = []
            while result.next() {
                let account = result.string(forColumn: "account")
                let pubKey = result.string(forColumn: "pubKey")
                let quantity = result.string(forColumn: "quantity")
                let lockToken = result.string(forColumn: "lockToken")
                let contractWallet = result.string(forColumn: "contractWallet")
                let r = AccountListModel(account!, _pubKey: pubKey!, _quantity: quantity, _lockToken: lockToken, _contractWallet: contractWallet)
                resp.append(r)
            }
            return resp
        } catch {
            return []
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
                resp?.resourceWidget = result.int(forColumn: "resourceWeidge") == 1
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
        if tokens.count == 0 {
            return
        }
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

    /// 存储账户的信息
    ///
    /// - Parameters:
    ///   - account: 账户信息
    open func saveAccountInfo(_ account: Account) {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(account)
            let infoString = String.init(data: jsonData, encoding: .utf8)
            let sql = "REPLACE INTO TAccounts (account, info) VALUES (?,?)"
            try db.executeUpdate(sql, values: [account.accountName, infoString ?? ""])
        } catch {
            
        }
    }
    
    /// 获取账户的信息
    ///
    /// - Parameters:
    ///   - account: 账户信息
    open func getAccountInfo(_ account: String) -> Account? {
        do {
            let sql = "SELECT * FROM TAccounts WHERE account = ?"
            let result = try db.executeQuery(sql, values: [account])
            var model: Account?
            let decodere = JSONDecoder()
            while result.next() {
                let info = result.string(forColumn: "info") ?? ""
                let data = info.data(using: .utf8)
                model = try decodere.decode(Account.self, from: data!)
            }
            return model
        } catch {
            return Optional.none
        }
    }
    
    /// 保存DApp
    ///
    /// - Parameter dapps: models
    open func saveDApps(_ dapps: [DAppModel]) {
        if dapps.count == 0 {
            return
        }
        do {
            db.beginTransaction()
            let sql = "REPLACE INTO TDApps (id, name, name_en, description_cn, description_en, url, img, token, tags) VALUES (?,?,?,?,?,?,?,?,?)"
            for model in dapps {
                try db.executeUpdate(sql, values: [
                        model.id,
                        model.name,
                        model.name_en,
                        model.description_cn,
                        model.description_en,
                        model.url,
                        model.img,
                        model.token,
                        model.tags.toJSONString() ?? ""
                    ])
            }
            db.commit()
        } catch {
            db.rollback()
        }
    }

    /// 获取以保存的DApp
    ///
    /// - Returns: DApps
    open func getSavedDApps(pageSize: Int) -> [DAppModel] {
        var sql: String = "SELECT * FROM TDApps ORDER BY id DESC"
        if pageSize > 0 {
            sql += " LIMIT \(pageSize)"
        }
        do {
            let result = try db.executeQuery(sql, values: nil)
            var resp: [DAppModel] = []
            while result.next() {
                let model: DAppModel = DAppModel()
                model.id = result.longLongInt(forColumn: "id")
                model.name = result.string(forColumn: "name")
                model.name_en = result.string(forColumn: "name_en")
                model.description_cn = result.string(forColumn: "description_cn")
                model.description_en = result.string(forColumn: "description_en")
                model.url = result.string(forColumn: "url")
                model.img = result.string(forColumn: "img")
                model.token = result.string(forColumn: "token")
                model.tags = [DAppTagsModel].deserialize(from: result.string(forColumn: "tags")) as? [DAppTagsModel]
                resp.append(model)
            }
            return resp
        } catch {
            return []
        }
    }
    
    /// 置顶DApp
    ///
    /// - Parameters:
    ///   - owner: 所属账户
    ///   - dappid: DApp id
    open func topMyDApp(owner: String, dappid: Int64) {
        do {
            db.beginTransaction()
            let sql = "REPLACE INTO TMyDApp (owner, dappid, weight) VALUES (?,?,?)"
            try db.executeUpdate(sql, values: [owner, dappid, 0])
            let update = "UPDATE TMyDApp SET weight = (SELECT MAX(weight) FROM TMyDApp) + 1 WHERE owner = ? AND dappid = ?"
            try db.executeUpdate(update, values: [owner, dappid])
            db.commit()
        } catch {
            db.rollback()
        }
    }
    
    /// 我的DApp列表
    ///
    /// - Parameters:
    ///   - owner: 所属账户
    ///   - pageSize: 每页个数
    /// - Returns: models
    open func myDappList(owner: String, pageSize: Int) -> [DAppModel] {
        do {
            var sql: String = "SELECT t2.* FROM TMyDApp t1 INNER JOIN TDApps t2 ON t1.dappid = t2.id WHERE t1.owner = ? ORDER BY t1.weight DESC"
            if pageSize > 0 {
                sql += " LIMIT \(pageSize)"
            }
            var resp: [DAppModel] = []
            let result = try db.executeQuery(sql, values: [owner])
            while result.next() {
                let model: DAppModel = DAppModel()
                model.id = result.longLongInt(forColumn: "id")
                model.name = result.string(forColumn: "name")
                model.name_en = result.string(forColumn: "name_en")
                model.description_cn = result.string(forColumn: "description_cn")
                model.description_en = result.string(forColumn: "description_en")
                model.url = result.string(forColumn: "url")
                model.img = result.string(forColumn: "img")
                model.token = result.string(forColumn: "token")
                model.tags = [DAppTagsModel].deserialize(from: result.string(forColumn: "tags")) as? [DAppTagsModel]
                resp.append(model)
            }
            return resp
        } catch {
            return []
        }
    }
}
