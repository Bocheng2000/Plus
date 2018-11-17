//
//  ClientManager.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/13.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ClientManager: NSObject {
    open static var shared: ClientManager = ClientManager()
    
    /// 获取chaninfo
    ///
    /// - Parameter successBlock: success block
    open func getInfo(successBlock: @escaping (Error?, ChainInfo?) -> Void) {
        EOSRPC.sharedInstance.chainInfo { (info, err) in
            successBlock(err, info)
        }
    }
    
    /// 获取账户的概要
    ///
    /// - Parameters:
    ///   - account: 账户名
    ///   - successBlock: block
    open func getAccount(account: String, successBlock: @escaping (Error?, Account?) -> Void) {
        EOSRPC.sharedInstance.getAccount(account: account) { (info, err) in
            successBlock(err, info)
        }
    }
    
    
    /// 账户注册
    ///
    /// - Parameters:
    ///   - account: 账户名
    ///   - publicKey: 公钥
    ///   - success: success block
    open func createAccunt(account: String, publicKey: String, success: @escaping (String?) -> Void) {
        let ts = Date.now()
        let hashVal = "\(account)\(publicKey)\(salt)\(ts)".md5String()
        let dict: [String: Any] = [
            "account": account,
            "pubkey": publicKey,
            "hash": hashVal,
            "t": ts
        ]
        Http.shareHttp().post(urlStr: tunnel, params: dict) { (err, dict) in
            DispatchQueue.main.async(execute: {
                if err != nil {
                    success("error")
                } else {
                    let msg: String = dict!["message"] as! String
                    if msg == "success" {
                        success(Optional.none)
                    } else if msg == "The interval is less than one hour" {
                        success("in an hour")
                    } else {
                        success("error")
                    }
                }
            })
        }
    }

    
    /// 根据公钥获取账户名
    ///
    /// - Parameters:
    ///   - pubKey: 公钥
    ///   - success: success block
    open func getKeyAccount(pubKey: String, success: @escaping (String?, [String]?) -> Void) {
        EOSRPC.sharedInstance.getKeyAccounts(pub: pubKey) { (result, err) in
            if err != nil {
                success(err?.localizedDescription, Optional.none)
            } else {
                success(Optional.none, result?.accountNames)
            }
        }
    }
    
    
    /// 获取账户的可用资产
    ///
    /// - Parameters:
    ///   - account: 账户名
    ///   - lowerBound: 起点
    ///   - success: success block
    open func getAccountInfo(_ account: String, lowerBound: Int32, success: @escaping (Error?, TableRowResponse<AssetsModel>?) -> Void) {
        let params: TableRowRequestParam = TableRowRequestParam(scope: account, code: "eosio.token", table: "accounts", json: true, lowerBound: lowerBound, upperBound: -1, limit: pageSize)
        EOSRPC.sharedInstance.getTableRows(param: params) { (resp: TableRowResponse<AssetsModel>?, err) in
                success(err, resp)
            }
    }
    
    /// 获取我的锁仓通证
    ///
    /// - Parameters:
    ///   - account: 用户名
    ///   - lowerBound: 起点
    ///   - success: success block
    open func getLockTokens(_ account: String, lowerBound: Int32, success: @escaping (Error?, TableRowResponse<AssetsModel>?) -> Void) {
        let params: TableRowRequestParam = TableRowRequestParam(scope: account, code: "eosio.token", table: "lockaccounts", json: true, lowerBound: lowerBound, upperBound: -1, limit: pageSize)
        EOSRPC.sharedInstance.getTableRows(param: params) { (resp: TableRowResponse<AssetsModel>?, err) in
            success(err, resp)
        }
    }
    
    /// 获取用户的合约钱包
    ///
    /// - Parameters:
    ///   - account: 用户名
    ///   - lowerBound: 起点
    ///   - success: success block
    open func getContractAsset(_ account: String, lowerBound: Int32, success: @escaping (Error?, TableRowResponse<AssetsModel>?) -> Void) {
        let params: TableRowRequestParam = TableRowRequestParam(scope: account, code: "eosio.token", table: "ctxaccounts", json: true, lowerBound: lowerBound, upperBound: -1, limit: pageSize)
        EOSRPC.sharedInstance.getTableRows(param: params) { (resp: TableRowResponse<AssetsModel>?, err) in
            success(err, resp)
        }
    }
    
    /// 获取合约下的所有通证
    ///
    /// - Parameters:
    ///   - contract: 合约名
    ///   - success: success block
    open func getTokenByContract(_ contract: String, success: @escaping (Error?, TableRowResponse<TokenSummary>?) -> Void) {
        let params: TableRowRequestParam = TableRowRequestParam(scope: contract, code: "eosio.token", table: "stats", json: true, lowerBound: 0, upperBound: -1, limit: pageSize)
        EOSRPC.sharedInstance.getTableRows(param: params) { (resp: TableRowResponse<TokenSummary>?, err) in
            success(err, resp)
        }
    }
}
