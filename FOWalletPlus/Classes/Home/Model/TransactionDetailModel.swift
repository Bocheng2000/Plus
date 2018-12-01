//
//  TransactionDetailModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/30.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class TransactionDetailModel: NSObject {
    var quantity: String!
    var symbol: String!
    var contract: String!
    var transactionDesc: String!
    var fromAccount: String!
    var toAccount: String!
    var memo: String!
    var created: String!
    var trx_id: String!
    var isReceive: Bool!
    var block_num: Int64!
    convenience init(_ _quantity: String!, _symbol: String, _contract: String, _transactionDesc: String, _fromAccount: String, _toAccount: String, _memo: String, _created: String, _trx_id: String, _isReceive: Bool, _block_num: Int64) {
        self.init()
        quantity = _quantity
        symbol = _symbol
        contract = _contract
        transactionDesc = _transactionDesc
        fromAccount = _fromAccount
        toAccount = _toAccount
        memo = _memo
        created = _created
        trx_id = _trx_id
        isReceive = _isReceive
        block_num = _block_num
    }
}
