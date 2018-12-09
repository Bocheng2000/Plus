//
//  LockTokenHistoryModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/30.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class LockTokenHistoryModel: FatherModel {
    var id: Int64!
    var from_account: String!
    var to_account: String!
    var symbol: String!
    var contract: String!
    var action: String!
    var data: LockTokenHistoryDataModel!
    var created: String!
    var trx_id: String!
    var isReceive: Bool = false
    var block_num: Int64!
}


class LockTokenHistoryDataModel: FatherModel {
    var quantity: QuantityModel!
    var expiration: String!
    var memo: String!
}

class LockTokenHistoryUnLockModel: LockTokenHistoryDataModel {
    var owner: String!
}

class LockTokenHistoryTransModel: LockTokenHistoryDataModel {
    var from: String!
    var to: String!
    var expiration_to: String?
}
