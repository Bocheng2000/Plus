//
//  CurrentAccountModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class AccountModel: NSObject {
    var account: String!
    var pubKey: String!
    var endPoint: String?
    var backUp: Bool?
    var resourceWidget: Bool?
    convenience init(_ _account: String, _pubKey: String!) {
        self.init()
        account = _account
        pubKey = _pubKey
    }
}

class AccountListModel: NSObject {
    var account: String!
    var pubKey: String!
    var quantity: String!
    var lockToken: String!
    var contractWallet: String!
    var sum: String! {
        get {
            let q = HomeUtils.getQuantity(quantity)
            let l = HomeUtils.getQuantity(lockToken)
            let c = HomeUtils.getQuantity(contractWallet)
            let all = q.toDecimal() + l.toDecimal() + c.toDecimal()
            return all.toFixed(HomeUtils.getTokenPrecision(q))
        }
    }
    convenience init(_ _account: String, _pubKey: String, _quantity: String?, _lockToken: String?, _contractWallet: String?) {
        self.init()
        account = _account
        pubKey = _pubKey
        quantity = _quantity ?? "0.0000 FO"
        lockToken = _lockToken ?? "0.0000 FO"
        contractWallet = _contractWallet ?? "0.0000 FO"
    }
}
