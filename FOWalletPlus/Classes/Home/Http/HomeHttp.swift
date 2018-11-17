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
            return []
        }
        // 将取回来的数据进行格式化
        var exists: [String: Bool] = [:]
        var nextAsset = availableAssets.map { (model) -> AccountAssetModel in
            let hide: Bool = model.balance.contract != "eosio"
            let quantity = HomeUtils.getQuantity(model.balance.quantity)
            let symbol = HomeUtils.getSymbol(model.balance.quantity)
            let precision = HomeUtils.getTokenPrecision(quantity)
            let zero: Float = 0
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
                let zero: Float = 0
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
                let zero: Float = 0
                let zeroToFix = HomeUtils.getFullQuantity(zero.toFixed(precision), symbol: symbol)
                let m = AccountAssetModel(value.primary, _belong: account, _contract: value.balance.contract, _hide: true, _quantity: zeroToFix, _lockToken: value.balance.quantity, _contractWallet: zeroToFix, _isSmart: tokens[key]?.isSmart ?? false)
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
                let zero: Float = 0
                let zeroToFix = HomeUtils.getFullQuantity(zero.toFixed(precision), symbol: symbol)
                let m = AccountAssetModel(value.primary, _belong: account, _contract: value.balance.contract, _hide: true, _quantity: zeroToFix, _lockToken: zeroToFix, _contractWallet: value.balance.quantity, _isSmart: tokens[key]?.isSmart ?? false)
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
    private func processToken(_ list: [AssetsModel]) -> [String: AssetsModel] {
        var dict: [String: AssetsModel] = [:]
        list.forEach { (model) in
            let symbol = HomeUtils.getSymbol(model.balance.quantity)
            let extendSymbol = HomeUtils.getExtendSymbol(symbol, contract: model.balance.contract)
            if dict[extendSymbol] != nil {
                let defaultQuantity = HomeUtils.getQuantity(dict[extendSymbol]!.balance.quantity)
                let quantity = HomeUtils.getQuantity(model.balance.quantity)
                let precision = HomeUtils.getTokenPrecision(defaultQuantity)
                dict[extendSymbol]!.balance.quantity = "\((defaultQuantity.toFloat() + quantity.toFloat()).toFixed(precision)) \(symbol)"
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
}
