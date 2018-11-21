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
    
    /// 转账
    ///
    /// - Parameters:
    ///   - model: 转账参数Model
    ///   - success: success block
    open func transfer(_ model: ExTransferModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = TransferModel(model.from, _to: model.to, _memo: model.memo, _quantity: model.quantity, _contract: model.contract)
            let abi = try AbiJson(code: "eosio.token", action: "extransfer", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.from, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 兑换通证
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func exchange(_ model: ToExchangeModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = ExchangeModel(model.owner, _memo: model.memo, _quantity: model.quantity, _fromContract: model.fromContract, _sym: "\(model.toPrecision!),\(model.toSymbol!)", _toContract: model.toContract)
            let abi = try AbiJson(code: "eosio.token", action: "exchange", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.owner, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 锁仓转账
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func transferInLock(_ model: ToTransferInLockModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = TransferInLockModel(model.from, _to: model.to, _quantity: model.quantity, _contract: model.contract, _memo: model.memo, _expiration: model.expiration, _expiration_to: model.expiration_to)
            let abi = try AbiJson(code: "eosio.token", action: "exlocktrans", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.from, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 解锁通证
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func unLockToken(_ model: ToUnLockTokenModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = UnLockTokenModel(model.owner, _quantity: model.quantity, _contract: model.contract, _expiration: model.expiration, _memo: model.memo)
            let abi = try AbiJson(code: "eosio.token", action: "exunlock", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.owner, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }

    /// 合约子钱包充值
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func rechargeWallet(_ model: ToContractWalletModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let recharge = ContractWalletModel(model.owner, _quantity: model.quantity, _contract: model.contract, _memo: model.memo)
            let abi = try AbiJson(code: "eosio.token", action: "ctxrecharge", json: recharge.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.owner, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 合约子钱包提现
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success blck
    open func withDrawWallet(_ model: ToContractWalletModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let recharge = ContractWalletModel(model.owner, _quantity: model.quantity, _contract: model.contract, _memo: model.memo)
            let abi = try AbiJson(code: "eosio.token", action: "ctxextract", json: recharge.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.owner, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 付费创建用户
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func createNewAccount(_ model: ToCreateAccountModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let newAccountModel = NewAccountModel(model.creator, _name: model.name, _key: model.pubKeyString)
            let newAccountAbi = try AbiJson(code: "eosio", action: "newaccount", json: newAccountModel.toJSONString()!)
            let buyrambytesModel = BuyRamBytesModel(model.creator, _receiver: model.name, _bytes: nil)
            let buyrambytesAbi = try AbiJson(code: "eosio", action: "buyrambytes", json: buyrambytesModel.toJSONString()!)
            let delegatebwModel = DelegateBWModel(model.creator, _receiver: model.name, _stake_net_quantity: "0.1000 FO", _stake_cpu_quantity: "0.1000 FO", _transfer: nil)
            let delegatebwAbi = try AbiJson(code: "eosio", action: "delegatebw", json: delegatebwModel.toJSONString()!)
            let prikey = try PrivateKey(keyString: model.pkString)
            TransactionUtil.pushTransaction(abis: [newAccountAbi, buyrambytesAbi, delegatebwAbi], account: model.creator, privateKey: prikey!) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }

    /// 抵押内存
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func delegateRam(_ model: ToDelegateRamModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = DelegateRamModel(model.payer, _receiver: model.receiver, _quant: model.quant)
            let abi = try AbiJson(code: "eosio", action: "buyram", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.payer, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 取消抵押
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func unDelegateRam(_ model: ToUnDelegateRamModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = UnDelegateRamModel(model.account, _bytes: model.bytes)
            let abi = try AbiJson(code: "eosio", action: "sellram", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.account, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 抵押网络
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func delegateNet(_ model: ToDelegateBWModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = DelegateBWModel(model.from, _receiver: model.receiver, _stake_net_quantity: model.stake_net_quantity, _stake_cpu_quantity: "0.0000 FO", _transfer: model.transfer)
            let abi = try AbiJson(code: "eosio", action: "delegatebw", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.from, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 取消抵押网络
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func unDelegateNet(_ model: ToUnDelegateBWModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = UnDelegateBWModel(model.from, _receiver: model.receiver, _unstake_cpu_quantity: "0.0000 FO", _unstake_net_quantity: model.unstake_net_quantity)
            let abi = try AbiJson(code: "eosio", action: "undelegatebw", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.from, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }

    /// 抵押CPU
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func delegateCpu(_ model: ToDelegateBWModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = DelegateBWModel(model.from, _receiver: model.receiver, _stake_net_quantity: "0.0000 FO", _stake_cpu_quantity: model.stake_cpu_quantity, _transfer: model.transfer)
            let abi = try AbiJson(code: "eosio", action: "delegatebw", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.from, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }

    /// 取消抵押CPU
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func unDelegateCpu(_ model: ToUnDelegateBWModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = UnDelegateBWModel(model.from, _receiver: model.receiver, _unstake_cpu_quantity: model.unstake_cpu_quantity, _unstake_net_quantity: "0.0000 FO")
            let abi = try AbiJson(code: "eosio", action: "undelegatebw", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.from, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// BP节点投票
    ///
    /// - Parameters:
    ///   - model: model
    ///   - success: success block
    open func vote(_ model: ToVoteModel, success: @escaping (Error?, TransactionResult?) -> Void) {
        do {
            let params = VoteModel(model.voter, _proxy: model.proxy, _producers: model.producers)
            let abi = try AbiJson(code: "eosio", action: "voteproducer", json: params.toJSONString()!)
            TransactionUtil.pushTransaction(abi: abi, account: model.voter, pkString: model.pkString) { (result, err) in
                success(err, result)
            }
        } catch let error {
            success(error, Optional.none)
        }
    }
    
    /// 获取内存市场的信息
    ///
    /// - Parameter success: success block
    open func ramMarket(success: @escaping (Error?, TableRowResponse<RamMarketModel>?) -> Void) {
        let params = TableRowRequestParam(scope: "eosio", code: "eosio", table: "rammarket", json: true, lowerBound: nil, upperBound: nil, limit: nil)
        EOSRPC.sharedInstance.getTableRows(param: params) { (resp: TableRowResponse<RamMarketModel>?, error) in
            success(error, resp)
        }
    }
    
    /// 获取全局信息
    ///
    /// - Parameter success: success block
    open func globalInfo(success: @escaping (Error?, TableRowResponse<GlobalInfoModel>?) -> Void) {
        let params = TableRowRequestParam(scope: "eosio", code: "eosio", table: "global", json: true, lowerBound: nil, upperBound: nil, limit: nil)
        EOSRPC.sharedInstance.getTableRows(param: params) { (resp: TableRowResponse<GlobalInfoModel>?, error) in
            success(error, resp)
        }
    }
}
