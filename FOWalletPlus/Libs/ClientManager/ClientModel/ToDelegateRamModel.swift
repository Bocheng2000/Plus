//
//  ToDelegateRamModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class ToDelegateRamModel: PkStringModel {
    var payer: String!
    var receiver: String!
    var quant: String!
    convenience init(_ _payer: String, _receiver: String, _quant: String) {
        self.init()
        payer = _payer
        receiver = _receiver
        quant = _quant
    }
}

class DelegateRamModel: FatherModel {
    var payer: String!
    var receiver: String!
    var quant: String!
    convenience init(_ _payer: String, _receiver: String, _quant: String) {
        self.init()
        payer = _payer
        receiver = _receiver
        quant = _quant
    }
}
