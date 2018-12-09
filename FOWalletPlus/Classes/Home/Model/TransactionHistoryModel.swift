//
//  TransactionHistoryModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/5.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class HistoryRespModel: NSObject {
    var lastId: Int64!
    var resp: [TransactionHistoryModel]!
}

class TransactionHistoryModel: FatherModel {
    var id: Int64!
    var block_num: Int64!
    var from_account: String!
    var to_account: String!
    var symbol: String!
    var contract: String!
    var action: String!
    var created: String!
    var trx_id: String!
    var quantity: String!
    var memo: String = ""
    var isReceive: Bool = false
    var desc: String = ""
}
