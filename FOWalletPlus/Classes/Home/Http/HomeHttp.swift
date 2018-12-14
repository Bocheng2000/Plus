//
//  HomeHttp.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/16.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class HomeHttp: NSObject {
    
    // MARK: ====== 构造FO和EOS的默认数据 =======
    open func generateDefaultDs() -> [AssetsModel] {
        let fo = AssetsModel(0, _balance: BalanceModel("0.0000 FO", _contract: "eosio"), _lock_timestamp: nil)
        let eos = AssetsModel(1, _balance: BalanceModel("0.0000 EOS", _contract: "eosio"), _lock_timestamp: nil)
        return [fo, eos]
    }
    
    /// 获取用户的通证资产以及通证的信息
    ///
    /// - Parameters:
    ///   - account: 用户名
    ///   - misHideList: 显示的通证的信息
    ///   - success: success block
    open func getAccountAssets(_ account: String, misHideList: [AccountAssetModel], success: @escaping (AssetsRespModel) -> Void) {
        getAvailableAsset(account, lowerBound: 0, list: []) { [weak self] (availableAssets) in
            self?.getLockToken(account, lowerBound: 0, list: [], success: { [weak self] (lockTokens) in
                self?.getContractAsset(account, lowerBound: 0, list: [], success: { [weak self] (contractAssets) in
                    let contracts = self?.getContractInAssets(availableAssets, lockTokens: lockTokens, contractWallet: contractAssets)
                    self?.getTokens(contracts!, tokens: [:], success: { (tokenSummary) in
                        let final = self?.processAssetsResult(availableAssets, lockTokens: lockTokens, contractWallet: contractAssets, account: account, misHideList: misHideList, tokens: tokenSummary)
                        let resp: AssetsRespModel = AssetsRespModel(final!, _tokens: tokenSummary)
                        success(resp)
                    })
                })
            })
        }
    }
    
    /// 处理结果
    ///
    /// - Parameters:
    ///   - availableAssets: 可用资产
    ///   - lockTokens: 锁仓
    ///   - contractWallet: 合约子钱包
    ///   - account: 账户名
    ///   - misHideList: 显示的通证列表
    /// - Returns: 资产列表
    private func processAssetsResult(_ availableAssets: [AssetsModel], lockTokens: [String: AssetsModel], contractWallet: [String: AssetsModel], account: String, misHideList: [AccountAssetModel], tokens: [String: TokenSummary]) -> [AccountAssetModel] {
        if availableAssets.count == 0 {
            return misHideList
        }
        // 将取回来的数据进行格式化
        var exists: [String: Bool] = [:]
        var nextAsset = availableAssets.map { (model) -> AccountAssetModel in
            let hide: Bool = model.balance.contract != "eosio"
            let quantity = HomeUtils.getQuantity(model.balance.quantity)
            let symbol = HomeUtils.getSymbol(model.balance.quantity)
            let precision = HomeUtils.getTokenPrecision(quantity)
            let zero: Decimal = 0
            let zeroToFix = HomeUtils.getFullQuantity(zero.toFixed(precision), symbol: symbol)
            let extendSymbol = HomeUtils.getExtendSymbol(symbol, contract: model.balance.contract)
            exists[extendSymbol] = true
            return AccountAssetModel(model.primary, _belong: account, _contract: model.balance.contract, _hide: hide, _quantity: model.balance.quantity, _lockToken: zeroToFix, _contractWallet: zeroToFix, _isSmart: tokens[extendSymbol]?.isSmart ?? false)
        }
        // 判断 FO/EOS 是否在用户的资产中，如果不存在就插入进去
        let defaultData = generateDefaultDs()
        defaultData.forEach { (model) in
            let symbol = HomeUtils.getSymbol(model.balance.quantity)
            let extendSymbol = HomeUtils.getExtendSymbol(symbol, contract: model.balance.contract)
            if exists[extendSymbol] == nil {
                let symbol = HomeUtils.getSymbol(model.balance.quantity)
                let zero: Decimal = 0
                let zeroToFix = HomeUtils.getFullQuantity(zero.toFixed(4), symbol: symbol)
                let m = AccountAssetModel(model.primary, _belong: account, _contract: model.balance.contract, _hide: false, _quantity: zeroToFix, _lockToken: zeroToFix, _contractWallet: zeroToFix, _isSmart: tokens[extendSymbol]?.isSmart ?? false)
                nextAsset.append(m)
            }
        }
        // 将FO/EOS 放到最顶端，并且FO第一位，EOS第二位
        var eosioTokens: [AccountAssetModel] = []
        var otherTokens: [AccountAssetModel] = []
        nextAsset.forEach { (model) in
            if model.contract == "eosio" {
                if model.symbol == "FO" {
                    eosioTokens.insert(model, at: 0)
                } else {
                    eosioTokens.append(model)
                }
                exists[HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)] = true
            } else {
                otherTokens.append(model)
            }
        }
        var existAtIndex: [String: Int] = [:]
        for (index, value) in nextAsset.enumerated() {
            let extendSymbol = HomeUtils.getExtendSymbol(value.symbol, contract: value.contract)
            existAtIndex[extendSymbol] = index
        }
        eosioTokens.append(contentsOf: otherTokens)
        nextAsset = eosioTokens
        eosioTokens.removeAll()
        otherTokens.removeAll()
        // 遍历用户的锁仓通证
        lockTokens.keys.forEach { (key) in
            let value: AssetsModel = lockTokens[key]!
            if exists[key] == nil {
                let symbol = HomeUtils.getSymbol(value.balance.quantity)
                let quantity = HomeUtils.getQuantity(value.balance.quantity)
                let precision = HomeUtils.getTokenPrecision(quantity)
                let zero: Decimal = Decimal(0)
                let zeroToFix = HomeUtils.getFullQuantity(zero.toFixed(precision), symbol: symbol)
                let m = AccountAssetModel(value.primary, _belong: account, _contract: value.balance.contract, _hide: false, _quantity: zeroToFix, _lockToken: value.balance.quantity, _contractWallet: zeroToFix, _isSmart: tokens[key]?.isSmart ?? false)
                nextAsset.append(m)
            } else {
                nextAsset[existAtIndex[key]!].lockToken = value.balance.quantity
            }
        }
        // 遍历合约子钱包的通证
        contractWallet.keys.forEach { (key) in
            let value: AssetsModel = contractWallet[key]!
            if exists[key] == nil {
                let symbol = HomeUtils.getSymbol(value.balance.quantity)
                let quantity = HomeUtils.getQuantity(value.balance.quantity)
                let precision = HomeUtils.getTokenPrecision(quantity)
                let zero: Decimal = Decimal(0)
                let zeroToFix = HomeUtils.getFullQuantity(zero.toFixed(precision), symbol: symbol)
                let m = AccountAssetModel(value.primary, _belong: account, _contract: value.balance.contract, _hide: false, _quantity: zeroToFix, _lockToken: zeroToFix, _contractWallet: value.balance.quantity, _isSmart: tokens[key]?.isSmart ?? false)
                nextAsset.append(m)
            } else {
                nextAsset[existAtIndex[key]!].contractWallet = value.balance.quantity
            }
        }
        exists.removeAll()
        existAtIndex.removeAll()
        if misHideList.count > 0 {
            misHideList.forEach { (misHide) in
                exists[HomeUtils.getExtendSymbol(misHide.symbol, contract: misHide.contract)] = true
            }
            nextAsset.forEach { (model) in
                if exists[HomeUtils.getExtendSymbol(model.symbol, contract: model.contract)] != nil {
                    model.hide = false
                } else {
                    model.hide = true
                }
                if model.contract == "eosio" {
                    model.hide = false
                }
            }
            exists.removeAll()
        }
        return nextAsset
    }
    
    /// 根据用户可用/锁仓/合约子钱包的数据, 去获取通证的详情
    ///
    /// - Parameters:
    ///   - availableAssets: 可用资产
    ///   - lockTokens: 锁仓
    ///   - contractWallet: 合约自钱包
    /// - Returns: 所有合约
    private func getContractInAssets(_ availableAssets: [AssetsModel], lockTokens: [String: AssetsModel], contractWallet: [String: AssetsModel]) -> [String] {
        var resp: [String: Bool] = [:]
        availableAssets.forEach { (e) in
            resp[e.balance.contract] = true
        }
        lockTokens.keys.forEach { (key) in
            resp[lockTokens[key]!.balance.contract] = true
        }
        contractWallet.keys.forEach { (key) in
            resp[contractWallet[key]!.balance.contract] = true
        }
        if resp["eosio"] == nil {
            resp["eosio"] = true
        }
        return Array(resp.keys)
    }
    
    /// 处理锁仓通证
    ///
    /// - Parameter list: 列表
    /// - Returns: 结果
    open func processToken(_ list: [AssetsModel]) -> [String: AssetsModel] {
        var dict: [String: AssetsModel] = [:]
        list.forEach { (model) in
            let symbol = HomeUtils.getSymbol(model.balance.quantity)
            let extendSymbol = HomeUtils.getExtendSymbol(symbol, contract: model.balance.contract)
            if dict[extendSymbol] != nil {
                let defaultQuantity = HomeUtils.getQuantity(dict[extendSymbol]!.balance.quantity)
                let quantity = HomeUtils.getQuantity(model.balance.quantity)
                let precision = HomeUtils.getTokenPrecision(defaultQuantity)
                dict[extendSymbol]!.balance.quantity = "\((defaultQuantity.toDecimal() + quantity.toDecimal()).toFixed(precision)) \(symbol)"
            } else {
                dict[extendSymbol] = model
            }
        }
        return dict
    }
    
    /// 获取用户的可用资产
    ///
    /// - Parameters:
    ///   - account: 用户名
    ///   - lowerBound: 起点
    ///   - list: 列表
    ///   - success: success block
    private func getAvailableAsset(_ account: String, lowerBound: Int32, list: [AssetsModel], success: @escaping ([AssetsModel]) -> Void) {
        ClientManager.shared.getAccountInfo(account, lowerBound: lowerBound) { (err, resp) in
            var nextList = list
            if resp != nil {
                nextList.append(contentsOf: resp!.rows!)
                if resp!.more {
                    let lastOne = resp!.rows?.last?.primary
                    self.getAvailableAsset(account, lowerBound: lastOne! + 1, list: nextList, success: success)
                    return
                }
            }
            if nextList.count == 0 {
                if err != nil {
                    success([])
                } else {
                    success(self.generateDefaultDs())
                }
            } else {
                success(nextList)
            }
        }
    }

    /// 获取锁仓通证
    ///
    /// - Parameters:
    ///   - account: 账户名
    ///   - lowerBound: 起点
    ///   - list: 列表
    ///   - success: success block
    private func getLockToken(_ account: String, lowerBound: Int32, list: [AssetsModel], success: @escaping ([String: AssetsModel]) -> Void) {
        ClientManager.shared.getLockTokens(account, lowerBound: lowerBound) { (err, resp) in
            var nextList = list
            if resp != nil {
                nextList.append(contentsOf: resp!.rows!)
                if resp!.more {
                    let lastOne = resp!.rows?.last?.primary
                    self.getLockToken(account, lowerBound: lastOne! + 1, list: nextList, success: success)
                    return
                }
            }
            success(self.processToken(nextList))
        }
    }
    
    /// 获取锁仓通证
    ///
    /// - Parameters:
    ///   - account: 账户名
    ///   - lowerBound: 起点
    ///   - list: 列表
    ///   - success: success block
    open func getLockTokenList(_ account: String, lowerBound: Int32, list: [AssetsModel], success: @escaping (Error?, [AssetsModel]) -> Void) {
        ClientManager.shared.getLockTokens(account, lowerBound: lowerBound) { (err, resp) in
            var nextList = list
            if resp != nil {
                nextList.append(contentsOf: resp!.rows!)
                if resp!.more {
                    let lastOne = resp!.rows?.last?.primary
                    self.getLockTokenList(account, lowerBound: lastOne! + 1, list: nextList, success: success)
                    return
                }
            }
            success(err, nextList)
        }
    }
    
    /// 获取合约子钱包
    ///
    /// - Parameters:
    ///   - account: 账户名
    ///   - lowerBound: 起点
    ///   - list: 列表
    ///   - success: success block
    private func getContractAsset(_ account: String, lowerBound: Int32, list: [AssetsModel], success: @escaping ([String: AssetsModel]) -> Void) {
        ClientManager.shared.getContractAsset(account, lowerBound: lowerBound) { (err, resp) in
            var nextList = list
            if resp != nil {
                nextList.append(contentsOf: resp!.rows!)
                if resp!.more {
                    let lastOne = resp?.rows?.last?.primary
                    self.getContractAsset(account, lowerBound: lastOne! + 1, list: nextList, success: success)
                    return
                }
            }
            success(self.processToken(nextList))
        }
    }
    
    /// 获取合约的通证
    ///
    /// - Parameters:
    ///   - contracts: 合约
    ///   - tokens: 通证数
    ///   - success: success block
    private func getTokens(_ contracts: [String], tokens: [String: TokenSummary], success: @escaping ([String: TokenSummary]) -> Void) {
        ClientManager.shared.getTokenByContract(contracts[0]) { (err, resp) in
            var nextTokens = tokens
            if resp != nil {
                resp!.rows?.forEach({ (e) in
                    let symbol = HomeUtils.getSymbol(e.supply)
                    let extendSymbol = HomeUtils.getExtendSymbol(symbol, contract: e.contract)
                    nextTokens[extendSymbol] = e
                })
            }
            var nextContracts = contracts
            nextContracts.remove(at: 0)
            if nextContracts.count > 0 {
                self.getTokens(nextContracts, tokens: nextTokens, success: success)
            } else {
                success(nextTokens)
            }
        }
    }

    /// 构造FO历史记录schema
    ///
    /// - Parameters:
    ///   - account: 账户
    ///   - maxId: 最大的ID
    /// - Returns: schema
    private func generateFOHistorySchema(_ table: String, account: String, maxId: Int64) -> String {
        return """
        {
            \(table)(
            where: {
                and:[
                    {
                        or:[
                            {
                                from_account:"\(account)"
                            },
                            {
                                to_account:"\(account)"
                            }
                        ]
                    }
                ]
                id: {
                    lt: \(maxId)
                }
            }
            limit: \(basePageSize)
            order: "-id"
            ){
            id
            block_num
            from_account
            to_account
            action
            data
            created
            trx_id
            }
        }
        """
    }
    
    /// 构造历史记录schema
    ///
    /// - Parameters:
    ///   - table: 表明
    ///   - symbol: 通证
    ///   - contract: 合约名
    ///   - account: 账户
    ///   - maxId: 最大的ID
    /// - Returns: schema
    private func generateHistorySchema(_ table: String, symbol: String, contract: String, account: String, maxId: Int64) -> String {
        return """
        {
          \(table)(
            where: {
                and:[
                    {
                        contract: "\(contract)"
                        symbol: "\(symbol)"
                        or:[
                            {
                                from_account:"\(account)"
                            },
                            {
                                to_account:"\(account)"
                            }
                        ]
                    }
                ]
                id: {
                    lt: \(maxId)
                }
            }
            limit: \(basePageSize)
            order: "-id"
            ){
                id
                block_num
                from_account
                to_account
                symbol
                contract
                action
                data
                created
                trx_id
            }
        }
        """
    }

    
    /// 处理锁仓的历史记录
    ///
    /// - Parameter body: list
    /// - Returns: resp
    private func processLockTokenHistory(body: Array<NSDictionary>?, account: String) -> [LockTokenHistoryModel] {
        var response: [LockTokenHistoryModel] = []
        if body == nil || body?.count == 0 {
            return response
        }
        for elem: NSDictionary in body! {
            let model = LockTokenHistoryModel.deserialize(from: elem)
            if model == nil {
                continue
            }
            let data = elem.object(forKey: "data") as! NSDictionary
            switch model!.action {
            case "exlocktrans":
                model?.data = LockTokenHistoryTransModel.deserialize(from: data)
                if model?.from_account == account {
                    model?.isReceive = false
                } else {
                    model?.isReceive = true
                }
                response.append(model!)
                break
            case "exunlock":
                model?.data = LockTokenHistoryUnLockModel.deserialize(from: data)
                model?.isReceive = false
                response.append(model!)
                break
            default:
                break
            }
        }
        return response
    }
    
    /// 获取锁仓的历史记录
    ///
    /// - Parameters:
    ///   - symbol: 通证名称
    ///   - contract: 合约名
    ///   - account: 账户名
    ///   - maxId: 最大ID
    ///   - success: block
    open func getLockTokenHistory(symbol: String, contract: String, account: String, maxId: Int64, success: @escaping (Error?, [LockTokenHistoryModel]?) -> Void) {
        let schema = generateHistorySchema("find_locktransactions", symbol: symbol, contract: contract, account: account, maxId: maxId)
        Http.shareHttp().graphql(urlStr: graphqlUri, params: schema) { (err, resp) in
            if err != nil {
                DispatchQueue.main.async(execute: {
                    success(err, Optional.none)
                })
            } else {
                let res = resp?.object(forKey: "data") as? NSDictionary
                let body = res?.object(forKey: "find_locktransactions") as? Array<NSDictionary>
                let response = self.processLockTokenHistory(body: body, account: account)
                DispatchQueue.main.async(execute: {
                    success(Optional.none, response)
                })
            }
        }
    }
    
    /// 处理历史交易
    ///
    /// - Parameters:
    ///   - body: 数据体
    ///   - account: a当前账户
    ///   - symbol: 通证
    ///   - contract: 合约名
    private func processTransactionHistory(body: Array<NSDictionary>?, account: String, symbol: String, contract: String) -> [TransactionHistoryModel] {
        var response: [TransactionHistoryModel] = []
        if body == nil || body?.count == 0 {
            return response
        }
        for elem: NSDictionary in body! {
            let model = TransactionHistoryModel.deserialize(from: elem)
            if model == nil {
                continue
            }
            model?.symbol = (elem["symbol"] ?? symbol) as? String
            model?.contract = (elem["contract"] ?? contract) as? String
            let data = elem.object(forKey: "data") as! NSDictionary
            switch model?.action {
            case "buyram":
                fallthrough
            case "buyrambytes":
                if data["payer"] as? String == account {
                    model?.quantity = data["quant"] as? String
                    model?.isReceive = false
                    model?.desc = LanguageHelper.localizedString(key: "BuyRamDesc")
                    response.append(model!)
                }
                break
            case "sellram":
                model?.quantity = data["quantity"] as? String
                model?.isReceive = true
                model?.desc = LanguageHelper.localizedString(key: "SellRamDesc")
                response.append(model!)
                break
            case "delegatebw":
                let net = data["stake_net_quantity"] as! String
                let netDeciaml = HomeUtils.getQuantity(net).toDecimal()
                if !netDeciaml.isZero { // 抵押网络
                    model?.action = "delegatebw_net"
                    model?.quantity = net
                    model?.desc = LanguageHelper.localizedString(key: "DelegateNet")
                } else {
                    model?.action = "delegatebw_cpu"
                    model?.quantity = data["stake_cpu_quantity"] as? String
                    model?.desc = LanguageHelper.localizedString(key: "DelegateCPU")
                }
                model?.isReceive = false
                response.append(model!)
                break
            case "undelegatebw":
                if data["from"] as? String == account {
                    let net = data["unstake_net_quantity"] as! String
                    let netDecimal = HomeUtils.getQuantity(net).toDecimal()
                    if !netDecimal.isZero { // 赎回网络
                        model?.action = "undelegatebw_net"
                        model?.quantity = net
                        model?.desc = LanguageHelper.localizedString(key: "UnDelegateNet")
                    } else {
                        model?.action = "undelegatebw_cpu"
                        model?.quantity = data["unstake_cpu_quantity"] as? String
                        model?.desc = LanguageHelper.localizedString(key: "UnDelegateCPU")
                    }
                    response.append(model!)
                }
                break
            case "exchange":
                let indata = data["in"] as! NSDictionary
                let inSymbol = HomeUtils.getSymbol(indata["quantity"] as! String)
                let inContract = indata["contract"] as? String
                if inSymbol == symbol && inContract == contract {
                    model?.quantity = indata["quantity"] as? String
                    model?.isReceive = false
                } else {
                    let outdata = data["out"] as! NSDictionary
                    model?.quantity = outdata["quantity"] as? String
                    model?.isReceive = true
                }
                model?.desc = LanguageHelper.localizedString(key: "ExchangeToken")
                model?.memo = (data["memo"] ?? "") as! String
                response.append(model!)
                break
            case "extransfer":
                fallthrough
            case "transfer":
                // extransfer action 的 quantity 中嵌套了一层 quantity
                let quantity = data["quantity"]
                var nextQuantity: String!
                if quantity is String {
                    nextQuantity = quantity as? String
                } else {
                    let qDict = quantity as! NSDictionary
                    nextQuantity = qDict["quantity"] as? String
                }
                if data["from"] as? String == account {
                    model?.isReceive = false
                    model?.desc = LanguageHelper.localizedString(key: "Pay")
                } else {
                    model?.isReceive = true
                    model?.desc = LanguageHelper.localizedString(key: "Receive")
                }
                model?.quantity = nextQuantity
                model?.memo = (data["memo"] ?? "") as! String
                response.append(model!)
                break
            default:
                break
            }
        }
        return response
    }
    
    /// 获取交易的历史记录
    ///
    /// - Parameters:
    ///   - table: 表名
    ///   - symbol: 通证名称
    ///   - contract: 合约名
    ///   - account: 账户名
    ///   - maxId: 最大ID
    ///   - success: block
    open func getTransactionHistory(symbol: String, contract: String, account:String, maxId: Int64, success: @escaping (Error?, HistoryRespModel?) -> Void) {
        var schema: String!
        var table: String!
        if symbol == "FO" && contract == "eosio" {
            table = "find_fotransactions"
            schema = generateFOHistorySchema(table, account: account, maxId: maxId)
        } else {
            table = "find_symbolTransactions"
            schema = generateHistorySchema(table, symbol: symbol, contract: contract, account: account, maxId: maxId)
        }
        Http.shareHttp().graphql(urlStr: graphqlUri, params: schema) { (err, resp) in
            if err != nil {
                DispatchQueue.main.async(execute: {
                    success(err, Optional.none)
                })
            } else {
                let res = resp?.object(forKey: "data") as? NSDictionary
                let body = res?.object(forKey: table) as? Array<NSDictionary>
                let response = self.processTransactionHistory(body: body, account: account, symbol: symbol, contract: contract)
                let resModel = HistoryRespModel()
                resModel.resp = response
                let id = body?.last?.object(forKey: "id")
                if id == nil {
                    resModel.lastId = 0
                } else {
                    resModel.lastId = id as? Int64
                }
                DispatchQueue.main.async(execute: {
                    success(Optional.none, resModel)
                })
            }
        }
    }
    
}
