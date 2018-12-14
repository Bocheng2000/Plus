//
//  DAppUtils.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/11.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class DAppUtils: NSObject {
    
    private var viewController: UIViewController!
    convenience init(_ _viewController: UIViewController) {
        self.init()
        viewController = _viewController
    }
    
    /// 获取链的信息
    ///
    /// - Parameter success: block
    open func getChainInfo(success: @escaping (String?, Dictionary<String, Any>?) -> Void) {
        ClientManager.shared.getInfo {(err, info) in
            if err != nil {
                success(err!.localizedDescription, nil)
            } else {
                do {
                    let encode = JSONEncoder()
                    var data = try encode.encode(info)
                    let jsonString = String.init(data: data, encoding: .utf8)!.convertJsonKeyName(.underscore)
                    data = jsonString.data(using: .utf8)!
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String, Any>
                    success(nil, json)
                } catch let ex {
                    success(ex.localizedDescription, nil)
                }
            }
        }
    }

    /// 获取当前登录的账户的信息
    ///
    /// - Parameter success: block
    open func getAccount(success: @escaping (String?, Dictionary<String, Any>?) -> Void) {
        let current = WalletManager.shared.getCurrent()
        if current == nil {
            success("no active account", nil)
            return
        }
        ClientManager.shared.getAccount(account: current!.account) { (err, account) in
            if err != nil {
                success(err!.localizedDescription, nil)
                return
            }
            do {
                let encode = JSONEncoder()
                var data = try encode.encode(account)
                let jsonString = String.init(data: data, encoding: .utf8)!.convertJsonKeyName(.underscore)
                data = jsonString.data(using: .utf8)!
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String, Any>
                success(nil, json)
            } catch let ex {
                success(ex.localizedDescription, nil)
            }
        }
    }

    
    /// 获取当前用户的资产
    ///
    /// - Parameter options: 查询参数 (nil/Array<String>/String)
    /// - Returns: assets
    open func getCurrencyBalance(options: Any?) -> [Any?] {
        let current = WalletManager.shared.getCurrent()
        if current == nil {
            return ["no active account", nil]
        } else {
            let assets = CacheHelper.shared.getAssetsByAccount(current!.account, hide: false)
            if options == nil {
                var resp: [String: Dictionary<String, String>] = [:]
                assets.forEach { (model) in
                    let extendSymbol = HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)
                    resp[extendSymbol] = [
                        "quantity": model.quantity,
                        "contract": model.contract
                    ]
                }
                return [nil, resp]
            } else if options is String {
                var resp: [String: Dictionary<String, Any>] = [:]
                for model in assets {
                    let extendSymbol = HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)
                    if extendSymbol == options as! String {
                        resp[extendSymbol] = [
                            "quantity": model.quantity,
                            "contract": model.contract
                        ]
                        break
                    }
                }
                return [nil, resp]
            } else if options is Array<String> {
                let opts = options as! Array<String>
                var asset: [String: AccountAssetModel] = [:]
                assets.forEach { (model) in
                    let extendSymbol = HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)
                    asset[extendSymbol] = model
                }
                var resp: [String: Dictionary<String, Any>] = [:]
                opts.forEach { (opt) in
                    if asset[opt] != nil {
                        resp[opt] = [
                            "quantity": asset[opt]!.quantity,
                            "contract": asset[opt]!.contract
                        ]
                    }
                }
                return [nil, resp]
            } else {
                return ["invalid params", nil]
            }
        }
    }
    
    /// 获取锁仓通证
    ///
    /// - Parameters:
    ///   - options: 查询参数 (nil/Array<String>/String)
    ///   - success: block
    open func getLockBalance(options: Any?, success: @escaping (String?, Dictionary<String, Dictionary<String, String>>?) -> Void) {
        if options == nil {
            success(nil, [:])
            return
        }
        let current = WalletManager.shared.getCurrent()
        if current == nil {
            success("no active account", nil)
            return
        }
        let homeHttp = HomeHttp()
        homeHttp.getLockTokenList(current!.account, lowerBound: 0, list: []) { (err, assets) in
            if err != nil {
                success(err!.localizedDescription, nil)
                return
            }
            var asset: [String: AssetsModel] = homeHttp.processToken(assets)
            if options is String {
                let opt = options as! String
                if asset[opt] != nil {
                    success(nil, [opt: [
                        "quantity": asset[opt]!.balance.quantity,
                        "contract": asset[opt]!.balance.contract
                        ]])
                } else {
                    success(nil, [:])
                }
                return
            }
            if options is Array<String> {
                let opts = options as! Array<String>
                var resp: [String: Dictionary<String, String>] = [:]
                opts.forEach({ (opt) in
                    if asset[opt] != nil {
                        resp[opt] = [
                            "quantity": asset[opt]!.balance.quantity,
                            "contract": asset[opt]!.balance.contract
                        ]
                    }
                })
                success(nil, resp)
                return
            }
            success(nil, [:])
        }
    }
    
    
    /// 转账付款
    ///
    /// - Parameters:
    ///   - options: 参数
    ///   - success: block
    open func payRequest(options: Any?, success: @escaping (String?, Dictionary<String, Any?>?) -> Void) {
        if !(options is Dictionary<String, String>) {
            success("invalid params", nil)
            return
        }
        let current = WalletManager.shared.getCurrent()
        if current == nil {
            success("invalid params", nil)
            return
        }
        let params = options as! Dictionary<String, String>
        if !checkPayParams(params: params) {
            success("no active account", nil)
            return
        }
        let amountSplit = params["amount"]!.split(separator: "@")
        let amount = String(amountSplit[0])
        let contract = String(amountSplit[1])
        let transType = AuthorizeItemModel(LanguageHelper.localizedString(key: "Behavior"), _detail: LanguageHelper.localizedString(key: "Transfer"))
        let fromItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferFrom"), _detail: current!.account)
        let toItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferTo"), _detail: params["to"]!)
        let count = AuthorizeItemModel(LanguageHelper.localizedString(key: "Quantity"), _detail: amount)
        let memoVal = AuthorizeItemModel(LanguageHelper.localizedString(key: "Memo"), _detail: params["memo"] ?? "")
        let extranferModel = ExTransferModel(amount, _from: current!.account, _to: params["to"]!, _memo: params["memo"] ?? "", _contract: contract)
        let authModel = AuthorizeModel(LanguageHelper.localizedString(key: "transactionInfo"), _items: [transType, fromItem, toItem, count, memoVal], _type: .transfer, _params: extranferModel)
        let auth = AuthorizeViewController(authModel)
        auth.cancelBlock = {
            success("canceled", nil)
        }
        auth.transactionRespBlock = {
            (resp: TransactionResult) in
            do {
                let encode = JSONEncoder()
                var data = try encode.encode(resp)
                let jsonString = String.init(data: data, encoding: .utf8)!.convertJsonKeyName(.underscore)
                data = jsonString.data(using: .utf8)!
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String, Any>
                success(nil, json)
            } catch let ex {
                success(ex.localizedDescription, nil)
            }
        }
        auth.show(source: viewController)
    }

    /// 检测支付参数
    ///
    /// - Parameter params: 参数
    /// - Returns: 是否符合入参规则
    private func checkPayParams(params: Dictionary<String, String>) -> Bool {
        let to = params["to"]
        if to == nil || to!.trim().count == 0  {
            return false
        }
        let amount = params["amount"]
        if amount == nil {
            return false
        }
        let amountSplit = amount?.split(separator: " ")
        if amountSplit?.count != 2 {
            return false
        }
        if String(amountSplit![1]).split(separator: "@").count != 2 {
            return false
        }
        if params["memo"] == nil {
            return false
        }
        return true
    }

    /// ironman -> getIdentity
    ///
    /// - Returns: identity
    open func getIdentity() -> [Any?] {
        let current = WalletManager.shared.getCurrent()
        if current == nil {
            return ["no active account"]
        }
        let accountMd5 = current!.account.md5String()
        let end = accountMd5.index(accountMd5.startIndex, offsetBy: 7)
        let identity: [String: Any] = [
            "hash": current!.account.md5String(),
            "publicKey": current!.pubKey,
            "name": String(accountMd5[..<end]),
            "kyc": false,
            "accounts": [
                [
                    "blockchain": "fibos",
                    "name": current!.account,
                    "authority": "active",
                    "publicKey": current!.pubKey
                ]
            ]
        ]
        return [nil, identity]
    }

    /// signProvider
    ///
    /// - Parameters:
    ///   - transaction: 交易信息
    ///   - success: success block
    open func signProvider(transaction: Dictionary<String, Any>, success: @escaping (String?, String?) -> Void) {
        let actions = transaction["actions"] as? NSArray
        if actions == nil || actions!.count < 1 {
            success("invalid params", nil)
            return
        }
        do {
            let action = actions!.firstObject as! Dictionary<String, Any>
            let actionName = action["name"] as! String
            let data = action["data"] as! String
            let authorization = action["authorization"] as? NSArray
            if authorization == nil || authorization!.count < 1 {
                success("invalid params", nil)
                return
            }
            let account = authorization!.firstObject as! Dictionary<String, String>
            let payAccount = account["actor"]
            let current = WalletManager.shared.getCurrent()!
            if current.account != payAccount {
                success("account dismatch", nil)
                return
            }
            ClientManager.shared.abiBinToJson(action: actionName, data: data) { (err, resp) in
                let behavior = AuthorizeItemModel(LanguageHelper.localizedString(key: "Behavior"), _detail: actionName)
                let fromItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferFrom"), _detail: current.account)
                var items: [AuthorizeItemModel] = [behavior, fromItem]
                if err != nil {
                    let data = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransactionData"), _detail: data)
                    items.append(data)
                } else {
                    let toItem = AuthorizeItemModel(LanguageHelper.localizedString(key: "TransferTo"), _detail: resp!.args!["to"]?.value as! String)
                    let quantity = AuthorizeItemModel(LanguageHelper.localizedString(key: "Quantity"), _detail: resp!.args!["quantity"]?.value as! String)
                    let memo = AuthorizeItemModel(LanguageHelper.localizedString(key: "Memo"), _detail: resp!.args!["memo"]?.value as! String)
                    items.append(contentsOf: [toItem, quantity, memo])
                }
                let authModel = AuthorizeModel(LanguageHelper.localizedString(key: "transactionInfo"), _items: items, _type: .exportPk, _params: PkStringModel())
                let auth = AuthorizeViewController(authModel)
                auth.exportPkStringBlock = {
                    (pkString: String) in
                    success(nil, pkString)
                }
                auth.cancelBlock = { success("user canceled", nil) }
                auth.show(source: self.viewController)
            }
        } catch let ex {
            success(ex.localizedDescription, nil)
        }
    }
}
