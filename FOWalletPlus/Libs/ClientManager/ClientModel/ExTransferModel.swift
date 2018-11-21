//
//  ExTransferModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/20.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ExTransferModel: PkStringModel {
    var quantity: String!
    var from: String!
    var to: String!
    var memo: String!
    var contract: String!
    convenience init(_ _quantity: String, _from: String, _to: String, _memo: String?, _contract: String) {
        self.init()
        quantity = _quantity
        from = _from
        to = _to
        memo = _memo ?? ""
        contract = _contract
    }
}

class TransferModel: FatherModel {
    var from: String!
    var to: String!
    var memo: String!
    var quantity: QuantityModel!
    
    convenience init(_ _from: String, _to: String, _memo: String, _quantity: String, _contract: String) {
        self.init()
        from = _from
        to = _to
        memo = _memo
        quantity = QuantityModel(_quantity, _contract: _contract)
    }
}

class QuantityModel: FatherModel {
    var quantity: String!
    var contract: String!
    convenience init(_ _quantity: String, _contract: String) {
        self.init()
        quantity = _quantity
        contract = _contract
    }
}
