//
//  PayModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/19.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class PayModel: FatherModel {
    var symbol: String!
    var contract: String!
    var account: String!
    var amount: String!
    var memo: String!
    convenience init(_ _symbol: String, _contract: String, _account: String, _amount: String, _memo: String) {
        self.init()
        symbol = _symbol
        contract = _contract
        account = _account
        amount = _amount
        memo = _memo
    }
}
