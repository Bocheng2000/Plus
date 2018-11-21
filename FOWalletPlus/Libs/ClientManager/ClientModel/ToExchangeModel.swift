//
//  ExchangeModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/20.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToExchangeModel: PkStringModel {
    var owner: String!
    var memo: String!
    var quantity: String!
    var fromContract: String!
    var toPrecision: Int!
    var toSymbol: String!
    var toContract: String!
    convenience init(_ _owner: String, _memo: String?, _quantity: String, _fromContract: String, _toPrecision: Int, _toSymbol: String, _toContract: String) {
        self.init()
        owner = _owner
        memo = _memo ?? ""
        quantity = _quantity
        fromContract = _fromContract
        toPrecision = _toPrecision
        toSymbol = _toSymbol
        toContract = _toContract
    }
}

class ExchangeModel: FatherModel {
    var owner: String!
    var memo: String!
    var quantity: QuantityModel!
    var tosym: ToSymModel!
    convenience init(_ _owner: String, _memo: String, _quantity: String, _fromContract: String, _sym: String, _toContract: String) {
        self.init()
        owner = _owner
        memo = _memo
        quantity = QuantityModel(_quantity, _contract: _fromContract)
        tosym = ToSymModel(_sym, _contract: _toContract)
    }
}

class ToSymModel: FatherModel {
    var sym: String!
    var contract: String!
    convenience init(_ _sym: String, _contract: String) {
        self.init()
        sym = _sym
        contract = _contract
    }
}
