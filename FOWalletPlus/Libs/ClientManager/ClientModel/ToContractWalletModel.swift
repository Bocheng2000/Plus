//
//  ToRechargeWallet.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToContractWalletModel: PkStringModel {
    var owner: String!
    var quantity: String!
    var contract: String!
    var memo: String!
    convenience init(_ _owner: String, _quantity: String, _contract: String, _memo: String?) {
        self.init()
        owner = _owner
        quantity = _quantity
        contract = _contract
        memo = _memo ?? ""
    }
}


class ContractWalletModel: FatherModel {
    var owner: String!
    var quantity: QuantityModel!
    var memo: String!
    convenience init(_ _owner: String, _quantity: String, _contract: String, _memo: String) {
        self.init()
        owner = _owner
        quantity = QuantityModel(_quantity, _contract: _contract)
        memo = _memo
    }
}
