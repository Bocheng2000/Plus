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
            }
            return resp
        } catch {
            return Optional.none
        }
    }
}
