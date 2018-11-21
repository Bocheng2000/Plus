//
//  TransferInLock.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToTransferInLockModel: PkStringModel {
    var from: String!
    var to: String!
    var quantity: String!
    var contract: String!
    var memo: String!
    var expiration: String!
    var expiration_to: String!
    convenience init(_ _from: String, _to: String, _quantity: String, _contract: String, _memo: String?, _expiration: String, _expiration_to: String) {
        self.init()
        from = _from
        to = _to
        quantity = _quantity
        contract = _contract
        memo = _memo ?? ""
        expiration = _expiration
        expiration_to = _expiration_to
    }
}

class TransferInLockModel: FatherModel {
    var from: String!
    var to: String!
    var quantity: QuantityModel!
    var memo: String!
    var expiration: String!
    var expiration_to: String!
    convenience init(_ _from: String, _to: String, _quantity: String, _contract: String, _memo: String, _expiration: String, _expiration_to: String) {
        self.init()
        from = _from
        to = _to
        quantity = QuantityModel(_quantity, _contract: _contract)
        memo = _memo
        expiration = _expiration
        expiration_to = _expiration_to
    }
}
