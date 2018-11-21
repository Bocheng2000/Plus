//
//  ToUnLockTokenModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToUnLockTokenModel: PkStringModel {
    var owner: String!
    var quantity: String!
    var contract: String!
    var expiration: String!
    var memo: String!
    convenience init(_ _owner: String, _quantity: String, _contract: String, _expiration: String, _memo: String?) {
        self.init()
        owner = _owner
        quantity = _quantity
        contract = _contract
        expiration = _expiration
        memo = _memo ?? ""
    }
}

class UnLockTokenModel: FatherModel {
    var owner: String!
    var quantity: QuantityModel!
    var expiration: String!
    var memo: String!
    convenience init(_ _owner: String, _quantity: String, _contract: String, _expiration: String, _memo: String) {
        self.init()
        owner = _owner
        quantity = QuantityModel(_quantity, _contract: _contract)
        expiration = _expiration
        memo = _memo
    }
}
