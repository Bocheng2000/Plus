//
//  AuthorizeModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/20.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

enum TransactionType: NSInteger {
    /**
     * 转账
     */
    case transfer = 0
    /**
     * 兑换
     */
    case exchange
    /**
     * 解锁通证
     */
    case unlockToken
    /**
     * 锁仓转账
     */
    case transferInLock
    /**
     * 合约子钱包充值
     */
    case rechargeWallet
    /**
     * 合约子钱包提现
     */
    case withDrawWallet
    /**
     * 付费创建账户
     */
    case createForPay
    /**
     * 抵押内存
     */
    case delegateRam
    /**
     * 取消抵押内存
     */
    case undelegateRam
    /**
     * 抵押网络
     */
    case delegateNet
    /**
     * 取消抵押网络
     */
    case undelegateNet
    /**
     * 抵押计算
     */
    case delegateCpu
    /**
     * 取消抵押计算
     */
    case undelegateCpu
    /**
     * 投票
     */
    case vote
}

class AuthorizeModel: NSObject {
    var title: String!
    var items: [AuthorizeItemModel]!
    var type:TransactionType!
    var params: Any?
    convenience init(_ _title: String, _items: [AuthorizeItemModel], _type: TransactionType, _params: Any?) {
        self.init()
        title = _title
        items = _items
        type = _type
        params = _params
    }
}

class AuthorizeItemModel: NSObject {
    var title: String!
    var detail: String!
    convenience init(_ _title: String, _detail: String) {
        self.init()
        title = _title
        detail = _detail
    }
}
